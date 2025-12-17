import 'package:flutter/material.dart';
import '../services/direct_database_service.dart';
import '../utils/app_colors.dart';

class DebugDatabaseScreen extends StatefulWidget {
  const DebugDatabaseScreen({super.key});

  @override
  State<DebugDatabaseScreen> createState() => _DebugDatabaseScreenState();
}

class _DebugDatabaseScreenState extends State<DebugDatabaseScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _students = [];
  List<String> _classes = [];
  Map<String, dynamic> _dbInfo = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDatabaseData();
  }

  Future<void> _loadDatabaseData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Test database connection
      final dbInfo = await DirectDatabaseService.getDatabaseInfo();
      
      // Load students
      final students = await DirectDatabaseService.getStudentsFromTable();
      
      // Load classes
      final classes = await DirectDatabaseService.getClassesFromTable();

      setState(() {
        _dbInfo = dbInfo;
        _students = students;
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadDatabaseData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDatabaseData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Database Info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Database Connection Info',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              ..._dbInfo.entries.map((entry) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text('${entry.key}: ${entry.value}'),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Students Count
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Students Data',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text('Total Students: ${_students.length}'),
                              const SizedBox(height: 8),
                              if (_students.isNotEmpty) ...[
                                const Text('First 10 students:'),
                                const SizedBox(height: 8),
                                ..._students.take(10).map((student) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Text(
                                        '${student['id']}: ${student['full_name']} - ${student['class']}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    )),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Classes
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Classes Data',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text('Total Classes: ${_classes.length}'),
                              const SizedBox(height: 8),
                              ..._classes.map((className) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text('• $className'),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Raw Data Button
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Raw Students Data'),
                              content: SizedBox(
                                width: double.maxFinite,
                                height: 400,
                                child: SingleChildScrollView(
                                  child: Text(
                                    _students.toString(),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Show Raw Data'),
                      ),
                    ],
                  ),
                ),
    );
  }
}