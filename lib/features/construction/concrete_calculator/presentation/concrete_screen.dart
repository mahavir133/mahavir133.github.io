import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../core/db/history_service.dart';
import '../utils/concrete_logic.dart';

class ConcreteScreen extends ConsumerStatefulWidget {
  const ConcreteScreen({super.key});

  @override
  ConsumerState<ConcreteScreen> createState() => _ConcreteScreenState();
}

class _ConcreteScreenState extends ConsumerState<ConcreteScreen> {
  bool _isMetric = true;
  ConcreteShape _selectedShape = ConcreteShape.slab;
  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController _wastageController = TextEditingController(
    text: '5',
  ); // 5% default

  ConcreteResult? _result;

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    for (var param in ConcreteLogic.getParamsForShape(_selectedShape)) {
      _controllers[param] = TextEditingController();
    }
    _result = null;
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    _wastageController.dispose();
    super.dispose();
  }

  String _formatShapeName(ConcreteShape type) {
    switch (type) {
      case ConcreteShape.slab:
        return 'Slab';
      case ConcreteShape.columnRound:
        return 'Round Column';
      case ConcreteShape.columnSquare:
        return 'Square Column';
      case ConcreteShape.footing:
        return 'Footing';
      case ConcreteShape.stairs:
        return 'Stairs';
    }
  }

  String _getUnitLabel(String param) {
    if (param == 'steps') return 'count';
    return _isMetric ? 'meters' : 'feet';
  }

  void _calculate() {
    final params = <String, double>{};
    for (var entry in _controllers.entries) {
      params[entry.key] = double.tryParse(entry.value.text) ?? 0.0;
    }
    final wastage = double.tryParse(_wastageController.text) ?? 0.0;

    setState(() {
      _result = ConcreteLogic.calculate(
        shape: _selectedShape,
        params: params,
        isMetric: _isMetric,
        wastagePercent: wastage,
      );
    });

    ref
        .read(historyServiceProvider)
        .logCalculation(
          moduleName: 'Concrete',
          category: 'Construction',
          inputs: '${_formatShapeName(_selectedShape)} | Wastage: $wastage%',
          result: '${_result!.volumeCubicMeters.toStringAsFixed(2)} m³',
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Concrete Calculator'),
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
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<ConcreteShape>(
                    options: ConcreteShape.values,
                    initialValue: _selectedShape,
                    displayStringForOption: _formatShapeName,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedShape = val;
                          _setupControllers();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                ..._controllers.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GlassTextField(
                      controller: entry.value,
                      hintText:
                          '${entry.key[0].toUpperCase()}${entry.key.substring(1)} (${_getUnitLabel(entry.key)})',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  );
                }),

                GlassTextField(
                  controller: _wastageController,
                  hintText: 'Wastage (%)',
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
                          'Required Volume',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildResultRow(
                          'Cubic Meters',
                          '${_result!.volumeCubicMeters.toStringAsFixed(3)} m³',
                        ),
                        _buildResultRow(
                          'Cubic Yards',
                          '${_result!.volumeCubicYards.toStringAsFixed(3)} yd³',
                        ),
                        _buildResultRow(
                          'Cubic Feet',
                          '${_result!.volumeCubicFeet.toStringAsFixed(3)} ft³',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Premixed Bags',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildResultRow('60 lb bags', '${_result!.bags60lb}'),
                        _buildResultRow('80 lb bags', '${_result!.bags80lb}'),
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

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
