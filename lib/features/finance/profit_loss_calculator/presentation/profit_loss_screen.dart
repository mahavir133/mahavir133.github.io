import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/profit_loss_calculator.dart';

class ProfitLossScreen extends ConsumerStatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  ConsumerState<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends ConsumerState<ProfitLossScreen> {
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _sellingController = TextEditingController();
  
  ProfitLossResult? _result;

  @override
  void dispose() {
    _costController.dispose();
    _sellingController.dispose();
    super.dispose();
  }

  void _calculate() {
    final cp = double.tryParse(_costController.text) ?? 0;
    final sp = double.tryParse(_sellingController.text) ?? 0;

    if (cp <= 0) return;

    final result = ProfitLossCalculator.calculate(
      costPrice: cp,
      sellingPrice: sp,
    );

    setState(() {
      _result = result;
    });

    ref.read(historyServiceProvider).logCalculation(
      moduleName: 'Profit & Loss',
      category: 'Finance & Business',
      inputs: 'CP: $cp, SP: $sp',
      result: '${result.isProfit ? 'Profit' : 'Loss'}: ${result.profitOrLoss.toStringAsFixed(2)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit & Loss'),
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
                  controller: _costController,
                  hintText: 'Cost Price (CP)',
                  prefixIcon: const Icon(Icons.shopping_cart),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _sellingController,
                  hintText: 'Selling Price (SP)',
                  prefixIcon: const Icon(Icons.sell),
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

  Widget _buildResultView(BuildContext context, ProfitLossResult result) {
    final theme = Theme.of(context);
    final color = result.isProfit ? Colors.greenAccent : Colors.redAccent;
    final title = result.isProfit ? 'Profit' : 'Loss';

    return GlassContainer(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            result.profitOrLoss.toStringAsFixed(2),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Divider(height: 32),
          _buildResultRow('Margin', '${result.marginPercentage.toStringAsFixed(2)}%'),
          const SizedBox(height: 8),
          _buildResultRow('Markup', '${result.markupPercentage.toStringAsFixed(2)}%'),
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
