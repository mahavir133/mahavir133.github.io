import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/body_fat_calculator.dart';

class BodyFatScreen extends ConsumerStatefulWidget {
  const BodyFatScreen({super.key});

  @override
  ConsumerState<BodyFatScreen> createState() => _BodyFatScreenState();
}

class _BodyFatScreenState extends ConsumerState<BodyFatScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _neckController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();
  
  String _gender = 'Male';
  double? _result;
  String? _error;

  @override
  void dispose() {
    _heightController.dispose();
    _neckController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _error = null);
    try {
      double height = double.tryParse(_heightController.text) ?? 0;
      double neck = double.tryParse(_neckController.text) ?? 0;
      double waist = double.tryParse(_waistController.text) ?? 0;
      double hip = double.tryParse(_hipController.text) ?? 0;

      final res = BodyFatCalculator.calculateNavyMethod(
        gender: _gender,
        heightCm: height,
        neckCm: neck,
        waistCm: waist,
        hipCm: hip,
      );

      setState(() => _result = res);

      ref.read(historyServiceProvider).logCalculation(
        moduleName: 'Body Fat %',
        category: 'Health & Fitness',
        inputs: '$_gender | H:$height, N:$neck, W:$waist, Hip:$hip',
        result: '${res.toStringAsFixed(1)}%',
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
        title: const Text('Body Fat % Calculator'),
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
                const Text('U.S. Navy Method', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                const SizedBox(height: 16),
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

                GlassTextField(controller: _heightController, hintText: 'Height (cm)'),
                const SizedBox(height: 16),
                GlassTextField(controller: _neckController, hintText: 'Neck Circumference (cm)'),
                const SizedBox(height: 16),
                GlassTextField(controller: _waistController, hintText: 'Waist Circumference (cm)'),
                
                if (_gender == 'Female') ...[
                  const SizedBox(height: 16),
                  GlassTextField(controller: _hipController, hintText: 'Hip Circumference (cm)'),
                ],

                const SizedBox(height: 24),
                GlassButton(onPressed: _calculate, child: const Text('Calculate')),
                const SizedBox(height: 24),
                
                if (_result != null)
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('Estimated Body Fat', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('${_result!.toStringAsFixed(1)}%', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                        const SizedBox(height: 16),
                        Text(_getCategory(_result!, _gender), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
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

  String _getCategory(double bf, String gender) {
    if (gender == 'Male') {
      if (bf < 6) return "Essential Fat";
      if (bf < 14) return "Athletes";
      if (bf < 18) return "Fitness";
      if (bf < 25) return "Average";
      return "Obese";
    } else {
      if (bf < 14) return "Essential Fat";
      if (bf < 21) return "Athletes";
      if (bf < 25) return "Fitness";
      if (bf < 32) return "Average";
      return "Obese";
    }
  }
}
