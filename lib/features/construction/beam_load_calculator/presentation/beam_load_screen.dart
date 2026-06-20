import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../core/db/history_service.dart';
import '../utils/beam_load_logic.dart';

class BeamLoadScreen extends ConsumerStatefulWidget {
  const BeamLoadScreen({super.key});

  @override
  ConsumerState<BeamLoadScreen> createState() => _BeamLoadScreenState();
}

class _BeamLoadScreenState extends ConsumerState<BeamLoadScreen> {
  bool _isMetric = true;
  LoadType _loadType = LoadType.point;

  final TextEditingController _length = TextEditingController();
  final TextEditingController _load = TextEditingController();
  final TextEditingController _modulusE = TextEditingController(
    text: '200',
  ); // Steel ~200 GPa
  final TextEditingController _inertiaI = TextEditingController();

  BeamResult? _result;

  @override
  void dispose() {
    _length.dispose();
    _load.dispose();
    _modulusE.dispose();
    _inertiaI.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _result = BeamLogic.calculate(
        length: double.tryParse(_length.text) ?? 0,
        load: double.tryParse(_load.text) ?? 0,
        modulusE: double.tryParse(_modulusE.text) ?? 0,
        inertiaI: double.tryParse(_inertiaI.text) ?? 0,
        loadType: _loadType,
        isMetric: _isMetric,
      );
    });

    ref
        .read(historyServiceProvider)
        .logCalculation(
          moduleName: 'Beam/Load',
          category: 'Construction',
          inputs: 'L:${_length.text}, Load:${_load.text}',
          result: 'Defl: ${_result!.maxDeflection.toStringAsFixed(2)}',
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lUnit = _isMetric ? 'm' : 'ft';
    final loadUnit = _loadType == LoadType.point
        ? (_isMetric ? 'kN' : 'kips')
        : (_isMetric ? 'kN/m' : 'kips/ft');
    final eUnit = _isMetric ? 'GPa' : 'ksi';
    final iUnit = _isMetric ? 'cm⁴' : 'in⁴';

    final shearUnit = _isMetric ? 'kN' : 'kips';
    final momentUnit = _isMetric ? 'kN·m' : 'kip·ft';
    final deflUnit = _isMetric ? 'mm' : 'in';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beam & Load Calculator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Row(
            children: [
              const Text('Imperial'),
              Switch(
                value: _isMetric,
                onChanged: (val) {
                  setState(() {
                    _isMetric = val;
                    if (val) {
                      _modulusE.text = '200'; // Steel in GPa
                    } else {
                      _modulusE.text = '29000'; // Steel in ksi
                    }
                    _result = null;
                  });
                },
                activeColor: theme.colorScheme.primary,
              ),
              const Text('Metric'),
              const SizedBox(width: 16),
            ],
          ),
        ],
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
                _buildSectionHeader('Support Type: Simply Supported'),
                const SizedBox(height: 16),

                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<LoadType>(
                    options: LoadType.values,
                    initialValue: _loadType,
                    displayStringForOption: (val) => val == LoadType.point
                        ? 'Point Load (Center)'
                        : 'Uniformly Distributed Load (UDL)',
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _loadType = val;
                          _result = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                _buildSectionHeader('Beam Details'),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _length,
                        hintText: 'Span Length ($lUnit)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassTextField(
                        controller: _load,
                        hintText: 'Load Magnitude ($loadUnit)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Material & Section Properties'),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _modulusE,
                        hintText: 'Modulus of Elasticity, E ($eUnit)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassTextField(
                        controller: _inertiaI,
                        hintText: 'Moment of Inertia, I ($iUnit)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                GlassButton(
                  onPressed: _calculate,
                  child: const Text('Calculate'),
                ),

                if (_result != null) ...[
                  const SizedBox(height: 32),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Structural Analysis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildResultRow(
                          'Max Deflection (δ)',
                          '${_result!.maxDeflection.toStringAsFixed(3)} $deflUnit',
                          isHighlight: true,
                        ),
                        const SizedBox(height: 16),
                        _buildResultRow(
                          'Max Shear Force (V)',
                          '${_result!.maxShear.toStringAsFixed(2)} $shearUnit',
                        ),
                        _buildResultRow(
                          'Max Bending Moment (M)',
                          '${_result!.maxMoment.toStringAsFixed(2)} $momentUnit',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isHighlight ? 24 : 16,
              color: isHighlight ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
