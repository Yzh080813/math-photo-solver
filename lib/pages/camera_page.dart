import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source, maxWidth: 1920);
    if (xFile != null && context.mounted) {
      Navigator.pop(context, xFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('拍照解题')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera, context),
              icon: const Icon(Icons.camera_alt),
              label: const Text('拍照'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery, context),
              icon: const Icon(Icons.photo_library),
              label: const Text('从相册选择'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
