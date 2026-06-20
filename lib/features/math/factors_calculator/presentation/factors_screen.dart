import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/factors_calculator.dart';

class FactorsScreen extends ConsumerStatefulWidget {
  const FactorsScreen({super.key});

  @override
  ConsumerState<FactorsScreen> createState() => _FactorsScreenState();
}

class _FactorsScreenState extends ConsumerState<FactorsScreen> {
  final TextEditingController _inputController = TextEditingController();

  bool _isFactorizationMode = false;
  FactorsResult? _result;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _calculate() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    if (_isFactorizationMode) {
      final n = int.tryParse(text);
      if (n == null || n <= 0) return;

      final res = FactorsCalculator.primeFactorization(n);
      setState(() => _result = res);

      ref
          .read(historyServiceProvider)
          .logCalculation(
            moduleName: 'Prime Factorization',
            category: 'Math & Academic',
            inputs: '$n',
            result: res.primeFactors?.join(' x ') ?? '',
          );
    } else {
      final parts = text
          .split(RegExp(r'[,\s]+'))
          .where((s) => s.isNotEmpty)
          .toList();
      final numbers = parts
          .map((e) => int.tryParse(e))
          .whereType<int>()
          .toList();
      if (numbers.isEmpty) return;

      final res = FactorsCalculator.calculateMulti(numbers);
      setState(() => _result = res);

      ref
          .read(historyServiceProvider)
          .logCalculation(
            moduleName: 'GCD / LCM',
            category: 'Math & Academic',
            inputs: numbers.join(', '),
            result: 'GCD: ${res.gcd}, LCM: ${res.lcm}',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isFactorizationMode ? 'Prime Factorization' : 'GCD & LCM Calculator',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFactorizationMode
                  ? Icons.format_list_numbered
                  : Icons.functions,
            ),
            tooltip: 'Toggle Mode',
            onPressed: () {
              setState(() {
                _isFactorizationMode = !_isFactorizationMode;
                _result = null;
                _inputController.clear();
              });
            },
          ),
        ],
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
                GlassTextField(
                  controller: _inputController,
                  hintText: _isFactorizationMode
                      ? 'Enter a single number'
                      : 'Enter numbers separated by comma/space',
                  keyboardType: TextInputType.text,
                ),
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

  Widget _buildResultView(ThemeData theme) {
    if (_isFactorizationMode) {
      final factors = _result!.primeFactors ?? [];
      return GlassContainer(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Prime Factors',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              factors.isEmpty ? 'None' : factors.join(' × '),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return GlassContainer(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildResultRow(
              'GCD (Greatest Common Divisor)',
              _result!.gcd.toString(),
              theme,
            ),
            const Divider(),
            _buildResultRow(
              'LCM (Least Common Multiple)',
              _result!.lcm.toString(),
              theme,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildResultRow(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
