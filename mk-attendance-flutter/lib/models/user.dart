class User {
  final int id;
  final String username;
  final String fullName;
  final String role;
  final bool canManageStudents;
  final bool canMarkAttendance;
  final bool canViewReports;
  final bool canExportData;
  final bool canManageUsers;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    this.role = 'user',
    this.canManageStudents = true,
    this.canMarkAttendance = true,
    this.canViewReports = true,
    this.canExportData = true,
    this.canManageUsers = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'user',
      canManageStudents: json['can_manage_students'] ?? true,
      canMarkAttendance: json['can_mark_attendance'] ?? true,
      canViewReports: json['can_view_reports'] ?? true,
      canExportData: json['can_export_data'] ?? true,
      canManageUsers: json['can_manage_users'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'role': role,
      'can_manage_students': canManageStudents,
      'can_mark_attendance': canMarkAttendance,
      'can_view_reports': canViewReports,
      'can_export_data': canExportData,
      'can_manage_users': canManageUsers,
    };
  }

  // Helper method to check if user is admin
  bool get isAdmin => role == 'admin' || canManageUsers;
}