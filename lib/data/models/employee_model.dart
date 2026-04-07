import 'package:equatable/equatable.dart';

/// Employee Model for HRIS Mobile Application
class EmployeeModel extends Equatable {
  final String id;
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
  final DateTime createdAt;
  final DateTime? updatedAt;

  const EmployeeModel({
    required this.id,
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
    required this.createdAt,
    this.updatedAt,
  });

  // Computed properties
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

  // Factory constructor from JSON
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      userId: json['userId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      department: json['department'] as String,
      position: json['position'] as String,
      manager: json['manager'] as String?,
      joinDate: DateTime.parse(json['joinDate'] as String),
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      address: json['address'] as String?,
      salary: (json['salary'] as num).toDouble(),
      employmentType: json['employmentType'] as String,
      status: json['status'] as String,
      profileImage: json['profileImage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'department': department,
      'position': position,
      'manager': manager,
      'joinDate': joinDate.toIso8601String(),
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'salary': salary,
      'employmentType': employmentType,
      'status': status,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // CopyWith method
  EmployeeModel copyWith({
    String? id,
    String? employeeId,
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? department,
    String? position,
    String? manager,
    DateTime? joinDate,
    DateTime? dateOfBirth,
    String? address,
    double? salary,
    String? employmentType,
    String? status,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      department: department ?? this.department,
      position: position ?? this.position,
      manager: manager ?? this.manager,
      joinDate: joinDate ?? this.joinDate,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      salary: salary ?? this.salary,
      employmentType: employmentType ?? this.employmentType,
      status: status ?? this.status,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    employeeId,
    userId,
    firstName,
    lastName,
    email,
    phoneNumber,
    department,
    position,
    manager,
    joinDate,
    dateOfBirth,
    address,
    salary,
    employmentType,
    status,
    profileImage,
    createdAt,
    updatedAt,
  ];
}

/// Employment Type Enum
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

/// Employee Status Enum
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
