import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../core/db/history_service.dart';
import '../utils/roof_logic.dart';

class RoofScreen extends ConsumerStatefulWidget {
  const RoofScreen({super.key});

  @override
  ConsumerState<RoofScreen> createState() => _RoofScreenState();
}

class _RoofScreenState extends ConsumerState<RoofScreen> {
  bool _isMetric = false; // Roofs are very commonly imperial (pitch 4:12 etc)

  final TextEditingController _baseLength = TextEditingController();
  final TextEditingController _baseWidth = TextEditingController();
  final TextEditingController _overhang = TextEditingController();
  final TextEditingController _pitch = TextEditingController();

  RoofResult? _result;

  @override
  void dispose() {
    _baseLength.dispose();
    _baseWidth.dispose();
    _overhang.dispose();
    _pitch.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _result = RoofLogic.calculate(
        baseLength: double.tryParse(_baseLength.text) ?? 0,
        baseWidth: double.tryParse(_baseWidth.text) ?? 0,
        overhang: double.tryParse(_overhang.text) ?? 0,
        pitch: double.tryParse(_pitch.text) ?? 0,
        isMetric: _isMetric,
      );
    });

    ref
        .read(historyServiceProvider)
        .logCalculation(
          moduleName: 'Roof',
          category: 'Construction',
          inputs: '${_baseLength.text}x${_baseWidth.text}',
          result: 'Area: ${_result!.roofArea.toStringAsFixed(1)}',
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = _isMetric ? 'm' : 'ft';
    final areaUnit = _isMetric ? 'm²' : 'sq ft';
    final pitchLabel = _isMetric ? 'Pitch (Degrees)' : 'Pitch (X in 12)';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roof Calculator (Gable)'),
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
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _baseLength,
                        hintText: 'Base Length ($unit)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassTextField(
                        controller: _baseWidth,
                        hintText: 'Base Width ($unit)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _overhang,
                  hintText: 'Overhang ($unit)',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _pitch,
                  hintText: pitchLabel,
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
                          'Roof Analysis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildResultRow(
                          'Roof Area',
                          '${_result!.roofArea.toStringAsFixed(2)} $areaUnit',
                          isHighlight: true,
                        ),
                        _buildResultRow(
                          'Rafter Length',
                          '${_result!.rafterLength.toStringAsFixed(2)} $unit',
                        ),
                        _buildResultRow(
                          'Ridge Length',
                          '${_result!.ridgeLength.toStringAsFixed(2)} $unit',
                        ),
                        const SizedBox(height: 16),
                        _buildResultRow(
                          'Shingle Bundles Needed',
                          '${_result!.shinglesNeeded} (inc. 10% waste)',
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
              fontSize: isHighlight ? 20 : 16,
              color: isHighlight ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
