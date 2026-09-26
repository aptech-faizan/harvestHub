import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';

/// Uploads product images to Cloudinary (unsigned REST API).
class CloudinaryService {
  Future<String> uploadImage(XFile file) async {
    if (CloudinaryConfig.cloudName.isEmpty || CloudinaryConfig.uploadPreset.isEmpty) {
      throw Exception('Cloudinary is not configured. Set cloud name and unsigned upload preset in AppConstants.');
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
    );

    try {
      final request = http.MultipartRequest('POST', uri);
      
      // Fix 1: Read as bytes to make it cross-platform compatible (Android, iOS, Web)
      final bytes = await file.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name,
      );

      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
      request.files.add(multipartFile);

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      // Fix 2: Detailed error handling
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('Cloudinary Error Body: ${response.body}');
        final body = jsonDecode(response.body);
        final errorMessage = body['error']?['message'] ?? 'Unknown error';
        throw Exception('Cloudinary Upload Failed (${response.statusCode}): $errorMessage');
      }

      final body = jsonDecode(response.body);
      if (body is! Map || body['secure_url'] == null) {
        throw Exception('Image upload failed: missing secure URL.');
      }

      return body['secure_url'].toString();
    } catch (e) {
      print('CloudinaryService Exception: $e');
      rethrow;
    }
  }
}