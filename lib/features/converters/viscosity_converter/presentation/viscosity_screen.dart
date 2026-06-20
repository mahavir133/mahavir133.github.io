import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../core/db/history_service.dart';
import '../utils/viscosity_converter.dart';

class ViscosityScreen extends ConsumerStatefulWidget {
  const ViscosityScreen({super.key});

  @override
  ConsumerState<ViscosityScreen> createState() => _ViscosityScreenState();
}

class _ViscosityScreenState extends ConsumerState<ViscosityScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _densityController = TextEditingController();

  String _inputUnit = ViscosityConverter.allUnits[0]; // Pa.s
  String _outputUnit = ViscosityConverter.allUnits[4]; // cSt
  String? _error;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _densityController.dispose();
    super.dispose();
  }

  void _convert() {
    setState(() => _error = null);

    if (_inputController.text.isEmpty) {
      _outputController.text = "";
      return;
    }

    double? val = double.tryParse(_inputController.text);
    if (val == null) {
      _outputController.text = "Error";
      return;
    }

    double? density = double.tryParse(_densityController.text);

    try {
      double result = ViscosityConverter.convert(
        value: val,
        from: _inputUnit,
        to: _outputUnit,
        densityKgM3: density,
      );

      if (result == 0) {
        _outputController.text = "0";
      } else if (result.abs() < 0.0001 || result.abs() > 1000000) {
        _outputController.text = result.toStringAsExponential(4);
      } else {
        _outputController.text = result
            .toStringAsFixed(6)
            .replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), '');
      }

      ref
          .read(historyServiceProvider)
          .logCalculation(
            moduleName: 'Viscosity',
            category: 'Advanced Converters',
            inputs: '$val $_inputUnit',
            result: '${_outputController.text} $_outputUnit',
          );
    } catch (e) {
      _outputController.text = "Requires Density";
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viscosity Converter'),
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

                GlassTextField(
                  controller: _densityController,
                  hintText: 'Fluid Density (kg/m³) [Optional]',
                  onChanged: (_) => _convert(),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Only required if converting between Dynamic and Kinematic viscosity.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),

                _buildConversionRow(_inputController, _inputUnit, (newUnit) {
                  setState(() => _inputUnit = newUnit!);
                  _convert();
                }, true),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.swap_vert, size: 32),
                    onPressed: () {
                      setState(() {
                        String temp = _inputUnit;
                        _inputUnit = _outputUnit;
                        _outputUnit = temp;
                        _convert();
                      });
                    },
                  ),
                ),

                _buildConversionRow(_outputController, _outputUnit, (newUnit) {
                  setState(() => _outputUnit = newUnit!);
                  _convert();
                }, false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversionRow(
    TextEditingController controller,
    String unit,
    ValueChanged<String?> onChanged,
    bool isInput,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassAutocomplete<String>(
            options: ViscosityConverter.allUnits,
            initialValue: unit,
            onChanged: (val) {
              onChanged(val);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            readOnly: !isInput,
            onChanged: (val) {
              if (isInput) _convert();
            },
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }
}
