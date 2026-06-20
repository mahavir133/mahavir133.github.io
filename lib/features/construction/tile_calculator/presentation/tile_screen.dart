import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../core/db/history_service.dart';
import '../utils/tile_logic.dart';

class TileScreen extends ConsumerStatefulWidget {
  const TileScreen({super.key});

  @override
  ConsumerState<TileScreen> createState() => _TileScreenState();
}

class _TileScreenState extends ConsumerState<TileScreen> {
  bool _isMetric = true;

  final TextEditingController _roomLength = TextEditingController();
  final TextEditingController _roomWidth = TextEditingController();
  final TextEditingController _tileLength = TextEditingController(
    text: '300',
  ); // mm default
  final TextEditingController _tileWidth = TextEditingController(text: '300');
  final TextEditingController _groutWidth = TextEditingController(text: '3');
  final TextEditingController _wastagePercent = TextEditingController(
    text: '10',
  );
  final TextEditingController _costPerTile = TextEditingController();

  TileResult? _result;

  @override
  void dispose() {
    _roomLength.dispose();
    _roomWidth.dispose();
    _tileLength.dispose();
    _tileWidth.dispose();
    _groutWidth.dispose();
    _wastagePercent.dispose();
    _costPerTile.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _result = TileLogic.calculate(
        roomLength: double.tryParse(_roomLength.text) ?? 0,
        roomWidth: double.tryParse(_roomWidth.text) ?? 0,
        tileLength: double.tryParse(_tileLength.text) ?? 0,
        tileWidth: double.tryParse(_tileWidth.text) ?? 0,
        groutWidth: double.tryParse(_groutWidth.text) ?? 0,
        wastagePercent: double.tryParse(_wastagePercent.text) ?? 0,
        costPerTile: double.tryParse(_costPerTile.text) ?? 0,
        isMetric: _isMetric,
      );
    });

    ref
        .read(historyServiceProvider)
        .logCalculation(
          moduleName: 'Tile/Flooring',
          category: 'Construction',
          inputs: 'Area: ${_result?.roomArea.toStringAsFixed(1)}',
          result: '${_result?.totalTiles} Tiles',
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = _isMetric ? 'm' : 'ft';
    final areaUnit = _isMetric ? 'm²' : 'sq ft';
    final tileUnit = _isMetric ? 'mm' : 'in';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tile & Flooring Calculator'),
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
                      _tileLength.text = '300';
                      _tileWidth.text = '300';
                      _groutWidth.text = '3';
                    } else {
                      _tileLength.text = '12';
                      _tileWidth.text = '12';
                      _groutWidth.text = '0.125';
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
                _buildSectionHeader('Room Size'),
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

                const SizedBox(height: 24),
                _buildSectionHeader('Tile Size'),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _tileLength,
                        hintText: 'Length ($tileUnit)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassTextField(
                        controller: _tileWidth,
                        hintText: 'Width ($tileUnit)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Details & Cost'),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _groutWidth,
                        hintText: 'Grout Gap ($tileUnit)',
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
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _costPerTile,
                  hintText: 'Cost per Tile (Optional)',
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
                          'Results',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildResultRow(
                          'Room Area',
                          '${_result!.roomArea.toStringAsFixed(2)} $areaUnit',
                        ),
                        const SizedBox(height: 16),
                        _buildResultRow(
                          'Total Tiles Required',
                          '${_result!.totalTiles}',
                          isHighlight: true,
                        ),
                        if (_result!.estimatedCost > 0)
                          _buildResultRow(
                            'Estimated Cost',
                            '${_result!.estimatedCost.toStringAsFixed(2)}',
                            isHighlight: true,
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
