import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/bac_calculator.dart';

class BacScreen extends ConsumerStatefulWidget {
  const BacScreen({super.key});

  @override
  ConsumerState<BacScreen> createState() => _BacScreenState();
}

class _BacScreenState extends ConsumerState<BacScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _abvController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  
  String _gender = 'Male';
  BacResult? _result;
  String? _error;

  @override
  void dispose() {
    _weightController.dispose();
    _volumeController.dispose();
    _abvController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _error = null);
    try {
      double weight = double.tryParse(_weightController.text) ?? 0;
      double volume = double.tryParse(_volumeController.text) ?? 0;
      double abv = double.tryParse(_abvController.text) ?? 0;
      double hours = double.tryParse(_hoursController.text) ?? 0;

      final res = BacCalculator.calculate(
        gender: _gender,
        weightKg: weight,
        volumeMl: volume,
        abvPercent: abv,
        hoursElapsed: hours,
      );

      setState(() => _result = res);

      ref.read(historyServiceProvider).logCalculation(
        moduleName: 'BAC Calculator',
        category: 'Health & Fitness',
        inputs: '${volume}ml @ $abv% | $hours hrs',
        result: 'BAC: ${res.bac.toStringAsFixed(3)}%',
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
        title: const Text('BAC Calculator'),
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

                Container(
                  padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(child: Text('For informational purposes only. Do not use this to determine if you are safe to drive.', style: TextStyle(color: Colors.orange, fontSize: 12))),
                    ],
                  ),
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

                GlassTextField(controller: _weightController, hintText: 'Weight (kg)'),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(child: GlassTextField(controller: _volumeController, hintText: 'Total Volume (ml)')),
                    const SizedBox(width: 8),
                    Expanded(child: GlassTextField(controller: _abvController, hintText: 'Alcohol % (ABV)')),
                  ],
                ),
                const SizedBox(height: 16),
                
                GlassTextField(controller: _hoursController, hintText: 'Hours since first drink'),

                const SizedBox(height: 24),
                GlassButton(onPressed: _calculate, child: const Text('Calculate BAC')),
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
    Color getBacColor(double bac) {
      if (bac == 0) return Colors.green;
      if (bac < 0.04) return Colors.yellow;
      if (bac < 0.08) return Colors.orange;
      return Colors.red;
    }

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Estimated Blood Alcohol Content', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('${_result!.bac.toStringAsFixed(3)}%', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: getBacColor(_result!.bac))),
          const SizedBox(height: 8),
          Text(_result!.status, style: TextStyle(fontSize: 16, color: getBacColor(_result!.bac))),
          const Divider(height: 32),
          const Text('Time until completely sober', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text('${_result!.timeToSober.inHours} hrs ${_result!.timeToSober.inMinutes.remainder(60)} mins', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
