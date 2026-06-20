import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/shoe_size_data.dart';

class ShoeSizeScreen extends ConsumerStatefulWidget {
  const ShoeSizeScreen({super.key});

  @override
  ConsumerState<ShoeSizeScreen> createState() => _ShoeSizeScreenState();
}

class _ShoeSizeScreenState extends ConsumerState<ShoeSizeScreen> {
  String _category = 'Adult';
  String _inputSystem = 'US Men';
  double? _inputValue;

  ShoeSizeData? _result;

  List<String> get _systemOptions => [
    'US Men',
    'US Women',
    'UK',
    'EU',
    'JP (cm)',
    'KR (mm) / Mondopoint',
    'India (IN)',
  ];

  List<double> get _availableSizes {
    final list = _category == 'Adult'
        ? ShoeSizeData.adultSizes
        : ShoeSizeData.childSizes;
    return list.map((s) {
      switch (_inputSystem) {
        case 'US Men':
          return s.usMen;
        case 'US Women':
          return s.usWomen;
        case 'UK':
          return s.uk;
        case 'India (IN)':
          return s.ind;
        case 'EU':
          return s.eu;
        case 'JP (cm)':
          return s.jp;
        case 'KR (mm) / Mondopoint':
          return s.kr;
        default:
          return s.usMen;
      }
    }).toList();
  }

  void _calculate() {
    final list = _category == 'Adult'
        ? ShoeSizeData.adultSizes
        : ShoeSizeData.childSizes;
    ShoeSizeData? match;
    for (var s in list) {
      double val = 0;
      switch (_inputSystem) {
        case 'US Men':
          val = s.usMen;
          break;
        case 'US Women':
          val = s.usWomen;
          break;
        case 'UK':
          val = s.uk;
          break;
        case 'EU':
          val = s.eu;
          break;
        case 'JP (cm)':
          val = s.jp;
          break;
        case 'KR (mm) / Mondopoint':
          val = s.kr;
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
            moduleName: 'Shoe Size',
            category: 'Apparel & Sizing',
            inputs: '$_category | $_inputValue $_inputSystem',
            result: 'EU: ${match.eu}',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shoe Size Converter'),
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
                const Text(
                  'Disclaimer: Sizes vary by brand. This uses standard international sizing.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: const ['Adult', 'Child'],
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
                  child: GlassAutocomplete<double>(
                    options: _availableSizes,
                    initialValue: _inputValue,
                    displayStringForOption: (v) =>
                        v.toString().replaceAll(RegExp(r'\.0$'), ''),
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
                        _buildRow('US Men', _result!.usMen),
                        _buildRow('US Women', _result!.usWomen),
                        _buildRow('UK', _result!.uk),
                        _buildRow('India (IN)', _result!.ind),
                        _buildRow('EU', _result!.eu),
                        _buildRow('JP (cm)', _result!.jp),
                        _buildRow('KR (mm)', _result!.kr),
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

  Widget _buildRow(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            val.toString().replaceAll(RegExp(r'\.0$'), ''),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
