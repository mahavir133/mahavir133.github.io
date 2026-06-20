import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/boolean_algebra.dart';

class BooleanScreen extends ConsumerStatefulWidget {
  const BooleanScreen({super.key});

  @override
  ConsumerState<BooleanScreen> createState() => _BooleanScreenState();
}

class _BooleanScreenState extends ConsumerState<BooleanScreen> {
  final TextEditingController _exprController = TextEditingController();
  final TextEditingController _varsController = TextEditingController(
    text: 'A, B',
  );

  List<String>? _result;
  String? _error;

  @override
  void dispose() {
    _exprController.dispose();
    _varsController.dispose();
    super.dispose();
  }

  void _calculate() {
    final expr = _exprController.text.trim();
    final varsStr = _varsController.text.trim();
    if (expr.isEmpty || varsStr.isEmpty) return;

    try {
      List<String> vars = varsStr
          .split(',')
          .map((e) => e.trim().toUpperCase())
          .where((e) => e.isNotEmpty)
          .toList();
      if (vars.length > 4)
        throw Exception("Max 4 variables supported for performance reasons.");

      final res = BooleanAlgebra.generateTruthTable(expr, vars);
      setState(() {
        _result = res;
        _error = null;
      });

      ref
          .read(historyServiceProvider)
          .logCalculation(
            moduleName: 'Boolean Algebra',
            category: 'Math & Academic',
            inputs: '$expr (${vars.join(',')})',
            result: 'Truth table generated',
          );
    } catch (e) {
      setState(() {
        _error =
            "Invalid Expression or Variables. Use A, B, C, AND, OR, NOT, XOR, ().";
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boolean Algebra'),
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
                GlassTextField(
                  controller: _exprController,
                  hintText: 'Enter expression (e.g. A AND (B OR C))',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _varsController,
                  hintText: 'Variables separated by commas (e.g. A, B, C)',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 24),
                GlassButton(
                  onPressed: _calculate,
                  child: const Text('Generate Truth Table'),
                ),
                const SizedBox(height: 24),

                if (_result != null)
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Truth Table',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ..._result!.map(
                          (line) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              line,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 16,
                              ),
                            ),
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
