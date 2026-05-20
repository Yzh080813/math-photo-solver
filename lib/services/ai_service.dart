import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class AiService {
  final String apiKey;
  final http.Client _client;

  AiService({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';

  Future<AiResponse> solveProblem(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': 'claude-sonnet-4-6',
        'max_tokens': 1024,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': '你是一个中小学数学解题助手。用户发来一道数学题的照片。请分析题目并给出答案和解题步骤。'
                    '请用 JSON 格式回复，格式为：{"answer": "最终答案", "steps": ["步骤1", "步骤2", ...]}',
              },
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': 'image/jpeg',
                  'data': base64Image,
                },
              },
            ],
          }
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw AiException('API 请求失败: ${response.statusCode} ${response.body}');
    }

    final body = jsonDecode(response.body);
    final content = body['content'] as List;
    final text = content[0]['text'] as String;

    return extractResponse(text);
  }

  /// Extracts and parses a JSON response from the AI's text reply.
  @visibleForTesting
  AiResponse extractResponse(String text) {
    // 解析 AI 返回的 JSON
    final jsonStart = text.indexOf('{');
    final jsonEnd = text.lastIndexOf('}') + 1;
    if (jsonStart == -1 || jsonEnd == 0) {
      // JSON 解析失败，直接返回原始文本
      return AiResponse(answer: text, steps: []);
    }

    try {
      final result = jsonDecode(text.substring(jsonStart, jsonEnd));
      return AiResponse(
        answer: result['answer'] as String? ?? text,
        steps: (result['steps'] as List?)?.cast<String>() ?? [],
      );
    } catch (_) {
      return AiResponse(answer: text, steps: []);
    }
  }

  void dispose() {
    _client.close();
  }
}

class AiResponse {
  final String answer;
  final List<String> steps;

  AiResponse({required this.answer, required this.steps});
}

class AiException implements Exception {
  final String message;
  AiException(this.message);
  @override
  String toString() => message;
}
