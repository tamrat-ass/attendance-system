import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/student_provider.dart';
import '../services/api_service.dart';

class SimpleReportsScreen extends StatefulWidget {
  const SimpleReportsScreen({super.key});

  @override
  State<SimpleReportsScreen> createState() => _SimpleReportsScreenState();
}

class _SimpleReportsScreenState extends State<SimpleReportsScreen> {
  bool _isLoading = false;
  String? _selectedClass;
  Map<String, dynamic> _reportData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    await studentProvider.loadStudents();
    await studentProvider.loadClasses();
    
    if (studentProvider.classes.isNotEmpty) {
      setState(() {
        _selectedClass = studentProvider.classes.first;
      });
    }
  }

  Future<void> _generateReport() async {
    if (_selectedClass == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final reports = await apiService.getReports(
        startDate: DateTime.now().subtract(const Duration(days: 7)).toIso8601String().split('T')[0],
        endDate: DateTime.now().toIso8601String().split('T')[0],
        className: _selectedClass,
      );

      setState(() {
        _reportData = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B4513),
              ),
            ),
            const SizedBox(height: 20),
            
            // Class Selection
            Consumer<StudentProvider>(
              builder: (context, studentProvider, child) {
                if (studentProvider.classes.isEmpty) {
                  return const Text('Loading classes...');
                }
                
                return DropdownButtonFormField<String>(
                  initialValue: _selectedClass,
                  decoration: const InputDecoration(
                    labelText: 'Select Class',
                    border: OutlineInputBorder(),
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
                  },
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Generate Report Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Generate Report'),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Report Results
            Expanded(
              child: _reportData.isEmpty
                  ? const Center(
                      child: Text(
                        'No report data available.\nSelect a class and generate report.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Report Results:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _reportData.toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}