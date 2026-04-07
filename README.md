# HRIS Mobile Application 📱

A comprehensive Human Resource Information System (HRIS) mobile application built with Flutter, based on POS Mobile Figma template design.

## ✨ Features

### 🏠 **Dashboard**
- Employee welcome screen with personalized greeting
- Today's attendance status with clock in/out functionality
- Quick action buttons for common HRIS tasks
- Monthly overview statistics (present days, absent days, late days, overtime hours)

### ⏰ **Attendance Management**
- Real-time attendance tracking
- Clock in/out functionality with location tracking
- Attendance history with detailed records
- Working hours calculation and overtime tracking
- Late arrival and early departure notifications

### 🏖️ **Leave Management**
- Leave balance overview for different leave types (Annual, Sick, Emergency, etc.)
- Leave application with reason and attachment support
- Leave history with approval status tracking
- Visual progress indicators for leave usage
- Emergency leave marking

### 👤 **Profile Management**
- Comprehensive employee profile information
- Personal details (contact, department, position, join date)
- Years of service calculation
- Settings and preferences
- Secure logout functionality

## 🎨 Design System

### **Colors**
- **Primary**: Deep blue (#2B3A55) - Professional and trustworthy
- **Secondary**: Light blue (#3EBAE0) - Modern and friendly
- **Accent**: Orange (#FFA726) - Energetic highlights
- **Status Colors**: Success (Green), Warning (Yellow), Error (Red), Info (Blue)

### **Typography**
- Clean, readable typography optimized for mobile devices
- Consistent heading hierarchy (H1-H6)
- Well-defined body text and label styles
- Accessible font sizes and line heights

### **Components**
- Material Design 3 principles
- Consistent spacing and dimensions
- Reusable cards and widgets
- Smooth animations and transitions

## 🏗️ Architecture

### **Project Structure**
```
lib/
├── core/
│   ├── constants/          # App constants (colors, strings, dimensions)
│   └── themes/            # App theme configuration
├── data/
│   ├── models/            # Data models (User, Employee, Attendance, Leave)
│   └── providers/         # Mock data providers (ready for API integration)
└── presentation/
    ├── screens/           # All UI screens
    │   ├── splash/        # Splash screen
    │   ├── auth/          # Login screen
    │   ├── dashboard/     # Main dashboard with tabs
    │   ├── attendance/    # Attendance management
    │   ├── leave/         # Leave management
    │   └── profile/       # User profile
    └── widgets/           # Reusable UI components
```

### **Key Features**
- **Clean Architecture**: Separation of concerns with clear layers
- **State Management**: Provider pattern (ready for complex state management)
- **Mock Data**: Complete mock data structure for development and testing
- **API Ready**: Structured for easy API integration
- **Responsive Design**: Optimized for various screen sizes
- **Type Safety**: Full Dart type safety with model classes

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK (3.0 or higher)
- Dart SDK
- iOS development: Xcode (for iOS deployment)
- Android development: Android Studio (for Android deployment)

### **Installation**

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-repo/HRIS-MOBILE.git
   cd HRIS-MOBILE/hris_mobile_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   
   **For Web:**
   ```bash
   flutter run -d chrome
   ```
   
   **For iOS Simulator:**
   ```bash
   flutter emulators --launch apple_ios_simulator
   flutter run -d ios
   ```
   
   **For Android Emulator:**
   ```bash
   flutter emulators --launch Medium_Phone_API_35
   flutter run -d android
   ```

### **Demo Credentials**
For testing the login functionality:
- **Email**: `demo@company.com`
- **Password**: `demo123`

## 📱 Screenshots

### Login Screen
- Clean, professional login interface
- Form validation with user-friendly error messages
- Demo credentials provided for easy testing

### Dashboard
- Welcome message with employee information
- Current attendance status card
- Quick action buttons for common tasks
- Monthly statistics overview

### Attendance
- Real-time attendance tracking
- Detailed attendance history
- Working hours calculation
- Status indicators (Present, Late, Absent)

### Leave Management
- Visual leave balance cards
- Leave type categorization with icons
- Leave history with approval status
- Progress indicators for leave usage

### Profile
- Comprehensive employee information
- Professional profile layout
- Settings and preferences access
- Secure logout functionality

## 🔧 Dependencies

### **Core Dependencies**
- `flutter`: Flutter SDK
- `provider`: State management
- `go_router`: Navigation routing
- `http` & `dio`: HTTP client for API calls
- `shared_preferences`: Local storage
- `intl`: Internationalization and date formatting
- `equatable`: Value equality

### **UI Dependencies**
- `flutter_svg`: SVG image support
- `cached_network_image`: Optimized image loading
- `image_picker`: Image selection functionality

## 🌐 API Integration

The application is structured to easily integrate with REST APIs:

### **Ready for Integration**
- Service layer architecture in place
- Mock data providers can be replaced with real API calls
- HTTP client configuration ready
- Error handling structure prepared
- Authentication flow structured

### **Mock Data Available**
- User and Employee models
- Attendance records with various statuses
- Leave requests and balances
- Dashboard statistics
- Complete data relationships

## 📦 Deployment

### **iOS App Store**
1. Configure iOS project settings in `ios/Runner.xcodeproj`
2. Set up App Store Connect account
3. Configure signing certificates
4. Build release version: `flutter build ios --release`
5. Upload to App Store Connect via Xcode

### **Google Play Store**
1. Configure Android project settings in `android/app/build.gradle`
2. Set up Google Play Console account
3. Configure app signing
4. Build release APK: `flutter build apk --release`
5. Upload to Google Play Console

### **Web Deployment**
1. Build web version: `flutter build web`
2. Deploy `build/web` folder to web hosting service
3. Configure domain and SSL certificate

## 🔒 Security Features

- Secure authentication flow
- Form validation and sanitization
- Safe navigation patterns
- Proper error handling
- No sensitive data in mock providers

## 🎯 Future Enhancements

### **Phase 2 Features**
- [ ] Real-time notifications
- [ ] Biometric authentication
- [ ] Offline mode with sync
- [ ] Dark mode support
- [ ] Multi-language support
- [ ] Advanced reporting and analytics

### **Technical Improvements**
- [ ] Unit and integration tests
- [ ] CI/CD pipeline setup
- [ ] Performance optimization
- [ ] Accessibility improvements
- [ ] Advanced state management (Bloc/Riverpod)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Development Team

- **Frontend Developer**: Flutter UI/UX implementation
- **Backend Integration**: Ready for API integration
- **Design System**: Based on POS Mobile Figma template

## 📞 Support

For support and questions:
- Create an issue in the GitHub repository
- Contact the development team
- Check the documentation for common solutions

---

## 🎉 Project Status

✅ **Completed:**
- Flutter project setup with optimal structure
- Complete design system implementation
- All UI screens based on Figma template
- Navigation flow between screens
- Mock data structure for future API integration
- Responsive design testing

🔄 **Ready for:**
- API integration
- Real authentication system
- Push notifications
- App store deployment
- Production environment setup

---

*Built with ❤️ using Flutter - Ready for production deployment to iOS App Store and Google Play Store*
