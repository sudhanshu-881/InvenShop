import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(String) onBarcodeScanned;
  final VoidCallback onClose;

  const BarcodeScannerWidget({
    Key? key,
    required this.onBarcodeScanned,
    required this.onClose,
  }) : super(key: key);

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isScanning = false;

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
      if (!await _requestCameraPermission()) {
        widget.onClose();
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final camera = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.first,
        );

        _cameraController = CameraController(
          camera,
          ResolutionPreset.high,
        );

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
      widget.onClose();
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        await _cameraController!.setFlashMode(FlashMode.off);
      }
    } catch (e) {
      debugPrint('Camera settings error: $e');
    }
  }

  void _simulateBarcodeScan() {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    // Simulate barcode detection with a realistic delay
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        // Generate a realistic barcode number
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final barcodeNumber = '${timestamp.toString().substring(7)}';
        widget.onBarcodeScanned(barcodeNumber);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            _buildCameraView(),
            _buildScanOverlay(),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.lightTheme.primaryColor,
              ),
              SizedBox(height: 2.h),
              Text(
                'Initializing camera...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CameraPreview(_cameraController!);
  }

  Widget _buildScanOverlay() {
    return Center(
      child: Container(
        width: 60.w,
        height: 30.h,
        decoration: BoxDecoration(
          border: Border.all(
            color:
                _isScanning ? AppTheme.lightTheme.primaryColor : Colors.white,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Corner indicators
            Positioned(
              top: -1,
              left: -1,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: AppTheme.lightTheme.primaryColor, width: 4),
                    left: BorderSide(
                        color: AppTheme.lightTheme.primaryColor, width: 4),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: AppTheme.lightTheme.primaryColor, width: 4),
                    right: BorderSide(
                        color: AppTheme.lightTheme.primaryColor, width: 4),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -1,
              left: -1,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: AppTheme.lightTheme.primaryColor, width: 4),
                    left: BorderSide(
                        color: AppTheme.lightTheme.primaryColor, width: 4),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -1,
              right: -1,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: AppTheme.lightTheme.primaryColor, width: 4),
                    right: BorderSide(
                        color: AppTheme.lightTheme.primaryColor, width: 4),
                  ),
                ),
              ),
            ),
            // Scanning line animation
            if (_isScanning)
              AnimatedContainer(
                duration: Duration(seconds: 2),
                curve: Curves.easeInOut,
                child: Container(
                  width: double.infinity,
                  height: 2,
                  color: AppTheme.lightTheme.primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 4.h,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            _isScanning
                ? 'Scanning barcode...'
                : 'Position barcode within the frame',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: "close_scanner",
                mini: true,
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                onPressed: widget.onClose,
                child: CustomIconWidget(
                  iconName: 'close',
                  color: Colors.black,
                  size: 20,
                ),
              ),
              FloatingActionButton(
                heroTag: "scan_barcode",
                backgroundColor: _isScanning
                    ? Colors.grey
                    : AppTheme.lightTheme.primaryColor,
                onPressed: _isScanning ? null : _simulateBarcodeScan,
                child: _isScanning
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : CustomIconWidget(
                        iconName: 'qr_code_scanner',
                        color: Colors.white,
                        size: 24,
                      ),
              ),
              if (!kIsWeb)
                FloatingActionButton(
                  heroTag: "toggle_flash_scanner",
                  mini: true,
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
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
                    iconName:
                        _cameraController?.value.flashMode == FlashMode.torch
                            ? 'flash_on'
                            : 'flash_off',
                    color: Colors.black,
                    size: 20,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
