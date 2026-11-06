import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static String get _cloudName =>
      dotenv.env['_cloudName'] ??
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ??
      "dmgq0yosy";

  static String get _uploadPreset =>
      dotenv.env['_uploadPreset'] ??
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ??
      "smart_waste";

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final cloudName = _cloudName;
      final uploadPreset = _uploadPreset;
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request =
          http.MultipartRequest("POST", uri)
            ..fields['upload_preset'] = uploadPreset
            ..files.add(
              await http.MultipartFile.fromPath('file', imageFile.path),
            );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return jsonMap['secure_url'] as String?;
      } else {
        final message =
            jsonMap['error']?['message'] ??
            'Lỗi tải ảnh lên Cloudinary (${response.statusCode})';
        throw Exception(message);
      }
    } catch (e) {
      print("Upload error: $e");
      rethrow;
    }
  }
}
