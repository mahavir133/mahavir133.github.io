import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/bmi_calculator.dart';

class BmiScreen extends ConsumerStatefulWidget {
  const BmiScreen({super.key});

  @override
  ConsumerState<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends ConsumerState<BmiScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  
  String _gender = 'Male';
  double _activityLevel = 1.2;
  
  BmiResult? _result;
  String? _error;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _error = null);
    try {
      double weight = double.tryParse(_weightController.text) ?? 0;
      double height = double.tryParse(_heightController.text) ?? 0;
      int age = int.tryParse(_ageController.text) ?? 0;

      final res = BmiCalculator.calculate(
        weightKg: weight,
        heightCm: height,
        age: age,
        gender: _gender,
        activityMultiplier: _activityLevel,
      );

      setState(() => _result = res);

      ref.read(historyServiceProvider).logCalculation(
        moduleName: 'BMI & TDEE',
        category: 'Health & Fitness',
        inputs: '${weight}kg, ${height}cm, $age yo, $_gender',
        result: 'BMI: ${res.bmi.toStringAsFixed(1)}, TDEE: ${res.tdee.round()} kcal',
      );
    } catch (e) {
      setState(() => _error = "Invalid inputs. Ensure all fields are valid positive numbers.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI / BMR / TDEE'),
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
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _gender = 'Male'),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(12),
                          child: Center(
                            child: Text('Male', style: TextStyle(fontWeight: _gender == 'Male' ? FontWeight.bold : FontWeight.normal, color: _gender == 'Male' ? theme.colorScheme.primary : null)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _gender = 'Female'),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(12),
                          child: Center(
                            child: Text('Female', style: TextStyle(fontWeight: _gender == 'Female' ? FontWeight.bold : FontWeight.normal, color: _gender == 'Female' ? theme.colorScheme.primary : null)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: GlassTextField(controller: _ageController, hintText: 'Age (years)')),
                    const SizedBox(width: 16),
                    Expanded(child: GlassTextField(controller: _weightController, hintText: 'Weight (kg)')),
                  ],
                ),
                const SizedBox(height: 16),
                
                GlassTextField(controller: _heightController, hintText: 'Height (cm)'),
                const SizedBox(height: 16),

                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<double>(
                    options: const [1.2, 1.375, 1.55, 1.725, 1.9],
                    initialValue: _activityLevel,
                    displayStringForOption: (val) {
                      if (val == 1.2) return 'Sedentary (little/no exercise)';
                      if (val == 1.375) return 'Lightly active (1-3 days/wk)';
                      if (val == 1.55) return 'Moderately active (3-5 days/wk)';
                      if (val == 1.725) return 'Very active (6-7 days/wk)';
                      return 'Extra active (physical job/2x train)';
                    },
                    onChanged: (val) {
                      if (val != null) setState(() => _activityLevel = val);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                GlassButton(onPressed: _calculate, child: const Text('Calculate')),
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
    Color getBmiColor(double bmi) {
      if (bmi < 18.5) return Colors.blueAccent;
      if (bmi < 25) return Colors.green;
      if (bmi < 30) return Colors.orange;
      return Colors.redAccent;
    }

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('BMI: ${_result!.bmi.toStringAsFixed(1)}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: getBmiColor(_result!.bmi))),
          Text(_result!.bmiCategory, style: TextStyle(fontSize: 18, color: getBmiColor(_result!.bmi))),
          const Divider(height: 32),
          _buildRow('BMR (Resting Energy)', '${_result!.bmr.round()} kcal/day'),
          const Divider(),
          _buildRow('TDEE (Maintenance)', '${_result!.tdee.round()} kcal/day'),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Macro Split Suggestions (Maintenance)', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          _buildRow('Protein (30%)', '${((_result!.tdee * 0.3) / 4).round()}g'),
          _buildRow('Fats (30%)', '${((_result!.tdee * 0.3) / 9).round()}g'),
          _buildRow('Carbs (40%)', '${((_result!.tdee * 0.4) / 4).round()}g'),
        ],
      ),
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
