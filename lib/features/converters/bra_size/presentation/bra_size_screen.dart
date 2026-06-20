import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/bra_size_data.dart';

class BraSizeScreen extends ConsumerStatefulWidget {
  const BraSizeScreen({super.key});

  @override
  ConsumerState<BraSizeScreen> createState() => _BraSizeScreenState();
}

class _BraSizeScreenState extends ConsumerState<BraSizeScreen> {
  String _inputSystem = 'US';
  String? _bandValue;
  String? _cupValue;

  BraBandData? _bandResult;
  BraCupData? _cupResult;

  List<String> get _systemOptions => ['US', 'UK', 'EU', 'FR', 'AU', 'JP'];

  List<String> get _availableBands {
    return BraBandData.bands.map((b) {
      switch (_inputSystem) {
        case 'US':
        case 'UK':
          return b.usUk;
        case 'EU':
        case 'JP':
          return b.euJp;
        case 'FR':
          return b.fr;
        case 'AU':
          return b.au;
        default:
          return b.usUk;
      }
    }).toList();
  }

  List<String> get _availableCups {
    return BraCupData.cups.map((c) {
      switch (_inputSystem) {
        case 'US':
          return c.us;
        case 'UK':
          return c.uk;
        case 'EU':
        case 'FR':
          return c.euFr;
        case 'AU':
          return c.au;
        case 'JP':
          return c.jp;
        default:
          return c.us;
      }
    }).toList();
  }

  void _calculate() {
    BraBandData? matchedBand;
    for (var b in BraBandData.bands) {
      String val = '';
      switch (_inputSystem) {
        case 'US':
        case 'UK':
          val = b.usUk;
          break;
        case 'EU':
        case 'JP':
          val = b.euJp;
          break;
        case 'FR':
          val = b.fr;
          break;
        case 'AU':
          val = b.au;
          break;
      }
      if (val == _bandValue) {
        matchedBand = b;
        break;
      }
    }

    BraCupData? matchedCup;
    for (var c in BraCupData.cups) {
      String val = '';
      switch (_inputSystem) {
        case 'US':
          val = c.us;
          break;
        case 'UK':
          val = c.uk;
          break;
        case 'EU':
        case 'FR':
          val = c.euFr;
          break;
        case 'AU':
          val = c.au;
          break;
        case 'JP':
          val = c.jp;
          break;
      }
      if (val == _cupValue) {
        matchedCup = c;
        break;
      }
    }

    setState(() {
      _bandResult = matchedBand;
      _cupResult = matchedCup;
    });

    if (matchedBand != null && matchedCup != null) {
      ref
          .read(historyServiceProvider)
          .logCalculation(
            moduleName: 'Bra Size',
            category: 'Apparel & Sizing',
            inputs: '$_bandValue$_cupValue $_inputSystem',
            result: 'US: ${matchedBand.usUk}${matchedCup.us}',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bra Size Converter'),
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
                    options: _systemOptions,
                    initialValue: _inputSystem,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _inputSystem = val;
                          _bandValue = null;
                          _cupValue = null;
                          _bandResult = null;
                          _cupResult = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GlassAutocomplete<String>(
                          options: _availableBands,
                          initialValue: _bandValue,
                          displayStringForOption: (v) => 'Band: $v',
                          onChanged: (val) {
                            if (val != null) setState(() => _bandValue = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GlassAutocomplete<String>(
                          options: _availableCups,
                          initialValue: _cupValue,
                          displayStringForOption: (v) => 'Cup: $v',
                          onChanged: (val) {
                            if (val != null) setState(() => _cupValue = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                GlassButton(
                  onPressed: (_bandValue == null || _cupValue == null)
                      ? () {}
                      : _calculate,
                  child: const Text('Convert'),
                ),

                if (_bandResult != null && _cupResult != null) ...[
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
                        _buildRow(
                          'US',
                          '${_bandResult!.usUk}${_cupResult!.us}',
                        ),
                        _buildRow(
                          'UK',
                          '${_bandResult!.usUk}${_cupResult!.uk}',
                        ),
                        _buildRow(
                          'EU',
                          '${_bandResult!.euJp}${_cupResult!.euFr}',
                        ),
                        _buildRow(
                          'France / Spain',
                          '${_bandResult!.fr}${_cupResult!.euFr}',
                        ),
                        _buildRow(
                          'Australia / NZ',
                          '${_bandResult!.au}${_cupResult!.au}',
                        ),
                        _buildRow(
                          'Japan',
                          '${_bandResult!.euJp}${_cupResult!.jp}',
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
