import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/craft_size_data.dart';

class CraftSizeScreen extends ConsumerStatefulWidget {
  const CraftSizeScreen({super.key});

  @override
  ConsumerState<CraftSizeScreen> createState() => _CraftSizeScreenState();
}

class _CraftSizeScreenState extends ConsumerState<CraftSizeScreen> {
  String _category = 'Wire Gauge';
  String _inputSystem = 'AWG / SWG';
  dynamic _inputValue;

  dynamic _result;

  List<String> get _systemOptions {
    if (_category == 'Wire Gauge') return ['AWG / SWG'];
    return ['Metric (mm)', 'US', 'UK'];
  }

  List<Object> get _availableSizes {
    if (_category == 'Wire Gauge') {
      return WireGaugeData.sizes.map((e) => e.gauge).toList();
    } else if (_category == 'Knitting Needles') {
      return KnittingNeedleData.sizes
          .map((s) {
            switch (_inputSystem) {
              case 'Metric (mm)':
                return s.metricMm;
              case 'US':
                return s.us;
              case 'UK':
                return s.uk;
              default:
                return s.metricMm;
            }
          })
          .toSet()
          .toList();
    } else {
      return CrochetHookData.sizes
          .map((s) {
            switch (_inputSystem) {
              case 'Metric (mm)':
                return s.metricMm;
              case 'US':
                return s.us;
              case 'UK':
                return s.uk;
              default:
                return s.metricMm;
            }
          })
          .toSet()
          .toList();
    }
  }

  void _calculate() {
    dynamic match;
    if (_category == 'Wire Gauge') {
      match = WireGaugeData.sizes.firstWhere(
        (e) => e.gauge == _inputValue,
        orElse: () => WireGaugeData.sizes.first,
      );
    } else if (_category == 'Knitting Needles') {
      for (var s in KnittingNeedleData.sizes) {
        dynamic val;
        switch (_inputSystem) {
          case 'Metric (mm)':
            val = s.metricMm;
            break;
          case 'US':
            val = s.us;
            break;
          case 'UK':
            val = s.uk;
            break;
        }
        if (val.toString() == _inputValue.toString()) {
          match = s;
          break;
        }
      }
    } else {
      for (var s in CrochetHookData.sizes) {
        dynamic val;
        switch (_inputSystem) {
          case 'Metric (mm)':
            val = s.metricMm;
            break;
          case 'US':
            val = s.us;
            break;
          case 'UK':
            val = s.uk;
            break;
        }
        if (val.toString() == _inputValue.toString()) {
          match = s;
          break;
        }
      }
    }

    setState(() {
      _result = match;
    });

    if (match != null) {
      ref
          .read(historyServiceProvider)
          .logCalculation(
            moduleName: 'Craft Size',
            category: 'Apparel & Sizing',
            inputs: '$_category | $_inputValue $_inputSystem',
            result: 'Converted',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Craft & Tool Sizes'),
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
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: const [
                      'Wire Gauge',
                      'Knitting Needles',
                      'Crochet Hooks',
                    ],
                    initialValue: _category,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _category = val;
                          _inputSystem = _systemOptions.first;
                          _inputValue = null;
                          _result = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: _systemOptions,
                    initialValue: _inputSystem,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _inputSystem = val;
                          _inputValue = null;
                          _result = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<Object>(
                    options: _availableSizes,
                    initialValue: _inputValue,
                    displayStringForOption: (v) => v is double
                        ? v.toString().replaceAll(RegExp(r'\.0$'), '')
                        : v.toString(),
                    onChanged: (val) {
                      if (val != null) setState(() => _inputValue = val);
                    },
                  ),
                ),

                const SizedBox(height: 24),
                GlassButton(
                  onPressed: _inputValue == null ? () {} : _calculate,
                  child: const Text('Convert'),
                ),

                if (_result != null) ...[
                  const SizedBox(height: 32),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Equivalents',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        if (_category == 'Wire Gauge') ...[
                          _buildRow(
                            'AWG Dia (mm)',
                            '${(_result as WireGaugeData).awgDiaMm} mm',
                          ),
                          _buildRow(
                            'AWG Area (mm²)',
                            '${(_result as WireGaugeData).awgMm2} mm²',
                          ),
                          _buildRow(
                            'SWG Dia (mm)',
                            '${(_result as WireGaugeData).swgDiaMm} mm',
                          ),
                        ] else ...[
                          _buildRow('Metric (mm)', '${_result.metricMm} mm'),
                          _buildRow('US', _result.us),
                          _buildRow('UK / Canada', _result.uk),
                        ],
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

  Widget _buildRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            val,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
