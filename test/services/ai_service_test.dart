import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:math_photo_app/services/ai_service.dart';

/// Helper to create [http.Response] with proper content-type header so that
/// Chinese characters are handled correctly.
http.Response jsonResponse(dynamic body, int statusCode) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: {'content-type': 'application/json'},
  );
}

/// Helper to create a minimal valid JPEG image for testing.
/// This produces a tiny 1x1 gray JPEG byte sequence.
List<int> _createFakeJpeg() {
  // Minimal valid JPEG (SOI + some minimal data + EOI)
  return [
    0xFF, 0xD8, // SOI
    0xFF, 0xE0, // APP0
    0x00, 0x10, // length
    0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x00,
    0x00, 0x01, 0x00, 0x01, 0x00, 0x00,
    0xFF, 0xDB, // DQT
    0x00, 0x43, // length
    0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08,
    0x07, 0x07, 0x07, 0x09, 0x09, 0x08, 0x0A, 0x0C,
    0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
    0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D,
    0x1A, 0x1C, 0x1C, 0x20, 0x24, 0x2E, 0x27, 0x20,
    0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
    0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27,
    0x39, 0x3D, 0x38, 0x32, 0x3C, 0x2E, 0x33, 0x34,
    0x32,
    0xFF, 0xC0, // SOF0
    0x00, 0x0B, // length
    0x01,       // precision
    0x00, 0x01, // height
    0x00, 0x01, // width
    0x01,       // number of components
    0x01, 0x11, 0x00,
    0xFF, 0xC4, // DHT
    0x00, 0x1F, // length
    0x00, 0x00, 0x01, 0x05, 0x01, 0x01, 0x01, 0x01,
    0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
    0x07, 0x08, 0x09, 0x0A, 0x0B,
    0xFF, 0xDA, // SOS
    0x00, 0x08, // length
    0x01, 0x01, 0x00, 0x00, 0x3F, 0x00,
    0x7F,       // one byte of entropy-coded data
    0xFF, 0xD9, // EOI
  ];
}

void main() {
  group('AiService.extractResponse', () {
    late AiService aiService;

    setUp(() {
      final mockClient = MockClient((request) async {
        return jsonResponse(
          {
            'content': [
              {'text': '{"answer": "x = 5", "steps": ["移项: 2x = 10", "除以2: x = 5"]}'}
            ]
          },
          200,
        );
      });
      aiService = AiService(apiKey: 'test-key', client: mockClient);
    });

    test('parses valid JSON response correctly', () {
      const text = '{"answer": "x = 5", "steps": ["移项: 2x = 10", "除以2: x = 5"]}';
      final response = aiService.extractResponse(text);
      expect(response.answer, 'x = 5');
      expect(response.steps, hasLength(2));
      expect(response.steps[0], '移项: 2x = 10');
      expect(response.steps[1], '除以2: x = 5');
    });

    test('handles text without JSON by returning raw text as answer', () {
      const text = '这道题的答案是 x = 5';
      final response = aiService.extractResponse(text);
      expect(response.answer, text);
      expect(response.steps, isEmpty);
    });

    test('handles invalid JSON gracefully', () {
      // JSON-like but truncated
      const text = '{"answer": "x = 5", "steps": ["移项';
      final response = aiService.extractResponse(text);
      // Should return raw text when JSON parsing fails
      expect(response.answer, text);
      expect(response.steps, isEmpty);
    });

    test('handles JSON missing steps field', () {
      const text = '{"answer": "42"}';
      final response = aiService.extractResponse(text);
      expect(response.answer, '42');
      expect(response.steps, isEmpty);
    });

    test('handles JSON missing answer field', () {
      const text = '{"steps": ["step1"]}';
      final response = aiService.extractResponse(text);
      expect(response.answer, text); // falls back to raw text
      expect(response.steps, hasLength(1));
      expect(response.steps[0], 'step1');
    });

    test('handles empty string', () {
      const text = '';
      final response = aiService.extractResponse(text);
      expect(response.answer, '');
      expect(response.steps, isEmpty);
    });
  });

  group('AiService.solveProblem', () {
    late AiService aiService;
    late String tempImagePath;

    setUp(() {
      // Create a temporary image file
      tempImagePath = '${Directory.systemTemp.path}/test_math_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File(tempImagePath).writeAsBytesSync(_createFakeJpeg());
    });

    tearDown(() {
      // Clean up temp file
      File(tempImagePath).deleteSync();
    });

    test('returns parsed response on successful API call', () async {
      final mockClient = MockClient((request) async {
        // Verify the request contains the image
        final body = jsonDecode(request.body);
        expect(body['messages'][0]['content'][1]['type'], 'image');
        expect(body['messages'][0]['content'][1]['source']['type'], 'base64');

        return jsonResponse(
          {
            'content': [
              {'text': '{"answer": "x = 3", "steps": ["简化: 3x = 9", "除以3: x = 3"]}'}
            ]
          },
          200,
        );
      });

      aiService = AiService(apiKey: 'test-key', client: mockClient);
      final response = await aiService.solveProblem(tempImagePath);

      expect(response.answer, 'x = 3');
      expect(response.steps, hasLength(2));
    });

    test('throws AiException on non-200 response', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': {'message': 'Unauthorized'}}),
          401,
        );
      });

      aiService = AiService(apiKey: 'bad-key', client: mockClient);

      expect(
        () => aiService.solveProblem(tempImagePath),
        throwsA(isA<AiException>()),
      );
    });

    test('handles non-JSON text response from API', () async {
      final mockClient = MockClient((request) async {
        return jsonResponse(
          {
            'content': [
              {'text': '答案是 x = 7。'}
            ]
          },
          200,
        );
      });

      aiService = AiService(apiKey: 'test-key', client: mockClient);
      final response = await aiService.solveProblem(tempImagePath);

      expect(response.answer, '答案是 x = 7。');
      expect(response.steps, isEmpty);
    });
  });
}
