import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'cloudinary_service.dart';
import 'supabase_service.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  
  // Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }
  
  // Pick image from camera
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }
  
  // Pick multiple images
  static Future<List<File>> pickMultipleImages({int maxImages = 5}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }
  
  // Upload image to Cloudinary and save to Supabase
  static Future<String?> uploadProductImage(File imageFile, {
    String? productId,
    String? category,
  }) async {
    try {
      // Upload to Cloudinary
      String? cloudinaryUrl = await CloudinaryService.uploadImageToFolder(
        imageFile.path,
        category ?? 'products',
      );
      
      if (cloudinaryUrl == null) {
        print('Failed to upload image to Cloudinary');
        return null;
      }
      
      // If productId is provided, save to Supabase
      if (productId != null) {
        await _saveImageToSupabase(cloudinaryUrl, productId, 'product');
      }
      
      return cloudinaryUrl;
    } catch (e) {
      print('Error uploading product image: $e');
      return null;
    }
  }
  
  // Upload multiple product images
  static Future<List<String>> uploadMultipleProductImages(
    List<File> imageFiles, {
    String? productId,
    String? category,
  }) async {
    List<String> uploadedUrls = [];
    
    for (File imageFile in imageFiles) {
      String? url = await uploadProductImage(imageFile, 
        productId: productId, 
        category: category,
      );
      if (url != null) {
        uploadedUrls.add(url);
      }
    }
    
    return uploadedUrls;
  }
  
  // Upload shop logo
  static Future<String?> uploadShopLogo(File imageFile) async {
    try {
      String? cloudinaryUrl = await CloudinaryService.uploadImageToFolder(
        imageFile.path,
        'shop-logos',
      );
      
      if (cloudinaryUrl == null) {
        print('Failed to upload shop logo to Cloudinary');
        return null;
      }
      
      // Update shop profile in Supabase
      final authService = AuthService();
      final shop = await authService.getCurrentShop();
      if (shop != null) {
        // Update shop logo URL in Supabase
        // This would require a new method in AuthService
      }
      
      return cloudinaryUrl;
    } catch (e) {
      print('Error uploading shop logo: $e');
      return null;
    }
  }
  
  // Upload customer photo
  static Future<String?> uploadCustomerPhoto(File imageFile, String customerId) async {
    try {
      String? cloudinaryUrl = await CloudinaryService.uploadImageToFolder(
        imageFile.path,
        'customers',
      );
      
      if (cloudinaryUrl == null) {
        print('Failed to upload customer photo to Cloudinary');
        return null;
      }
      
      // Save to Supabase
      await _saveImageToSupabase(cloudinaryUrl, customerId, 'customer');
      
      return cloudinaryUrl;
    } catch (e) {
      print('Error uploading customer photo: $e');
      return null;
    }
  }
  
  // Save image metadata to Supabase
  static Future<void> _saveImageToSupabase(
    String imageUrl, 
    String entityId, 
    String entityType,
  ) async {
    try {
      final client = SupabaseService.client;
      
      await client.from('images').insert({
        'url': imageUrl,
        'entity_id': entityId,
        'entity_type': entityType,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving image to Supabase: $e');
    }
  }
  
  // Get optimized image URL
  static String getOptimizedImageUrl(String originalUrl, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    if (CloudinaryService.isCloudinaryUrl(originalUrl)) {
      return CloudinaryService.getOptimizedUrl(
        originalUrl,
        width: width,
        height: height,
        quality: quality,
        format: format,
      );
    }
    
    // For non-Cloudinary URLs, return as-is
    return originalUrl;
  }
  
  // Get thumbnail URL
  static String getThumbnailUrl(String originalUrl, {int size = 200}) {
    if (CloudinaryService.isCloudinaryUrl(originalUrl)) {
      return CloudinaryService.getThumbnailUrl(originalUrl, size: size);
    }
    
    return originalUrl;
  }
  
  // Get product grid image URL
  static String getProductGridUrl(String originalUrl) {
    if (CloudinaryService.isCloudinaryUrl(originalUrl)) {
      return CloudinaryService.getProductGridUrl(originalUrl);
    }
    
    return originalUrl;
  }
  
  // Get responsive image URLs
  static Map<String, String> getResponsiveUrls(String originalUrl) {
    if (CloudinaryService.isCloudinaryUrl(originalUrl)) {
      return CloudinaryService.getResponsiveUrls(originalUrl);
    }
    
    return {
      'thumbnail': originalUrl,
      'small': originalUrl,
      'medium': originalUrl,
      'large': originalUrl,
      'original': originalUrl,
    };
  }
  
  // Compress image before upload
  static Future<File> compressImage(File imageFile, {int quality = 85}) async {
    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basename(imageFile.path);
      final compressedPath = path.join(tempDir.path, 'compressed_$fileName');
      
      // For now, return the original file
      // In production, you might want to use a compression library
      return imageFile;
    } catch (e) {
      print('Error compressing image: $e');
      return imageFile;
    }
  }
  
  // Delete image from both Cloudinary and Supabase
  static Future<bool> deleteImage(String imageUrl, String entityId) async {
    try {
      bool cloudinaryDeleted = true;
      bool supabaseDeleted = true;
      
      // Delete from Cloudinary if it's a Cloudinary URL
      if (CloudinaryService.isCloudinaryUrl(imageUrl)) {
        String? publicId = CloudinaryService.getPublicId(imageUrl);
        if (publicId != null) {
          cloudinaryDeleted = await CloudinaryService.deleteImage(publicId);
        }
      }
      
      // Delete from Supabase
      try {
        final client = SupabaseService.client;
        await client
            .from('images')
            .delete()
            .eq('url', imageUrl)
            .eq('entity_id', entityId);
      } catch (e) {
        print('Error deleting image from Supabase: $e');
        supabaseDeleted = false;
      }
      
      return cloudinaryDeleted && supabaseDeleted;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
  
  // Get image picker options
  static Future<File?> showImagePickerOptions(BuildContext context) async {
    return await showModalBottomSheet<File>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final File? image = await pickImageFromGallery();
                  if (image != null) {
                    Navigator.of(context).pop(image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final File? image = await pickImageFromCamera();
                  if (image != null) {
                    Navigator.of(context).pop(image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Validate image file
  static bool isValidImageFile(File file) {
    final String extension = path.extension(file.path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(extension);
  }
  
  // Get file size in MB
  static Future<double> getFileSizeInMB(File file) async {
    try {
      final int bytes = await file.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      return 0.0;
    }
  }
  
  // Check if file size is within limits
  static Future<bool> isFileSizeValid(File file, {double maxSizeMB = 10.0}) async {
    final double sizeInMB = await getFileSizeInMB(file);
    return sizeInMB <= maxSizeMB;
  }
}