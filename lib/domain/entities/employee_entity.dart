import 'base_entity.dart';

/// Employee Entity - Domain layer with company context
class Employee extends CompanyEntity {
  final String employeeId;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String department;
  final String position;
  final String? manager;
  final DateTime joinDate;
  final DateTime? dateOfBirth;
  final String? address;
  final double salary;
  final String employmentType;
  final String status;
  final String? profileImage;

  const Employee({
    required super.id,
    required super.companyId,
    required this.employeeId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    required this.department,
    required this.position,
    this.manager,
    required this.joinDate,
    this.dateOfBirth,
    this.address,
    required this.salary,
    required this.employmentType,
    required this.status,
    this.profileImage,
    required super.createdAt,
    super.updatedAt,
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  int get yearsOfService {
    final now = DateTime.now();
    int years = now.year - joinDate.year;
    if (now.month < joinDate.month ||
        (now.month == joinDate.month && now.day < joinDate.day)) {
      years--;
    }
    return years;
  }
}

/// Employment Type
enum EmploymentType {
  fullTime('full_time'),
  partTime('part_time'),
  contract('contract'),
  intern('intern');

  const EmploymentType(this.value);
  final String value;

  static EmploymentType fromString(String value) {
    return EmploymentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => EmploymentType.fullTime,
    );
  }
}

/// Employee Status
enum EmployeeStatus {
  active('active'),
  inactive('inactive'),
  terminated('terminated'),
  onLeave('on_leave');

  const EmployeeStatus(this.value);
  final String value;

  static EmployeeStatus fromString(String value) {
    return EmployeeStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => EmployeeStatus.active,
    );
  }
}