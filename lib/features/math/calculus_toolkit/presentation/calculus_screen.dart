import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/calculus_toolkit.dart';

class CalculusScreen extends ConsumerStatefulWidget {
  const CalculusScreen({super.key});

  @override
  ConsumerState<CalculusScreen> createState() => _CalculusScreenState();
}

class _CalculusScreenState extends ConsumerState<CalculusScreen> {
  String _mode = 'Differentiation f\'(x)';

  final TextEditingController _exprController = TextEditingController();
  final TextEditingController _p1Controller = TextEditingController();
  final TextEditingController _p2Controller = TextEditingController();

  CalculusResult? _result;

  @override
  void dispose() {
    _exprController.dispose();
    _p1Controller.dispose();
    _p2Controller.dispose();
    super.dispose();
  }

  void _calculate() {
    final expr = _exprController.text.trim();
    if (expr.isEmpty) return;

    CalculusResult res;

    if (_mode == 'Differentiation f\'(x)') {
      double atX = double.tryParse(_p1Controller.text) ?? 0;
      res = CalculusToolkit.differentiate(expr, atX);
    } else if (_mode == 'Integration ∫f(x)dx') {
      double a = double.tryParse(_p1Controller.text) ?? 0;
      double b = double.tryParse(_p2Controller.text) ?? 0;
      res = CalculusToolkit.integrate(expr, a, b);
    } else {
      // Limit
      double approx = double.tryParse(_p1Controller.text) ?? 0;
      res = CalculusToolkit.limit(expr, approx);
    }

    setState(() => _result = res);

    if (res.error == null && res.value != null) {
      ref
          .read(historyServiceProvider)
          .logCalculation(
            moduleName: 'Calculus Toolkit',
            category: 'Math & Academic',
            inputs: 'f(x)=$expr | Op: $_mode',
            result: res.value!.toStringAsFixed(6),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isIntegration = _mode == 'Integration ∫f(x)dx';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculus Toolkit'),
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
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GlassAutocomplete<String>(
                    options: const [
                      'Differentiation f\'(x)',
                      'Integration ∫f(x)dx',
                      'Limit',
                    ],
                    initialValue: _mode,
                    onChanged: (val) {
                      if (val != null)
                        setState(() {
                          _mode = val;
                          _result = null;
                        });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                GlassTextField(
                  controller: _exprController,
                  hintText: 'Enter function f(x) e.g., x^2 + sin(x)',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),

                if (isIntegration) ...[
                  Row(
                    children: [
                      Expanded(
                        child: GlassTextField(
                          controller: _p1Controller,
                          hintText: 'Lower Bound (a)',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassTextField(
                          controller: _p2Controller,
                          hintText: 'Upper Bound (b)',
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  GlassTextField(
                    controller: _p1Controller,
                    hintText: _mode.contains('Differentiation')
                        ? 'Evaluate at x ='
                        : 'Approach x =',
                  ),
                ],

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
                        const SizedBox(height: 8),
                        if (_result!.error != null)
                          Text(
                            _result!.error!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.redAccent,
                            ),
                          )
                        else
                          Text(
                            _result!.value!.toStringAsFixed(6),
                            style: TextStyle(
                              fontSize: 32,
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
