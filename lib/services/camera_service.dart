import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> takePhoto() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    return file;
  }
}
