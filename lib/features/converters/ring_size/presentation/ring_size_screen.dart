import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/ring_size_data.dart';

class RingSizeScreen extends ConsumerStatefulWidget {
  const RingSizeScreen({super.key});

  @override
  ConsumerState<RingSizeScreen> createState() => _RingSizeScreenState();
}

class _RingSizeScreenState extends ConsumerState<RingSizeScreen> {
  String _inputSystem = 'US';
  dynamic _inputValue;

  RingSizeData? _result;

  List<String> get _systemOptions => [
    'US',
    'UK',
    'EU',
    'JP',
    'India (IN)',
    'Diameter (mm)',
    'Circumference (mm)',
  ];

  List<Object> get _availableSizes {
    return RingSizeData.sizes.map((s) {
      switch (_inputSystem) {
        case 'US':
          return s.us;
        case 'UK':
          return s.uk;
        case 'EU':
          return s.eu;
        case 'JP':
          return s.jp;
        case 'India (IN)':
          return s.ind;
        case 'Diameter (mm)':
          return s.diameterMm;
        case 'Circumference (mm)':
          return s.circumferenceMm;
        default:
          return s.us;
      }
    }).toList();
  }

  void _calculate() {
    RingSizeData? match;
    for (var s in RingSizeData.sizes) {
      dynamic val;
      switch (_inputSystem) {
        case 'US':
          val = s.us;
          break;
        case 'UK':
          val = s.uk;
          break;
        case 'EU':
          val = s.eu;
          break;
        case 'JP':
          val = s.jp;
          break;
        case 'India (IN)':
          val = s.ind;
          break;
        case 'Diameter (mm)':
          val = s.diameterMm;
          break;
        case 'Circumference (mm)':
          val = s.circumferenceMm;
          break;
      }
      if (val == _inputValue) {
        match = s;
        break;
      }
    }

    setState(() {
      _result = match;
    });

    if (match != null) {
      ref
          .read(historyServiceProvider)
          .logCalculation(
            moduleName: 'Ring Size',
            category: 'Apparel & Sizing',
            inputs: '$_inputValue $_inputSystem',
            result: 'US: ${match.us}',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ring Size Converter'),
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
                    displayStringForOption: (v) {
                      if (v is double)
                        return v.toString().replaceAll(RegExp(r'\.0$'), '');
                      return v.toString();
                    },
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
                        _buildRow('US', _result!.us),
                        _buildRow('UK / Australia', _result!.uk),
                        _buildRow('EU (ISO)', _result!.eu),
                        _buildRow('Japan', _result!.jp),
                        _buildRow('India', _result!.ind),
                        _buildRow('Diameter', '${_result!.diameterMm} mm'),
                        _buildRow(
                          'Circumference',
                          '${_result!.circumferenceMm} mm',
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

  Widget _buildRow(String label, dynamic val) {
    String text = val is double
        ? val.toString().replaceAll(RegExp(r'\.0$'), '')
        : val.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
