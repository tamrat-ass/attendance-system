import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';

import '../utils/ethiopian_date.dart';
import '../services/csv_export_service.dart';
import '../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedClass;
  String _startDate = DateTime.now().subtract(const Duration(days: 30)).toIso8601String().split('T')[0];
  String _endDate = DateTime.now().toIso8601String().split('T')[0];
  Map<String, Map<String, int>> _reportData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    await studentProvider.loadStudents();
    await studentProvider.loadClasses(); // Load classes from database
    
    if (studentProvider.classes.isNotEmpty && _selectedClass == null) {
      setState(() {
        _selectedClass = studentProvider.classes.first;
      });
      _generateReport();
    }
  }

  Future<void> _generateReport() async {
    if (_selectedClass == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      
      // Get report statistics from API
      final statistics = await apiService.getReportStatistics(
        startDate: _startDate,
        endDate: _endDate,
        className: _selectedClass,
      );

      // Convert API response to the format expected by the UI
      final Map<String, Map<String, int>> reportData = {};
      
      for (final stat in statistics) {
        final date = stat['date'] as String;
        reportData[date] = {
          'present': stat['present'] ?? 0,
          'absent': stat['absent'] ?? 0,
          'late': stat['late'] ?? 0,
          'permission': stat['permission'] ?? 0,
        };
      }

      setState(() {
        _reportData = reportData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_startDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.toIso8601String().split('T')[0];
      });
      _generateReport();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_endDate),
      firstDate: DateTime.parse(_startDate),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _endDate = picked.toIso8601String().split('T')[0];
      });
      _generateReport();
    }
  }

  Future<void> _exportReport() async {
    if (_reportData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No data to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await CsvExportService.exportAttendanceReport(
        _reportData,
        _selectedClass!,
        _startDate,
        _endDate,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report exported successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryWithOpacity(0.1),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                // Class Selection
                Consumer<StudentProvider>(
                  builder: (context, studentProvider, child) {
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedClass,
                      decoration: const InputDecoration(
                        labelText: 'Select Class',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: studentProvider.classes.map((className) {
                        return DropdownMenuItem(
                          value: className,
                          child: Text(className),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClass = value;
                        });
                        _generateReport();
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                
                // Date Range
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectStartDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                EthiopianDateUtils.formatDate(_startDate),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _selectEndDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                EthiopianDateUtils.formatDate(_endDate),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Generate Report Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generateReport,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.analytics),
                    label: const Text('Generate Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Report Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reportData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No attendance data found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select a class and date range to generate report',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Summary Cards
                            _buildSummaryCards(),
                            const SizedBox(height: 24),
                            
                            // Daily Report
                            Text(
                              'Daily Attendance Report',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDailyReport(),
                          ],
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: _reportData.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _exportReport,
              icon: const Icon(Icons.download),
              label: const Text('Export CSV'),
            )
          : null,
    );
  }

  Widget _buildSummaryCards() {
    // Calculate totals
    int totalPresent = 0;
    int totalAbsent = 0;
    int totalLate = 0;
    int totalPermission = 0;
    
    for (final dayData in _reportData.values) {
      totalPresent += dayData['present'] ?? 0;
      totalAbsent += dayData['absent'] ?? 0;
      totalLate += dayData['late'] ?? 0;
      totalPermission += dayData['permission'] ?? 0;
    }
    
    final totalDays = _reportData.length;
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Present',
            totalPresent.toString(),
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Absent',
            totalAbsent.toString(),
            AppColors.primary,
            Icons.cancel,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Late',
            totalLate.toString(),
            Colors.orange,
            Icons.access_time,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Permission',
            totalPermission.toString(),
            AppColors.primary,
            Icons.assignment_turned_in,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyReport() {
    final sortedDates = _reportData.keys.toList()..sort();
    
    return Card(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Present', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Absent', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Late', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Permission', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          
          // Data Rows
          ...sortedDates.map((date) {
            final dayData = _reportData[date]!;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      EthiopianDateUtils.formatDate(date),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(child: Text('${dayData['present'] ?? 0}')),
                  Expanded(child: Text('${dayData['absent'] ?? 0}')),
                  Expanded(child: Text('${dayData['late'] ?? 0}')),
                  Expanded(child: Text('${dayData['permission'] ?? 0}')),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}