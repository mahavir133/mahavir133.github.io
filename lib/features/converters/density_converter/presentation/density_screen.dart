import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../core/db/history_service.dart';
import '../utils/density_converter.dart';

class DensityScreen extends ConsumerStatefulWidget {
  const DensityScreen({super.key});

  @override
  ConsumerState<DensityScreen> createState() => _DensityScreenState();
}

class _DensityScreenState extends ConsumerState<DensityScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  String _inputUnit = DensityConverter.units[0];
  String _outputUnit = DensityConverter.units[1];

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _convert() {
    if (_inputController.text.isEmpty) {
      _outputController.text = "";
      return;
    }

    double? val = double.tryParse(_inputController.text);
    if (val == null) {
      _outputController.text = "Error";
      return;
    }

    double result = DensityConverter.convert(val, _inputUnit, _outputUnit);

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
          moduleName: 'Density',
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
        title: const Text('Density Converter'),
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
            options: DensityConverter.units,
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
