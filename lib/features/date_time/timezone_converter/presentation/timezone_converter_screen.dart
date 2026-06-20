import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../core/db/history_service.dart';
import '../utils/timezone_logic.dart';

class TimezoneConverterScreen extends ConsumerStatefulWidget {
  const TimezoneConverterScreen({super.key});

  @override
  ConsumerState<TimezoneConverterScreen> createState() =>
      _TimezoneConverterScreenState();
}

class _TimezoneConverterScreenState
    extends ConsumerState<TimezoneConverterScreen> {
  String _sourceZone = 'UTC';
  String _targetZone = 'America/New_York';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  late List<String> _availableZones;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final DateFormat _timeFormat = DateFormat('hh:mm a');

  @override
  void initState() {
    super.initState();
    _availableZones = TimeZoneLogic.getAvailableTimeZones();
    // Default to local if available
    try {
      final local = tz.local.name;
      if (_availableZones.contains(local)) {
        _sourceZone = local;
      }
    } catch (e) {
      // Local timezone might not be configured, default to UTC
    }
  }

  void _logCalculation(tz.TZDateTime target) {
    ref
        .read(historyServiceProvider)
        .logCalculation(
          moduleName: 'Time Zone',
          category: 'Date & Time',
          inputs: '$_sourceZone to $_targetZone',
          result: '${_timeFormat.format(target)}',
        );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Create the actual DateTime object from selected date and time
    final sourceDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final convertedTime = TimeZoneLogic.convertTime(
      time: sourceDateTime,
      fromZoneName: _sourceZone,
      toZoneName: _targetZone,
    );

    // Call logger after build occasionally? Actually let's just log on button press to "Save to history", or just rely on state.
    // Let's add a button to explicitly log if needed, or we just auto-log when changing zones.
    // A save button is cleaner for history.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Zone Converter'),
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
                _buildSectionHeader('Source Time'),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _dateFormat.format(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickTime,
                        child: GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Time',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedTime.format(context),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Source Time Zone'),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: _availableZones,
                    initialValue: _sourceZone,
                    displayStringForOption: (val) => val,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _sourceZone = val;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 32),
                const Icon(Icons.swap_vert, size: 40, color: Colors.grey),
                const SizedBox(height: 16),

                _buildSectionHeader('Target Time Zone'),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: _availableZones,
                    initialValue: _targetZone,
                    displayStringForOption: (val) => val,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _targetZone = val;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 32),
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        _targetZone,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _timeFormat.format(convertedTime),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _dateFormat.format(convertedTime),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        convertedTime.timeZoneName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _logCalculation(convertedTime),
                  icon: const Icon(Icons.history),
                  label: const Text('Save to History'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}
