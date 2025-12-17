class ClassModel {
  final int? id;
  final String className;
  final String? description;
  final DateTime? createdAt;

  ClassModel({
    this.id,
    required this.className,
    this.description,
    this.createdAt,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      className: json['name'] ?? json['class_name'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': className,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  ClassModel copyWith({
    int? id,
    String? className,
    String? description,
    DateTime? createdAt,
  }) {
    return ClassModel(
      id: id ?? this.id,
      className: className ?? this.className,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ClassModel(id: $id, className: $className, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassModel &&
        other.id == id &&
        other.className == className &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^ className.hashCode ^ description.hashCode;
  }
}