import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/pace_calculator.dart';

class PaceScreen extends ConsumerStatefulWidget {
  const PaceScreen({super.key});

  @override
  ConsumerState<PaceScreen> createState() => _PaceScreenState();
}

class _PaceScreenState extends ConsumerState<PaceScreen> {
  final TextEditingController _distController = TextEditingController();
  final TextEditingController _timeHController = TextEditingController(text: '0');
  final TextEditingController _timeMController = TextEditingController(text: '0');
  final TextEditingController _timeSController = TextEditingController(text: '0');
  final TextEditingController _paceMController = TextEditingController(text: '0');
  final TextEditingController _paceSController = TextEditingController(text: '0');
  
  String _distUnit = 'Kilometers'; // or Miles
  String _calcMode = 'Calculate Pace'; // Calculate Time, Calculate Distance
  
  PaceResult? _result;
  String? _error;

  @override
  void dispose() {
    _distController.dispose();
    _timeHController.dispose();
    _timeMController.dispose();
    _timeSController.dispose();
    _paceMController.dispose();
    _paceSController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _error = null);
    try {
      double? distVal = double.tryParse(_distController.text);
      if (distVal != null && _distUnit == 'Miles') {
        distVal = distVal / 0.621371; // convert to km internally
      }

      int tH = int.tryParse(_timeHController.text) ?? 0;
      int tM = int.tryParse(_timeMController.text) ?? 0;
      int tS = int.tryParse(_timeSController.text) ?? 0;
      Duration? time = Duration(hours: tH, minutes: tM, seconds: tS);
      if (time.inSeconds == 0) time = null;

      int pM = int.tryParse(_paceMController.text) ?? 0;
      int pS = int.tryParse(_paceSController.text) ?? 0;
      Duration? pace = Duration(minutes: pM, seconds: pS);
      if (pace.inSeconds == 0) pace = null;

      // If they gave miles pace, convert to km pace
      if (pace != null && _distUnit == 'Miles') {
        pace = Duration(seconds: (pace.inSeconds * 0.621371).round());
      }

      double? finalDist = _calcMode == 'Calculate Distance' ? null : distVal;
      Duration? finalTime = _calcMode == 'Calculate Time' ? null : time;
      Duration? finalPace = _calcMode == 'Calculate Pace' ? null : pace;

      final res = PaceCalculator.calculate(
        distanceKm: finalDist,
        time: finalTime,
        pacePerKm: finalPace,
      );

      setState(() => _result = res);

      ref.read(historyServiceProvider).logCalculation(
        moduleName: 'Pace Calculator',
        category: 'Health & Fitness',
        inputs: 'Mode: $_calcMode',
        result: 'Time: ${_formatDuration(res.time)}',
      );
    } catch (e) {
      setState(() => _error = "Please fill out the 2 required fields properly.");
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool needDist = _calcMode != 'Calculate Distance';
    bool needTime = _calcMode != 'Calculate Time';
    bool needPace = _calcMode != 'Calculate Pace';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pace Calculator'),
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

                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: const ['Calculate Pace', 'Calculate Time', 'Calculate Distance'],
                    initialValue: _calcMode,
                    onChanged: (val) {
                      if (val != null) setState(() { _calcMode = val; _result = null; });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                if (needDist) ...[
                  Row(
                    children: [
                      Expanded(flex: 2, child: GlassTextField(controller: _distController, hintText: 'Distance')),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: GlassAutocomplete<String>(
                            options: const ['Kilometers', 'Miles'],
                            initialValue: _distUnit,
                            displayStringForOption: (val) => val == 'Kilometers' ? 'km' : 'mi',
                            onChanged: (val) {
                              if (val != null) setState(() => _distUnit = val);
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                if (needTime) ...[
                  const Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: GlassTextField(controller: _timeHController, hintText: 'Hrs')), const SizedBox(width: 8),
                      Expanded(child: GlassTextField(controller: _timeMController, hintText: 'Min')), const SizedBox(width: 8),
                      Expanded(child: GlassTextField(controller: _timeSController, hintText: 'Sec')),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                if (needPace) ...[
                  Text('Pace (per ${_distUnit == 'Miles' ? 'mi' : 'km'})', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: GlassTextField(controller: _paceMController, hintText: 'Min')), const SizedBox(width: 8),
                      Expanded(child: GlassTextField(controller: _paceSController, hintText: 'Sec')),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                GlassButton(onPressed: _calculate, child: Text(_calcMode)),
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
          const Text('Results', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          _buildRow('Distance', '${_result!.distanceKm.toStringAsFixed(2)} km / ${_result!.distanceMi.toStringAsFixed(2)} mi'),
          const Divider(),
          _buildRow('Time', _formatDuration(_result!.time)),
          const Divider(),
          _buildRow('Pace (per km)', _formatDuration(_result!.pacePerKm)),
          _buildRow('Pace (per mi)', _formatDuration(_result!.pacePerMi)),
          const Divider(),
          _buildRow('Speed', '${_result!.speedKmh.toStringAsFixed(2)} km/h / ${_result!.speedMph.toStringAsFixed(2)} mph'),
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
