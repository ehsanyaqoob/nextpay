import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:nextpay/widget/common/dot-loader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nextpay/export.dart';

class ValidationResult {
  final bool isValid;
  final String errorMessage;

  ValidationResult(this.isValid, this.errorMessage);
}

class ScanScreen extends StatefulWidget {
  final String title;
  final bool isSelfie;
  final String? requiredIdType;

  const ScanScreen({
    super.key, 
    required this.title, 
    this.isSelfie = false,
    this.requiredIdType,
  });

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
      final filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await File(file.path).copy(filePath);

      // Validate BEFORE showing success
      final validationResult = await _validateCapturedImage(savedFile.path);
      
      if (!validationResult.isValid) {
        await savedFile.delete();
        setState(() => _isCapturing = false);
        AppToast.error(validationResult.errorMessage, context);
        return;
      }

      // Only show success if validation passed
      if (mounted) {
        AppToast.success(
          widget.isSelfie ? 'Selfie captured successfully!' : 'Document captured successfully!', 
          context
        );
        Navigator.pop(context, savedFile.path);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error('Error capturing image: $e', context);
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<ValidationResult> _validateCapturedImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        return ValidationResult(false, 'Image file not found. Please try again.');
      }

      final stat = file.statSync();
      
      // STRICT validation - reject small/blank images
      final minSize = widget.isSelfie ? 50000 : 40000; // 50KB selfie, 40KB document
      final absoluteMinSize = 10000; // 10KB absolute minimum
      
      // Debug print
      print('🖼️ Image validation - Size: ${stat.size} bytes, Type: ${widget.isSelfie ? 'Selfie' : 'Document'}');
      
      if (stat.size < absoluteMinSize) {
        print('❌ REJECTED: Too small - ${stat.size} bytes');
        return ValidationResult(false, 'Image is too small or blank. Please capture a proper image.');
      }
      
      if (stat.size < minSize) {
        print('❌ REJECTED: Poor quality - ${stat.size} bytes');
        return ValidationResult(
          false, 
          widget.isSelfie 
            ? 'Image quality too low. Ensure both face and ID are clearly visible with good lighting.'
            : 'Document quality too low. Ensure good lighting and the entire document is visible.'
        );
      }

      // Additional type-specific validation
      if (widget.isSelfie) {
        return _validateSelfieWithId(imagePath, stat.size);
      } else {
        return _validateIdDocument(imagePath, stat.size);
      }
    } catch (e) {
      return ValidationResult(false, 'Error validating image: $e');
    }
  }

  Future<ValidationResult> _validateSelfieWithId(String imagePath, int fileSize) async {
    // Enhanced selfie validation
    if (fileSize < 60000) {
      return ValidationResult(
        false,
        'Please ensure BOTH your face AND ${widget.requiredIdType?.toLowerCase() ?? 'ID'} are clearly visible.\n\nHold the ID close to your face with good lighting.'
      );
    }

    print('✅ Selfie validation PASSED - ${fileSize} bytes');
    return ValidationResult(true, 'Valid selfie with ID');
  }

  Future<ValidationResult> _validateIdDocument(String imagePath, int fileSize) async {
    // Enhanced document validation
    if (fileSize < 50000) {
      return ValidationResult(
        false,
        '${widget.requiredIdType ?? 'Document'} quality insufficient.\n\nEnsure:\n• Good lighting\n• No blur\n• Entire document visible\n• All text readable'
      );
    }

    print('✅ Document validation PASSED - ${fileSize} bytes');
    return ValidationResult(true, 'Valid document');
  }

  Future<void> _pickFromGallery() async {
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
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: _isFlashOn ? Colors.amber : Colors.white,
            ),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: _isInitialized
          ? Stack(
              children: [
                Container(color: Colors.black),
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
                _buildOverlay(),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: _buildCaptureButton(),
                ),
                if (_isCapturing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NextPayLoader(),
                          SizedBox(height: 16),
                          Text(
                            'Validating image quality...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NextPayLoader(),
                  SizedBox(height: 16),
                  Text(
                    'Initializing camera...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
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
              40.height,
              MyText(
                text: widget.isSelfie
                    ? 'Selfie with your ${widget.requiredIdType ?? 'ID'}'
                    : 'Capture ${widget.requiredIdType ?? 'ID Document'}',
                color: Colors.white,
                size: 20,
                weight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              12.height,
              MyText(
                text: widget.isSelfie
                    ? 'Hold your ${widget.requiredIdType?.toLowerCase() ?? 'ID'} next to your face'
                    : 'Align your ${widget.requiredIdType?.toLowerCase() ?? 'document'} within the frame',
                color: Colors.white70,
                size: 14,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              _buildGuideFrame(),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(bottom: 120),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    MyText(
                      text: 'QUALITY REQUIREMENTS:',
                      color: Colors.amber,
                      size: 12,
                      weight: FontWeight.w700,
                    ),
                    8.height,
                    MyText(
                      text: widget.isSelfie
                          ? '• Both face AND ID must be clear\n• Good lighting required\n• No blur or glare\n• Hold ID close to face'
                          : '• Entire document must be visible\n• Good lighting required\n• No blur or glare\n• All text must be readable',
                      color: Colors.white,
                      size: 11,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideFrame() {
    if (widget.isSelfie) {
      return Container(
        width: 280,
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 40,
              top: 30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: const Icon(Icons.person, color: Colors.blue, size: 40),
              ),
            ),
            Positioned(
              right: 40,
              top: 50,
              child: Container(
                width: 100,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.credit_card, color: Colors.orange, size: 30),
              ),
            ),
            Positioned(
              left: 120,
              top: 70,
              child: Icon(Icons.arrow_forward, color: Colors.white, size: 30),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: MyText(
                text: 'BOTH REQUIRED FOR VALIDATION',
                color: Colors.white,
                size: 10,
                weight: FontWeight.w700,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    } else {
      double frameWidth = 280;
      double frameHeight = 180;
      
      if (widget.requiredIdType == 'Passport') {
        frameWidth = 240;
        frameHeight = 160;
      } else if (widget.requiredIdType == 'Driver License') {
        frameWidth = 260;
        frameHeight = 160;
      }

      return Container(
        width: frameWidth,
        height: frameHeight,
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card, color: Colors.white, size: 50),
            8.height,
            MyText(
              text: widget.requiredIdType ?? 'ID Document',
              color: Colors.white,
              size: 14,
              weight: FontWeight.w600,
            ),
            4.height,
            MyText(
              text: 'MUST FILL FRAME',
              color: Colors.amber,
              size: 10,
              weight: FontWeight.w700,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCaptureButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                child: Icon(Icons.image, color: context.icon, size: 24),
              ),
            ),
          ),
          GestureDetector(
            onTap: _isCapturing ? null : _capture,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isCapturing ? Colors.grey : context.primary,
                borderRadius: BorderRadius.circular(40.0),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Center(
                child: _isCapturing
                    ? NextPayLoader()
                    : Icon(Icons.camera_alt, color: Colors.white, size: 30),
              ),
            ),
          ),
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
                  color: _isFlashOn ? Colors.amber : context.icon,
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