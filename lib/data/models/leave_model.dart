import 'package:equatable/equatable.dart';

/// Leave Model for HRIS Mobile Application
class LeaveModel extends Equatable {
  final String id;
  final String employeeId;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String reason;
  final String status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final List<String>? attachments;
  final bool isEmergency;
  final DateTime appliedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LeaveModel({
    required this.id,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.attachments,
    this.isEmergency = false,
    required this.appliedAt,
    required this.createdAt,
    this.updatedAt,
  });

  // Computed properties
  bool get isPending => status == LeaveStatus.pending.value;
  bool get isApproved => status == LeaveStatus.approved.value;
  bool get isRejected => status == LeaveStatus.rejected.value;
  bool get isCancelled => status == LeaveStatus.cancelled.value;

  bool get isUpcoming {
    final now = DateTime.now();
    return startDate.isAfter(now) && isApproved;
  }

  bool get isOngoing {
    final now = DateTime.now();
    return startDate.isBefore(now) && endDate.isAfter(now) && isApproved;
  }

  bool get isPast {
    final now = DateTime.now();
    return endDate.isBefore(now);
  }

  String get formattedDateRange {
    final start = '${startDate.day}/${startDate.month}/${startDate.year}';
    final end = '${endDate.day}/${endDate.month}/${endDate.year}';
    return '$start - $end';
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  // Factory constructor from JSON
  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      leaveType: json['leaveType'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalDays: json['totalDays'] as int,
      reason: json['reason'] as String,
      status: json['status'] as String,
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'] as List)
          : null,
      isEmergency: json['isEmergency'] as bool? ?? false,
      appliedAt: DateTime.parse(json['appliedAt'] as String),
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
      'leaveType': leaveType,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'reason': reason,
      'status': status,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'attachments': attachments,
      'isEmergency': isEmergency,
      'appliedAt': appliedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // CopyWith method
  LeaveModel copyWith({
    String? id,
    String? employeeId,
    String? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDays,
    String? reason,
    String? status,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
    List<String>? attachments,
    bool? isEmergency,
    DateTime? appliedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      attachments: attachments ?? this.attachments,
      isEmergency: isEmergency ?? this.isEmergency,
      appliedAt: appliedAt ?? this.appliedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    employeeId,
    leaveType,
    startDate,
    endDate,
    totalDays,
    reason,
    status,
    approvedBy,
    approvedAt,
    rejectionReason,
    attachments,
    isEmergency,
    appliedAt,
    createdAt,
    updatedAt,
  ];
}

/// Leave Type Enum
enum LeaveType {
  annual('annual'),
  sick('sick'),
  maternity('maternity'),
  paternity('paternity'),
  emergency('emergency'),
  bereavement('bereavement'),
  personal('personal'),
  study('study');

  const LeaveType(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case LeaveType.annual:
        return 'Annual Leave';
      case LeaveType.sick:
        return 'Sick Leave';
      case LeaveType.maternity:
        return 'Maternity Leave';
      case LeaveType.paternity:
        return 'Paternity Leave';
      case LeaveType.emergency:
        return 'Emergency Leave';
      case LeaveType.bereavement:
        return 'Bereavement Leave';
      case LeaveType.personal:
        return 'Personal Leave';
      case LeaveType.study:
        return 'Study Leave';
    }
  }

  static LeaveType fromString(String value) {
    return LeaveType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => LeaveType.annual,
    );
  }
}

/// Leave Status Enum
enum LeaveStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  cancelled('cancelled');

  const LeaveStatus(this.value);
  final String value;

  static LeaveStatus fromString(String value) {
    return LeaveStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => LeaveStatus.pending,
    );
  }
}

/// Leave Balance Model
class LeaveBalanceModel extends Equatable {
  final String employeeId;
  final String leaveType;
  final int totalDays;
  final int usedDays;
  final int remainingDays;
  final int year;
  final DateTime? expiryDate;

  const LeaveBalanceModel({
    required this.employeeId,
    required this.leaveType,
    required this.totalDays,
    required this.usedDays,
    required this.remainingDays,
    required this.year,
    this.expiryDate,
  });

  // Computed properties
  double get usagePercentage =>
      totalDays > 0 ? (usedDays / totalDays) * 100 : 0;

  // Factory constructor from JSON
  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceModel(
      employeeId: json['employeeId'] as String,
      leaveType: json['leaveType'] as String,
      totalDays: json['totalDays'] as int,
      usedDays: json['usedDays'] as int,
      remainingDays: json['remainingDays'] as int,
      year: json['year'] as int,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'leaveType': leaveType,
      'totalDays': totalDays,
      'usedDays': usedDays,
      'remainingDays': remainingDays,
      'year': year,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    employeeId,
    leaveType,
    totalDays,
    usedDays,
    remainingDays,
    year,
    expiryDate,
  ];
}
