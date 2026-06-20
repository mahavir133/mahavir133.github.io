import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/statistics_calculator.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  final TextEditingController _xController = TextEditingController();
  final TextEditingController _yController = TextEditingController();

  bool _isRegression = false;
  StatisticsResult? _statResult;
  RegressionResult? _regResult;
  String? _error;

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _error = null);
    try {
      final xValues = _xController.text
          .split(RegExp(r'[,\s]+'))
          .where((s) => s.isNotEmpty)
          .map((e) => double.tryParse(e))
          .whereType<double>()
          .toList();

      if (xValues.isEmpty) throw Exception('Enter valid numeric data.');

      if (_isRegression) {
        final yValues = _yController.text
            .split(RegExp(r'[,\s]+'))
            .where((s) => s.isNotEmpty)
            .map((e) => double.tryParse(e))
            .whereType<double>()
            .toList();
        if (xValues.length != yValues.length)
          throw Exception('X and Y must have the same number of elements.');

        final res = StatisticsCalculator.calculateRegression(xValues, yValues);
        setState(() {
          _regResult = res;
          _statResult = null;
        });

        ref
            .read(historyServiceProvider)
            .logCalculation(
              moduleName: 'Statistics (Regression)',
              category: 'Math & Academic',
              inputs: 'X: ${_xController.text}\nY: ${_yController.text}',
              result:
                  'Corr: ${res.correlation.toStringAsFixed(4)}, Eq: y = ${res.slope.toStringAsFixed(4)}x + ${res.intercept.toStringAsFixed(4)}',
            );
      } else {
        final res = StatisticsCalculator.calculateSingle(xValues);
        setState(() {
          _statResult = res;
          _regResult = null;
        });

        ref
            .read(historyServiceProvider)
            .logCalculation(
              moduleName: 'Statistics (Single)',
              category: 'Math & Academic',
              inputs: 'Data: ${_xController.text}',
              result:
                  'Mean: ${res.mean.toStringAsFixed(4)}, SD: ${res.stdDev.toStringAsFixed(4)}',
            );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isRegression ? 'Linear Regression' : 'Statistics Calculator',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isRegression ? Icons.show_chart : Icons.bar_chart),
            tooltip: 'Toggle Mode',
            onPressed: () {
              setState(() {
                _isRegression = !_isRegression;
                _statResult = null;
                _regResult = null;
              });
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                GlassTextField(
                  controller: _xController,
                  hintText: _isRegression
                      ? 'Enter X values (comma separated)'
                      : 'Enter dataset (comma separated)',
                  maxLines: 3,
                  keyboardType: TextInputType.text,
                ),
                if (_isRegression) ...[
                  const SizedBox(height: 16),
                  GlassTextField(
                    controller: _yController,
                    hintText: 'Enter Y values (comma separated)',
                    maxLines: 3,
                    keyboardType: TextInputType.text,
                  ),
                ],
                const SizedBox(height: 24),
                GlassButton(
                  onPressed: _calculate,
                  child: const Text('Calculate'),
                ),
                const SizedBox(height: 24),

                if (_statResult != null) _buildStatResult(theme),
                if (_regResult != null) _buildRegResult(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatResult(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildRow('Mean', _statResult!.mean.toStringAsFixed(4)),
          const Divider(),
          _buildRow('Median', _statResult!.median.toStringAsFixed(4)),
          const Divider(),
          _buildRow(
            'Mode',
            _statResult!.mode.isEmpty ? 'None' : _statResult!.mode.join(', '),
          ),
          const Divider(),
          _buildRow('Std Deviation', _statResult!.stdDev.toStringAsFixed(4)),
          const Divider(),
          _buildRow('Variance', _statResult!.variance.toStringAsFixed(4)),
          const Divider(),
          _buildRow('Q1 (25th Percentile)', _statResult!.q1.toStringAsFixed(4)),
          const Divider(),
          _buildRow('Q3 (75th Percentile)', _statResult!.q3.toStringAsFixed(4)),
        ],
      ),
    );
  }

  Widget _buildRegResult(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildRow(
            'Correlation (r)',
            _regResult!.correlation.toStringAsFixed(4),
          ),
          const Divider(),
          _buildRow(
            'R Squared (r²)',
            pow(_regResult!.correlation, 2).toStringAsFixed(4),
          ),
          const Divider(),
          _buildRow('Slope (m)', _regResult!.slope.toStringAsFixed(4)),
          const Divider(),
          _buildRow('Intercept (b)', _regResult!.intercept.toStringAsFixed(4)),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Linear Equation:', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            'y = ${_regResult!.slope.toStringAsFixed(4)}x + ${_regResult!.intercept.toStringAsFixed(4)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            val,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
