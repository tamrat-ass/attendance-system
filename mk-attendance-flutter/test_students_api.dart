import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔥 Testing Students API...');
  
  try {
    final response = await http.get(
      Uri.parse('https://mk-attendance.vercel.app/api/students'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    print('🔥 Response Status: ${response.statusCode}');
    print('🔥 Response Headers: ${response.headers}');
    print('🔥 Response Body Length: ${response.body.length}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('🔥 Success: ${data['message']}');
      print('🔥 Count: ${data['count']}');
      print('🔥 Students found: ${data['data']?.length ?? 0}');
      
      if (data['data'] != null && data['data'].isNotEmpty) {
        print('🔥 First student: ${data['data'][0]}');
        print('🔥 All students:');
        for (int i = 0; i < data['data'].length; i++) {
          final student = data['data'][i];
          print('   ${i + 1}. ${student['full_name']} - ${student['class']} - ${student['phone']}');
        }
      }
    } else {
      print('🔥 Error: ${response.body}');
    }
  } catch (e) {
    print('🔥 Exception: $e');
  }
}