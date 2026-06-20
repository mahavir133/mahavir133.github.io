import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/one_rep_max_calculator.dart';

class OneRepMaxScreen extends ConsumerStatefulWidget {
  const OneRepMaxScreen({super.key});

  @override
  ConsumerState<OneRepMaxScreen> createState() => _OneRepMaxScreenState();
}

class _OneRepMaxScreenState extends ConsumerState<OneRepMaxScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  
  String _unit = 'kg'; // or lbs
  OneRepMaxResult? _result;
  String? _error;

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _error = null);
    try {
      double weight = double.tryParse(_weightController.text) ?? 0;
      int reps = int.tryParse(_repsController.text) ?? 0;

      final res = OneRepMaxCalculator.calculate(weight, reps);

      setState(() => _result = res);

      ref.read(historyServiceProvider).logCalculation(
        moduleName: 'One Rep Max',
        category: 'Health & Fitness',
        inputs: '$weight$_unit x $reps reps',
        result: 'Est 1RM: ${res.average.toStringAsFixed(1)}$_unit',
      );
    } catch (e) {
      setState(() => _error = "Invalid inputs. Enter weight and reps > 0.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('One Rep Max (1RM)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.surface, theme.colorScheme.surface.withOpacity(0.8)],
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
                    padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(bottom: 16),
                    color: Colors.redAccent.withOpacity(0.2),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),

                Row(
                  children: [
                    Expanded(child: GlassTextField(controller: _weightController, hintText: 'Weight Lifted')),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GlassAutocomplete<String>(
                          options: const ['kg', 'lbs'],
                          initialValue: _unit,
                          onChanged: (val) {
                            if (val != null) setState(() => _unit = val);
                          },
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                GlassTextField(controller: _repsController, hintText: 'Reps Completed'),
                
                const SizedBox(height: 24),
                GlassButton(onPressed: _calculate, child: const Text('Calculate 1RM')),
                const SizedBox(height: 24),
                
                if (_result != null) _buildResult(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(ThemeData theme) {
    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('Estimated 1RM (Average)', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text('${_result!.average.toStringAsFixed(1)} $_unit', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const Divider(height: 32),
              _buildRow('Epley Formula', '${_result!.epley.toStringAsFixed(1)} $_unit'),
              _buildRow('Brzycki Formula', '${_result!.brzycki.toStringAsFixed(1)} $_unit'),
              _buildRow('Lombardi Formula', '${_result!.lombardi.toStringAsFixed(1)} $_unit'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Weight Percentages', style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              ..._result!.percentages.entries.map((e) => _buildRow('${e.key}%', '${e.value.toStringAsFixed(1)} $_unit')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
