import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/emi_calculator.dart';

class EmiCalculatorScreen extends ConsumerStatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  ConsumerState<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends ConsumerState<EmiCalculatorScreen> {
  final TextEditingController _principalController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _tenureController = TextEditingController();
  
  bool _isTenureInYears = true;
  EmiResult? _result;

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  void _calculateEmi() {
    final principal = double.tryParse(_principalController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    final tenure = int.tryParse(_tenureController.text) ?? 0;

    if (principal <= 0 || tenure <= 0) return;

    final tenureMonths = _isTenureInYears ? tenure * 12 : tenure;

    final result = EmiCalculator.calculate(
      principal: principal,
      annualInterestRate: rate,
      tenureMonths: tenureMonths,
    );

    setState(() {
      _result = result;
    });

    // Log to history
    ref.read(historyServiceProvider).logCalculation(
      moduleName: 'EMI / Loan Calculator',
      category: 'Finance & Business',
      inputs: 'P: $principal, R: $rate%, T: $tenure ${_isTenureInYears ? 'Yrs' : 'Mos'}',
      result: 'EMI: ${result.emi.toStringAsFixed(2)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMI Calculator'),
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
                GlassTextField(
                  controller: _principalController,
                  hintText: 'Principal Amount',
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _rateController,
                  hintText: 'Interest Rate (%)',
                  prefixIcon: const Icon(Icons.percent),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: GlassTextField(
                        controller: _tenureController,
                        hintText: 'Tenure',
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: GlassContainer(
                        height: 56,
                        padding: EdgeInsets.zero,
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isTenureInYears = true),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _isTenureInYears 
                                      ? theme.colorScheme.primary.withOpacity(0.3)
                                      : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('Yrs'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isTenureInYears = false),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !_isTenureInYears 
                                      ? theme.colorScheme.primary.withOpacity(0.3)
                                      : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('Mos'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GlassButton(
                  onPressed: _calculateEmi,
                  child: const Text('Calculate'),
                ),
                const SizedBox(height: 24),
                if (_result != null) _buildResultView(context, _result!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultView(BuildContext context, EmiResult result) {
    final theme = Theme.of(context);
    final principal = double.tryParse(_principalController.text) ?? 0;

    return GlassContainer(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Monthly EMI',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            result.emi.toStringAsFixed(2),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const Divider(height: 32),
          _buildResultRow('Total Interest', result.totalInterest.toStringAsFixed(2)),
          const SizedBox(height: 8),
          _buildResultRow('Total Payment', result.totalPayment.toStringAsFixed(2)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Colors.blueAccent,
                    value: principal,
                    title: 'Principal',
                    radius: 40,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    color: Colors.redAccent,
                    value: result.totalInterest,
                    title: 'Interest',
                    radius: 40,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
