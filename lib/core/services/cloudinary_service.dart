import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = "your_cloud_name";
  static const String _uploadPreset = "your_unsigned_preset";
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$_cloudName/image/upload",
      );

      final request =
          http.MultipartRequest("POST", uri)
            ..fields['upload_preset'] = _uploadPreset
            ..files.add(
              await http.MultipartFile.fromPath('file', imageFile.path),
            );

      final response = await request.send();

      final resData = await http.Response.fromStream(response);
      final jsonMap = jsonDecode(resData.body);

      if (response.statusCode == 200) {
        return jsonMap['secure_url'];
      } else {
        throw Exception(jsonMap['error']['message']);
      }
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }
}
