import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DocumentUploadSection extends StatefulWidget {
  final Function(XFile?) onBusinessLicenseSelected;
  final Function(XFile?) onTaxIdSelected;
  final XFile? businessLicenseFile;
  final XFile? taxIdFile;

  const DocumentUploadSection({
    Key? key,
    required this.onBusinessLicenseSelected,
    required this.onTaxIdSelected,
    this.businessLicenseFile,
    this.taxIdFile,
  }) : super(key: key);

  @override
  State<DocumentUploadSection> createState() => _DocumentUploadSectionState();
}

class _DocumentUploadSectionState extends State<DocumentUploadSection> {
  final ImagePicker _picker = ImagePicker();
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _showCamera = false;
  String _currentUploadType = '';

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
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;
    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          debugPrint('Flash mode not supported: $e');
        }
      }
    } catch (e) {
      debugPrint('Camera settings error: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _showCamera = false;
      });

      if (_currentUploadType == 'business_license') {
        widget.onBusinessLicenseSelected(photo);
      } else if (_currentUploadType == 'tax_id') {
        widget.onTaxIdSelected(photo);
      }
    } catch (e) {
      debugPrint('Photo capture error: $e');
    }
  }

  Future<void> _pickFromGallery(String uploadType) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (uploadType == 'business_license') {
          widget.onBusinessLicenseSelected(image);
        } else if (uploadType == 'tax_id') {
          widget.onTaxIdSelected(image);
        }
      }
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
  }

  Future<void> _showImageSourceDialog(String uploadType) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  if (await _requestCameraPermission()) {
                    setState(() {
                      _currentUploadType = uploadType;
                      _showCamera = true;
                    });
                  }
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'photo_library',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery(uploadType);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String description,
    required String uploadType,
    required XFile? selectedFile,
    required VoidCallback onUpload,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedFile != null
              ? Colors.green
              : Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: selectedFile != null ? 'check_circle' : 'description',
                color: selectedFile != null
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: selectedFile != null ? Colors.green : null,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 2.h),
          if (selectedFile != null) ...[
            Container(
              width: double.infinity,
              height: 20.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: kIsWeb
                    ? Image.network(
                        selectedFile.path,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: CustomIconWidget(
                                iconName: 'description',
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      )
                    : Image.file(
                        File(selectedFile.path),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: CustomIconWidget(
                                iconName: 'description',
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onUpload,
                    icon: CustomIconWidget(
                      iconName: 'refresh',
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    label: const Text('Retake'),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: CustomIconWidget(
                      iconName: 'check',
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                    label: const Text('Uploaded'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onUpload,
                icon: CustomIconWidget(
                  iconName: 'upload_file',
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                label: const Text('Upload Document'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showCamera && _isCameraInitialized && _cameraController != null) {
      return Container(
        height: 100.h,
        child: Stack(
          children: [
            CameraPreview(_cameraController!),
            Positioned(
              top: 8.h,
              left: 4.w,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _showCamera = false;
                  });
                },
                icon: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10.h,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _capturePhoto,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'camera_alt',
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'folder_open',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Verification Documents',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildDocumentUploadCard(
            title: 'Business License *',
            description:
                'Upload a clear photo of your business license or registration certificate',
            uploadType: 'business_license',
            selectedFile: widget.businessLicenseFile,
            onUpload: () => _showImageSourceDialog('business_license'),
          ),
          SizedBox(height: 3.h),
          _buildDocumentUploadCard(
            title: 'Tax ID Document *',
            description:
                'Upload your tax identification document or EIN certificate',
            uploadType: 'tax_id',
            selectedFile: widget.taxIdFile,
            onUpload: () => _showImageSourceDialog('tax_id'),
          ),
        ],
      ),
    );
  }
}
