import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_engine/math_engine.dart';
import '../provider/providers.dart';
import 'app_shell.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  final bool isScientificMode;

  const CalculatorScreen({super.key, required this.isScientificMode});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Tab 0 is standard, Tab 1 is scientific
    _pageController = PageController(initialPage: widget.isScientificMode ? 1 : 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CalculatorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync PageView when Tab changes
    final targetPage = widget.isScientificMode ? 1 : 0;
    if (_pageController.hasClients && _pageController.page?.round() != targetPage) {
      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    // List of programmer bases to render
    final isProgrammer = state.programmerBase != NumberBase.dec;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isProgrammer
              ? 'Programmer Calculator'
              : (widget.isScientificMode ? 'Scientific Calculator' : 'Standard Calculator'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Degree/Radian toggle for scientific mode
          if (widget.isScientificMode)
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                notifier.toggleDegreeMode();
              },
              child: Text(
                state.isDegreeMode ? 'DEG' : 'RAD',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          // Programmer mode switch
          IconButton(
            icon: Icon(
              isProgrammer ? Icons.terminal : Icons.terminal_outlined,
              color: isProgrammer ? Theme.of(context).colorScheme.primary : null,
            ),
            tooltip: 'Programmer Mode',
            onPressed: () {
              HapticFeedback.lightImpact();
              if (isProgrammer) {
                notifier.setProgrammerBase(NumberBase.dec);
              } else {
                notifier.setProgrammerBase(NumberBase.hex); // default to Hex
              }
            },
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;

          // If landscape, we merge standard and scientific into a side-by-side layout
          if (isLandscape) {
            return _buildLandscapeLayout(context, state, notifier);
          }

          // Portrait layout with Swipe integration
          return Column(
            children: [
              _buildDisplay(context, state),
              if (isProgrammer) _buildBaseSelector(context, state, notifier),
              const Divider(height: 1),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (pageIndex) {
                    ref.read(currentTabProvider.notifier).state = pageIndex;
                  },
                  children: [
                    _buildStandardKeypad(context, state, notifier),
                    _buildScientificKeypad(context, state, notifier),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ----------------------------------------------------
  // Helper UI Sub-components
  // ----------------------------------------------------

  Widget _buildDisplay(BuildContext context, CalculatorState state) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      alignment: Alignment.bottomRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Formula input
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Text(
              state.expression.isEmpty ? ' ' : state.expression,
              style: TextStyle(
                fontSize: 28,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Result
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Text(
              state.result,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: state.errorMessage != null
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseSelector(BuildContext context, CalculatorState state, CalculatorNotifier notifier) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: NumberBase.values.map((base) {
          final isSelected = state.programmerBase == base;
          return ChoiceChip(
            label: Text(base.name.toUpperCase()),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                HapticFeedback.lightImpact();
                notifier.setProgrammerBase(base);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  // Standard Grid Keypad
  Widget _buildStandardKeypad(BuildContext context, CalculatorState state, CalculatorNotifier notifier) {
    final keys = [
      'C', '(', ')', '⌫',
      '7', '8', '9', '/',
      '4', '5', '6', '*',
      '1', '2', '3', '-',
      '0', '.', '%', '+',
      '='
    ];

    return _buildKeyGrid(context, keys, state, notifier);
  }

  // Scientific Grid Keypad
  Widget _buildScientificKeypad(BuildContext context, CalculatorState state, CalculatorNotifier notifier) {
    final keys = [
      'sin', 'cos', 'tan', '⌫',
      'asin', 'acos', 'atan', '^',
      'ln', 'log', 'logBase', '!',
      'sqrt', 'cbrt', 'nPr', 'nCr',
      'pi', 'e', 'N_A', 'c',
      'h', 'C', '='
    ];

    return _buildKeyGrid(context, keys, state, notifier, columns: 4);
  }

  // Programmer Grid Keypad
  Widget _buildProgrammerKeypad(BuildContext context, CalculatorState state, CalculatorNotifier notifier) {
    final keys = [
      'A', 'B', 'C', '⌫',
      'D', 'E', 'F', 'C',
      '&', '|', '^', '~',
      '<<', '>>', '7', '8',
      '9', '4', '5', '6',
      '1', '2', '3', '0',
      '='
    ];

    return _buildKeyGrid(context, keys, state, notifier, columns: 4);
  }

  Widget _buildKeyGrid(
    BuildContext context,
    List<String> keys,
    CalculatorState state,
    CalculatorNotifier notifier, {
    int columns = 4,
  }) {
    return GridView(
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: columns == 4 ? 1.3 : 1.1,
      ),
      children: keys.map((key) {
        final enabled = _isKeyEnabled(key, state.programmerBase);
        return _buildButton(context, key, enabled, notifier);
      }).toList(),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    bool enabled,
    CalculatorNotifier notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    Color bg;
    Color fg;

    final isOp = ['+', '-', '*', '/', '%', '^', '&', '|', '<<', '>>', '~'].contains(text);

    if (!enabled) {
      bg = colorScheme.surfaceVariant.withOpacity(0.2);
      fg = colorScheme.onSurface.withOpacity(0.2);
    } else if (text == '=') {
      bg = colorScheme.primary;
      fg = colorScheme.onPrimary;
    } else if (text == 'C' || text == '⌫') {
      bg = colorScheme.errorContainer;
      fg = colorScheme.onErrorContainer;
    } else if (isOp) {
      bg = colorScheme.primaryContainer;
      fg = colorScheme.onPrimaryContainer;
    } else {
      bg = colorScheme.surfaceVariant;
      fg = colorScheme.onSurfaceVariant;
    }

    return ScaleButton(
      onPressed: enabled
          ? () {
              HapticFeedback.lightImpact();
              if (text == 'C') {
                notifier.clear();
              } else if (text == '⌫') {
                notifier.backspace();
              } else if (text == '=') {
                notifier.evaluate();
              } else {
                // Formatting function appends
                if (['sin', 'cos', 'tan', 'asin', 'acos', 'atan', 'ln', 'log', 'sqrt', 'cbrt', 'abs'].contains(text)) {
                  notifier.append('$text(');
                } else if (text == 'logBase' || text == 'nPr' || text == 'nCr') {
                  notifier.append('$text(');
                } else {
                  notifier.append(text);
                }
              }
            }
          : null,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: text.length > 3 ? 16 : 22,
            fontWeight: FontWeight.bold,
            color: fg,
          ),
        ),
      ),
    );
  }

  bool _isKeyEnabled(String key, NumberBase base) {
    if (base == NumberBase.dec) return true;

    // Programmer base validations:
    // Hex: all standard hex digits enabled
    if (base == NumberBase.hex) {
      if (['.', '%'].contains(key)) return false; // base float/modulo not supported
      return true;
    }

    // Binary: only 0, 1, action keys, bitwise ops enabled
    if (base == NumberBase.bin) {
      final binValids = ['0', '1', 'C', '⌫', '=', '&', '|', '^', '~', '<<', '>>'];
      return binValids.contains(key) || _isHexLetter(key) == false;
    }

    // Octal: only 0-7, action keys, bitwise ops enabled
    if (base == NumberBase.oct) {
      if (['8', '9'].contains(key)) return false;
      if (['.', '%'].contains(key)) return false;
      if (_isHexLetter(key)) return false;
      return true;
    }

    // Decimal (programmer variant): hex letters disabled
    if (_isHexLetter(key)) return false;
    if (['.', '%'].contains(key)) return false;
    return true;
  }

  bool _isHexLetter(String key) {
    return ['A', 'B', 'C', 'D', 'E', 'F'].contains(key) && key.length == 1;
  }

  // Landscape Layout (side by side standard + scientific)
  Widget _buildLandscapeLayout(
    BuildContext context,
    CalculatorState state,
    CalculatorNotifier notifier,
  ) {
    final isProg = state.programmerBase != NumberBase.dec;

    return Column(
      children: [
        Expanded(child: _buildDisplay(context, state)),
        if (isProg) _buildBaseSelector(context, state, notifier),
        const Divider(height: 1),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              // Left half: Scientific or Programmer controls
              Expanded(
                child: isProg
                    ? _buildProgrammerKeypad(context, state, notifier)
                    : _buildScientificKeypad(context, state, notifier),
              ),
              const VerticalDivider(width: 1),
              // Right half: Standard Keypad
              Expanded(
                child: _buildStandardKeypad(context, state, notifier),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------
// Custom Scale Button for Micro-Animations
// ----------------------------------------------------

class ScaleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const ScaleButton({super.key, this.onPressed, required this.child});

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    _scale = 1.0;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 70),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1.0 - _controller.value;

    return GestureDetector(
      onTapDown: widget.onPressed != null
          ? (_) {
              _controller.forward();
            }
          : null,
      onTapUp: widget.onPressed != null
          ? (_) {
              _controller.reverse();
              widget.onPressed!();
            }
          : null,
      onTapCancel: widget.onPressed != null
          ? () {
              _controller.reverse();
            }
          : null,
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
