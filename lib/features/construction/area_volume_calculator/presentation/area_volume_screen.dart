import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../core/db/history_service.dart';
import '../utils/area_volume_logic.dart';

class AreaVolumeScreen extends ConsumerStatefulWidget {
  const AreaVolumeScreen({super.key});

  @override
  ConsumerState<AreaVolumeScreen> createState() => _AreaVolumeScreenState();
}

class _AreaVolumeScreenState extends ConsumerState<AreaVolumeScreen> {
  String _dimensionType = '2D Shapes'; // '2D Shapes' or '3D Solids'
  ShapeType _selectedShape = ShapeType.triangle;
  final Map<String, TextEditingController> _controllers = {};

  double? _areaResult;
  double? _volumeResult;
  double? _surfaceAreaResult;

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    for (var param in AreaVolumeLogic.getParamsForShape(_selectedShape)) {
      _controllers[param] = TextEditingController();
    }
    _areaResult = null;
    _volumeResult = null;
    _surfaceAreaResult = null;
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<ShapeType> get _availableShapes {
    if (_dimensionType == '2D Shapes') {
      return [
        ShapeType.triangle,
        ShapeType.circle,
        ShapeType.trapezoid,
        ShapeType.ellipse,
        ShapeType.polygon,
      ];
    } else {
      return [
        ShapeType.sphere,
        ShapeType.cone,
        ShapeType.cylinder,
        ShapeType.torus,
        ShapeType.frustum,
      ];
    }
  }

  String _formatShapeName(ShapeType type) {
    String name = type.toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }

  void _calculate() {
    final params = <String, double>{};
    for (var entry in _controllers.entries) {
      params[entry.key] = double.tryParse(entry.value.text) ?? 0.0;
    }

    setState(() {
      if (_dimensionType == '2D Shapes') {
        _areaResult = AreaVolumeLogic.calculateArea(_selectedShape, params);
      } else {
        _volumeResult = AreaVolumeLogic.calculateVolume(_selectedShape, params);
        _surfaceAreaResult = AreaVolumeLogic.calculateSurfaceArea(
          _selectedShape,
          params,
        );
      }
    });

    ref
        .read(historyServiceProvider)
        .logCalculation(
          moduleName: 'Area & Volume',
          category: 'Construction',
          inputs:
              '${_formatShapeName(_selectedShape)} | Params: ${params.values.join(',')}',
          result: _dimensionType == '2D Shapes'
              ? 'Area: ${_areaResult?.toStringAsFixed(2)}'
              : 'Vol: ${_volumeResult?.toStringAsFixed(2)}',
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Area & Volume'),
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
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: const ['2D Shapes', '3D Solids'],
                    initialValue: _dimensionType,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _dimensionType = val;
                          _selectedShape = _availableShapes.first;
                          _setupControllers();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<ShapeType>(
                    options: _availableShapes,
                    initialValue: _selectedShape,
                    displayStringForOption: _formatShapeName,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedShape = val;
                          _setupControllers();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                ..._controllers.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GlassTextField(
                      controller: entry.value,
                      hintText: 'Enter ${entry.key}',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 8),
                GlassButton(
                  onPressed: _calculate,
                  child: const Text('Calculate'),
                ),

                if (_areaResult != null) ...[
                  const SizedBox(height: 32),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Area',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          '${_areaResult!.toStringAsFixed(4)} units²',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_volumeResult != null && _surfaceAreaResult != null) ...[
                  const SizedBox(height: 32),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Volume',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          '${_volumeResult!.toStringAsFixed(4)} units³',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          'Surface Area',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          '${_surfaceAreaResult!.toStringAsFixed(4)} units²',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
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
}
