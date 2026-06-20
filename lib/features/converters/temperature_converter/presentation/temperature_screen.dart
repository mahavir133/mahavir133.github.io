import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../core/db/history_service.dart';
import '../utils/temperature_converter.dart';

class TemperatureScreen extends ConsumerStatefulWidget {
  const TemperatureScreen({super.key});

  @override
  ConsumerState<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends ConsumerState<TemperatureScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  String _inputUnit = TemperatureConverter.units[0]; // Celsius
  String _outputUnit = TemperatureConverter.units[1]; // Fahrenheit

  String _formula = "";

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _convert() {
    if (_inputController.text.isEmpty) {
      _outputController.text = "";
      setState(() => _formula = "");
      return;
    }

    double? val = double.tryParse(_inputController.text);
    if (val == null) {
      _outputController.text = "Error";
      return;
    }

    final res = TemperatureConverter.convert(val, _inputUnit, _outputUnit);
    _outputController.text = res.value
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), '');

    setState(() {
      _formula = res.formula;
    });

    ref
        .read(historyServiceProvider)
        .logCalculation(
          moduleName: 'Temperature',
          category: 'Advanced Converters',
          inputs: '$val $_inputUnit',
          result: '${_outputController.text} $_outputUnit',
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Converter'),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
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

                  const SizedBox(height: 32),

                  if (_formula.isNotEmpty)
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Mathematical Formula Used:',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formula,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
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
            options: TemperatureConverter.units,
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
