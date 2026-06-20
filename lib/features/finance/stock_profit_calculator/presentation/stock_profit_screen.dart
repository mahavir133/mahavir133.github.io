import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/stock_profit_calculator.dart';

class StockProfitScreen extends ConsumerStatefulWidget {
  const StockProfitScreen({super.key});

  @override
  ConsumerState<StockProfitScreen> createState() => _StockProfitScreenState();
}

class _StockProfitScreenState extends ConsumerState<StockProfitScreen> {
  final TextEditingController _buyController = TextEditingController();
  final TextEditingController _sellController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _buyFeeController = TextEditingController(text: '0');
  final TextEditingController _sellFeeController = TextEditingController(text: '0');
  
  StockProfitResult? _result;

  @override
  void dispose() {
    _buyController.dispose();
    _sellController.dispose();
    _qtyController.dispose();
    _buyFeeController.dispose();
    _sellFeeController.dispose();
    super.dispose();
  }

  void _calculate() {
    final buy = double.tryParse(_buyController.text) ?? 0;
    final sell = double.tryParse(_sellController.text) ?? 0;
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final buyFee = double.tryParse(_buyFeeController.text) ?? 0;
    final sellFee = double.tryParse(_sellFeeController.text) ?? 0;

    if (qty <= 0 || buy <= 0) return;

    final result = StockProfitCalculator.calculate(
      buyPrice: buy,
      sellPrice: sell,
      quantity: qty,
      buyFees: buyFee,
      sellFees: sellFee,
    );

    setState(() {
      _result = result;
    });

    ref.read(historyServiceProvider).logCalculation(
      moduleName: 'Stock/Crypto Profit',
      category: 'Finance & Business',
      inputs: 'Buy: $buy, Sell: $sell, Qty: $qty',
      result: '${result.isProfit ? 'Profit' : 'Loss'}: ${result.profitOrLoss.toStringAsFixed(2)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock & Crypto Profit'),
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
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _buyController,
                        hintText: 'Buy Price',
                        prefixIcon: const Icon(Icons.account_balance_wallet),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassTextField(
                        controller: _sellController,
                        hintText: 'Sell Price',
                        prefixIcon: const Icon(Icons.account_balance_wallet),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _qtyController,
                  hintText: 'Quantity (Shares/Tokens)',
                  prefixIcon: const Icon(Icons.format_list_numbered),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _buyFeeController,
                        hintText: 'Buy Fees',
                        prefixIcon: const Icon(Icons.receipt),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassTextField(
                        controller: _sellFeeController,
                        hintText: 'Sell Fees',
                        prefixIcon: const Icon(Icons.receipt),
                      ),
                    ),
                  ],
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

  Widget _buildResultView(BuildContext context, StockProfitResult result) {
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
          _buildResultRow('Total Invested', result.totalInvested.toStringAsFixed(2)),
          const SizedBox(height: 8),
          _buildResultRow('Total Revenue', result.totalRevenue.toStringAsFixed(2)),
          const SizedBox(height: 8),
          _buildResultRow('ROI', '${result.roi.toStringAsFixed(2)}%'),
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
