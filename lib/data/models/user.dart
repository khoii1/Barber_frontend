class User {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String role;
  final String status;
  final String? tz;

  User({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    required this.role,
    this.status = 'active',
    this.tz,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      fullName: json['fullName'] ?? '',
      email: json['email'],
      phone: json['phone'],
      role: json['role'] ?? 'User',
      status: json['status'] ?? 'active',
      tz: json['tz'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'status': status,
      'tz': tz,
    };
  }
}

