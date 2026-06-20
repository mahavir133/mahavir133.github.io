import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../core/db/history_service.dart';
import '../utils/timestamp_logic.dart';

class TimestampScreen extends ConsumerStatefulWidget {
  const TimestampScreen({super.key});

  @override
  ConsumerState<TimestampScreen> createState() => _TimestampScreenState();
}

class _TimestampScreenState extends ConsumerState<TimestampScreen> {
  final TextEditingController _unixController = TextEditingController();
  TimestampResult? _result;

  @override
  void dispose() {
    _unixController.dispose();
    super.dispose();
  }

  void _convertUnix() {
    final timestamp = int.tryParse(_unixController.text);
    if (timestamp != null) {
      setState(() {
        _result = TimestampLogic.fromUnix(timestamp);
      });
      _logCalculation();
    }
  }

  void _setCurrentTime() {
    final now = DateTime.now();
    _unixController.text = (now.millisecondsSinceEpoch ~/ 1000).toString();
    _convertUnix();
  }

  void _logCalculation() {
    if (_result != null) {
      ref
          .read(historyServiceProvider)
          .logCalculation(
            moduleName: 'Timestamp',
            category: 'Date & Time',
            inputs: 'Unix: ${_unixController.text}',
            result: '${_result!.relativeTime}',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timestamp Converter'),
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
                  'Unix Epoch Timestamp',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _unixController,
                        hintText: 'e.g. 1672531199',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: _setCurrentTime,
                      icon: const Icon(Icons.access_time),
                      tooltip: 'Use Current Time',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.2,
                        ),
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                GlassButton(
                  onPressed: _convertUnix,
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
                          'Human Readable',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _result!.humanReadable,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'ISO 8601 Format',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _result!.iso8601,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Relative Time',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _result!.relativeTime,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
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
}
