import '../models/user_model.dart';
import '../models/employee_model.dart';
import '../models/attendance_model.dart';
import '../models/leave_model.dart';

/// Mock Data Provider for HRIS Mobile Application
/// This provides sample data for UI development and testing
class MockDataProvider {
  // Sample User Data
  static UserModel get sampleUser {
    return UserModel(
      id: 'user_001',
      email: 'john.doe@company.com',
      firstName: 'John',
      lastName: 'Doe',
      profileImage: null,
      role: 'employee',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    );
  }

  // Sample Employee Data
  static EmployeeModel get sampleEmployee {
    return EmployeeModel(
      id: 'emp_001',
      employeeId: 'EMP001',
      userId: 'user_001',
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@company.com',
      phoneNumber: '+1234567890',
      department: 'Engineering',
      position: 'Senior Developer',
      manager: 'Jane Smith',
      joinDate: DateTime(2023, 1, 15),
      dateOfBirth: DateTime(1990, 5, 20),
      address: '123 Main St, City, State 12345',
      salary: 75000.0,
      employmentType: 'full_time',
      status: 'active',
      profileImage: null,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    );
  }

  // Sample Employees List
  static List<EmployeeModel> get sampleEmployees {
    return [
      sampleEmployee,
      EmployeeModel(
        id: 'emp_002',
        employeeId: 'EMP002',
        userId: 'user_002',
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane.smith@company.com',
        phoneNumber: '+1234567891',
        department: 'Engineering',
        position: 'Team Lead',
        manager: 'Mike Johnson',
        joinDate: DateTime(2022, 3, 10),
        dateOfBirth: DateTime(1988, 8, 15),
        address: '456 Oak Ave, City, State 12345',
        salary: 85000.0,
        employmentType: 'full_time',
        status: 'active',
        profileImage: null,
        createdAt: DateTime.now().subtract(const Duration(days: 500)),
        updatedAt: DateTime.now(),
      ),
      EmployeeModel(
        id: 'emp_003',
        employeeId: 'EMP003',
        userId: 'user_003',
        firstName: 'Mike',
        lastName: 'Johnson',
        email: 'mike.johnson@company.com',
        phoneNumber: '+1234567892',
        department: 'Engineering',
        position: 'Engineering Manager',
        manager: null,
        joinDate: DateTime(2021, 6, 1),
        dateOfBirth: DateTime(1985, 12, 3),
        address: '789 Pine Rd, City, State 12345',
        salary: 95000.0,
        employmentType: 'full_time',
        status: 'active',
        profileImage: null,
        createdAt: DateTime.now().subtract(const Duration(days: 700)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Sample Attendance Data
  static List<AttendanceModel> get sampleAttendanceRecords {
    final now = DateTime.now();
    return [
      // Today's attendance
      AttendanceModel(
        id: 'att_001',
        employeeId: 'emp_001',
        date: DateTime(now.year, now.month, now.day),
        clockIn: DateTime(now.year, now.month, now.day, 9, 0),
        clockOut: null, // Still working
        workingHours: null,
        breakTime: const Duration(hours: 1),
        overtime: null,
        status: 'present',
        location: 'Office',
        notes: null,
        isLate: false,
        isEarlyLeave: false,
        createdAt: DateTime(now.year, now.month, now.day, 9, 0),
        updatedAt: null,
      ),
      // Yesterday's attendance
      AttendanceModel(
        id: 'att_002',
        employeeId: 'emp_001',
        date: DateTime(now.year, now.month, now.day - 1),
        clockIn: DateTime(now.year, now.month, now.day - 1, 8, 45),
        clockOut: DateTime(now.year, now.month, now.day - 1, 17, 30),
        workingHours: const Duration(hours: 8, minutes: 45),
        breakTime: const Duration(hours: 1),
        overtime: const Duration(minutes: 30),
        status: 'present',
        location: 'Office',
        notes: null,
        isLate: false,
        isEarlyLeave: false,
        createdAt: DateTime(now.year, now.month, now.day - 1, 8, 45),
        updatedAt: DateTime(now.year, now.month, now.day - 1, 17, 30),
      ),
      // Day before yesterday - Late
      AttendanceModel(
        id: 'att_003',
        employeeId: 'emp_001',
        date: DateTime(now.year, now.month, now.day - 2),
        clockIn: DateTime(now.year, now.month, now.day - 2, 9, 15),
        clockOut: DateTime(now.year, now.month, now.day - 2, 18, 0),
        workingHours: const Duration(hours: 8, minutes: 45),
        breakTime: const Duration(hours: 1),
        overtime: null,
        status: 'late',
        location: 'Office',
        notes: 'Traffic jam',
        isLate: true,
        isEarlyLeave: false,
        createdAt: DateTime(now.year, now.month, now.day - 2, 9, 15),
        updatedAt: DateTime(now.year, now.month, now.day - 2, 18, 0),
      ),
    ];
  }

  // Sample Leave Data
  static List<LeaveModel> get sampleLeaveRecords {
    final now = DateTime.now();
    return [
      LeaveModel(
        id: 'leave_001',
        employeeId: 'emp_001',
        leaveType: 'annual',
        startDate: DateTime(now.year, now.month + 1, 15),
        endDate: DateTime(now.year, now.month + 1, 19),
        totalDays: 5,
        reason: 'Family vacation',
        status: 'pending',
        approvedBy: null,
        approvedAt: null,
        rejectionReason: null,
        attachments: null,
        isEmergency: false,
        appliedAt: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: null,
      ),
      LeaveModel(
        id: 'leave_002',
        employeeId: 'emp_001',
        leaveType: 'sick',
        startDate: DateTime(now.year, now.month - 1, 5),
        endDate: DateTime(now.year, now.month - 1, 7),
        totalDays: 3,
        reason: 'Flu symptoms',
        status: 'approved',
        approvedBy: 'Jane Smith',
        approvedAt: DateTime(now.year, now.month - 1, 4),
        rejectionReason: null,
        attachments: ['medical_certificate.pdf'],
        isEmergency: false,
        appliedAt: DateTime(now.year, now.month - 1, 3),
        createdAt: DateTime(now.year, now.month - 1, 3),
        updatedAt: DateTime(now.year, now.month - 1, 4),
      ),
    ];
  }

  // Sample Leave Balance Data
  static List<LeaveBalanceModel> get sampleLeaveBalances {
    return [
      LeaveBalanceModel(
        employeeId: 'emp_001',
        leaveType: 'annual',
        totalDays: 21,
        usedDays: 8,
        remainingDays: 13,
        year: DateTime.now().year,
        expiryDate: DateTime(DateTime.now().year, 12, 31),
      ),
      LeaveBalanceModel(
        employeeId: 'emp_001',
        leaveType: 'sick',
        totalDays: 10,
        usedDays: 3,
        remainingDays: 7,
        year: DateTime.now().year,
        expiryDate: DateTime(DateTime.now().year, 12, 31),
      ),
      LeaveBalanceModel(
        employeeId: 'emp_001',
        leaveType: 'emergency',
        totalDays: 5,
        usedDays: 0,
        remainingDays: 5,
        year: DateTime.now().year,
        expiryDate: DateTime(DateTime.now().year, 12, 31),
      ),
    ];
  }

  // Dashboard Statistics
  static Map<String, dynamic> get dashboardStats {
    return {
      'totalEmployees': 150,
      'presentToday': 142,
      'absentToday': 5,
      'lateToday': 3,
      'onLeaveToday': 8,
      'pendingLeaveRequests': 12,
      'thisMonthWorkingDays': 22,
      'thisMonthPresentDays': 18,
      'thisMonthAbsentDays': 2,
      'thisMonthLateDays': 2,
      'overtimeHours': 15.5,
      'averageWorkingHours': 8.2,
    };
  }

  // Company Departments
  static List<String> get departments {
    return [
      'Engineering',
      'Human Resources',
      'Finance',
      'Marketing',
      'Sales',
      'Operations',
      'Customer Support',
      'Quality Assurance',
      'Administration',
    ];
  }

  // Job Positions
  static List<String> get positions {
    return [
      'Software Engineer',
      'Senior Software Engineer',
      'Team Lead',
      'Engineering Manager',
      'Product Manager',
      'HR Manager',
      'Finance Manager',
      'Marketing Specialist',
      'Sales Representative',
      'Customer Support Agent',
      'QA Engineer',
      'Administrative Assistant',
    ];
  }

  // Sample notifications
  static List<Map<String, dynamic>> get sampleNotifications {
    final now = DateTime.now();
    return [
      {
        'id': 'notif_001',
        'title': 'Leave Request Approved',
        'message':
            'Your annual leave request for June 15-19 has been approved.',
        'type': 'leave',
        'isRead': false,
        'createdAt': now.subtract(const Duration(hours: 2)),
      },
      {
        'id': 'notif_002',
        'title': 'Payslip Available',
        'message': 'Your payslip for May 2024 is now available for download.',
        'type': 'payroll',
        'isRead': false,
        'createdAt': now.subtract(const Duration(days: 1)),
      },
      {
        'id': 'notif_003',
        'title': 'Team Meeting Reminder',
        'message': 'Don\'t forget about the team meeting at 2:00 PM today.',
        'type': 'reminder',
        'isRead': true,
        'createdAt': now.subtract(const Duration(hours: 6)),
      },
    ];
  }
}
