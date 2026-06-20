import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../core/db/history_service.dart';
import '../utils/equation_solver.dart';

class EquationSolverScreen extends ConsumerStatefulWidget {
  const EquationSolverScreen({super.key});

  @override
  ConsumerState<EquationSolverScreen> createState() =>
      _EquationSolverScreenState();
}

class _EquationSolverScreenState extends ConsumerState<EquationSolverScreen> {
  String _mode = 'Quadratic';
  List<TextEditingController> _controllers = [];
  dynamic _result;

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    for (var c in _controllers) {
      c.dispose();
    }
    int count = 0;
    if (_mode == 'Linear')
      count = 2; // a, b
    else if (_mode == 'Quadratic')
      count = 3; // a, b, c
    else if (_mode == 'System (2 Vars)')
      count = 6; // a1,b1,c1, a2,b2,c2

    _controllers = List.generate(count, (_) => TextEditingController());
    _result = null;
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    super.dispose();
  }

  void _calculate() {
    final values = _controllers
        .map((c) => double.tryParse(c.text) ?? 0)
        .toList();

    dynamic res;
    String inputLog = '';

    if (_mode == 'Linear') {
      res = EquationSolver.solveLinear(values[0], values[1]);
      inputLog = '${values[0]}x + ${values[1]} = 0';
    } else if (_mode == 'Quadratic') {
      res = EquationSolver.solveQuadratic(values[0], values[1], values[2]);
      inputLog = '${values[0]}x² + ${values[1]}x + ${values[2]} = 0';
    } else if (_mode == 'System (2 Vars)') {
      res = EquationSolver.solveSystem2(
        values[0],
        values[1],
        values[2],
        values[3],
        values[4],
        values[5],
      );
      inputLog =
          '${values[0]}x + ${values[1]}y = ${values[2]} | ${values[3]}x + ${values[4]}y = ${values[5]}';
    }

    setState(() => _result = res);

    ref
        .read(historyServiceProvider)
        .logCalculation(
          moduleName: 'Equation Solver',
          category: 'Math & Academic',
          inputs: inputLog,
          result: (res is List) ? res.join(', ') : res.toString(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equation Solver'),
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
              children: [
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: const ['Linear', 'Quadratic', 'System (2 Vars)'],
                    initialValue: _mode,
                    displayStringForOption: (val) {
                      if (val == 'Linear') return 'Linear (ax + b = 0)';
                      if (val == 'Quadratic')
                        return 'Quadratic (ax² + bx + c = 0)';
                      return 'System of 2 Equations';
                    },
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _mode = val;
                          _setupControllers();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),
                ..._buildInputs(),
                const SizedBox(height: 24),
                GlassButton(onPressed: _calculate, child: const Text('Solve')),
                const SizedBox(height: 24),
                if (_result != null) _buildResultView(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildInputs() {
    List<Widget> widgets = [];
    if (_mode == 'Linear' || _mode == 'Quadratic') {
      List<String> labels = _mode == 'Linear'
          ? ['a (coef of x)', 'b (constant)']
          : ['a (coef of x²)', 'b (coef of x)', 'c (constant)'];
      for (int i = 0; i < labels.length; i++) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: GlassTextField(
              controller: _controllers[i],
              hintText: labels[i],
            ),
          ),
        );
      }
    } else if (_mode == 'System (2 Vars)') {
      widgets.add(
        const Text(
          'Equation 1: a1x + b1y = c1',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      widgets.add(
        Row(
          children: [
            Expanded(
              child: GlassTextField(
                controller: _controllers[0],
                hintText: 'a1',
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: GlassTextField(
                controller: _controllers[1],
                hintText: 'b1',
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: GlassTextField(
                controller: _controllers[2],
                hintText: 'c1',
              ),
            ),
          ],
        ),
      );
      widgets.add(const SizedBox(height: 16));
      widgets.add(
        const Text(
          'Equation 2: a2x + b2y = c2',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      widgets.add(
        Row(
          children: [
            Expanded(
              child: GlassTextField(
                controller: _controllers[3],
                hintText: 'a2',
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: GlassTextField(
                controller: _controllers[4],
                hintText: 'b2',
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: GlassTextField(
                controller: _controllers[5],
                hintText: 'c2',
              ),
            ),
          ],
        ),
      );
    }
    return widgets;
  }

  Widget _buildResultView(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Solution', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          if (_result is String)
            Text(
              _result,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            )
          else if (_result is List)
            ...(_result as List).map(
              (r) => Text(
                r,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
