/// Domain entity for User
/// Pure business object without any framework dependencies
class UserEntity {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String role;
  final String status;
  final String? tz;

  UserEntity({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    required this.role,
    this.status = 'active',
    this.tz,
  });

  bool get isStylist => role.toLowerCase() == 'stylist';
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isActive => status == 'active';
}
