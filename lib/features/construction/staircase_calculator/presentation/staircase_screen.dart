import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../core/db/history_service.dart';
import '../utils/staircase_logic.dart';

class StaircaseScreen extends ConsumerStatefulWidget {
  const StaircaseScreen({super.key});

  @override
  ConsumerState<StaircaseScreen> createState() => _StaircaseScreenState();
}

class _StaircaseScreenState extends ConsumerState<StaircaseScreen> {
  bool _isMetric = true;

  final TextEditingController _totalRise = TextEditingController();
  final TextEditingController _targetTread =
      TextEditingController(); // Optional

  StaircaseResult? _result;

  @override
  void dispose() {
    _totalRise.dispose();
    _targetTread.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _result = StaircaseLogic.calculate(
        totalRise: double.tryParse(_totalRise.text) ?? 0,
        targetTread: double.tryParse(_targetTread.text) ?? 0,
        isMetric: _isMetric,
      );
    });

    ref
        .read(historyServiceProvider)
        .logCalculation(
          moduleName: 'Staircase',
          category: 'Construction',
          inputs: 'Rise: ${_totalRise.text}',
          result: '${_result!.numberOfSteps} Steps',
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = _isMetric ? 'm' : 'in';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staircase Calculator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Row(
            children: [
              const Text('Imperial'),
              Switch(
                value: _isMetric,
                onChanged: (val) {
                  setState(() {
                    _isMetric = val;
                    // Auto-convert values if needed, or just clear
                    _result = null;
                  });
                },
                activeColor: theme.colorScheme.primary,
              ),
              const Text('Metric'),
              const SizedBox(width: 16),
            ],
          ),
        ],
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
                GlassTextField(
                  controller: _totalRise,
                  hintText: 'Total Rise / Height ($unit)',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _targetTread,
                  hintText: 'Target Tread Depth ($unit) [Optional]',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),

                const SizedBox(height: 24),
                GlassButton(
                  onPressed: _calculate,
                  child: const Text('Calculate'),
                ),

                if (_result != null) ...[
                  const SizedBox(height: 32),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Stair Layout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildResultRow(
                          'Number of Steps (Risers)',
                          '${_result!.numberOfSteps}',
                          isHighlight: true,
                        ),
                        _buildResultRow(
                          'Number of Treads',
                          '${_result!.numberOfSteps - 1}',
                        ),
                        const SizedBox(height: 16),
                        _buildResultRow(
                          'Riser Height',
                          '${_result!.riserHeight.toStringAsFixed(3)} $unit',
                        ),
                        _buildResultRow(
                          'Tread Run',
                          '${_result!.treadRun.toStringAsFixed(3)} $unit',
                        ),
                        const SizedBox(height: 16),
                        _buildResultRow(
                          'Total Run',
                          '${_result!.totalRun.toStringAsFixed(3)} $unit',
                        ),
                        _buildResultRow(
                          'Stringer Length',
                          '${_result!.stringerLength.toStringAsFixed(3)} $unit',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isHighlight ? 24 : 16,
              color: isHighlight ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
