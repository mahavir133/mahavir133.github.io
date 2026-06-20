import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/base_converter.dart';

class BaseConverterScreen extends ConsumerStatefulWidget {
  const BaseConverterScreen({super.key});

  @override
  ConsumerState<BaseConverterScreen> createState() =>
      _BaseConverterScreenState();
}

class _BaseConverterScreenState extends ConsumerState<BaseConverterScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _val2Controller =
      TextEditingController(); // For bitwise
  final TextEditingController _customBaseController = TextEditingController(
    text: '36',
  );

  int _inputBase = 10;
  String _bitwiseOp = 'AND';
  bool _isBitwiseMode = false;

  BaseConverterResult? _result;
  String? _bitwiseResult;

  @override
  void dispose() {
    _inputController.dispose();
    _val2Controller.dispose();
    _customBaseController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_isBitwiseMode) {
      final val1 = _inputController.text.trim();
      final val2 = _val2Controller.text.trim();
      if (val1.isEmpty || val2.isEmpty) return;

      final res = BaseConverter.bitwiseOp(val1, val2, _inputBase, _bitwiseOp);
      setState(() {
        _bitwiseResult = res;
        _result = null;
      });

      ref
          .read(historyServiceProvider)
          .logCalculation(
            moduleName: 'Base Converter',
            category: 'Math & Academic',
            inputs: '$val1 $_bitwiseOp $val2 (Base $_inputBase)',
            result: res,
          );
    } else {
      final val = _inputController.text.trim();
      if (val.isEmpty) return;

      final customBase = int.tryParse(_customBaseController.text) ?? 36;
      final res = BaseConverter.convert(
        value: val,
        fromBase: _inputBase,
        toCustomBase: customBase,
      );

      setState(() {
        _result = res;
        _bitwiseResult = null;
      });

      if (res.decimal != 'Error') {
        ref
            .read(historyServiceProvider)
            .logCalculation(
              moduleName: 'Base Converter',
              category: 'Math & Academic',
              inputs: '$val (Base $_inputBase)',
              result: 'Dec: ${res.decimal}, Hex: ${res.hex}',
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Base Converter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isBitwiseMode ? Icons.calculate : Icons.memory),
            tooltip: _isBitwiseMode ? 'Conversion Mode' : 'Bitwise Mode',
            onPressed: () {
              setState(() {
                _isBitwiseMode = !_isBitwiseMode;
                _result = null;
                _bitwiseResult = null;
              });
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GlassAutocomplete<int>(
                    options: const [2, 8, 10, 16],
                    initialValue: _inputBase,
                    displayStringForOption: (val) {
                      if (val == 2) return 'Binary (Base 2)';
                      if (val == 8) return 'Octal (Base 8)';
                      if (val == 10) return 'Decimal (Base 10)';
                      return 'Hexadecimal (Base 16)';
                    },
                    onChanged: (val) {
                      if (val != null) setState(() => _inputBase = val);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _inputController,
                  hintText: _isBitwiseMode ? 'Value 1' : 'Enter Value',
                  keyboardType: TextInputType.text,
                ),

                if (_isBitwiseMode) ...[
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GlassAutocomplete<String>(
                      options: const ['AND', 'OR', 'XOR'],
                      initialValue: _bitwiseOp,
                      displayStringForOption: (val) {
                        if (val == 'AND') return 'AND (&)';
                        if (val == 'OR') return 'OR (|)';
                        return 'XOR (^)';
                      },
                      onChanged: (val) {
                        if (val != null) setState(() => _bitwiseOp = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassTextField(
                    controller: _val2Controller,
                    hintText: 'Value 2',
                    keyboardType: TextInputType.text,
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  GlassTextField(
                    controller: _customBaseController,
                    hintText: 'Custom Target Base (2-36)',
                    keyboardType: TextInputType.number,
                  ),
                ],

                const SizedBox(height: 24),
                GlassButton(
                  onPressed: _calculate,
                  child: const Text('Calculate'),
                ),
                const SizedBox(height: 24),

                if (_result != null && !_isBitwiseMode)
                  _buildConversionResultView(context, _result!),
                if (_bitwiseResult != null && _isBitwiseMode)
                  _buildBitwiseResultView(context, _bitwiseResult!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversionResultView(
    BuildContext context,
    BaseConverterResult result,
  ) {
    if (result.decimal == 'Error') {
      return const Center(
        child: Text(
          'Invalid Input for Selected Base',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return GlassContainer(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResultRow('Binary (2)', result.binary),
          const Divider(),
          _buildResultRow('Octal (8)', result.octal),
          const Divider(),
          _buildResultRow('Decimal (10)', result.decimal),
          const Divider(),
          _buildResultRow('Hex (16)', result.hex),
          const Divider(),
          _buildResultRow('Custom Base', result.customBaseResult),
        ],
      ),
    );
  }

  Widget _buildBitwiseResultView(BuildContext context, String result) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text(
            'Result',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            result,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
