import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/clothing_size_data.dart';

class ClothingSizeScreen extends ConsumerStatefulWidget {
  const ClothingSizeScreen({super.key});

  @override
  ConsumerState<ClothingSizeScreen> createState() => _ClothingSizeScreenState();
}

class _ClothingSizeScreenState extends ConsumerState<ClothingSizeScreen> {
  String _category = 'Tops';
  String _inputSystem = 'Intl (XS-XL)';
  String? _inputValue;

  ClothingSizeData? _result;

  List<String> get _systemOptions => [
    'Intl (XS-XL)',
    'US',
    'UK',
    'EU',
    'JP',
    'KR',
    'AU',
  ];

  List<String> get _availableSizes {
    return ClothingSizeData.sizes
        .where((e) => e.category == _category)
        .map((s) {
          switch (_inputSystem) {
            case 'Intl (XS-XL)':
              return s.intl;
            case 'US':
              return s.us;
            case 'UK':
              return s.uk;
            case 'EU':
              return s.eu;
            case 'JP':
              return s.jp;
            case 'KR':
              return s.kr;
            case 'AU':
              return s.au;
            default:
              return s.intl;
          }
        })
        .toSet()
        .toList(); // toSet to remove duplicates
  }

  void _calculate() {
    ClothingSizeData? match;
    for (var s in ClothingSizeData.sizes.where(
      (e) => e.category == _category,
    )) {
      String val = '';
      switch (_inputSystem) {
        case 'Intl (XS-XL)':
          val = s.intl;
          break;
        case 'US':
          val = s.us;
          break;
        case 'UK':
          val = s.uk;
          break;
        case 'EU':
          val = s.eu;
          break;
        case 'JP':
          val = s.jp;
          break;
        case 'KR':
          val = s.kr;
          break;
        case 'AU':
          val = s.au;
          break;
      }
      if (val == _inputValue) {
        match = s;
        break;
      }
    }

    setState(() {
      _result = match;
    });

    if (match != null) {
      ref
          .read(historyServiceProvider)
          .logCalculation(
            moduleName: 'Clothing Size',
            category: 'Apparel & Sizing',
            inputs: '$_category | $_inputValue $_inputSystem',
            result: 'US: ${match.us}',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clothing Size Converter'),
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
                    options: const ['Tops', 'Bottoms', 'Dresses'],
                    initialValue: _category,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _category = val;
                          _inputValue = null;
                          _result = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: _systemOptions,
                    initialValue: _inputSystem,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _inputSystem = val;
                          _inputValue = null;
                          _result = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: _availableSizes,
                    initialValue: _inputValue,
                    onChanged: (val) {
                      if (val != null) setState(() => _inputValue = val);
                    },
                  ),
                ),

                const SizedBox(height: 24),
                GlassButton(
                  onPressed: _inputValue == null ? () {} : _calculate,
                  child: const Text('Convert'),
                ),

                if (_result != null) ...[
                  const SizedBox(height: 32),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Equivalents',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildRow('International', _result!.intl),
                        _buildRow('US', _result!.us),
                        _buildRow('UK', _result!.uk),
                        _buildRow('EU', _result!.eu),
                        _buildRow('Japan', _result!.jp),
                        _buildRow('Korea', _result!.kr),
                        _buildRow('Australia', _result!.au),
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

  Widget _buildRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            val,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
