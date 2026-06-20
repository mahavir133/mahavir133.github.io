import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../provider/providers.dart';
import '../../data/repository/currency_repository.dart';

class CurrencyScreen extends ConsumerStatefulWidget {
  const CurrencyScreen({super.key});

  @override
  ConsumerState<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends ConsumerState<CurrencyScreen> {
  final TextEditingController _amountController = TextEditingController(text: '1.0');
  String _chartPeriod = '30D'; // 7D, 30D, 90D, 1Y
  String? _expandedCurrency; // currency code for showing historical chart

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currencyProvider);
    final notifier = ref.read(currencyProvider.notifier);

    // Sync base amount
    if (double.tryParse(_amountController.text) != state.baseAmount) {
      _amountController.text = state.baseAmount.toString();
    }

    final allCurrencyCodes = CurrencyRepository.currencyNames.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Exchange', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Active Alerts',
            onPressed: () => _showActiveAlertsDialog(context, state, notifier),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Rates',
            onPressed: () {
              HapticFeedback.lightImpact();
              notifier.refreshRates();
            },
          ),
        ],
      ),
      body: state.isLoading && state.rates.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. Offline & Caching Banner
                if (state.isOffline || state.cacheTimestamp != null)
                  _buildStatusBanner(context, state),

                // 2. Base Currency Selector and Amount
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Base Currency', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  value: state.baseCurrency,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  items: allCurrencyCodes.map((code) {
                                    return DropdownMenuItem(
                                      value: code,
                                      child: Text(
                                        '${CurrencyRepository.currencyToEmoji(code)} $code',
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      HapticFeedback.lightImpact();
                                      notifier.changeBaseCurrency(val);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                    labelText: 'Amount',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (val) {
                                    final d = double.tryParse(val) ?? 0.0;
                                    notifier.updateBaseAmount(d);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Watchlist (Multi-Currency Targets)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // 3. Targets List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.targetCurrencies.length,
                    itemBuilder: (context, idx) {
                      final target = state.targetCurrencies[idx];
                      if (target == state.baseCurrency) return const SizedBox.shrink();

                      final rate = _calculateRate(state.rates, state.baseCurrency, target);
                      final convertedVal = state.baseAmount * rate;
                      final isExpanded = _expandedCurrency == target;

                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Text(
                                CurrencyRepository.currencyToEmoji(target),
                                style: const TextStyle(fontSize: 32),
                              ),
                              title: Text(
                                '$target - ${CurrencyRepository.currencyNames[target] ?? ''}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              subtitle: Text(
                                'Rate: 1 ${state.baseCurrency} = ${rate.toStringAsFixed(4)} $target',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${CurrencyRepository.currencySymbols[target] ?? ''} ${convertedVal.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, size: 16),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  _expandedCurrency = isExpanded ? null : target;
                                });
                              },
                            ),
                            if (isExpanded)
                              _buildExpandedChartCard(context, state, target, rate, notifier),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_currency_fab',
        onPressed: () => _showAddCurrencySheet(context, allCurrencyCodes, notifier),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, CurrencyState state) {
    final theme = Theme.of(context);
    final isExpired = state.isOffline;
    final timeStr = state.cacheTimestamp != null
        ? '${state.cacheTimestamp!.hour.toString().padLeft(2, '0')}:${state.cacheTimestamp!.minute.toString().padLeft(2, '0')}'
        : 'Unknown';

    return Container(
      color: isExpired ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            isExpired ? Icons.cloud_off : Icons.cloud_done,
            color: isExpired ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isExpired
                  ? 'Offline Mode. Using rates cached at $timeStr'
                  : 'Live rates updated at $timeStr',
              style: TextStyle(
                color: isExpired ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedChartCard(
    BuildContext context,
    CurrencyState state,
    String target,
    double rate,
    CurrencyNotifier notifier,
  ) {
    final repo = ref.read(currencyRepositoryProvider);
    int days = 30;
    if (_chartPeriod == '7D') days = 7;
    if (_chartPeriod == '90D') days = 90;
    if (_chartPeriod == '1Y') days = 365;

    final trend = repo.getHistoricalRates(state.baseCurrency, target, days, state.rates);

    // Prepare chart spots
    final spots = <FlSpot>[];
    double minRate = double.infinity;
    double maxRate = double.negativeInfinity;

    for (int i = 0; i < trend.length; i++) {
      final r = trend[i]['rate'] as double;
      spots.add(FlSpot(i.toDouble(), r));
      if (r < minRate) minRate = r;
      if (r > maxRate) maxRate = r;
    }

    final yPadding = (maxRate - minRate) * 0.15;
    minRate = minRate - yPadding;
    maxRate = maxRate + yPadding;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Period Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['7D', '30D', '90D', '1Y'].map((p) {
              final isSel = _chartPeriod == p;
              return ChoiceChip(
                label: Text(p),
                selected: isSel,
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      _chartPeriod = p;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Chart
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minY: minRate,
                maxY: maxRate,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Watchlist controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.notifications_active),
                label: const Text('Add Alert'),
                onPressed: () => _showAddAlertSheet(context, target, rate, notifier),
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Remove', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  notifier.removeFromWatchlist(target);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateRate(Map<String, double> rates, String base, String target) {
    final baseVal = rates[base] ?? 1.0;
    final targetVal = rates[target] ?? 1.0;
    return targetVal / baseVal;
  }

  void _showAddCurrencySheet(
    BuildContext context,
    List<String> codes,
    CurrencyNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = codes.where((c) {
              final name = CurrencyRepository.currencyNames[c]?.toLowerCase() ?? '';
              return c.toLowerCase().contains(query.toLowerCase()) || name.contains(query.toLowerCase());
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: SizedBox(
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search Currencies',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          query = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final c = filtered[index];
                          return ListTile(
                            leading: Text(
                              CurrencyRepository.currencyToEmoji(c),
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text('$c - ${CurrencyRepository.currencyNames[c]}'),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              notifier.addToWatchlist(c);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddAlertSheet(
    BuildContext context,
    String target,
    double currentRate,
    CurrencyNotifier notifier,
  ) {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: currentRate.toStringAsFixed(4));
    bool isAbove = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create Rate Alert for $target',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Current Rate: 1 base = ${currentRate.toStringAsFixed(4)} $target'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Target Threshold ($target)',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter threshold value';
                        if (double.tryParse(val) == null) return 'Enter a valid decimal';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Trigger when rate is:'),
                        ToggleButtons(
                          isSelected: [isAbove, !isAbove],
                          onPressed: (idx) {
                            setModalState(() {
                              isAbove = idx == 0;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Above'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Below'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          HapticFeedback.lightImpact();
                          notifier.addAlert(
                            target,
                            double.parse(controller.text),
                            isAbove,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save Alert'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showActiveAlertsDialog(
    BuildContext context,
    CurrencyState state,
    CurrencyNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Active Alerts'),
          content: state.alerts.isEmpty
              ? const SizedBox(
                  height: 60,
                  child: Center(child: Text('No active alerts set.')),
                )
              : SizedBox(
                  width: double.maxFinite,
                  height: 200,
                  child: ListView.builder(
                    itemCount: state.alerts.length,
                    itemBuilder: (context, index) {
                      final alert = state.alerts[index];
                      final dir = alert.isAbove ? '≥' : '≤';
                      return ListTile(
                        leading: const Icon(Icons.notifications_active, color: Colors.blue),
                        title: Text(
                          '${alert.baseCurrency}/${alert.targetCurrency} $dir ${alert.threshold.toStringAsFixed(4)}',
                        ),
                        subtitle: Text(alert.isActive ? 'Active' : 'Triggered'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            notifier.removeAlert(alert.id);
                            Navigator.pop(context);
                            _showActiveAlertsDialog(context, ref.read(currencyProvider), notifier);
                          },
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
