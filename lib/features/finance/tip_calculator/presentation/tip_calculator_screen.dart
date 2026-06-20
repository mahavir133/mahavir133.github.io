import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/tip_calculator.dart';

class TipCalculatorScreen extends ConsumerStatefulWidget {
  const TipCalculatorScreen({super.key});

  @override
  ConsumerState<TipCalculatorScreen> createState() => _TipCalculatorScreenState();
}

class _TipCalculatorScreenState extends ConsumerState<TipCalculatorScreen> {
  final TextEditingController _billController = TextEditingController();
  final TextEditingController _tipController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController(text: '1');
  
  TipResult? _result;

  @override
  void dispose() {
    _billController.dispose();
    _tipController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  void _calculate() {
    final bill = double.tryParse(_billController.text) ?? 0;
    final tip = double.tryParse(_tipController.text) ?? 0;
    final people = int.tryParse(_peopleController.text) ?? 1;

    if (bill <= 0 || people <= 0) return;

    final result = TipCalculator.calculate(
      billAmount: bill,
      tipPercentage: tip,
      numberOfPeople: people,
    );

    setState(() {
      _result = result;
    });

    ref.read(historyServiceProvider).logCalculation(
      moduleName: 'Tip & Split',
      category: 'Finance & Business',
      inputs: 'Bill: $bill, Tip: $tip%, People: $people',
      result: 'Total: ${result.totalBill.toStringAsFixed(2)}, Per Person: ${result.perPersonAmount.toStringAsFixed(2)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tip & Bill Splitter'),
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
                  controller: _billController,
                  hintText: 'Bill Amount',
                  prefixIcon: const Icon(Icons.receipt),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _tipController,
                  hintText: 'Tip Percentage (%)',
                  prefixIcon: const Icon(Icons.percent),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _peopleController,
                  hintText: 'Number of People',
                  prefixIcon: const Icon(Icons.people),
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

  Widget _buildResultView(BuildContext context, TipResult result) {
    final theme = Theme.of(context);

    return GlassContainer(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Per Person Amount',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            result.perPersonAmount.toStringAsFixed(2),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const Divider(height: 32),
          _buildResultRow('Total Tip', result.tipAmount.toStringAsFixed(2)),
          const SizedBox(height: 8),
          _buildResultRow('Total Bill', result.totalBill.toStringAsFixed(2)),
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
