import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/probability_calculator.dart';

class ProbabilityScreen extends ConsumerStatefulWidget {
  const ProbabilityScreen({super.key});

  @override
  ConsumerState<ProbabilityScreen> createState() => _ProbabilityScreenState();
}

class _ProbabilityScreenState extends ConsumerState<ProbabilityScreen> {
  String _mode = 'Permutations (nPr)';

  final TextEditingController _nController = TextEditingController();
  final TextEditingController _rController = TextEditingController();
  final TextEditingController _pController =
      TextEditingController(); // For Binomial (p) or Poisson (lambda)

  String? _result;
  String? _error;

  @override
  void dispose() {
    _nController.dispose();
    _rController.dispose();
    _pController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _error = null);
    try {
      double res = 0;
      int n = int.tryParse(_nController.text) ?? 0;
      int r = int.tryParse(_rController.text) ?? 0; // Or k

      switch (_mode) {
        case 'Permutations (nPr)':
          res = ProbabilityCalculator.permutations(n, r);
          break;
        case 'Combinations (nCr)':
          res = ProbabilityCalculator.combinations(n, r);
          break;
        case 'Binomial Distribution':
          double p = double.tryParse(_pController.text) ?? 0.0;
          res = ProbabilityCalculator.binomial(
            n,
            r,
            p,
          ); // n=trials, r=k, p=prob
          break;
        case 'Poisson Distribution':
          double lambda = double.tryParse(_pController.text) ?? 0.0;
          res = ProbabilityCalculator.poisson(lambda, r); // r=k
          break;
      }

      setState(() => _result = res.toStringAsFixed(6));

      ref
          .read(historyServiceProvider)
          .logCalculation(
            moduleName: 'Probability',
            category: 'Math & Academic',
            inputs: 'Op: $_mode',
            result: res.toStringAsFixed(6),
          );
    } catch (e) {
      setState(() => _error = "Invalid inputs.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool needsP =
        _mode == 'Binomial Distribution' || _mode == 'Poisson Distribution';
    bool isPoisson = _mode == 'Poisson Distribution';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Probability Calculator'),
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
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: const [
                      'Permutations (nPr)',
                      'Combinations (nCr)',
                      'Binomial Distribution',
                      'Poisson Distribution',
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

                if (!isPoisson) ...[
                  GlassTextField(
                    controller: _nController,
                    hintText: _mode.contains('Binomial')
                        ? 'n (Trials)'
                        : 'n (Total Items)',
                  ),
                  const SizedBox(height: 16),
                ],

                GlassTextField(
                  controller: _rController,
                  hintText: (_mode.contains('Binomial') || isPoisson)
                      ? 'k (Successes)'
                      : 'r (Selected Items)',
                ),

                if (needsP) ...[
                  const SizedBox(height: 16),
                  GlassTextField(
                    controller: _pController,
                    hintText: isPoisson
                        ? 'λ (Average Rate)'
                        : 'p (Probability of Success, 0 to 1)',
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
                        Text(
                          _result!,
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
