import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../core/db/history_service.dart';
import '../utils/paint_logic.dart';

class PaintScreen extends ConsumerStatefulWidget {
  const PaintScreen({super.key});

  @override
  ConsumerState<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends ConsumerState<PaintScreen> {
  bool _isMetric = true;

  final TextEditingController _roomLength = TextEditingController();
  final TextEditingController _roomWidth = TextEditingController();
  final TextEditingController _roomHeight = TextEditingController();
  final TextEditingController _numDoors = TextEditingController(text: '1');
  final TextEditingController _numWindows = TextEditingController(text: '1');
  final TextEditingController _coats = TextEditingController(text: '2');
  final TextEditingController _coverage = TextEditingController(
    text: '10',
  ); // 10 m2/L

  PaintResult? _result;

  @override
  void dispose() {
    _roomLength.dispose();
    _roomWidth.dispose();
    _roomHeight.dispose();
    _numDoors.dispose();
    _numWindows.dispose();
    _coats.dispose();
    _coverage.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _result = PaintLogic.calculate(
        roomLength: double.tryParse(_roomLength.text) ?? 0,
        roomWidth: double.tryParse(_roomWidth.text) ?? 0,
        roomHeight: double.tryParse(_roomHeight.text) ?? 0,
        numDoors: int.tryParse(_numDoors.text) ?? 0,
        numWindows: int.tryParse(_numWindows.text) ?? 0,
        coats: int.tryParse(_coats.text) ?? 1,
        coveragePerUnit:
            double.tryParse(_coverage.text) ?? (_isMetric ? 10 : 350),
        isMetric: _isMetric,
      );
    });

    ref
        .read(historyServiceProvider)
        .logCalculation(
          moduleName: 'Paint',
          category: 'Construction',
          inputs: 'Room: ${_roomLength.text}x${_roomWidth.text}',
          result:
              '${_isMetric ? _result!.totalPaintLiters.toStringAsFixed(1) + " L" : _result!.totalPaintGallons.toStringAsFixed(1) + " Gal"}',
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = _isMetric ? 'm' : 'ft';
    final areaUnit = _isMetric ? 'm²' : 'sq ft';
    final coverageLabel = _isMetric
        ? 'Coverage (m²/Liter)'
        : 'Coverage (sq ft/Gallon)';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paint Calculator'),
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
                    if (val) {
                      _coverage.text = '10'; // 10 m2/L
                    } else {
                      _coverage.text = '350'; // 350 sqft/Gal
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
                _buildSectionHeader('Room Dimensions'),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _roomLength,
                        hintText: 'Length ($unit)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassTextField(
                        controller: _roomWidth,
                        hintText: 'Width ($unit)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _roomHeight,
                  hintText: 'Height ($unit)',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Openings (Standard Size Deductions)'),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _numDoors,
                        hintText: 'Number of Doors',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassTextField(
                        controller: _numWindows,
                        hintText: 'Number of Windows',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Paint Details'),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _coats,
                        hintText: 'Number of Coats',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassTextField(
                        controller: _coverage,
                        hintText: coverageLabel,
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
                          'Net Wall Area (1 Coat)',
                          '${_result!.netWallArea.toStringAsFixed(2)} $areaUnit',
                        ),
                        const SizedBox(height: 16),
                        _buildResultRow(
                          'Liters Required',
                          '${_result!.totalPaintLiters.toStringAsFixed(2)} L',
                          isHighlight: _isMetric,
                        ),
                        _buildResultRow(
                          'Gallons Required',
                          '${_result!.totalPaintGallons.toStringAsFixed(2)} Gal',
                          isHighlight: !_isMetric,
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
