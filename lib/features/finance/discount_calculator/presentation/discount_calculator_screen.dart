import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/discount_calculator.dart';

class DiscountCalculatorScreen extends ConsumerStatefulWidget {
  const DiscountCalculatorScreen({super.key});

  @override
  ConsumerState<DiscountCalculatorScreen> createState() => _DiscountCalculatorScreenState();
}

class _DiscountCalculatorScreenState extends ConsumerState<DiscountCalculatorScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discount1Controller = TextEditingController();
  final TextEditingController _discount2Controller = TextEditingController();
  
  DiscountResult? _result;

  @override
  void dispose() {
    _priceController.dispose();
    _discount1Controller.dispose();
    _discount2Controller.dispose();
    super.dispose();
  }

  void _calculate() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final d1 = double.tryParse(_discount1Controller.text) ?? 0;
    final d2 = double.tryParse(_discount2Controller.text) ?? 0;

    if (price <= 0) return;

    final result = DiscountCalculator.calculate(
      originalPrice: price,
      discount1: d1,
      discount2: d2,
    );

    setState(() {
      _result = result;
    });

    ref.read(historyServiceProvider).logCalculation(
      moduleName: 'Discount Calculator',
      category: 'Finance & Business',
      inputs: 'Price: $price, D1: $d1%, D2: $d2%',
      result: 'Final: ${result.finalPrice.toStringAsFixed(2)}, Savings: ${result.savings.toStringAsFixed(2)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discount Calculator'),
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
                  controller: _priceController,
                  hintText: 'Original Price',
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _discount1Controller,
                  hintText: 'Discount 1 (%)',
                  prefixIcon: const Icon(Icons.percent),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _discount2Controller,
                  hintText: 'Discount 2 (%) (Optional)',
                  prefixIcon: const Icon(Icons.percent),
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

  Widget _buildResultView(BuildContext context, DiscountResult result) {
    final theme = Theme.of(context);

    return GlassContainer(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Final Price',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            result.finalPrice.toStringAsFixed(2),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const Divider(height: 32),
          _buildResultRow('Total Savings', result.savings.toStringAsFixed(2)),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
      ],
    );
  }
}
