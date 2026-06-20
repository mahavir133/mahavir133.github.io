import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/calorie_calculator.dart';

class CalorieScreen extends ConsumerStatefulWidget {
  const CalorieScreen({super.key});

  @override
  ConsumerState<CalorieScreen> createState() => _CalorieScreenState();
}

class _CalorieScreenState extends ConsumerState<CalorieScreen> {
  final TextEditingController _maintenanceController = TextEditingController();
  
  String _goal = 'Lose';
  double _weeklyChange = 0.5;
  
  CalorieResult? _result;
  String? _error;

  @override
  void dispose() {
    _maintenanceController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _error = null);
    try {
      double tdee = double.tryParse(_maintenanceController.text) ?? 0;

      final res = CalorieCalculator.plan(
        maintenanceCalories: tdee,
        goal: _goal,
        weeklyChangeKg: _weeklyChange,
      );

      setState(() => _result = res);

      ref.read(historyServiceProvider).logCalculation(
        moduleName: 'Calorie Planner',
        category: 'Health & Fitness',
        inputs: 'TDEE: $tdee | $_goal $_weeklyChange kg/wk',
        result: '${res.targetCalories.round()} kcal/day',
      );
    } catch (e) {
      setState(() => _error = "Invalid inputs.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Deficit / Surplus'),
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

                GlassTextField(controller: _maintenanceController, hintText: 'Maintenance Calories (TDEE)'),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('You can calculate your TDEE in the BMI/BMR calculator.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                const SizedBox(height: 16),

                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: const ['Lose', 'Maintain', 'Gain'],
                    initialValue: _goal,
                    displayStringForOption: (val) => '$val Weight',
                    onChanged: (val) {
                      if (val != null) setState(() => _goal = val);
                    },
                  ),
                ),
                
                if (_goal != 'Maintain') ...[
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GlassAutocomplete<double>(
                      options: const [0.25, 0.50, 0.75, 1.00],
                      initialValue: _weeklyChange,
                      displayStringForOption: (val) {
                        if (val == 0.25) return '0.25 kg (0.5 lbs) / week (Mild)';
                        if (val == 0.50) return '0.50 kg (1.0 lbs) / week (Standard)';
                        if (val == 0.75) return '0.75 kg (1.5 lbs) / week (Aggressive)';
                        return '1.00 kg (2.0 lbs) / week (Extreme)';
                      },
                      onChanged: (val) {
                        if (val != null) setState(() => _weeklyChange = val);
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                GlassButton(onPressed: _calculate, child: const Text('Calculate Plan')),
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
    bool lowCalories = _result!.targetCalories < 1200 && _result!.goal == 'Lose';

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Daily Target Calories', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text('${_result!.targetCalories.round()} kcal', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          
          if (_result!.difference > 0) ...[
            const SizedBox(height: 8),
            Text('(${_result!.goal == 'Lose' ? '-' : '+'}${_result!.difference.round()} kcal ${_result!.goal == 'Lose' ? 'Deficit' : 'Surplus'})', style: const TextStyle(fontSize: 18, color: Colors.grey)),
          ],

          if (lowCalories) ...[
            const Divider(height: 32),
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(child: Text('Warning: Consuming under 1,200 calories a day is generally not recommended without medical supervision.', style: TextStyle(color: Colors.orange, fontSize: 12))),
              ],
            )
          ]
        ],
      ),
    );
  }
}
