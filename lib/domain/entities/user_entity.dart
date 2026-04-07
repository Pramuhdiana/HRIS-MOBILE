import 'base_entity.dart';

/// User Entity - Domain layer
class User extends BaseEntity {
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String role;
  final bool isActive;

  const User({
    required super.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.role,
    this.isActive = true,
    required super.createdAt,
    super.updatedAt,
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
}

/// User Roles
enum UserRole {
  employee('employee'),
  manager('manager'),
  hr('hr'),
  admin('admin');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.employee,
    );
  }
}