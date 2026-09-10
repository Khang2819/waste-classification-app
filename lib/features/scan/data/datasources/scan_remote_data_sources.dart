import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/scan_model.dart';

abstract class ScanRemoteDataSource {
  Future<ScanModel> scanWaste(String imagePath);
}

class ScanRemoteDataSourceImpl implements ScanRemoteDataSource {
  final GenerativeModel? _customModel;
  final String? _apiKey;

  ScanRemoteDataSourceImpl({GenerativeModel? customModel, String? apiKey})
    : _customModel = customModel,
      _apiKey = apiKey;

  String get _effectiveApiKey {
    final key = _apiKey ?? dotenv.env['GEMINI_API_KEY'];
    return key?.trim() ?? '';
  }

  @override
  Future<ScanModel> scanWaste(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('File ảnh không tồn tại tại đường dẫn: $imagePath');
      }

      final apiKey = _effectiveApiKey;
      if (apiKey.isEmpty) {
        throw Exception(
          'Chưa tìm thấy GEMINI_API_KEY. Vui lòng kiểm tra file .env hoặc cấu hình API key.',
        );
      }

      final bytes = await file.readAsBytes();

      const prompt = '''
Bạn là chuyên gia phân loại rác thải và bảo vệ môi trường.
Hãy phân tích hình ảnh này và phân loại rác thải theo đúng cấu trúc JSON sau:
{
  "label": "Tên loại rác (Ví dụ: Chai nhựa PET / Vỏ lon nhôm / Hộp xốp / Rác hữu cơ...)",
  "confidence": 0.95,
  "instruction": "Hướng dẫn cụ thể cách xử lý hoặc phân loại (Ví dụ: Thuộc nhóm rác tái chế. Rửa sạch, làm dẹp và bỏ vào thùng màu vàng.)"
}
Chỉ trả về chuỗi JSON hợp lệ, không thêm chữ markdown hay giải thích ngoài.
''';

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', bytes)]),
      ];

      GenerateContentResponse? response;
      Object? lastError;

      if (_customModel != null) {
        response = await _customModel.generateContent(content);
      } else {
        const candidateModels = [
          // 'gemini-2.5-flash',
          // 'gemini-flash-latest',
          // 'gemini-2.5-flash-lite',
          'gemini-3.5-flash-lite',
          'gemini-2.5-flash',
        ];

        for (final modelName in candidateModels) {
          try {
            final model = GenerativeModel(
              model: modelName,
              apiKey: apiKey,
              generationConfig: GenerationConfig(
                responseMimeType: 'application/json',
                temperature: 0.2,
              ),
            );
            response = await model.generateContent(content);
            if (response.text != null && response.text!.trim().isNotEmpty) {
              break;
            }
          } catch (e) {
            lastError = e;
            debugPrint(
              'Model $modelName gặp lỗi: $e. Đang thử model kế tiếp...',
            );
          }
        }
      }

      final responseText = response?.text;

      if (responseText == null || responseText.trim().isEmpty) {
        throw Exception(
          'Không nhận được kết quả từ Gemini AI. Chi tiết: $lastError',
        );
      }

      String cleanJson = responseText.trim();
      if (cleanJson.contains('{') && cleanJson.contains('}')) {
        final startIndex = cleanJson.indexOf('{');
        final endIndex = cleanJson.lastIndexOf('}');
        cleanJson = cleanJson.substring(startIndex, endIndex + 1);
      }

      final Map<String, dynamic> data = jsonDecode(cleanJson);

      data['imagePath'] = imagePath;

      return ScanModel.fromJson(data);
    } catch (e) {
      throw Exception('Lỗi khi phân loại rác: $e');
    }
  }
}
