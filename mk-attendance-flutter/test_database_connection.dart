import 'dart:convert';
import 'package:http/http.dart' as http;

// Test direct connection to your database
void main() async {
  print('🔍 Testing direct connection to your database...');
  
  try {
    // Test students table
    final response = await http.get(
      Uri.parse('https://mk-attendance.vercel.app/api/students'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    print('📊 Students API Response Status: ${response.statusCode}');
    print('📊 Students API Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final students = data['data'] ?? [];
      print('📊 Number of students in database: ${students.length}');
      
      // Show first few students
      for (int i = 0; i < (students.length > 5 ? 5 : students.length); i++) {
        final student = students[i];
        print('📊 Student ${i + 1}: ${student['full_name']} - ${student['class']}');
      }
    }
    
  } catch (e) {
    print('❌ Database connection error: $e');
  }
}