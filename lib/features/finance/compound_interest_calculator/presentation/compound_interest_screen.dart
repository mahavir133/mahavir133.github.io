import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/compound_interest_calculator.dart';

class CompoundInterestScreen extends ConsumerStatefulWidget {
  const CompoundInterestScreen({super.key});

  @override
  ConsumerState<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends ConsumerState<CompoundInterestScreen> {
  final TextEditingController _principalController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  
  int _compoundingFrequency = 12; // Default Monthly
  CompoundResult? _result;

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _calculate() {
    final principal = double.tryParse(_principalController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    final time = double.tryParse(_timeController.text) ?? 0;

    if (principal <= 0 || time <= 0) return;

    final result = CompoundInterestCalculator.calculate(
      principal: principal,
      annualRate: rate,
      timeInYears: time,
      compoundingFrequencyPerYear: _compoundingFrequency,
    );

    setState(() {
      _result = result;
    });

    ref.read(historyServiceProvider).logCalculation(
      moduleName: 'Compound Interest',
      category: 'Finance & Business',
      inputs: 'P: $principal, R: $rate%, T: $time Yrs, Freq: $_compoundingFrequency/yr',
      result: 'Total: ${result.totalAmount.toStringAsFixed(2)}, Interest: ${result.totalInterest.toStringAsFixed(2)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compound Interest'),
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
                  hintText: 'Annual Interest Rate (%)',
                  prefixIcon: const Icon(Icons.percent),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _timeController,
                  hintText: 'Time Period (Years)',
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                const SizedBox(height: 16),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<int>(
                    options: const [1, 2, 4, 12, 365],
                    initialValue: _compoundingFrequency,
                    displayStringForOption: (val) {
                      if (val == 1) return 'Annually (1/yr)';
                      if (val == 2) return 'Semi-Annually (2/yr)';
                      if (val == 4) return 'Quarterly (4/yr)';
                      if (val == 12) return 'Monthly (12/yr)';
                      return 'Daily (365/yr)';
                    },
                    onChanged: (val) {
                      if (val != null) setState(() => _compoundingFrequency = val);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                GlassButton(
                  onPressed: _calculate,
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

  Widget _buildResultView(BuildContext context, CompoundResult result) {
    final theme = Theme.of(context);

    return GlassContainer(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Total Amount',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            result.totalAmount.toStringAsFixed(2),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const Divider(height: 32),
          _buildResultRow('Total Interest', result.totalInterest.toStringAsFixed(2)),
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
