import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';

class StopwatchTimerScreen extends ConsumerStatefulWidget {
  const StopwatchTimerScreen({super.key});

  @override
  ConsumerState<StopwatchTimerScreen> createState() =>
      _StopwatchTimerScreenState();
}

class _StopwatchTimerScreenState extends ConsumerState<StopwatchTimerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Stopwatch state
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _stopwatchTimer;
  List<String> _laps = [];

  // Timer state
  Timer? _countdownTimer;
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;

  final TextEditingController _timerMinController = TextEditingController(
    text: '0',
  );
  final TextEditingController _timerSecController = TextEditingController(
    text: '0',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stopwatchTimer?.cancel();
    _countdownTimer?.cancel();
    _timerMinController.dispose();
    _timerSecController.dispose();
    super.dispose();
  }

  // --- STOPWATCH METHODS ---
  void _startStopwatch() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _stopwatchTimer = Timer.periodic(const Duration(milliseconds: 30), (
        timer,
      ) {
        if (mounted) setState(() {});
      });
    } else {
      _stopwatch.stop();
      _stopwatchTimer?.cancel();
      if (mounted) setState(() {});
    }
  }

  void _resetStopwatch() {
    _stopwatch.stop();
    _stopwatch.reset();
    _stopwatchTimer?.cancel();
    _laps.clear();
    setState(() {});
  }

  void _recordLap() {
    if (_stopwatch.isRunning) {
      final elapsed = _stopwatch.elapsed;
      final formatted = _formatDuration(elapsed, true);
      setState(() {
        _laps.insert(0, formatted);
      });
    }
  }

  String _formatDuration(Duration d, bool includeMillis) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final min = twoDigits(d.inMinutes.remainder(60));
    final sec = twoDigits(d.inSeconds.remainder(60));
    if (includeMillis) {
      final millis = (d.inMilliseconds.remainder(1000) ~/ 10)
          .toString()
          .padLeft(2, '0');
      if (d.inHours > 0) {
        return '${twoDigits(d.inHours)}:$min:$sec.$millis';
      }
      return '$min:$sec.$millis';
    } else {
      if (d.inHours > 0) {
        return '${twoDigits(d.inHours)}:$min:$sec';
      }
      return '$min:$sec';
    }
  }

  // --- TIMER METHODS ---
  void _startPauseTimer() {
    if (_isTimerRunning) {
      _countdownTimer?.cancel();
      setState(() => _isTimerRunning = false);
    } else {
      if (_remainingSeconds == 0) {
        int m = int.tryParse(_timerMinController.text) ?? 0;
        int s = int.tryParse(_timerSecController.text) ?? 0;
        _totalSeconds = (m * 60) + s;
        _remainingSeconds = _totalSeconds;
      }

      if (_remainingSeconds > 0) {
        setState(() => _isTimerRunning = true);
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_remainingSeconds > 0) {
            setState(() => _remainingSeconds--);
          } else {
            _countdownTimer?.cancel();
            setState(() => _isTimerRunning = false);
            // Optionally play a sound here
          }
        });
      }
    }
  }

  void _resetTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _remainingSeconds = 0;
      _totalSeconds = 0;
    });
  }

  void _setPomodoro() {
    _resetTimer();
    setState(() {
      _timerMinController.text = '25';
      _timerSecController.text = '0';
      _totalSeconds = 25 * 60;
      _remainingSeconds = _totalSeconds;
    });
  }

  String _formatRemaining() {
    int m = _remainingSeconds ~/ 60;
    int s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch & Timer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stopwatch', icon: Icon(Icons.timer)),
            Tab(text: 'Timer', icon: Icon(Icons.hourglass_bottom)),
          ],
        ),
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
          child: TabBarView(
            controller: _tabController,
            children: [_buildStopwatchTab(theme), _buildTimerTab(theme)],
          ),
        ),
      ),
    );
  }

  Widget _buildStopwatchTab(ThemeData theme) {
    final displayTime = _formatDuration(_stopwatch.elapsed, true);

    return Column(
      children: [
        const SizedBox(height: 40),
        Text(
          displayTime,
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              heroTag: 'sw_reset',
              onPressed: _resetStopwatch,
              backgroundColor: Colors.grey.shade800,
              child: const Icon(Icons.stop),
            ),
            const SizedBox(width: 24),
            FloatingActionButton.large(
              heroTag: 'sw_start',
              onPressed: _startStopwatch,
              backgroundColor: _stopwatch.isRunning
                  ? Colors.red
                  : theme.colorScheme.primary,
              child: Icon(
                _stopwatch.isRunning ? Icons.pause : Icons.play_arrow,
              ),
            ),
            const SizedBox(width: 24),
            FloatingActionButton(
              heroTag: 'sw_lap',
              onPressed: _stopwatch.isRunning ? _recordLap : null,
              backgroundColor: Colors.grey.shade800,
              child: const Icon(Icons.flag),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _laps.length,
            itemBuilder: (context, index) {
              return GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lap ${_laps.length - index}',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    Text(
                      _laps[index],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimerTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          if (_remainingSeconds > 0 || _isTimerRunning) ...[
            Text(
              _formatRemaining(),
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeInput(_timerMinController, 'Min'),
                const Text(
                  ' : ',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                _buildTimeInput(_timerSecController, 'Sec'),
              ],
            ),
          ],

          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: 't_reset',
                onPressed: _resetTimer,
                backgroundColor: Colors.grey.shade800,
                child: const Icon(Icons.stop),
              ),
              const SizedBox(width: 24),
              FloatingActionButton.large(
                heroTag: 't_start',
                onPressed: _startPauseTimer,
                backgroundColor: _isTimerRunning
                    ? Colors.red
                    : theme.colorScheme.primary,
                child: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
              ),
            ],
          ),

          const SizedBox(height: 60),
          ElevatedButton.icon(
            onPressed: _setPomodoro,
            icon: const Icon(Icons.local_cafe),
            label: const Text('25-Minute Pomodoro'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
              foregroundColor: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInput(TextEditingController controller, String label) {
    return SizedBox(
      width: 100,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
