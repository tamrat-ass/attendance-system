class User {
  final int? id;
  final String username;
  final String? email;
  final String fullName;
  final String role;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Permissions
  final bool canManageStudents;
  final bool canAddStudent;
  final bool canUpdateStudent;
  final bool canUploadStudents;
  final bool canDeleteStudent;
  final bool canMarkAttendance;
  final bool canViewReports;
  final bool canExportData;
  final bool canManageUsers;
  final bool canDeleteUser;
  final bool canManagePasswords;

  User({
    this.id,
    required this.username,
    this.email,
    required this.fullName,
    required this.role,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
    this.canManageStudents = true,
    this.canAddStudent = true,
    this.canUpdateStudent = true,
    this.canUploadStudents = false,
    this.canDeleteStudent = false,
    this.canMarkAttendance = true,
    this.canViewReports = false,
    this.canExportData = false,
    this.canManageUsers = false,
    this.canDeleteUser = false,
    this.canManagePasswords = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'],
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'user',
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      canManageStudents: json['can_manage_students'] == 1 || json['can_manage_students'] == true,
      canAddStudent: json['can_add_student'] == 1 || json['can_add_student'] == true,
      canUpdateStudent: json['can_update_student'] == 1 || json['can_update_student'] == true,
      canUploadStudents: json['can_upload_students'] == 1 || json['can_upload_students'] == true,
      canDeleteStudent: json['can_delete_student'] == 1 || json['can_delete_student'] == true,
      canMarkAttendance: json['can_mark_attendance'] == 1 || json['can_mark_attendance'] == true,
      canViewReports: json['can_view_reports'] == 1 || json['can_view_reports'] == true,
      canExportData: json['can_export_data'] == 1 || json['can_export_data'] == true,
      canManageUsers: json['can_manage_users'] == 1 || json['can_manage_users'] == true,
      canDeleteUser: json['can_delete_user'] == 1 || json['can_delete_user'] == true,
      canManagePasswords: json['can_manage_passwords'] == 1 || json['can_manage_passwords'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'role': role,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'can_manage_students': canManageStudents,
      'can_add_student': canAddStudent,
      'can_update_student': canUpdateStudent,
      'can_upload_students': canUploadStudents,
      'can_delete_student': canDeleteStudent,
      'can_mark_attendance': canMarkAttendance,
      'can_view_reports': canViewReports,
      'can_export_data': canExportData,
      'can_manage_users': canManageUsers,
      'can_delete_user': canDeleteUser,
      'can_manage_passwords': canManagePasswords,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    String? role,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? canManageStudents,
    bool? canAddStudent,
    bool? canUpdateStudent,
    bool? canUploadStudents,
    bool? canDeleteStudent,
    bool? canMarkAttendance,
    bool? canViewReports,
    bool? canExportData,
    bool? canManageUsers,
    bool? canDeleteUser,
    bool? canManagePasswords,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      canManageStudents: canManageStudents ?? this.canManageStudents,
      canAddStudent: canAddStudent ?? this.canAddStudent,
      canUpdateStudent: canUpdateStudent ?? this.canUpdateStudent,
      canUploadStudents: canUploadStudents ?? this.canUploadStudents,
      canDeleteStudent: canDeleteStudent ?? this.canDeleteStudent,
      canMarkAttendance: canMarkAttendance ?? this.canMarkAttendance,
      canViewReports: canViewReports ?? this.canViewReports,
      canExportData: canExportData ?? this.canExportData,
      canManageUsers: canManageUsers ?? this.canManageUsers,
      canDeleteUser: canDeleteUser ?? this.canDeleteUser,
      canManagePasswords: canManagePasswords ?? this.canManagePasswords,
    );
  }

  // Helper methods
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isManager => role.toLowerCase() == 'manager';
  bool get isUser => role.toLowerCase() == 'user';
  bool get isActive => status.toLowerCase() == 'active';

  String get roleDisplayName {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'manager':
        return 'Manager';
      case 'user':
        return 'User';
      default:
        return role;
    }
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, fullName: $fullName, role: $role}';
  }
}