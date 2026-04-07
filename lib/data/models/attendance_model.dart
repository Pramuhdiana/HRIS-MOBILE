import 'package:equatable/equatable.dart';

/// Attendance Model for HRIS Mobile Application
class AttendanceModel extends Equatable {
  final String id;
  final String employeeId;
  final DateTime date;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final Duration? workingHours;
  final Duration? breakTime;
  final Duration? overtime;
  final String status;
  final String? location;
  final String? notes;
  final bool isLate;
  final bool isEarlyLeave;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.date,
    this.clockIn,
    this.clockOut,
    this.workingHours,
    this.breakTime,
    this.overtime,
    required this.status,
    this.location,
    this.notes,
    this.isLate = false,
    this.isEarlyLeave = false,
    required this.createdAt,
    this.updatedAt,
  });

  // Computed properties
  bool get hasClockIn => clockIn != null;
  bool get hasClockOut => clockOut != null;
  bool get isComplete => hasClockIn && hasClockOut;

  String get formattedClockIn {
    if (clockIn == null) return '--:--';
    return '${clockIn!.hour.toString().padLeft(2, '0')}:${clockIn!.minute.toString().padLeft(2, '0')}';
  }

  String get formattedClockOut {
    if (clockOut == null) return '--:--';
    return '${clockOut!.hour.toString().padLeft(2, '0')}:${clockOut!.minute.toString().padLeft(2, '0')}';
  }

  String get formattedWorkingHours {
    if (workingHours == null) return '0h 0m';
    final hours = workingHours!.inHours;
    final minutes = workingHours!.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  Duration? get totalWorkingTime {
    if (clockIn == null || clockOut == null) return null;
    Duration total = clockOut!.difference(clockIn!);
    if (breakTime != null) {
      total = total - breakTime!;
    }
    return total;
  }

  // Factory constructor from JSON
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      date: DateTime.parse(json['date'] as String),
      clockIn: json['clockIn'] != null
          ? DateTime.parse(json['clockIn'] as String)
          : null,
      clockOut: json['clockOut'] != null
          ? DateTime.parse(json['clockOut'] as String)
          : null,
      workingHours: json['workingHours'] != null
          ? Duration(seconds: json['workingHours'] as int)
          : null,
      breakTime: json['breakTime'] != null
          ? Duration(seconds: json['breakTime'] as int)
          : null,
      overtime: json['overtime'] != null
          ? Duration(seconds: json['overtime'] as int)
          : null,
      status: json['status'] as String,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      isLate: json['isLate'] as bool? ?? false,
      isEarlyLeave: json['isEarlyLeave'] as bool? ?? false,
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
      'date': date.toIso8601String(),
      'clockIn': clockIn?.toIso8601String(),
      'clockOut': clockOut?.toIso8601String(),
      'workingHours': workingHours?.inSeconds,
      'breakTime': breakTime?.inSeconds,
      'overtime': overtime?.inSeconds,
      'status': status,
      'location': location,
      'notes': notes,
      'isLate': isLate,
      'isEarlyLeave': isEarlyLeave,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // CopyWith method
  AttendanceModel copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    DateTime? clockIn,
    DateTime? clockOut,
    Duration? workingHours,
    Duration? breakTime,
    Duration? overtime,
    String? status,
    String? location,
    String? notes,
    bool? isLate,
    bool? isEarlyLeave,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      clockIn: clockIn ?? this.clockIn,
      clockOut: clockOut ?? this.clockOut,
      workingHours: workingHours ?? this.workingHours,
      breakTime: breakTime ?? this.breakTime,
      overtime: overtime ?? this.overtime,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isLate: isLate ?? this.isLate,
      isEarlyLeave: isEarlyLeave ?? this.isEarlyLeave,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    employeeId,
    date,
    clockIn,
    clockOut,
    workingHours,
    breakTime,
    overtime,
    status,
    location,
    notes,
    isLate,
    isEarlyLeave,
    createdAt,
    updatedAt,
  ];
}

/// Attendance Status Enum
enum AttendanceStatus {
  present('present'),
  absent('absent'),
  late('late'),
  halfDay('half_day'),
  sick('sick'),
  vacation('vacation');

  const AttendanceStatus(this.value);
  final String value;

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AttendanceStatus.present,
    );
  }
}
