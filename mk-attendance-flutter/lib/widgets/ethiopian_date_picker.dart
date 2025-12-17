import 'package:flutter/material.dart';
import '../utils/correct_ethiopian_date.dart';

class EthiopianDatePicker extends StatefulWidget {
  final Map<String, int>? initialDate;
  final Function(Map<String, int>) onDateSelected;
  final String label;

  const EthiopianDatePicker({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    required this.label,
  });

  @override
  State<EthiopianDatePicker> createState() => _EthiopianDatePickerState();
}

class _EthiopianDatePickerState extends State<EthiopianDatePicker> {
  late Map<String, int> _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? CorrectEthiopianDateUtils.getCurrentEthiopianDate();
  }

  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (context) => _EthiopianDatePickerDialog(
        initialDate: _selectedDate,
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
          });
          widget.onDateSelected(date);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showDatePicker,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          CorrectEthiopianDateUtils.formatEthiopianDate(_selectedDate),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class _EthiopianDatePickerDialog extends StatefulWidget {
  final Map<String, int> initialDate;
  final Function(Map<String, int>) onDateSelected;

  const _EthiopianDatePickerDialog({
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<_EthiopianDatePickerDialog> createState() => _EthiopianDatePickerDialogState();
}

class _EthiopianDatePickerDialogState extends State<_EthiopianDatePickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate['year']!;
    _selectedMonth = widget.initialDate['month']!;
    _selectedDay = widget.initialDate['day']!;
  }

  int _getMaxDaysInMonth(int month) {
    if (month == 13) return 6; // Pagumen has 6 days
    return 30; // All other months have 30 days
  }

  @override
  Widget build(BuildContext context) {
    final maxDays = _getMaxDaysInMonth(_selectedMonth);
    
    // Ensure selected day is valid for the month
    if (_selectedDay > maxDays) {
      _selectedDay = maxDays;
    }

    return AlertDialog(
      title: const Text('የቀን መምረጫ'),
      content: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          children: [
            // Year Picker
            Row(
              children: [
                const Text('ዓመት: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    isExpanded: true,
                    items: List.generate(10, (index) {
                      final year = DateTime.now().year - 7 - 5 + index; // Current Ethiopian year ± 5
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Month Picker
            Row(
              children: [
                const Text('ወር: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: DropdownButton<int>(
                    value: _selectedMonth,
                    isExpanded: true,
                    items: List.generate(13, (index) {
                      final monthIndex = index + 1;
                      final monthName = CorrectEthiopianDateUtils.ethiopianMonths[index];
                      return DropdownMenuItem(
                        value: monthIndex,
                        child: Text('$monthIndex. $monthName'),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value!;
                        // Adjust day if it exceeds the new month's max days
                        final maxDays = _getMaxDaysInMonth(_selectedMonth);
                        if (_selectedDay > maxDays) {
                          _selectedDay = maxDays;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Day Picker
            Row(
              children: [
                const Text('ቀን: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: DropdownButton<int>(
                    value: _selectedDay,
                    isExpanded: true,
                    items: List.generate(maxDays, (index) {
                      final day = index + 1;
                      return DropdownMenuItem(
                        value: day,
                        child: Text(day.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedDay = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Selected Date Display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    'የተመረጠው ቀን:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CorrectEthiopianDateUtils.formatEthiopianDate({
                      'year': _selectedYear,
                      'month': _selectedMonth,
                      'day': _selectedDay,
                    }),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ሰርዝ'),
        ),
        ElevatedButton(
          onPressed: () {
            final selectedDate = {
              'year': _selectedYear,
              'month': _selectedMonth,
              'day': _selectedDay,
            };
            widget.onDateSelected(selectedDate);
            Navigator.pop(context);
          },
          child: const Text('ምረጥ'),
        ),
      ],
    );
  }
}