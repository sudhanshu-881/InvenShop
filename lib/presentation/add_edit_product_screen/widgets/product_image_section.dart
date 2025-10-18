import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProductImageSection extends StatefulWidget {
  final List<XFile> images;
  final Function(List<XFile>) onImagesChanged;
  final int? primaryImageIndex;
  final Function(int) onPrimaryImageChanged;

  const ProductImageSection({
    Key? key,
    required this.images,
    required this.onImagesChanged,
    this.primaryImageIndex,
    required this.onPrimaryImageChanged,
  }) : super(key: key);

  @override
  State<ProductImageSection> createState() => _ProductImageSectionState();
}

class _ProductImageSectionState extends State<ProductImageSection> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _showCamera = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final camera = kIsWeb
            ? _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.front,
                orElse: () => _cameras.first)
            : _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.back,
                orElse: () => _cameras.first);

        _cameraController = CameraController(
            camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

        await _cameraController!.initialize();
        await _applySettings();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {
      debugPrint('Focus mode error: $e');
    }

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {
        debugPrint('Flash mode error: $e');
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      final updatedImages = List<XFile>.from(widget.images)..add(photo);
      widget.onImagesChanged(updatedImages);

      setState(() {
        _showCamera = false;
      });
    } catch (e) {
      debugPrint('Photo capture error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> pickedImages = await _imagePicker.pickMultiImage();
      if (pickedImages.isNotEmpty) {
        final updatedImages = List<XFile>.from(widget.images)
          ..addAll(pickedImages);
        widget.onImagesChanged(updatedImages);
      }
    } catch (e) {
      debugPrint('Gallery picker error: $e');
    }
  }

  void _removeImage(int index) {
    final updatedImages = List<XFile>.from(widget.images)..removeAt(index);
    widget.onImagesChanged(updatedImages);

    if (widget.primaryImageIndex == index) {
      widget.onPrimaryImageChanged(updatedImages.isNotEmpty ? 0 : -1);
    } else if (widget.primaryImageIndex != null &&
        widget.primaryImageIndex! > index) {
      widget.onPrimaryImageChanged(widget.primaryImageIndex! - 1);
    }
  }

  void _reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final updatedImages = List<XFile>.from(widget.images);
    final item = updatedImages.removeAt(oldIndex);
    updatedImages.insert(newIndex, item);
    widget.onImagesChanged(updatedImages);

    if (widget.primaryImageIndex == oldIndex) {
      widget.onPrimaryImageChanged(newIndex);
    } else if (widget.primaryImageIndex != null) {
      if (oldIndex < widget.primaryImageIndex! &&
          newIndex >= widget.primaryImageIndex!) {
        widget.onPrimaryImageChanged(widget.primaryImageIndex! - 1);
      } else if (oldIndex > widget.primaryImageIndex! &&
          newIndex <= widget.primaryImageIndex!) {
        widget.onPrimaryImageChanged(widget.primaryImageIndex! + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Images',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        _showCamera ? _buildCameraView() : _buildImageGrid(),
        SizedBox(height: 2.h),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        height: 40.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline,
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
      );
    }

    return Container(
      height: 40.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            CameraPreview(_cameraController!),
            Positioned(
              bottom: 2.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: "close_camera",
                    mini: true,
                    backgroundColor: AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.9),
                    onPressed: () {
                      setState(() {
                        _showCamera = false;
                      });
                    },
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: "capture_photo",
                    backgroundColor: AppTheme.lightTheme.primaryColor,
                    onPressed: _capturePhoto,
                    child: CustomIconWidget(
                      iconName: 'camera_alt',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  if (!kIsWeb)
                    FloatingActionButton(
                      heroTag: "toggle_flash",
                      mini: true,
                      backgroundColor: AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.9),
                      onPressed: () async {
                        try {
                          final currentFlashMode =
                              _cameraController!.value.flashMode;
                          final newFlashMode = currentFlashMode == FlashMode.off
                              ? FlashMode.torch
                              : FlashMode.off;
                          await _cameraController!.setFlashMode(newFlashMode);
                          setState(() {});
                        } catch (e) {
                          debugPrint('Flash toggle error: $e');
                        }
                      },
                      child: CustomIconWidget(
                        iconName: _cameraController!.value.flashMode ==
                                FlashMode.torch
                            ? 'flash_on'
                            : 'flash_off',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Container(
      constraints: BoxConstraints(
        minHeight: 20.h,
        maxHeight: 40.h,
      ),
      child: widget.images.isEmpty
          ? _buildEmptyState()
          : ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.images.length,
              onReorder: _reorderImages,
              itemBuilder: (context, index) {
                return _buildImageCard(index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'add_photo_alternate',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 48,
          ),
          SizedBox(height: 1.h),
          Text(
            'Add product images',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Tap camera or gallery to add photos',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(int index) {
    final isPrimary = widget.primaryImageIndex == index;

    return Container(
      key: ValueKey(widget.images[index].path),
      width: 25.w,
      margin: EdgeInsets.only(right: 2.w),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPrimary
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.outline,
                width: isPrimary ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1,
                child: kIsWeb
                    ? Image.network(
                        widget.images[index].path,
                        fit: BoxFit.cover,
                      )
                    : CustomImageWidget(
                        imageUrl: widget.images[index].path,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        semanticLabel: "Product image ${index + 1}",
                      ),
              ),
            ),
          ),
          if (isPrimary)
            Positioned(
              top: 1.w,
              left: 1.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Primary',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontSize: 8.sp,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 1.w,
            right: 1.w,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: EdgeInsets.all(0.5.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.error
                      .withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onError,
                  size: 16,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 1.w,
            right: 1.w,
            child: GestureDetector(
              onTap: () => widget.onPrimaryImageChanged(index),
              child: Container(
                padding: EdgeInsets.all(0.5.w),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: isPrimary ? 'star' : 'star_border',
                  color: isPrimary
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              if (await _requestCameraPermission()) {
                setState(() {
                  _showCamera = true;
                });
              }
            },
            icon: CustomIconWidget(
              iconName: 'camera_alt',
              color: AppTheme.lightTheme.primaryColor,
              size: 20,
            ),
            label: Text('Camera'),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickFromGallery,
            icon: CustomIconWidget(
              iconName: 'photo_library',
              color: AppTheme.lightTheme.primaryColor,
              size: 20,
            ),
            label: Text('Gallery'),
          ),
        ),
      ],
    );
  }
}
