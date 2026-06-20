import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../presentation/widgets/glass_container.dart';
import '../../../../presentation/widgets/glass_autocomplete.dart';
import '../../../../presentation/widgets/glass_button.dart';
import '../../../../presentation/widgets/glass_text_field.dart';
import '../../../../core/db/history_service.dart';
import '../utils/working_days_logic.dart';

class WorkingDaysScreen extends ConsumerStatefulWidget {
  const WorkingDaysScreen({super.key});

  @override
  ConsumerState<WorkingDaysScreen> createState() => _WorkingDaysScreenState();
}

class _WorkingDaysScreenState extends ConsumerState<WorkingDaysScreen> {
  DateTime _startDate = DateTime.now();
  final TextEditingController _daysToAdd = TextEditingController(text: '30');
  bool _excludeWeekends = true;
  String _region = 'None';

  WorkingDaysResult? _result;

  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final List<String> _regions = ['None', 'US', 'UK', 'IN'];

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _daysToAdd.dispose();
    super.dispose();
  }

  void _calculate() {
    final days = int.tryParse(_daysToAdd.text) ?? 0;

    // Generate holidays based on selected region for current and next year
    List<DateTime> holidays = [];
    if (_region != 'None') {
      holidays.addAll(
        WorkingDaysLogic.getStandardHolidays(_startDate.year, _region),
      );
      holidays.addAll(
        WorkingDaysLogic.getStandardHolidays(_startDate.year + 1, _region),
      );
    }

    setState(() {
      _result = WorkingDaysLogic.addWorkingDays(
        startDate: _startDate,
        daysToAdd: days,
        excludeWeekends: _excludeWeekends,
        customHolidays: holidays,
      );
    });

    ref
        .read(historyServiceProvider)
        .logCalculation(
          moduleName: 'Working Days',
          category: 'Date & Time',
          inputs: '${_dateFormat.format(_startDate)} + $days days',
          result: '${_dateFormat.format(_result!.targetDate)}',
        );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
      _calculate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Working Days Calculator'),
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
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Date',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _dateFormat.format(_startDate),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                GlassTextField(
                  controller: _daysToAdd,
                  hintText: 'Days to Add (Use negative to subtract)',
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                ),

                const SizedBox(height: 24),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Exclude Weekends',
                        style: TextStyle(fontSize: 16),
                      ),
                      Switch(
                        value: _excludeWeekends,
                        onChanged: (val) {
                          setState(() {
                            _excludeWeekends = val;
                          });
                        },
                        activeColor: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    'Exclude Standard Holidays For Region',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassAutocomplete<String>(
                    options: _regions,
                    initialValue: _region,
                    displayStringForOption: (val) => val,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _region = val;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 32),
                GlassButton(
                  onPressed: _calculate,
                  child: const Text('Calculate Target Date'),
                ),

                if (_result != null) ...[
                  const SizedBox(height: 32),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Target Date',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            _dateFormat.format(_result!.targetDate),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            DateFormat(
                              'EEEE',
                            ).format(_result!.targetDate), // Day of week
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        _buildResultRow(
                          'Total Calendar Days Passed',
                          '${_result!.totalCalendarDays}',
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

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
