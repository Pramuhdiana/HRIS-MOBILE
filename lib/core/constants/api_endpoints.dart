/// API Endpoints Constants
/// Centralized location for all API endpoints
class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://mangroup.id';

  // Auth Endpoints
  static const String login = '/ms-auth/api/auth/login';
  static const String loginGoogle = '/ms-auth/api/auth/login/google';
  static const String logout = '/ms-auth/api/auth/logout';
  static const String refreshToken = '/ms-auth/api/auth/refresh';
  static const String forgotPassword = '/ms-auth/api/auth/forgot-password';
  static const String resetPassword = '/ms-auth/api/auth/reset-password';

  // User Endpoints
  /// GET `/profile` — untuk data lengkap gunakan query `type=detail` (lihat [ProfileDataSource.getProfile]).
  static const String userProfile = '/ms-user/api/profile';
  // Update profile pakai endpoint yang sama dengan GET profile (method POST).
  static const String updateProfile = '/ms-user/api/profile';
  static const String updateProfilePhoto = '/ms-user/api/profile/photo';
  static const String changePassword = '/ms-user/api/account/changePassword';

  // Employee Endpoints
  static const String employees = '/ms-employee/api/employees';
  static const String employeeDetail = '/ms-employee/api/employees/{id}';
  static const String employeeByCompany =
      '/ms-employee/api/employees/company/{companyId}';

  // Attendance Endpoints
  static const String attendance = '/ms-attendance/api/attendance';
  static const String clockIn = '/ms-attendance/api/attendance/clock-in';
  static const String clockOut = '/ms-attendance/api/attendance/clock-out';
  static const String attendanceHistory =
      '/ms-attendance/api/attendance/history';
  static const String attendanceToday = '/ms-attendance/api/attendance/today';

  // Leave Endpoints
  static const String leaves = '/ms-leave/api/leaves';
  static const String leaveBalance = '/ms-leave/api/leaves/balance';
  static const String applyLeave = '/ms-leave/api/leaves/apply';
  static const String leaveHistory = '/ms-leave/api/leaves/history';
  static const String leaveDetail = '/ms-leave/api/leaves/{id}';

  // Payroll Endpoints
  static const String payroll = '/ms-payroll/api/payroll';
  static const String payslip = '/ms-payroll/api/payroll/payslip';
  static const String payslipHistory =
      '/ms-payroll/api/payroll/payslip/history';
  static const String payslipDetail = '/ms-payroll/api/payroll/payslip/{id}';

  // Company Endpoints
  static const String companies = '/ms-company/api/companies';
  static const String companyDetail = '/ms-company/api/companies/{id}';
  static const String switchCompany = '/ms-company/api/companies/{id}/switch';

  // Notification Endpoints
  static const String notifications = '/ms-notification/api/notifications';
  static const String notificationRead =
      '/ms-notification/api/notifications/{id}/read';
  static const String notificationUnreadCount =
      '/ms-notification/api/notifications/unread/count';

  // Helper method to replace path parameters
  static String replacePathParams(
    String endpoint,
    Map<String, dynamic> params,
  ) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }
}
