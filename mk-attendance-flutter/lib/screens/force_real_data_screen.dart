import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_colors.dart';

class ForceRealDataScreen extends StatefulWidget {
  const ForceRealDataScreen({super.key});

  @override
  State<ForceRealDataScreen> createState() => _ForceRealDataScreenState();
}

class _ForceRealDataScreenState extends State<ForceRealDataScreen> {
  List<Map<String, dynamic>> _realStudents = [];
  bool _isLoading = false;
  String? _error;
  String _apiResponse = '';

  @override
  void initState() {
    super.initState();
    _loadRealStudents();
  }

  Future<void> _loadRealStudents() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _apiResponse = '';
    });

    try {
      print('🔥 FORCE TEST: Calling your EXACT database API...');
      
      // Call your EXACT API endpoint
      final response = await http.get(
        Uri.parse('https://mk-attendance.vercel.app/api/students'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🔥 FORCE TEST: Response Status: ${response.statusCode}');
      print('🔥 FORCE TEST: Response Body: ${response.body}');

      setState(() {
        _apiResponse = 'Status: ${response.statusCode}\n\nResponse: ${response.body}';
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final students = List<Map<String, dynamic>>.from(data['data'] ?? []);
        
        print('🔥 FORCE TEST: Found ${students.length} students');
        
        setState(() {
          _realStudents = students;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'API Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔥 FORCE TEST ERROR: $e');
      setState(() {
        _error = 'Connection Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FORCE REAL DATA TEST'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadRealStudents,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _realStudents.isNotEmpty ? Colors.green : Colors.red,
            child: Column(
              children: [
                Text(
                  _realStudents.isNotEmpty 
                    ? '✅ SUCCESS: ${_realStudents.length} REAL STUDENTS LOADED'
                    : '❌ FAILED: NO REAL DATA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_error != null)
                  Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ),
          
          // Students List
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_realStudents.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _realStudents.length,
                itemBuilder: (context, index) {
                  final student = _realStudents[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          '${student['id']}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      title: Text(
                        student['full_name'] ?? 'No Name',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Class: ${student['class'] ?? 'No Class'}'),
                          Text('Phone: ${student['phone'] ?? 'No Phone'}'),
                        ],
                      ),
                      trailing: Text(
                        student['gender'] ?? 'N/A',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RAW API RESPONSE:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Text(
                        _apiResponse.isEmpty ? 'No response yet...' : _apiResponse,
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loadRealStudents,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.cloud_download),
        label: const Text('FORCE RELOAD'),
      ),
    );
  }
}