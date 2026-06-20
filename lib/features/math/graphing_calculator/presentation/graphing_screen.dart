import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';

class GraphingScreen extends ConsumerStatefulWidget {
  const GraphingScreen({super.key});

  @override
  ConsumerState<GraphingScreen> createState() => _GraphingScreenState();
}

class _GraphingScreenState extends ConsumerState<GraphingScreen> {
  final TextEditingController _exprController = TextEditingController(
    text: 'sin(x)',
  );
  Expression? _expression;
  String? _error;

  double _scale = 50.0; // Pixels per unit
  double _baseScale = 50.0;
  Offset _offset = Offset.zero; // Pan offset

  @override
  void initState() {
    super.initState();
    _parseExpression();
  }

  @override
  void dispose() {
    _exprController.dispose();
    super.dispose();
  }

  void _parseExpression() {
    try {
      Parser p = Parser();
      _expression = p.parse(_exprController.text.trim());
      setState(() => _error = null);
    } catch (e) {
      setState(() => _error = "Invalid expression");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graphing Calculator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text(
                      'y = ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: GlassTextField(
                        controller: _exprController,
                        hintText: 'e.g., sin(x) + x^2',
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent,
                      ),
                      onPressed: _parseExpression,
                    ),
                  ],
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: GestureDetector(
                      onScaleStart: (details) {
                        _baseScale = _scale;
                      },
                      onScaleUpdate: (details) {
                        setState(() {
                          _offset += details.focalPointDelta;
                          _scale = (_baseScale * details.scale).clamp(
                            5.0,
                            500.0,
                          );
                        });
                      },
                      child: CustomPaint(
                        painter: GraphPainter(
                          expression: _expression,
                          scale: _scale,
                          panOffset: _offset,
                          theme: theme,
                        ),
                        child: Container(
                          color: Colors.transparent,
                        ), // Catch gestures
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Pinch to zoom, drag to pan.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final Expression? expression;
  final double scale;
  final Offset panOffset;
  final ThemeData theme;

  GraphPainter({
    required this.expression,
    required this.scale,
    required this.panOffset,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()..color = theme.colorScheme.surface.withOpacity(0.5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final originX = size.width / 2 + panOffset.dx;
    final originY = size.height / 2 + panOffset.dy;

    final axisPaint = Paint()
      ..color = theme.colorScheme.onSurface.withOpacity(0.5)
      ..strokeWidth = 2.0;

    final gridPaint = Paint()
      ..color = theme.colorScheme.onSurface.withOpacity(0.1)
      ..strokeWidth = 1.0;

    // Draw Grid
    double step = scale;
    while (step < 20) step *= 2; // Prevent too dense grid

    // Vertical grid lines
    for (double x = originX % step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    // Horizontal grid lines
    for (double y = originY % step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw Axes
    canvas.drawLine(
      Offset(0, originY),
      Offset(size.width, originY),
      axisPaint,
    ); // X-axis
    canvas.drawLine(
      Offset(originX, 0),
      Offset(originX, size.height),
      axisPaint,
    ); // Y-axis

    if (expression == null) return;

    // Draw Graph
    final graphPaint = Paint()
      ..color = theme.colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    Path path = Path();
    bool first = true;
    ContextModel cm = ContextModel();
    Variable xVar = Variable('x');

    // Sample every pixel horizontally
    for (double px = 0; px < size.width; px++) {
      double xMath = (px - originX) / scale;
      cm.bindVariable(xVar, Number(xMath));

      try {
        double yMath = expression!.evaluate(EvaluationType.REAL, cm);
        if (yMath.isNaN || yMath.isInfinite) {
          first = true;
          continue;
        }

        double py = originY - (yMath * scale);

        // Don't draw points wildly off-screen to avoid weird stroke artifacts
        if (py < -size.height * 10 || py > size.height * 10) {
          first = true;
          continue;
        }

        if (first) {
          path.moveTo(px, py);
          first = false;
        } else {
          path.lineTo(px, py);
        }
      } catch (e) {
        first = true;
      }
    }

    canvas.drawPath(path, graphPaint);
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.expression != expression ||
        oldDelegate.scale != scale ||
        oldDelegate.panOffset != panOffset;
  }
}
