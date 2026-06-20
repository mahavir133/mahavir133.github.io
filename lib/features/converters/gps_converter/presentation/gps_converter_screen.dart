import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/gps_converter_logic.dart';

class GpsConverterScreen extends ConsumerStatefulWidget {
  const GpsConverterScreen({super.key});

  @override
  ConsumerState<GpsConverterScreen> createState() => _GpsConverterScreenState();
}

class _GpsConverterScreenState extends ConsumerState<GpsConverterScreen> {
  String _inputMode = 'Decimal Degrees (DD)';

  // DD Controllers
  final _ddLatController = TextEditingController();
  final _ddLonController = TextEditingController();

  // DMS Controllers
  final _dmsLatDController = TextEditingController();
  final _dmsLatMController = TextEditingController();
  final _dmsLatSController = TextEditingController();
  String _dmsLatHem = 'N';
  final _dmsLonDController = TextEditingController();
  final _dmsLonMController = TextEditingController();
  final _dmsLonSController = TextEditingController();
  String _dmsLonHem = 'E';

  // UTM Controllers
  final _utmZoneController = TextEditingController();
  final _utmLetterController = TextEditingController();
  final _utmEastingController = TextEditingController();
  final _utmNorthingController = TextEditingController();

  // MGRS / Plus Code Controllers
  final _singleInputController = TextEditingController();

  GpsCoordinate? _result;
  String? _error;

  @override
  void dispose() {
    _ddLatController.dispose();
    _ddLonController.dispose();
    _dmsLatDController.dispose();
    _dmsLatMController.dispose();
    _dmsLatSController.dispose();
    _dmsLonDController.dispose();
    _dmsLonMController.dispose();
    _dmsLonSController.dispose();
    _utmZoneController.dispose();
    _utmLetterController.dispose();
    _utmEastingController.dispose();
    _utmNorthingController.dispose();
    _singleInputController.dispose();
    super.dispose();
  }

  void _convert() {
    setState(() => _error = null);
    GpsCoordinate? coord;

    try {
      if (_inputMode == 'Decimal Degrees (DD)') {
        coord = GpsCoordinate.fromDD(
          _ddLatController.text,
          _ddLonController.text,
        );
      } else if (_inputMode == 'Degrees, Minutes, Seconds (DMS)') {
        coord = GpsCoordinate.fromDMS(
          int.tryParse(_dmsLatDController.text) ?? 0,
          int.tryParse(_dmsLatMController.text) ?? 0,
          double.tryParse(_dmsLatSController.text) ?? 0,
          _dmsLatHem,
          int.tryParse(_dmsLonDController.text) ?? 0,
          int.tryParse(_dmsLonMController.text) ?? 0,
          double.tryParse(_dmsLonSController.text) ?? 0,
          _dmsLonHem,
        );
      } else if (_inputMode == 'UTM') {
        coord = GpsCoordinate.fromUTM(
          int.tryParse(_utmZoneController.text) ?? 0,
          _utmLetterController.text.trim().toUpperCase(),
          double.tryParse(_utmEastingController.text) ?? 0,
          double.tryParse(_utmNorthingController.text) ?? 0,
        );
      } else if (_inputMode == 'MGRS') {
        coord = GpsCoordinate.fromMGRS(
          _singleInputController.text.toUpperCase(),
        );
      } else if (_inputMode == 'Plus Codes') {
        coord = GpsCoordinate.fromPlusCode(
          _singleInputController.text.toUpperCase(),
        );
      }

      if (coord != null) {
        setState(() => _result = coord);
        ref
            .read(historyServiceProvider)
            .logCalculation(
              moduleName: 'GPS Converter',
              category: 'Advanced Converters',
              inputs: 'Format: $_inputMode',
              result: coord.decimalDegrees,
            );
      } else {
        setState(() => _error = 'Invalid Input. Please check your values.');
      }
    } catch (e) {
      setState(() => _error = 'Error parsing coordinates.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Coordinate Converter'),
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
                  'Input Format',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: const [
                      'Decimal Degrees (DD)',
                      'Degrees, Minutes, Seconds (DMS)',
                      'UTM',
                      'MGRS',
                      'Plus Codes',
                    ],
                    initialValue: _inputMode,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _inputMode = val;
                          _result = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),

                _buildInputFields(),

                const SizedBox(height: 24),
                GlassButton(onPressed: _convert, child: const Text('Convert')),

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

  Widget _buildInputFields() {
    if (_inputMode == 'Decimal Degrees (DD)') {
      return Row(
        children: [
          Expanded(
            child: GlassTextField(
              controller: _ddLatController,
              hintText: 'Latitude (e.g. 40.7128)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GlassTextField(
              controller: _ddLonController,
              hintText: 'Longitude (e.g. -74.0060)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
            ),
          ),
        ],
      );
    } else if (_inputMode == 'Degrees, Minutes, Seconds (DMS)') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Latitude', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: GlassTextField(
                  controller: _dmsLatDController,
                  hintText: 'Deg',
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: GlassTextField(
                  controller: _dmsLatMController,
                  hintText: 'Min',
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: GlassTextField(
                  controller: _dmsLatSController,
                  hintText: 'Sec',
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: GlassAutocomplete<String>(
                  options: const ['N', 'S'],
                  initialValue: _dmsLatHem,
                  onChanged: (v) {
                    if (v != null) _dmsLatHem = v;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Longitude',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Expanded(
                child: GlassTextField(
                  controller: _dmsLonDController,
                  hintText: 'Deg',
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: GlassTextField(
                  controller: _dmsLonMController,
                  hintText: 'Min',
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: GlassTextField(
                  controller: _dmsLonSController,
                  hintText: 'Sec',
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: GlassAutocomplete<String>(
                  options: const ['E', 'W'],
                  initialValue: _dmsLonHem,
                  onChanged: (v) {
                    if (v != null) _dmsLonHem = v;
                  },
                ),
              ),
            ],
          ),
        ],
      );
    } else if (_inputMode == 'UTM') {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: GlassTextField(
                  controller: _utmZoneController,
                  hintText: 'Zone (e.g. 33)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: GlassTextField(
                  controller: _utmLetterController,
                  hintText: 'Band (e.g. T)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GlassTextField(
                  controller: _utmEastingController,
                  hintText: 'Easting',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GlassTextField(
                  controller: _utmNorthingController,
                  hintText: 'Northing',
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return GlassTextField(
        controller: _singleInputController,
        hintText: _inputMode == 'MGRS'
            ? 'e.g. 4QFJ12345678'
            : 'e.g. 849VCWC8+R9',
      );
    }
  }

  Widget _buildResultView(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Converted Coordinates',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          _buildResultRow('Decimal Degrees', _result!.decimalDegrees),
          const Divider(),
          _buildResultRow('DMS', _result!.dms),
          const Divider(),
          _buildResultRow('UTM', _result!.utm),
          const Divider(),
          _buildResultRow('MGRS', _result!.mgrs),
          const Divider(),
          _buildResultRow('Plus Code', _result!.plusCode),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
