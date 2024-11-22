import 'package:file_picker/file_picker.dart';

class MediaService {
  bool _isPicking = false; // Flag to track if the picker is already active

  Future<PlatformFile?> pickImageFromLibrary() async {
    if (_isPicking) return null; // Prevent opening the picker if it is already active

    _isPicking = true; // Set the flag to indicate the picker is active

    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    
    _isPicking = false; // Reset the flag after the picker is done

    if (result != null) {
      return result.files.first;
    }
    return null;
  }
}