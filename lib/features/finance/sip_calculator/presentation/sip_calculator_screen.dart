import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/sip_calculator.dart';

class SipCalculatorScreen extends ConsumerStatefulWidget {
  const SipCalculatorScreen({super.key});

  @override
  ConsumerState<SipCalculatorScreen> createState() => _SipCalculatorScreenState();
}

class _SipCalculatorScreenState extends ConsumerState<SipCalculatorScreen> {
  final TextEditingController _investmentController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _tenureController = TextEditingController();
  
  SipResult? _result;

  @override
  void dispose() {
    _investmentController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  void _calculateSip() {
    final investment = double.tryParse(_investmentController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    final tenure = int.tryParse(_tenureController.text) ?? 0;

    if (investment <= 0 || tenure <= 0) return;

    final result = SipCalculator.calculateSip(
      monthlyInvestment: investment,
      annualReturnRate: rate,
      tenureYears: tenure,
    );

    setState(() {
      _result = result;
    });

    // Log to history
    ref.read(historyServiceProvider).logCalculation(
      moduleName: 'SIP Calculator',
      category: 'Finance & Business',
      inputs: 'Inv: $investment/mo, R: $rate%, T: $tenure Yrs',
      result: 'Total: ${result.totalValue.toStringAsFixed(0)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIP Calculator'),
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
                  controller: _investmentController,
                  hintText: 'Monthly Investment',
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _rateController,
                  hintText: 'Expected Return Rate (%)',
                  prefixIcon: const Icon(Icons.trending_up),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _tenureController,
                  hintText: 'Time Period (Years)',
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                const SizedBox(height: 24),
                GlassButton(
                  onPressed: _calculateSip,
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

  Widget _buildResultView(BuildContext context, SipResult result) {
    final theme = Theme.of(context);

    return GlassContainer(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Total Value',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            result.totalValue.toStringAsFixed(0),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const Divider(height: 32),
          _buildResultRow('Invested Amount', result.investedAmount.toStringAsFixed(0)),
          const SizedBox(height: 8),
          _buildResultRow('Estimated Returns', result.estimatedReturns.toStringAsFixed(0)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Colors.blueAccent,
                    value: result.investedAmount,
                    title: 'Invested',
                    radius: 40,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    color: Colors.greenAccent,
                    value: result.estimatedReturns,
                    title: 'Returns',
                    radius: 40,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
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
