import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/water_intake_calculator.dart';

class WaterIntakeScreen extends ConsumerStatefulWidget {
  const WaterIntakeScreen({super.key});

  @override
  ConsumerState<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends ConsumerState<WaterIntakeScreen> {
  final TextEditingController _weightController = TextEditingController();
  
  String _climate = 'Moderate';
  String _activityLevel = 'Sedentary';
  
  double? _resultMl;
  String? _error;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _error = null);
    try {
      double weight = double.tryParse(_weightController.text) ?? 0;

      final res = WaterIntakeCalculator.calculateMl(
        weightKg: weight,
        climate: _climate,
        activityLevel: _activityLevel,
      );

      setState(() => _resultMl = res);

      ref.read(historyServiceProvider).logCalculation(
        moduleName: 'Water Intake',
        category: 'Health & Fitness',
        inputs: '${weight}kg | $_climate | $_activityLevel',
        result: '${(res / 1000).toStringAsFixed(2)} L/day',
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake Calculator'),
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

                GlassTextField(controller: _weightController, hintText: 'Weight (kg)'),
                const SizedBox(height: 16),
                
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: const ['Temperate', 'Warm/Hot', 'Extreme Heat/Humid'],
                    initialValue: _climate,
                    onChanged: (val) {
                      if (val != null) setState(() => _climate = val);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: const ['Sedentary', 'Light', 'Moderate', 'Intense', 'Extreme'],
                    initialValue: _activityLevel,
                    displayStringForOption: (val) {
                      if (val == 'Sedentary') return 'Sedentary (Little to no exercise)';
                      if (val == 'Light') return 'Light (Exercise 1-2 days/week)';
                      if (val == 'Moderate') return 'Moderate (Exercise 3-4 days/week)';
                      if (val == 'Intense') return 'Active (Exercise 5-6 days/week)';
                      return 'Extreme (Intense training)';
                    },
                    onChanged: (val) {
                      if (val != null) setState(() => _activityLevel = val);
                    },
                  ),
                ),

                const SizedBox(height: 24),
                GlassButton(onPressed: _calculate, child: const Text('Calculate Needs')),
                const SizedBox(height: 24),
                
                if (_resultMl != null)
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('Daily Goal', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('${(_resultMl! / 1000).toStringAsFixed(2)} Liters', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                        const SizedBox(height: 8),
                        Text('(~${(_resultMl! / 250).round()} cups of water)', style: const TextStyle(fontSize: 18, color: Colors.blueAccent)),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
