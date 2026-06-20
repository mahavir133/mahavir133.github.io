import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/salary_calculator.dart';

class SalaryCalculatorScreen extends ConsumerStatefulWidget {
  const SalaryCalculatorScreen({super.key});

  @override
  ConsumerState<SalaryCalculatorScreen> createState() => _SalaryCalculatorScreenState();
}

class _SalaryCalculatorScreenState extends ConsumerState<SalaryCalculatorScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController(text: '40');
  
  SalaryFrequency _frequency = SalaryFrequency.yearly;
  SalaryResult? _result;

  @override
  void dispose() {
    _amountController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _calculate() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final hours = double.tryParse(_hoursController.text) ?? 40;

    if (amount <= 0 || hours <= 0) return;

    final result = SalaryCalculator.calculate(
      amount: amount,
      frequency: _frequency,
      hoursPerWeek: hours,
    );

    setState(() {
      _result = result;
    });

    ref.read(historyServiceProvider).logCalculation(
      moduleName: 'Salary Calculator',
      category: 'Finance & Business',
      inputs: 'Amt: $amount, Freq: ${_frequency.name}',
      result: 'Yearly: ${result.yearly.toStringAsFixed(2)}, Monthly: ${result.monthly.toStringAsFixed(2)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Calculator'),
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
                  controller: _amountController,
                  hintText: 'Amount',
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                ),
                const SizedBox(height: 16),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GlassAutocomplete<String>(
                          options: const ['Hourly', 'Daily', 'Weekly', 'Bi-Weekly', 'Monthly', 'Yearly'],
                          initialValue: _frequency.name,
                          onChanged: (val) {
                            if (val != null) setState(() => _frequency = SalaryFrequency.values.firstWhere((e) => e.name == val));
                          },
                        ),
                    ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _hoursController,
                  hintText: 'Hours per week',
                  prefixIcon: const Icon(Icons.timer),
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

  Widget _buildResultView(BuildContext context, SalaryResult result) {
    return GlassContainer(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResultRow('Yearly', result.yearly.toStringAsFixed(2)),
          const Divider(),
          _buildResultRow('Monthly', result.monthly.toStringAsFixed(2)),
          const Divider(),
          _buildResultRow('Bi-Weekly', result.biWeekly.toStringAsFixed(2)),
          const Divider(),
          _buildResultRow('Weekly', result.weekly.toStringAsFixed(2)),
          const Divider(),
          _buildResultRow('Daily', result.daily.toStringAsFixed(2)),
          const Divider(),
          _buildResultRow('Hourly', result.hourly.toStringAsFixed(2)),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
