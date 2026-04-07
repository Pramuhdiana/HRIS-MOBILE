/// App Strings - Text constants for HRIS Mobile Application
class AppStrings {
  // App Info
  static const String appName = 'HRIS Mobile';
  static const String appVersion = '1.0.0';

  // Authentication
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String rememberMe = 'Remember Me';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";

  // Navigation
  static const String home = 'Home';
  static const String dashboard = 'Dashboard';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String attendance = 'Attendance';
  static const String leave = 'Leave';
  static const String payroll = 'Payroll';
  static const String employees = 'Employees';
  static const String reports = 'Reports';
  static const String notifications = 'Notifications';

  // Dashboard
  static const String welcome = 'Welcome';
  static const String todayAttendance = "Today's Attendance";
  static const String clockIn = 'Clock In';
  static const String clockOut = 'Clock Out';
  static const String checkIn = 'Check In';
  static const String checkOut = 'Check Out';
  static const String workingHours = 'Working Hours';
  static const String overtime = 'Overtime';
  static const String present = 'Present';
  static const String absent = 'Absent';
  static const String late = 'Late';

  // Profile
  static const String personalInfo = 'Personal Information';
  static const String employeeId = 'Employee ID';
  static const String fullName = 'Full Name';
  static const String department = 'Department';
  static const String position = 'Position';
  static const String joinDate = 'Join Date';
  static const String phoneNumber = 'Phone Number';
  static const String address = 'Address';
  static const String dateOfBirth = 'Date of Birth';
  static const String editProfile = 'Edit Profile';

  // Leave Management
  static const String leaveBalance = 'Leave Balance';
  static const String applyLeave = 'Apply Leave';
  static const String leaveHistory = 'Leave History';
  static const String leaveType = 'Leave Type';
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String reason = 'Reason';
  static const String approved = 'Approved';
  static const String pending = 'Pending';
  static const String rejected = 'Rejected';
  static const String annualLeave = 'Annual Leave';
  static const String sickLeave = 'Sick Leave';
  static const String emergencyLeave = 'Emergency Leave';

  // Payroll
  static const String salary = 'Salary';
  static const String payslip = 'Payslip';
  static const String basicSalary = 'Basic Salary';
  static const String allowances = 'Allowances';
  static const String deductions = 'Deductions';
  static const String netPay = 'Net Pay';
  static const String grossPay = 'Gross Pay';
  static const String tax = 'Tax';
  static const String bonus = 'Bonus';

  // Common Actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String submit = 'Submit';
  static const String confirm = 'Confirm';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String view = 'View';
  static const String update = 'Update';
  static const String refresh = 'Refresh';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String next = 'Next';
  static const String previous = 'Previous';
  static const String done = 'Done';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';

  // Status Messages
  static const String loading = 'Loading...';
  static const String noData = 'No data available';
  static const String success = 'Success';
  static const String error = 'Error';
  static const String warning = 'Warning';
  static const String info = 'Information';

  // Error Messages
  static const String emailRequired = 'Email is required';
  static const String passwordRequired = 'Password is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error, please try again';
  static const String unauthorized = 'Unauthorized access';
  static const String sessionExpired = 'Session expired, please login again';

  // Date & Time
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String thisWeek = 'This Week';
  static const String thisMonth = 'This Month';
  static const String selectDate = 'Select Date';
  static const String selectTime = 'Select Time';

  // Months
  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // Days
  static const List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
}
