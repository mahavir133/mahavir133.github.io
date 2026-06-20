import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/matrix_calculator.dart';

class MatrixScreen extends ConsumerStatefulWidget {
  const MatrixScreen({super.key});

  @override
  ConsumerState<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends ConsumerState<MatrixScreen> {
  int _rowsA = 2;
  int _colsA = 2;
  int _rowsB = 2;
  int _colsB = 2;

  String _operation = 'A + B';
  dynamic _result;
  String? _error;

  late List<List<TextEditingController>> _matrixAControllers;
  late List<List<TextEditingController>> _matrixBControllers;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _matrixAControllers = List.generate(
      _rowsA,
      (_) => List.generate(_colsA, (_) => TextEditingController(text: '0')),
    );
    _matrixBControllers = List.generate(
      _rowsB,
      (_) => List.generate(_colsB, (_) => TextEditingController(text: '0')),
    );
  }

  void _rebuildA() {
    final newControllers = List.generate(
      _rowsA,
      (r) => List.generate(_colsA, (c) {
        if (r < _matrixAControllers.length &&
            c < _matrixAControllers[0].length) {
          return _matrixAControllers[r][c];
        }
        return TextEditingController(text: '0');
      }),
    );
    setState(() => _matrixAControllers = newControllers);
  }

  void _rebuildB() {
    final newControllers = List.generate(
      _rowsB,
      (r) => List.generate(_colsB, (c) {
        if (r < _matrixBControllers.length &&
            c < _matrixBControllers[0].length) {
          return _matrixBControllers[r][c];
        }
        return TextEditingController(text: '0');
      }),
    );
    setState(() => _matrixBControllers = newControllers);
  }

  void _calculate() {
    setState(() => _error = null);
    try {
      final a = _matrixAControllers
          .map((row) => row.map((c) => double.tryParse(c.text) ?? 0.0).toList())
          .toList();
      final b = _matrixBControllers
          .map((row) => row.map((c) => double.tryParse(c.text) ?? 0.0).toList())
          .toList();

      dynamic res;
      switch (_operation) {
        case 'A + B':
          res = MatrixCalculator.add(a, b);
          break;
        case 'A - B':
          res = MatrixCalculator.subtract(a, b);
          break;
        case 'A * B':
          res = MatrixCalculator.multiply(a, b);
          break;
        case 'Transpose A':
          res = MatrixCalculator.transpose(a);
          break;
        case 'Determinant A':
          res = MatrixCalculator.determinant(a);
          break;
        case 'Inverse A':
          res = MatrixCalculator.inverse(a);
          break;
      }

      setState(() => _result = res);

      ref
          .read(historyServiceProvider)
          .logCalculation(
            moduleName: 'Matrix Calculator',
            category: 'Math & Academic',
            inputs: 'Op: $_operation (${_rowsA}x$_colsA)',
            result: res is List<List<double>>
                ? 'Matrix calculated'
                : res.toString(),
          );
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnary = _operation.contains('A') && !_operation.contains('B');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matrix Calculator'),
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

                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: const [
                      'A + B',
                      'A - B',
                      'A * B',
                      'Transpose A',
                      'Determinant A',
                      'Inverse A',
                    ],
                    initialValue: _operation,
                    displayStringForOption: (val) {
                      if (val == 'A + B') return 'Add (A + B)';
                      if (val == 'A - B') return 'Subtract (A - B)';
                      if (val == 'A * B') return 'Multiply (A * B)';
                      if (val == 'Transpose A') return 'Transpose of A';
                      if (val == 'Determinant A') return 'Determinant of A';
                      return 'Inverse of A';
                    },
                    onChanged: (val) {
                      if (val != null)
                        setState(() {
                          _operation = val;
                          _result = null;
                        });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                _buildMatrixEditor('Matrix A', _rowsA, _colsA, (r, c) {
                  _rowsA = r;
                  _colsA = c;
                  _rebuildA();
                }, _matrixAControllers),

                if (!isUnary) ...[
                  const SizedBox(height: 24),
                  _buildMatrixEditor('Matrix B', _rowsB, _colsB, (r, c) {
                    _rowsB = r;
                    _colsB = c;
                    _rebuildB();
                  }, _matrixBControllers),
                ],

                const SizedBox(height: 24),
                GlassButton(
                  onPressed: _calculate,
                  child: const Text('Calculate'),
                ),
                const SizedBox(height: 24),
                if (_result != null) _buildResultView(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatrixEditor(
    String title,
    int rows,
    int cols,
    Function(int, int) onChanged,
    List<List<TextEditingController>> controllers,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _buildDimAdjuster('R', rows, (v) => onChanged(v, cols)),
                  const Text(' x '),
                  _buildDimAdjuster('C', cols, (v) => onChanged(rows, v)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (int r = 0; r < rows; r++) ...[
            Row(
              children: [
                for (int c = 0; c < cols; c++) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: GlassTextField(
                        controller: controllers[r][c],
                        hintText: '',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDimAdjuster(String label, int val, Function(int) onChanged) {
    return Row(
      children: [
        Text(label),
        IconButton(
          icon: const Icon(Icons.remove, size: 16),
          onPressed: val > 1 ? () => onChanged(val - 1) : null,
        ),
        Text('$val'),
        IconButton(
          icon: const Icon(Icons.add, size: 16),
          onPressed: val < 5
              ? () => onChanged(val + 1)
              : null, // Limit to 5x5 in UI for spacing reasons, even if logic handles 10x10
        ),
      ],
    );
  }

  Widget _buildResultView(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Result', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          if (_result is double)
            Text(
              (_result as double).toStringAsFixed(4),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            )
          else if (_result is List<List<double>>)
            Text(
              MatrixCalculator.matrixToString(_result),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
