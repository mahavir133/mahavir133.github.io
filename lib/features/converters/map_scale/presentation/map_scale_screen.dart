import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/map_scale_calculator.dart';

class MapScaleScreen extends ConsumerStatefulWidget {
  const MapScaleScreen({super.key});

  @override
  ConsumerState<MapScaleScreen> createState() => _MapScaleScreenState();
}

class _MapScaleScreenState extends ConsumerState<MapScaleScreen> {
  final _scaleController = TextEditingController(text: '50000');
  final _inputController = TextEditingController();

  String _mode = 'Map to Real-World'; // or 'Real-World to Map'

  String _mapUnit = 'cm';
  String _realUnit = 'km';

  double? _result;
  String? _error;

  @override
  void dispose() {
    _scaleController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _error = null);

    final scale = double.tryParse(_scaleController.text);
    final inputVal = double.tryParse(_inputController.text);

    if (scale == null || scale <= 0) {
      setState(
        () => _error = 'Please enter a valid scale ratio (e.g., 50000).',
      );
      return;
    }

    if (inputVal == null || inputVal < 0) {
      setState(() => _error = 'Please enter a valid input distance.');
      return;
    }

    try {
      double res;
      if (_mode == 'Map to Real-World') {
        res = MapScaleCalculator.mapToReal(
          inputVal,
          _mapUnit,
          scale,
          _realUnit,
        );

        ref
            .read(historyServiceProvider)
            .logCalculation(
              moduleName: 'Map Scale',
              category: 'Advanced Converters',
              inputs: 'Scale 1:${scale.toInt()} | Map: $inputVal $_mapUnit',
              result: '${res.toStringAsFixed(4)} $_realUnit',
            );
      } else {
        res = MapScaleCalculator.realToMap(
          inputVal,
          _realUnit,
          scale,
          _mapUnit,
        );

        ref
            .read(historyServiceProvider)
            .logCalculation(
              moduleName: 'Map Scale',
              category: 'Advanced Converters',
              inputs: 'Scale 1:${scale.toInt()} | Real: $inputVal $_realUnit',
              result: '${res.toStringAsFixed(4)} $_mapUnit',
            );
      }
      setState(() => _result = res);
    } catch (e) {
      setState(() => _error = 'Error calculating map scale.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMapToReal = _mode == 'Map to Real-World';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Scale Converter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 16),
                    color: Colors.redAccent.withOpacity(0.2),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                // Mode Toggle
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: const ['Map to Real-World', 'Real-World to Map'],
                    initialValue: _mode,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _mode = val;
                          _result = null;
                          _inputController.clear();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Scale Input
                const Text(
                  'Scale Ratio',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      '1 : ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlassTextField(
                        controller: _scaleController,
                        hintText: '50000',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Distance Input
                Text(
                  isMapToReal ? 'Map Distance' : 'Real-World Distance',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: GlassTextField(
                        controller: _inputController,
                        hintText: 'Enter distance',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: GlassAutocomplete<String>(
                        options: isMapToReal
                            ? const ['mm', 'cm', 'inches']
                            : const ['meters', 'km', 'miles', 'feet', 'yards'],
                        initialValue: isMapToReal ? _mapUnit : _realUnit,
                        onChanged: (val) {
                          if (val != null)
                            setState(
                              () => isMapToReal
                                  ? _mapUnit = val
                                  : _realUnit = val,
                            );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Target Unit Select
                const Text(
                  'Convert To',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: !isMapToReal
                        ? const ['mm', 'cm', 'inches']
                        : const ['meters', 'km', 'miles', 'feet', 'yards'],
                    initialValue: !isMapToReal ? _mapUnit : _realUnit,
                    onChanged: (val) {
                      if (val != null)
                        setState(
                          () => !isMapToReal ? _mapUnit = val : _realUnit = val,
                        );
                    },
                  ),
                ),

                const SizedBox(height: 32),
                GlassButton(
                  onPressed: _calculate,
                  child: const Text('Calculate'),
                ),

                if (_result != null) ...[
                  const SizedBox(height: 32),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          isMapToReal ? 'Real-World Distance' : 'Map Distance',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${_result!.toStringAsFixed(4).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "")} ${isMapToReal ? _realUnit : _mapUnit}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
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
}
