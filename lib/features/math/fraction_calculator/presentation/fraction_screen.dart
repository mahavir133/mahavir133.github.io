import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/fraction_calculator.dart';

class FractionScreen extends ConsumerStatefulWidget {
  const FractionScreen({super.key});

  @override
  ConsumerState<FractionScreen> createState() => _FractionScreenState();
}

class _FractionScreenState extends ConsumerState<FractionScreen> {
  final TextEditingController _num1Controller = TextEditingController();
  final TextEditingController _den1Controller = TextEditingController();
  final TextEditingController _num2Controller = TextEditingController();
  final TextEditingController _den2Controller = TextEditingController();

  String _operator = '+';
  String? _resultStr;
  String? _mixedStr;
  String? _decimalStr;
  String? _error;

  @override
  void dispose() {
    _num1Controller.dispose();
    _den1Controller.dispose();
    _num2Controller.dispose();
    _den2Controller.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _error = null);

    try {
      final n1 = int.parse(_num1Controller.text);
      final d1 = int.parse(_den1Controller.text);
      final n2 = int.parse(_num2Controller.text);
      final d2 = int.parse(_den2Controller.text);

      final f1 = Fraction(n1, d1);
      final f2 = Fraction(n2, d2);
      Fraction res;

      switch (_operator) {
        case '+':
          res = f1 + f2;
          break;
        case '-':
          res = f1 - f2;
          break;
        case 'x':
          res = f1 * f2;
          break;
        case '/':
          res = f1 / f2;
          break;
        default:
          throw Exception("Unknown operator");
      }

      setState(() {
        _resultStr = res.toString();
        _mixedStr = res.toMixedNumber();
        _decimalStr = res.toDouble().toStringAsFixed(4);
      });

      ref
          .read(historyServiceProvider)
          .logCalculation(
            moduleName: 'Fraction Calculator',
            category: 'Math & Academic',
            inputs: '$f1 $_operator $f2',
            result: res.toString(),
          );
    } catch (e) {
      setState(() {
        _error = "Invalid Input: Check denominators or numbers.";
        _resultStr = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fraction Calculator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                Row(
                  children: [
                    Expanded(
                      child: _buildFractionInput(
                        _num1Controller,
                        _den1Controller,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildOperatorSelector(theme),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFractionInput(
                        _num2Controller,
                        _den2Controller,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GlassButton(
                  onPressed: _calculate,
                  child: const Text('Calculate'),
                ),
                const SizedBox(height: 24),
                if (_resultStr != null) _buildResultView(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFractionInput(
    TextEditingController numCtrl,
    TextEditingController denCtrl,
  ) {
    return Column(
      children: [
        GlassTextField(
          controller: numCtrl,
          hintText: 'Num',
          keyboardType: TextInputType.number,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(thickness: 2),
        ),
        GlassTextField(
          controller: denCtrl,
          hintText: 'Den',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildOperatorSelector(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GlassAutocomplete<String>(
        options: const ['+', '-', 'x', '/'],
        initialValue: _operator,
        displayStringForOption: (val) => ' $val ',
        onChanged: (val) {
          if (val != null) setState(() => _operator = val);
        },
      ),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text('Result (Improper)', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            _resultStr!,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mixed Number:', style: TextStyle(fontSize: 16)),
              Text(
                _mixedStr!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Decimal:', style: TextStyle(fontSize: 16)),
              Text(
                _decimalStr!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
