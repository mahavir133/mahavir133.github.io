import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../core/db/history_service.dart';
import '../providers/currency_provider.dart';
import '../utils/currency_info.dart';

class CurrencyScreen extends ConsumerStatefulWidget {
  const CurrencyScreen({super.key});

  @override
  ConsumerState<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends ConsumerState<CurrencyScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  String _inputUnit = 'USD';
  String _outputUnit = 'EUR';

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _convert(Map<String, double> rates) {
    if (_inputController.text.isEmpty) {
      _outputController.text = "";
      return;
    }

    double? val = double.tryParse(_inputController.text);
    if (val == null) {
      _outputController.text = "Error";
      return;
    }

    // Convert: USD is base in this API
    // formula: (amount / fromRate) * toRate
    double fromRate = rates[_inputUnit] ?? 1.0;
    double toRate = rates[_outputUnit] ?? 1.0;

    double result = (val / fromRate) * toRate;

    _outputController.text = result
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), '');

    ref
        .read(historyServiceProvider)
        .logCalculation(
          moduleName: 'Currency',
          category: 'Advanced Converters',
          inputs: '$val $_inputUnit',
          result: '${_outputController.text} $_outputUnit',
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratesAsyncValue = ref.watch(currencyRatesProvider);
    final lastUpdate = ref.watch(currencyUpdateDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ratesAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Offline & No Cache',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(err.toString(), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(currencyRatesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (rates) {
                List<String> units = rates.keys.toList()..sort();

                // Ensure initial units are valid
                if (!units.contains(_inputUnit)) _inputUnit = units.first;
                if (!units.contains(_outputUnit))
                  _outputUnit = units.length > 1 ? units[1] : units.first;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      if (lastUpdate != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Rates updated: ${lastUpdate.toLocal().toString().split('.')[0]}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      _buildConversionRow(
                        _inputController,
                        _inputUnit,
                        units,
                        (newUnit) {
                          setState(() => _inputUnit = newUnit!);
                          _convert(rates);
                        },
                        true,
                        rates,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: IconButton(
                          icon: const Icon(Icons.swap_vert, size: 32),
                          onPressed: () {
                            setState(() {
                              String temp = _inputUnit;
                              _inputUnit = _outputUnit;
                              _outputUnit = temp;
                              _convert(rates);
                            });
                          },
                        ),
                      ),

                      _buildConversionRow(
                        _outputController,
                        _outputUnit,
                        units,
                        (newUnit) {
                          setState(() => _outputUnit = newUnit!);
                          _convert(rates);
                        },
                        false,
                        rates,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversionRow(
    TextEditingController controller,
    String unit,
    List<String> units,
    ValueChanged<String?> onChanged,
    bool isInput,
    Map<String, double> rates,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassAutocomplete<String>(
            options: units,
            initialValue: unit,
            displayStringForOption: (val) => CurrencyInfo.getDisplayName(val),
            onChanged: (val) {
              onChanged(val);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            readOnly: !isInput,
            onChanged: (val) {
              if (isInput) _convert(rates);
            },
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }
}
