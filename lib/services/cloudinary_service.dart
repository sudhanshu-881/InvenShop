import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static final String _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static final String _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
  static final String _apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static final String _apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
  
  // Upload image to Cloudinary
  static Future<String?> uploadImage(String imagePath) async {
    try {
      final dio = Dio();
      
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
        'upload_preset': _uploadPreset,
        'folder': 'invenshop/products',
        'public_id': 'product_${DateTime.now().millisecondsSinceEpoch}',
        'tags': 'invenshop,product',
      });
      
      final response = await dio.post(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data['secure_url'];
      }
      return null;
    } catch (e) {
      print('Cloudinary upload failed: $e');
      return null;
    }
  }
  
  // Upload multiple images
  static Future<List<String>> uploadMultipleImages(List<String> imagePaths) async {
    List<String> uploadedUrls = [];
    
    for (String imagePath in imagePaths) {
      String? url = await uploadImage(imagePath);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }
    
    return uploadedUrls;
  }
  
  // Upload image with custom folder
  static Future<String?> uploadImageToFolder(String imagePath, String folder) async {
    try {
      final dio = Dio();
      
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
        'upload_preset': _uploadPreset,
        'folder': 'invenshop/$folder',
        'public_id': '${folder}_${DateTime.now().millisecondsSinceEpoch}',
        'tags': 'invenshop,$folder',
      });
      
      final response = await dio.post(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
        data: formData,
      );
      
      if (response.statusCode == 200) {
        return response.data['secure_url'];
      }
      return null;
    } catch (e) {
      print('Cloudinary upload failed: $e');
      return null;
    }
  }
  
  // Generate optimized URL
  static String getOptimizedUrl(String originalUrl, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
    String crop = 'scale',
    String gravity = 'auto',
  }) {
    if (originalUrl.isEmpty) return originalUrl;
    
    // Parse the URL to insert transformations
    String baseUrl = originalUrl.split('/upload/')[0];
    String path = originalUrl.split('/upload/')[1];
    
    // Build transformation string
    List<String> transformations = [];
    
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    if (crop != 'scale') transformations.add('c_$crop');
    if (gravity != 'auto') transformations.add('g_$gravity');
    transformations.add('q_$quality');
    transformations.add('f_$format');
    
    String transformationString = transformations.join(',');
    
    return '$baseUrl/upload/$transformationString/$path';
  }
  
  // Generate thumbnail URL
  static String getThumbnailUrl(String originalUrl, {int size = 200}) {
    return getOptimizedUrl(
      originalUrl,
      width: size,
      height: size,
      crop: 'fill',
      quality: 'auto',
    );
  }
  
  // Generate product grid URL
  static String getProductGridUrl(String originalUrl, {int width = 300}) {
    return getOptimizedUrl(
      originalUrl,
      width: width,
      height: width,
      crop: 'fill',
      quality: 'auto',
    );
  }
  
  // Generate banner URL
  static String getBannerUrl(String originalUrl, {int width = 800, int height = 400}) {
    return getOptimizedUrl(
      originalUrl,
      width: width,
      height: height,
      crop: 'fill',
      quality: 'auto',
    );
  }
  
  // Delete image from Cloudinary
  static Future<bool> deleteImage(String publicId) async {
    try {
      final dio = Dio();
      
      // Generate signature for authenticated request
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String signature = _generateSignature(publicId, timestamp);
      
      final response = await dio.post(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/destroy',
        data: {
          'public_id': publicId,
          'timestamp': timestamp,
          'api_key': _apiKey,
          'signature': signature,
        },
      );
      
      return response.statusCode == 200 && response.data['result'] == 'ok';
    } catch (e) {
      print('Cloudinary delete failed: $e');
      return false;
    }
  }
  
  // Generate signature for authenticated requests
  static String _generateSignature(String publicId, String timestamp) {
    // This is a simplified signature generation
    // In production, use proper HMAC-SHA1 signature
    String toSign = "public_id=$publicId&timestamp=$timestamp$_apiSecret";
    return toSign.hashCode.toString();
  }
  
  // Get image info
  static Future<Map<String, dynamic>?> getImageInfo(String publicId) async {
    try {
      final dio = Dio();
      
      final response = await dio.get(
        'https://api.cloudinary.com/v1_1/$_cloudName/resources/image/upload',
        queryParameters: {
          'public_ids': publicId,
          'max_results': 1,
        },
      );
      
      if (response.statusCode == 200 && response.data['resources'].isNotEmpty) {
        return response.data['resources'][0];
      }
      return null;
    } catch (e) {
      print('Cloudinary info fetch failed: $e');
      return null;
    }
  }
  
  // Generate responsive image URLs
  static Map<String, String> getResponsiveUrls(String originalUrl) {
    return {
      'thumbnail': getThumbnailUrl(originalUrl, size: 150),
      'small': getOptimizedUrl(originalUrl, width: 300),
      'medium': getOptimizedUrl(originalUrl, width: 600),
      'large': getOptimizedUrl(originalUrl, width: 1200),
      'original': originalUrl,
    };
  }
  
  // Generate WebP format URL
  static String getWebPUrl(String originalUrl, {int? width, int? height}) {
    return getOptimizedUrl(
      originalUrl,
      width: width,
      height: height,
      format: 'webp',
      quality: 'auto',
    );
  }
  
  // Generate AVIF format URL (for modern browsers)
  static String getAVIFUrl(String originalUrl, {int? width, int? height}) {
    return getOptimizedUrl(
      originalUrl,
      width: width,
      height: height,
      format: 'avif',
      quality: 'auto',
    );
  }
  
  // Check if URL is from Cloudinary
  static bool isCloudinaryUrl(String url) {
    return url.contains('cloudinary.com');
  }
  
  // Extract public ID from Cloudinary URL
  static String? getPublicId(String url) {
    if (!isCloudinaryUrl(url)) return null;
    
    try {
      List<String> parts = url.split('/');
      String filename = parts.last.split('.')[0];
      return filename;
    } catch (e) {
      return null;
    }
  }
}