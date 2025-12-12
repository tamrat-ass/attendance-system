class SimpleAttendance {
  final int studentId;
  final String date;
  final String status; // 'present', 'absent', 'late', 'permission'
  final String notes;

  SimpleAttendance({
    required this.studentId,
    required this.date,
    required this.status,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'date': date,
      'status': status,
      'notes': notes,
    };
  }

  factory SimpleAttendance.fromJson(Map<String, dynamic> json) {
    return SimpleAttendance(
      studentId: json['student_id'] ?? 0,
      date: json['date'] ?? '',
      status: json['status'] ?? 'absent',
      notes: json['notes'] ?? '',
    );
  }
}