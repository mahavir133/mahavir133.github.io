import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/vector_calculator.dart';

class VectorScreen extends ConsumerStatefulWidget {
  const VectorScreen({super.key});

  @override
  ConsumerState<VectorScreen> createState() => _VectorScreenState();
}

class _VectorScreenState extends ConsumerState<VectorScreen> {
  final List<TextEditingController> _v1Controllers = List.generate(
    3,
    (_) => TextEditingController(text: '0'),
  );
  final List<TextEditingController> _v2Controllers = List.generate(
    3,
    (_) => TextEditingController(text: '0'),
  );

  String _operation = 'Add (V1 + V2)';
  String? _result;

  @override
  void dispose() {
    for (var c in _v1Controllers) c.dispose();
    for (var c in _v2Controllers) c.dispose();
    super.dispose();
  }

  void _calculate() {
    final v1 = Vector3D(
      double.tryParse(_v1Controllers[0].text) ?? 0,
      double.tryParse(_v1Controllers[1].text) ?? 0,
      double.tryParse(_v1Controllers[2].text) ?? 0,
    );
    final v2 = Vector3D(
      double.tryParse(_v2Controllers[0].text) ?? 0,
      double.tryParse(_v2Controllers[1].text) ?? 0,
      double.tryParse(_v2Controllers[2].text) ?? 0,
    );

    String res = '';

    switch (_operation) {
      case 'Add (V1 + V2)':
        res = (v1 + v2).toString();
        break;
      case 'Subtract (V1 - V2)':
        res = (v1 - v2).toString();
        break;
      case 'Dot Product':
        res = v1.dot(v2).toStringAsFixed(4);
        break;
      case 'Cross Product':
        res = v1.cross(v2).toString();
        break;
      case 'Angle Between':
        res = '${v1.angleBetween(v2).toStringAsFixed(2)}°';
        break;
      case 'Magnitude V1':
        res = v1.magnitude.toStringAsFixed(4);
        break;
    }

    setState(() => _result = res);

    ref
        .read(historyServiceProvider)
        .logCalculation(
          moduleName: 'Vector Calculator',
          category: 'Math & Academic',
          inputs: 'V1: $v1, V2: $v2 | Op: $_operation',
          result: res,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vector Calculator'),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Vector 1 (x, y, z)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _v1Controllers[0],
                        hintText: 'x',
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: GlassTextField(
                        controller: _v1Controllers[1],
                        hintText: 'y',
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: GlassTextField(
                        controller: _v1Controllers[2],
                        hintText: 'z',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Vector 2 (x, y, z)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _v2Controllers[0],
                        hintText: 'x',
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: GlassTextField(
                        controller: _v2Controllers[1],
                        hintText: 'y',
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: GlassTextField(
                        controller: _v2Controllers[2],
                        hintText: 'z',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: const [
                      'Add (V1 + V2)',
                      'Subtract (V1 - V2)',
                      'Dot Product',
                      'Cross Product',
                      'Angle Between',
                      'Magnitude V1',
                    ],
                    initialValue: _operation,
                    displayStringForOption: (val) {
                      if (val == 'Magnitude V1') return 'Magnitude of V1';
                      return val;
                    },
                    onChanged: (val) {
                      if (val != null) setState(() => _operation = val);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                GlassButton(
                  onPressed: _calculate,
                  child: const Text('Calculate'),
                ),
                const SizedBox(height: 24),
                if (_result != null)
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Result',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _result!,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
