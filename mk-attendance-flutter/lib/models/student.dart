class Student {
  final int? id;
  final String fullName;
  final String phone;
  final String className;
  final String? gender;
  final String? email;

  Student({
    this.id,
    required this.fullName,
    required this.phone,
    required this.className,
    this.gender = 'Male',
    this.email,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      className: json['class'] ?? '',
      gender: json['gender'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'class': className,
      'gender': gender,
      'email': email,
    };
  }

  Student copyWith({
    int? id,
    String? fullName,
    String? phone,
    String? className,
    String? gender,
    String? email,
  }) {
    return Student(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      className: className ?? this.className,
      gender: gender ?? this.gender,
      email: email ?? this.email,
    );
  }
}