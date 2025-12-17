class Attendance {
  final int id;
  final int studentId;
  final String studentName;
  final String date;
  final String status;
  final String className;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Attendance({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.status,
    required this.className,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? 0,
      studentId: json['student_id'] ?? json['studentId'] ?? 0,
      studentName: json['student_name'] ?? json['studentName'] ?? json['full_name'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? 'absent',
      className: json['class_name'] ?? json['className'] ?? json['class'] ?? '',
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'date': date,
      'status': status,
      'class_name': className,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Attendance copyWith({
    int? id,
    int? studentId,
    String? studentName,
    String? date,
    String? status,
    String? className,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      date: date ?? this.date,
      status: status ?? this.status,
      className: className ?? this.className,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attendance &&
        other.id == id &&
        other.studentId == studentId &&
        other.date == date &&
        other.status == status &&
        other.className == className;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        studentId.hashCode ^
        date.hashCode ^
        status.hashCode ^
        className.hashCode;
  }

  @override
  String toString() {
    return 'Attendance(id: $id, studentId: $studentId, studentName: $studentName, date: $date, status: $status, className: $className)';
  }
}