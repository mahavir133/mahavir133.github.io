import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/complex_calculator.dart';

class ComplexScreen extends ConsumerStatefulWidget {
  const ComplexScreen({super.key});

  @override
  ConsumerState<ComplexScreen> createState() => _ComplexScreenState();
}

class _ComplexScreenState extends ConsumerState<ComplexScreen> {
  final TextEditingController _r1Controller = TextEditingController();
  final TextEditingController _i1Controller = TextEditingController();
  final TextEditingController _r2Controller = TextEditingController();
  final TextEditingController _i2Controller = TextEditingController();

  String _operator = '+';
  ComplexResult? _result;
  String? _error;

  @override
  void dispose() {
    _r1Controller.dispose();
    _i1Controller.dispose();
    _r2Controller.dispose();
    _i2Controller.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _error = null);

    try {
      final r1 = double.tryParse(_r1Controller.text) ?? 0;
      final i1 = double.tryParse(_i1Controller.text) ?? 0;
      final c1 = ComplexNumber(r1, i1);

      ComplexNumber res;

      if (_operator == '^') {
        final power = double.tryParse(_r2Controller.text) ?? 0;
        res = c1.power(power);
      } else {
        final r2 = double.tryParse(_r2Controller.text) ?? 0;
        final i2 = double.tryParse(_i2Controller.text) ?? 0;
        final c2 = ComplexNumber(r2, i2);

        switch (_operator) {
          case '+':
            res = c1 + c2;
            break;
          case '-':
            res = c1 - c2;
            break;
          case 'x':
            res = c1 * c2;
            break;
          case '/':
            res = c1 / c2;
            break;
          default:
            throw Exception("Unknown operator");
        }
      }

      setState(() {
        _result = res.toResult();
      });

      ref
          .read(historyServiceProvider)
          .logCalculation(
            moduleName: 'Complex Number',
            category: 'Math & Academic',
            inputs: 'Op: $_operator', // Simplified for brevity
            result: res.toRectangularString(),
          );
    } catch (e) {
      setState(() {
        _error = "Invalid Input: Check your numbers.";
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complex Numbers'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 16),
                    color: Colors.redAccent.withOpacity(0.2),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const Text(
                  'Complex Number 1 (a + bi)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _r1Controller,
                        hintText: 'Real (a)',
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('+'),
                    ),
                    Expanded(
                      child: GlassTextField(
                        controller: _i1Controller,
                        hintText: 'Imag (b)',
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('i'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildOperatorSelector(theme),
                const SizedBox(height: 16),

                if (_operator == '^') ...[
                  const Text(
                    'Power (n)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  GlassTextField(controller: _r2Controller, hintText: 'n'),
                ] else ...[
                  const Text(
                    'Complex Number 2 (c + di)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GlassTextField(
                          controller: _r2Controller,
                          hintText: 'Real (c)',
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('+'),
                      ),
                      Expanded(
                        child: GlassTextField(
                          controller: _i2Controller,
                          hintText: 'Imag (d)',
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text('i'),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                GlassButton(
                  onPressed: _calculate,
                  child: const Text('Calculate'),
                ),
                const SizedBox(height: 24),
                if (_result != null) _buildResultView(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperatorSelector(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassAutocomplete<String>(
        options: const ['+', '-', 'x', '/', '^'],
        initialValue: _operator,
        displayStringForOption: (val) {
          if (val == '+') return 'Add (+)';
          if (val == '-') return 'Subtract (-)';
          if (val == 'x') return 'Multiply (x)';
          if (val == '/') return 'Divide (/)';
          return 'Power (^)';
        },
        onChanged: (val) {
          if (val != null) setState(() => _operator = val);
        },
      ),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text('Rectangular Form', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            _result!.rectangular,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 32),
          const Text(
            'Polar Form (r ∠ θ)',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            _result!.polar,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
