import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../services/image_service.dart';

class ImagePickerWidget extends StatefulWidget {
  final List<String> imageUrls;
  final Function(List<String>) onImagesChanged;
  final int maxImages;
  final String? category;
  final bool showPreview;
  final double? width;
  final double? height;

  const ImagePickerWidget({
    Key? key,
    required this.imageUrls,
    required this.onImagesChanged,
    this.maxImages = 5,
    this.category,
    this.showPreview = true,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Grid
        if (widget.showPreview) ...[
          SizedBox(
            height: widget.height ?? 20.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.imageUrls.length + (widget.imageUrls.length < widget.maxImages ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == widget.imageUrls.length) {
                  return _buildAddImageButton();
                }
                return _buildImageItem(widget.imageUrls[index], index);
              },
            ),
          ),
          SizedBox(height: 1.h),
        ] else ...[
          _buildAddImageButton(),
        ],

        // Upload Progress
        if (_isUploading) ...[
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            backgroundColor: AppTheme.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
          ),
        ],
      ],
    );
  }

  Widget _buildAddImageButton() {
    return Container(
      width: widget.width ?? 15.w,
      height: widget.height ?? 20.h,
      margin: EdgeInsets.only(right: 2.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.borderLight,
          style: BorderStyle.solid,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _isUploading ? null : _pickImages,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 6.w,
              color: AppTheme.textSecondaryLight,
            ),
            SizedBox(height: 1.h),
            Text(
              'Add Image',
              style: TextStyle(
                fontSize: 10.sp,
                color: AppTheme.textSecondaryLight,
              ),
            ),
            if (widget.maxImages > 1)
              Text(
                '${widget.imageUrls.length}/${widget.maxImages}',
                style: TextStyle(
                  fontSize: 8.sp,
                  color: AppTheme.textSecondaryLight,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(String imageUrl, int index) {
    return Container(
      width: widget.width ?? 15.w,
      height: widget.height ?? 20.h,
      margin: EdgeInsets.only(right: 2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: ImageService.getProductGridUrl(imageUrl),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppTheme.backgroundLight,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryLight,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppTheme.backgroundLight,
                child: Icon(
                  Icons.error,
                  color: AppTheme.errorLight,
                  size: 4.w,
                ),
              ),
            ),
          ),

          // Delete Button
          Positioned(
            top: 1.w,
            right: 1.w,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 3.w,
                ),
              ),
            ),
          ),

          // Primary Badge
          if (index == 0 && widget.imageUrls.length > 1)
            Positioned(
              bottom: 1.w,
              left: 1.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Primary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      setState(() {
        _isUploading = true;
      });

      // Show image picker options
      File? selectedImage = await ImageService.showImagePickerOptions(context);
      
      if (selectedImage != null) {
        // Validate file
        if (!ImageService.isValidImageFile(selectedImage)) {
          _showSnackBar('Please select a valid image file (JPG, PNG, GIF, WebP)', isError: true);
          return;
        }

        // Check file size
        if (!await ImageService.isFileSizeValid(selectedImage, maxSizeMB: 10.0)) {
          _showSnackBar('Image size must be less than 10MB', isError: true);
          return;
        }

        // Upload image
        String? uploadedUrl = await ImageService.uploadProductImage(
          selectedImage,
          category: widget.category,
        );

        if (uploadedUrl != null) {
          List<String> updatedUrls = List.from(widget.imageUrls);
          updatedUrls.add(uploadedUrl);
          widget.onImagesChanged(updatedUrls);
          _showSnackBar('Image uploaded successfully');
        } else {
          _showSnackBar('Failed to upload image', isError: true);
        }
      }
    } catch (e) {
      _showSnackBar('Error uploading image: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _removeImage(int index) {
    List<String> updatedUrls = List.from(widget.imageUrls);
    updatedUrls.removeAt(index);
    widget.onImagesChanged(updatedUrls);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorLight : AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// Single Image Picker Widget
class SingleImagePickerWidget extends StatelessWidget {
  final String? imageUrl;
  final Function(String?) onImageChanged;
  final String? category;
  final double? width;
  final double? height;
  final String? placeholder;

  const SingleImagePickerWidget({
    Key? key,
    this.imageUrl,
    required this.onImageChanged,
    this.category,
    this.width,
    this.height,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        width: width ?? 20.w,
        height: height ?? 20.w,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.borderLight,
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: ImageService.getProductGridUrl(imageUrl!),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.backgroundLight,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryLight,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.backgroundLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 8.w,
            color: AppTheme.textSecondaryLight,
          ),
          SizedBox(height: 1.h),
          Text(
            placeholder ?? 'Add Image',
            style: TextStyle(
              fontSize: 10.sp,
              color: AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      File? selectedImage = await ImageService.showImagePickerOptions(context);
      
      if (selectedImage != null) {
        // Validate file
        if (!ImageService.isValidImageFile(selectedImage)) {
          _showSnackBar(context, 'Please select a valid image file (JPG, PNG, GIF, WebP)', isError: true);
          return;
        }

        // Check file size
        if (!await ImageService.isFileSizeValid(selectedImage, maxSizeMB: 10.0)) {
          _showSnackBar(context, 'Image size must be less than 10MB', isError: true);
          return;
        }

        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Upload image
        String? uploadedUrl = await ImageService.uploadProductImage(
          selectedImage,
          category: category,
        );

        // Hide loading
        Navigator.of(context).pop();

        if (uploadedUrl != null) {
          onImageChanged(uploadedUrl);
          _showSnackBar(context, 'Image uploaded successfully');
        } else {
          _showSnackBar(context, 'Failed to upload image', isError: true);
        }
      }
    } catch (e) {
      _showSnackBar(context, 'Error uploading image: ${e.toString()}', isError: true);
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorLight : AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}