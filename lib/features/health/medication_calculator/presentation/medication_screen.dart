import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/medication_calculator.dart';

class MedicationScreen extends ConsumerStatefulWidget {
  const MedicationScreen({super.key});

  @override
  ConsumerState<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends ConsumerState<MedicationScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _concentrationController = TextEditingController();
  
  MedicationResult? _result;
  String? _error;

  @override
  void dispose() {
    _weightController.dispose();
    _doseController.dispose();
    _concentrationController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _error = null);
    try {
      double weight = double.tryParse(_weightController.text) ?? 0;
      double dose = double.tryParse(_doseController.text) ?? 0;
      
      double? conc;
      if (_concentrationController.text.isNotEmpty) {
        conc = double.tryParse(_concentrationController.text);
      }

      final res = MedicationCalculator.calculate(
        weightKg: weight,
        dosePerKgMg: dose,
        concentrationMgPerMl: conc,
      );

      setState(() => _result = res);

      ref.read(historyServiceProvider).logCalculation(
        moduleName: 'Medication Dosage',
        category: 'Health & Fitness',
        inputs: '${weight}kg | ${dose}mg/kg',
        result: 'Total Dose: ${res.totalDoseMg} mg ${res.volumeMl != null ? '(${res.volumeMl} mL)' : ''}',
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
        title: const Text('Medication Dosage'),
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
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Expanded(child: Text('MEDICAL DISCLAIMER: For informational purposes only. Do NOT use this to replace professional medical advice. Always double check calculations.', style: TextStyle(color: Colors.redAccent, fontSize: 12))),
                    ],
                  ),
                ),

                GlassTextField(controller: _weightController, hintText: 'Patient Weight (kg)'),
                const SizedBox(height: 16),
                
                GlassTextField(controller: _doseController, hintText: 'Target Dose (mg per kg)'),
                const SizedBox(height: 16),
                
                GlassTextField(controller: _concentrationController, hintText: 'Liquid Concentration (mg/mL) [Optional]'),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Leave blank if the medication is a solid pill/tablet.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),

                const SizedBox(height: 24),
                GlassButton(onPressed: _calculate, child: const Text('Calculate Dosage')),
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
          const Text('Total Medication Dose', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('${_result!.totalDoseMg.toStringAsFixed(1)} mg', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          
          if (_result!.volumeMl != null) ...[
            const Divider(height: 32),
            const Text('Liquid Volume to Administer', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('${_result!.volumeMl!.toStringAsFixed(2)} mL', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ],
        ],
      ),
    );
  }
}
