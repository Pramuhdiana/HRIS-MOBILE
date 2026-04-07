# HRIS Mobile Architecture

## 📐 Clean Architecture dengan Multi-Company Support

Aplikasi ini menggunakan **Clean Architecture** dengan **Riverpod** untuk state management, dirancang untuk mendukung **multi-company HRIS**.

---

## 🏗️ Folder Structure

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants, company context
│   ├── themes/             # App themes
│   ├── utils/              # Utility functions
│   ├── errors/             # Error handling (Failures)
│   └── network/            # API client, network config
│
├── domain/                  # Business Logic Layer
│   ├── entities/           # Domain entities (pure Dart)
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Business logic use cases
│
├── data/                    # Data Layer
│   ├── models/             # Data models (JSON serializable)
│   ├── datasources/        # Data sources
│   │   ├── remote/         # API data sources
│   │   └── local/          # Local storage data sources
│   └── repositories/       # Repository implementations
│
├── presentation/            # UI Layer
│   ├── providers/          # Riverpod providers
│   ├── screens/            # App screens
│   └── widgets/            # Reusable widgets
│
└── shared/                  # Shared resources
    ├── widgets/            # Shared widgets
    └── utils/              # Shared utilities
```

---

## 🎯 Architecture Principles

### 1. **Separation of Concerns**
- **Domain**: Pure business logic, no dependencies
- **Data**: Data sources, models, repository implementations
- **Presentation**: UI, state management, user interactions

### 2. **Dependency Rule**
- **Domain** ← **Data** ← **Presentation**
- Inner layers don't know about outer layers
- Dependencies point inward

### 3. **Multi-Company Support**
- `CompanyContext` manages active company
- All company-scoped entities extend `CompanyEntity`
- API client automatically includes company headers

---

## 🔄 Data Flow

```
User Action
    ↓
Presentation Layer (Screen/Widget)
    ↓
Provider (Riverpod)
    ↓
UseCase (Business Logic)
    ↓
Repository Interface (Domain)
    ↓
Repository Implementation (Data)
    ↓
Data Source (Remote/Local)
    ↓
API/Storage
```

---

## 📦 Key Components

### **Domain Layer**

#### Entities
- Pure Dart classes
- No dependencies on frameworks
- Business objects (User, Employee, Attendance, etc.)

#### Repositories (Interfaces)
- Define contracts for data operations
- Extend `BaseRepository`
- Return `Either<Failure, T>`

#### Use Cases
- Single responsibility
- Business logic operations
- Extend `UseCase<Type, Params>`

### **Data Layer**

#### Models
- JSON serializable
- Extend `BaseModel<T>`
- Convert to/from entities

#### Data Sources
- **Remote**: API calls via `ApiClient`
- **Local**: SharedPreferences, SQLite, etc.

#### Repository Implementations
- Implement domain repository interfaces
- Handle data source coordination
- Error handling and mapping

### **Presentation Layer**

#### Providers (Riverpod)
- State management
- Dependency injection
- Business logic coordination

#### Screens
- UI composition
- User interactions
- Provider consumption

#### Widgets
- Reusable UI components
- Stateless when possible
- ConsumerWidget for state

---

## 🏢 Multi-Company Architecture

### Company Context
```dart
// Set company context
updateCompanyContext(ref, CompanyContext(
  companyId: 'comp_001',
  companyName: 'Company A',
));

// All API calls automatically include X-Company-Id header
// All company-scoped entities include companyId
```

### Company-Scoped Entities
```dart
class Employee extends CompanyEntity {
  // Automatically includes companyId
  // All queries filtered by company
}
```

---

## 🔌 Dependency Injection (Riverpod)

### Provider Types
- **Provider**: Simple value providers
- **StateProvider**: Simple state
- **StateNotifierProvider**: Complex state with logic
- **FutureProvider**: Async data loading
- **StreamProvider**: Stream data

### Example
```dart
// Define provider
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier(ref.read(authRepositoryProvider));
});

// Use in widget
class UserProfile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    // ...
  }
}
```

---

## 🚀 Best Practices

### 1. **Use Cases**
- One use case = one business operation
- Keep use cases small and focused
- Use `Either<Failure, T>` for error handling

### 2. **Repositories**
- One repository per domain entity
- Implement caching strategy
- Handle offline scenarios

### 3. **Providers**
- Keep providers focused
- Use composition over inheritance
- Avoid deep provider nesting

### 4. **Error Handling**
- Use `Failure` classes for errors
- Map exceptions to failures in repositories
- Show user-friendly messages in UI

### 5. **Testing**
- Test use cases (business logic)
- Test repositories (data layer)
- Test providers (state management)
- Mock data sources

---

## 📝 Example: Adding New Feature

### 1. Create Entity (Domain)
```dart
// domain/entities/leave_request.dart
class LeaveRequest extends CompanyEntity {
  final String employeeId;
  final LeaveType type;
  // ...
}
```

### 2. Create Repository Interface (Domain)
```dart
// domain/repositories/leave_repository.dart
abstract class LeaveRepository extends BaseRepository {
  FutureResult<List<LeaveRequest>> getLeaveRequests(String employeeId);
  FutureResult<LeaveRequest> createLeaveRequest(LeaveRequest request);
}
```

### 3. Create Use Case (Domain)
```dart
// domain/usecases/get_leave_requests.dart
class GetLeaveRequests extends UseCase<List<LeaveRequest>, String> {
  final LeaveRepository repository;
  
  GetLeaveRequests(this.repository);
  
  @override
  Future<Either<Failure, List<LeaveRequest>>> call(String employeeId) {
    return repository.getLeaveRequests(employeeId);
  }
}
```

### 4. Create Model (Data)
```dart
// data/models/leave_request_model.dart
class LeaveRequestModel extends BaseModel<LeaveRequest> {
  // JSON serialization
  // Entity conversion
}
```

### 5. Create Data Source (Data)
```dart
// data/datasources/remote/leave_remote_datasource.dart
class LeaveRemoteDataSource implements RemoteDataSource {
  final ApiClient apiClient;
  // API calls
}
```

### 6. Implement Repository (Data)
```dart
// data/repositories/leave_repository_impl.dart
class LeaveRepositoryImpl implements LeaveRepository {
  final LeaveRemoteDataSource remoteDataSource;
  // Implementation
}
```

### 7. Create Provider (Presentation)
```dart
// presentation/providers/leave_provider.dart
final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepositoryImpl(/* ... */);
});

final leaveRequestsProvider = FutureProvider<List<LeaveRequest>>((ref) async {
  final repository = ref.read(leaveRepositoryProvider);
  final useCase = GetLeaveRequests(repository);
  final result = await useCase.call(employeeId);
  return result.fold((failure) => throw failure, (data) => data);
});
```

### 8. Create Screen (Presentation)
```dart
// presentation/screens/leave/leave_list_screen.dart
class LeaveListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaveRequests = ref.watch(leaveRequestsProvider);
    // UI
  }
}
```

---

## 🔐 Security & Multi-Company Isolation

- Company context validated on every request
- Data filtered by company at repository level
- User permissions checked per company
- API includes company isolation headers

---

## 📚 Resources

- [Riverpod Documentation](https://riverpod.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Best Practices](https://docs.flutter.dev/development/data-and-backend/state-mgmt/options)

---

**Architecture designed for scalability, maintainability, and multi-company support!** 🚀