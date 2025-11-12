import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:nextpay/widget/common/dot-loader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nextpay/export.dart';

class ScanScreen extends StatefulWidget {
  final String title;
  final bool isSelfie;

  const ScanScreen({super.key, required this.title, this.isSelfie = false});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _permissionGranted = false;
  bool _isCapturing = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndInitCamera();
  }

  Future<void> _checkPermissionAndInitCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        AppToast.error('Camera permission is required.', context);
        Navigator.pop(context);
      }
      return;
    }
    _permissionGranted = true;
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) throw 'No cameras found';

      CameraDescription camera = _cameras!.firstWhere(
        (c) => widget.isSelfie
            ? c.lensDirection == CameraLensDirection.front
            : c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(camera, ResolutionPreset.high);
      await _controller!.initialize();

      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) {
        AppToast.error('Camera initialization failed: $e', context);
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (!_isInitialized) return;
    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      setState(() => _isFlashOn = !_isFlashOn);
      AppToast.info(
        _isFlashOn ? 'Flash turned on' : 'Flash turned off',
        context,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      AppToast.error('Error toggling flash: $e', context);
    }
  }

  Future<void> _capture() async {
    if (!_isInitialized || !_permissionGranted || _isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      XFile file = await _controller!.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await File(file.path).copy(filePath);

      if (mounted) {
        AppToast.success('Photo captured successfully', context);
        Navigator.pop(context, savedFile.path);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error('Error capturing image: $e', context);
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    // Import image_picker package and implement
    // This is a placeholder for gallery selection
    AppToast.info('Gallery selection coming soon', context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isInitialized
          ? Stack(
              children: [
                // Full black background
                Container(color: Colors.black),

                // Camera Preview with rounded corners - centered
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),

                // Overlay with ID card template
                _buildOverlay(),

                // Capture button at bottom
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: _buildCaptureButton(),
                ),
              ],
            )
          : const Center(child: NextPayLoader()),
    );
  }

  Widget _buildOverlay() {
    return IgnorePointer(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
          child: Column(
            children: [
              60.height,
              // Title
              MyText(
                text: widget.isSelfie
                    ? 'Selfie with your ID'
                    : 'Photo of your ID card',
                color: Colors.white,
                size: 20,
                weight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),

              12.height,
              // Subtitle
              MyText(
                text: widget.isSelfie
                    ? 'Hold your ID next to your face'
                    : 'Please point the camera at the ID card',
                color: Colors.white70,
                size: 14,
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              
              if (widget.isSelfie) const Spacer(),

              100.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gallery icon (left)
          GestureDetector(
            onTap: _isCapturing ? null : _pickFromGallery,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(30.0)
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  color: context.icon,
                  size: 24,
                ),
              ),
            ),
          ),

          // Capture button - Main (Center & Larger)
          GestureDetector(
            onTap: _isCapturing ? null : _capture,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: context.primary,
                borderRadius: BorderRadius.circular(100.0)
                
              ),
              child: Center(
                child: _isCapturing
                    ?NextPayLoader()
                    : SvgPicture.asset(Assets.camera, color: context.icon, height: 40.0,)
              ),
            ),
          ),

          // Flash toggle icon (right)
          GestureDetector(
            onTap: _isCapturing ? null : _toggleFlash,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(30.0)
              ),
              child: Center(
                child: Icon(
                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: _isFlashOn ? Colors.orange : context.primary,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}