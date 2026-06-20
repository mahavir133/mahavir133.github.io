import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/coordinate_distance_calculator.dart';

class CoordinateDistanceScreen extends ConsumerStatefulWidget {
  const CoordinateDistanceScreen({super.key});

  @override
  ConsumerState<CoordinateDistanceScreen> createState() =>
      _CoordinateDistanceScreenState();
}

class _CoordinateDistanceScreenState
    extends ConsumerState<CoordinateDistanceScreen> {
  final _lat1Controller = TextEditingController();
  final _lon1Controller = TextEditingController();
  final _lat2Controller = TextEditingController();
  final _lon2Controller = TextEditingController();

  DistanceResult? _result;
  String? _error;

  @override
  void dispose() {
    _lat1Controller.dispose();
    _lon1Controller.dispose();
    _lat2Controller.dispose();
    _lon2Controller.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _error = null);

    final lat1 = double.tryParse(_lat1Controller.text);
    final lon1 = double.tryParse(_lon1Controller.text);
    final lat2 = double.tryParse(_lat2Controller.text);
    final lon2 = double.tryParse(_lon2Controller.text);

    if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) {
      setState(() => _error = 'Please enter valid coordinates.');
      return;
    }

    try {
      final res = CoordinateDistanceCalculator.calculate(
        lat1,
        lon1,
        lat2,
        lon2,
      );
      setState(() => _result = res);

      ref
          .read(historyServiceProvider)
          .logCalculation(
            moduleName: 'Coordinate Distance',
            category: 'Advanced Converters',
            inputs: 'P1($lat1, $lon1) -> P2($lat2, $lon2)',
            result: '${res.distanceKm.toStringAsFixed(2)} km',
          );
    } catch (e) {
      setState(() => _error = 'Error calculating distance.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distance Between Coordinates'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
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

                const Text(
                  'Point A',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _lat1Controller,
                        hintText: 'Latitude',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassTextField(
                        controller: _lon1Controller,
                        hintText: 'Longitude',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  'Point B',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _lat2Controller,
                        hintText: 'Latitude',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassTextField(
                        controller: _lon2Controller,
                        hintText: 'Longitude',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                GlassButton(
                  onPressed: _calculate,
                  child: const Text('Calculate Distance'),
                ),

                if (_result != null) ...[
                  const SizedBox(height: 32),
                  _buildResultView(theme),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Distance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          _buildResultRow(
            'Kilometers',
            '${_result!.distanceKm.toStringAsFixed(2)} km',
          ),
          const Divider(),
          _buildResultRow(
            'Miles',
            '${_result!.distanceMiles.toStringAsFixed(2)} mi',
          ),
          const Divider(),
          _buildResultRow(
            'Nautical Miles',
            '${_result!.distanceNM.toStringAsFixed(2)} NM',
          ),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Initial Bearing',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          _buildResultRow(
            'Degrees',
            '${_result!.initialBearing.toStringAsFixed(2)}°',
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
