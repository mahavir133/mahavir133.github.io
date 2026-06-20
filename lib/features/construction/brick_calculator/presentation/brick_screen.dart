import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../core/db/history_service.dart';
import '../utils/brick_logic.dart';

class BrickScreen extends ConsumerStatefulWidget {
  const BrickScreen({super.key});

  @override
  ConsumerState<BrickScreen> createState() => _BrickScreenState();
}

class _BrickScreenState extends ConsumerState<BrickScreen> {
  bool _isMetric = true;

  final TextEditingController _wallLength = TextEditingController();
  final TextEditingController _wallHeight = TextEditingController();
  final TextEditingController _openingsArea = TextEditingController(text: '0');

  final TextEditingController _brickLength = TextEditingController(text: '215');
  final TextEditingController _brickHeight = TextEditingController(text: '65');
  final TextEditingController _brickDepth = TextEditingController(
    text: '102.5',
  );

  final TextEditingController _mortarThickness = TextEditingController(
    text: '10',
  );
  final TextEditingController _wastagePercent = TextEditingController(
    text: '5',
  );

  BrickResult? _result;

  @override
  void dispose() {
    _wallLength.dispose();
    _wallHeight.dispose();
    _openingsArea.dispose();
    _brickLength.dispose();
    _brickHeight.dispose();
    _brickDepth.dispose();
    _mortarThickness.dispose();
    _wastagePercent.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _result = BrickLogic.calculate(
        wallLength: double.tryParse(_wallLength.text) ?? 0,
        wallHeight: double.tryParse(_wallHeight.text) ?? 0,
        brickLength: double.tryParse(_brickLength.text) ?? 0,
        brickHeight: double.tryParse(_brickHeight.text) ?? 0,
        brickDepth: double.tryParse(_brickDepth.text) ?? 0,
        mortarThickness: double.tryParse(_mortarThickness.text) ?? 0,
        openingsArea: double.tryParse(_openingsArea.text) ?? 0,
        wastagePercent: double.tryParse(_wastagePercent.text) ?? 0,
        isMetric: _isMetric,
      );
    });

    ref
        .read(historyServiceProvider)
        .logCalculation(
          moduleName: 'Brick/Block',
          category: 'Construction',
          inputs: 'Wall: ${_wallLength.text}x${_wallHeight.text}',
          result: '${_result!.totalBricks} Bricks',
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brick/Block Calculator'),
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
                    // Reset defaults based on unit
                    if (val) {
                      _brickLength.text = '215'; // Standard UK/Metric mm
                      _brickHeight.text = '65';
                      _brickDepth.text = '102.5';
                      _mortarThickness.text = '10';
                    } else {
                      _brickLength.text = '8'; // Standard US modular inches
                      _brickHeight.text = '2.25';
                      _brickDepth.text = '3.625';
                      _mortarThickness.text = '0.375';
                    }
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
                _buildSectionHeader('Wall Dimensions'),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _wallLength,
                        hintText: 'Length (${_isMetric ? "m" : "ft"})',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassTextField(
                        controller: _wallHeight,
                        hintText: 'Height (${_isMetric ? "m" : "ft"})',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _openingsArea,
                  hintText: 'Openings Area (${_isMetric ? "m²" : "sq ft"})',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Brick Dimensions'),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _brickLength,
                        hintText: 'L (${_isMetric ? "mm" : "in"})',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassTextField(
                        controller: _brickHeight,
                        hintText: 'H (${_isMetric ? "mm" : "in"})',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassTextField(
                        controller: _brickDepth,
                        hintText: 'D (${_isMetric ? "mm" : "in"})',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Mortar & Wastage'),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _mortarThickness,
                        hintText: 'Mortar (${_isMetric ? "mm" : "in"})',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassTextField(
                        controller: _wastagePercent,
                        hintText: 'Wastage (%)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
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
                          'Results',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildResultRow(
                          'Total Bricks Needed',
                          '${_result!.totalBricks}',
                          isHighlight: true,
                        ),
                        _buildResultRow(
                          'Net Wall Area',
                          '${_result!.wallArea.toStringAsFixed(2)} ${_isMetric ? "m²" : "sq ft"}',
                        ),
                        _buildResultRow(
                          'Mortar Volume',
                          '${_result!.mortarVolumeCubicMeters.toStringAsFixed(3)} m³ / ${_result!.mortarVolumeCubicFeet.toStringAsFixed(2)} ft³',
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
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
