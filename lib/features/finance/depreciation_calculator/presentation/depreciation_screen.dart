import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/depreciation_calculator.dart';

class DepreciationScreen extends ConsumerStatefulWidget {
  const DepreciationScreen({super.key});

  @override
  ConsumerState<DepreciationScreen> createState() => _DepreciationScreenState();
}

class _DepreciationScreenState extends ConsumerState<DepreciationScreen> {
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _salvageController = TextEditingController();
  final TextEditingController _lifeController = TextEditingController();
  
  DepreciationResult? _result;

  @override
  void dispose() {
    _costController.dispose();
    _salvageController.dispose();
    _lifeController.dispose();
    super.dispose();
  }

  void _calculate() {
    final cost = double.tryParse(_costController.text) ?? 0;
    final salvage = double.tryParse(_salvageController.text) ?? 0;
    final life = int.tryParse(_lifeController.text) ?? 0;

    if (cost <= 0 || life <= 0) return;

    final result = DepreciationCalculator.calculateStraightLine(
      assetCost: cost,
      salvageValue: salvage,
      usefulLife: life,
    );

    setState(() {
      _result = result;
    });

    ref.read(historyServiceProvider).logCalculation(
      moduleName: 'Depreciation (Straight Line)',
      category: 'Finance & Business',
      inputs: 'Cost: $cost, Salvage: $salvage, Life: $life yrs',
      result: 'Total Depr: ${result.totalDepreciation.toStringAsFixed(2)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depreciation (Straight Line)'),
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
                  hintText: 'Asset Cost',
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _salvageController,
                  hintText: 'Salvage Value (End Value)',
                  prefixIcon: const Icon(Icons.recycling),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _lifeController,
                  hintText: 'Useful Life (Years)',
                  prefixIcon: const Icon(Icons.timelapse),
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

  Widget _buildResultView(BuildContext context, DepreciationResult result) {
    final theme = Theme.of(context);

    return GlassContainer(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Total Depreciation',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            result.totalDepreciation.toStringAsFixed(2),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const Divider(height: 32),
          const Text('Annual Breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...result.table.map((row) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Year ${row.year}'),
                Text(
                  'Book Val: ${row.bookValue.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
