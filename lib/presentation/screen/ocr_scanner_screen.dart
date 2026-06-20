import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../provider/providers.dart';
import '../../core/util/image_preprocessor.dart';

class OcrScannerScreen extends ConsumerStatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  ConsumerState<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends ConsumerState<OcrScannerScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isBatchMode = false;
  final List<String> _batchResults = []; // stores results in batch mode

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  // Mock sample list for emulator debugging
  final List<Map<String, String>> _sampleProblems = [
    {'label': 'Simple Equation', 'expr': '3x + 5 = 20'},
    {'label': 'Variables Both Sides', 'expr': '5x - 4 = 2x + 8'},
    {'label': 'Fractional Equation', 'expr': 'x / 2 + 7 = 15'},
    {'label': 'Arithmetic Exponent', 'expr': '5^2 + sqrt(9)'},
    {'label': 'Factorial Combination', 'expr': '5! + nCr(5, 2)'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras[0],
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      // Camera failed to load (common in simulators). Graceful degradation is active.
      debugPrint('Camera init failed: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ocrState = ref.watch(ocrProvider);
    final ocrNotifier = ref.read(ocrProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Math OCR Solver', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Batch Mode Toggle
          Row(
            children: [
              const Text('Batch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Switch(
                value: _isBatchMode,
                onChanged: (val) {
                  setState(() {
                    _isBatchMode = val;
                    if (!val) _batchResults.clear();
                  });
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 1. Camera View or Emulator fallback
          _isCameraInitialized && _cameraController != null
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: CameraPreview(_cameraController!),
                        ),
                        // Reticle bounding box overlay
                        CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: ScanOverlayPainter(),
                        ),
                      ],
                    );
                  },
                )
              : _buildSimulatorFallback(context, ocrNotifier),

          // 2. Loading overlay
          if (_isProcessing || ocrState.status == OcrStatus.loading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'AI is preprocessing & analyzing equation...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Batch Mode Tray Overlay
          if (_isBatchMode && _batchResults.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 100,
              child: Card(
                color: Colors.black.withOpacity(0.75),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.playlist_add_check, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Scanned ${_batchResults.length} equations',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _showBatchResultsSheet(context),
                        child: const Text('View & Solve All', style: TextStyle(color: Colors.yellow)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 4. Capture & Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery Picker button
                FloatingActionButton.small(
                  heroTag: 'gallery_btn',
                  onPressed: () => _pickImage(ImageSource.gallery, ocrNotifier),
                  tooltip: 'Pick from Gallery',
                  child: const Icon(Icons.photo_library),
                ),

                // Capture shutter button (only if camera exists)
                if (_isCameraInitialized)
                  GestureDetector(
                    onTap: () => _captureAndProcess(ocrNotifier),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300, width: 4),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                      ),
                    ),
                  ),

                // Manual Input trigger
                FloatingActionButton.small(
                  heroTag: 'keyboard_btn',
                  onPressed: () => _showSolutionSheet(context, '', ocrNotifier),
                  tooltip: 'Manual Type Solver',
                  child: const Icon(Icons.keyboard),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatorFallback(BuildContext context, OcrNotifier notifier) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.photo_camera_back, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Camera Not Available',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'No physical camera was detected on this device. You can pick an image from the gallery or choose a mock math problem below to verify the OCR Solver:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 24),
            // Mock choices
            const Text('Click a Mock Problem to Scan:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._sampleProblems.map((prob) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(prob['label'] ?? ''),
                  subtitle: Text(
                    prob['expr'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showSolutionSheet(context, prob['expr']!, notifier);
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Core Processing Mechanics
  // ----------------------------------------------------

  Future<void> _captureAndProcess(OcrNotifier notifier) async {
    if (_cameraController == null || !_isCameraInitialized || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      HapticFeedback.mediumImpact();
      final XFile rawFile = await _cameraController!.takePicture();
      final preprocessedFile = await ImagePreprocessor.preprocess(File(rawFile.path));

      final inputImage = InputImage.fromFilePath(preprocessedFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      final cleanedText = _cleanOcrOutput(recognizedText.text);

      setState(() {
        _isProcessing = false;
      });

      if (_isBatchMode) {
        if (cleanedText.isNotEmpty) {
          setState(() {
            _batchResults.add(cleanedText);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added "$cleanedText" to batch tray')),
          );
        }
      } else {
        _showSolutionSheet(context, cleanedText, notifier);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OCR Scan failed: $e')),
      );
    }
  }

  Future<void> _pickImage(ImageSource source, OcrNotifier notifier) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _isProcessing = true;
      });

      final preprocessedFile = await ImagePreprocessor.preprocess(File(image.path));
      final inputImage = InputImage.fromFilePath(preprocessedFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      final cleanedText = _cleanOcrOutput(recognizedText.text);

      setState(() {
        _isProcessing = false;
      });

      if (_isBatchMode) {
        if (cleanedText.isNotEmpty) {
          setState(() {
            _batchResults.add(cleanedText);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added "$cleanedText" to batch tray')),
          );
        }
      } else {
        _showSolutionSheet(context, cleanedText, notifier);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import/recognize text: $e')),
      );
    }
  }

  String _cleanOcrOutput(String rawText) {
    // Basic regex cleaning for OCR math recognition
    return rawText
        .replaceAll('o', '0')
        .replaceAll('O', '0')
        .replaceAll('I', '1')
        .replaceAll('l', '1')
        .replaceAll('z', '2')
        .replaceAll('Z', '2')
        .replaceAll('s', '5')
        .replaceAll('S', '5')
        .replaceAll('x', 'x') // preserve variable x
        .replaceAll('X', 'x')
        .replaceAll('?', '')
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ----------------------------------------------------
  // Bottom Sheet Solution Renderers
  // ----------------------------------------------------

  void _showSolutionSheet(
    BuildContext context,
    String initialExpression,
    OcrNotifier notifier,
  ) {
    notifier.setParsedText(initialExpression);
    if (initialExpression.isNotEmpty) {
      notifier.solve();
    }

    final controller = TextEditingController(text: initialExpression);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final ocrState = ref.watch(ocrProvider);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Edit Scanned Equation',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        labelText: 'Equation',
                        border: OutlineInputBorder(),
                        hintText: 'e.g. 3x + 5 = 20',
                      ),
                      onChanged: (val) {
                        notifier.setParsedText(val);
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text('Evaluate / Solve'),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        notifier.setParsedText(controller.text);
                        notifier.solve();
                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 20),

                    // Results section
                    if (ocrState.status == OcrStatus.success) ...[
                      const Divider(),
                      const Text(
                        'Result',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ocrState.solutionResult ?? '',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const SizedBox(height: 16),

                      // Step-by-step solver steps
                      if (ocrState.steps.isNotEmpty) ...[
                        const Text(
                          'Step-by-Step Solution:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...ocrState.steps.map((step) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.arrow_right, color: Colors.deepPurple),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        step.description,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        step.equation,
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 16,
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ] else if (ocrState.status == OcrStatus.error) ...[
                      const Divider(),
                      const Text(
                        'Solver Error',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      Text(ocrState.errorMessage ?? ''),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showBatchResultsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final engine = ref.read(mathEngineProvider);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: SizedBox(
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Batch Solve (${_batchResults.length} Problems)',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear_all, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _batchResults.clear();
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: _batchResults.length,
                    itemBuilder: (context, index) {
                      final expr = _batchResults[index];
                      String res = 'Error';
                      try {
                        if (expr.contains('=')) {
                          final steps = engine.solve(expr);
                          res = steps.last.equation;
                        } else {
                          res = engine.evaluate(expr).toString();
                        }
                      } catch (e) {
                        res = 'Error: $e';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(expr, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Solve: $res', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------
// Guiding Custom Painter
// ----------------------------------------------------

class ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Draw opaque layout outside crop area
    final width = size.width;
    final height = size.height;
    final boxW = width * 0.8;
    final boxH = 120.0;
    final left = (width - boxW) / 2;
    final top = (height - boxH) / 2;
    final rect = Rect.fromLTWH(left, top, boxW, boxH);

    // Left block
    canvas.drawRect(Rect.fromLTWH(0, 0, left, height), paint);
    // Right block
    canvas.drawRect(Rect.fromLTWH(left + boxW, 0, width - (left + boxW), height), paint);
    // Top block
    canvas.drawRect(Rect.fromLTWH(left, 0, boxW, top), paint);
    // Bottom block
    canvas.drawRect(Rect.fromLTWH(left, top + boxH, boxW, height - (top + boxH)), paint);

    // Draw border around focus crop area
    final boxPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      boxPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
