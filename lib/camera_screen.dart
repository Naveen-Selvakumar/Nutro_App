import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  XFile? imageFile;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras![0], ResolutionPreset.medium);

    await controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> takePhoto() async {
    if (!controller!.value.isInitialized) return;
    final image = await controller!.takePicture();
    setState(() {
      imageFile = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera Capture"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: CameraPreview(controller!),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: imageFile == null
                  ? const Text("No photo taken yet.")
                  : Image.file(File(imageFile!.path)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: takePhoto,
            icon: const Icon(Icons.camera),
            label: const Text("Take Photo"),
          ),
        ],
      ),
    );
  }
}
