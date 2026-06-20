import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/heart_rate_calculator.dart';

class HeartRateScreen extends ConsumerStatefulWidget {
  const HeartRateScreen({super.key});

  @override
  ConsumerState<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends ConsumerState<HeartRateScreen> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _restingHrController = TextEditingController();
  
  HeartRateResult? _result;
  String? _error;

  @override
  void dispose() {
    _ageController.dispose();
    _restingHrController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _error = null);
    try {
      int age = int.tryParse(_ageController.text) ?? 0;
      int? restingHr = int.tryParse(_restingHrController.text);
      if (restingHr != null && restingHr <= 0) restingHr = null;

      final res = HeartRateCalculator.calculateZones(age: age, restingHr: restingHr);

      setState(() => _result = res);

      ref.read(historyServiceProvider).logCalculation(
        moduleName: 'Heart Rate Zones',
        category: 'Health & Fitness',
        inputs: 'Age: $age, RHR: ${restingHr ?? 'N/A'}',
        result: 'Max HR: ${res.maxHr}',
      );
    } catch (e) {
      setState(() => _error = "Invalid age. Please enter a valid age.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate Zones'),
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

                GlassTextField(controller: _ageController, hintText: 'Age (years)'),
                const SizedBox(height: 16),
                GlassTextField(controller: _restingHrController, hintText: 'Resting Heart Rate (Optional)'),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Enter your resting HR to use the more accurate Karvonen method.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),

                const SizedBox(height: 24),
                GlassButton(onPressed: _calculate, child: const Text('Calculate Zones')),
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
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Estimated Max Heart Rate', style: TextStyle(color: Colors.grey)),
          Text('${_result!.maxHr} bpm', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          const Divider(height: 32),
          ..._result!.zones.map((z) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(z.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${z.minHr} - ${z.maxHr} bpm', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(z.description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
