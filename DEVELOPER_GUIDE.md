# 📚 Developer Guide - Menambahkan Fitur Baru

## 🎯 Panduan Lengkap untuk Menambahkan UI, PAGE, LOGIC, API, dll

---

## 📁 Struktur Folder & Lokasi File

### **1. MENAMBAHKAN UI / WIDGET**

#### **Reusable Widget (Shared)**
📍 **Lokasi**: `lib/shared/widgets/`
- Widget yang digunakan di banyak tempat
- Contoh: Custom buttons, cards, input fields
- **File**: `lib/shared/widgets/custom_button.dart`

#### **Feature-Specific Widget**
📍 **Lokasi**: `lib/presentation/widgets/`
- Widget khusus untuk feature tertentu
- Contoh: AttendanceCard, LeaveBalanceCard
- **File**: `lib/presentation/widgets/attendance_card.dart`

---

### **2. MENAMBAHKAN PAGE / SCREEN**

📍 **Lokasi**: `lib/presentation/screens/[feature_name]/`

**Struktur:**
```
lib/presentation/screens/
├── auth/
│   └── login_screen.dart
├── dashboard/
│   └── home_tab.dart
├── attendance/
│   └── attendance_tab.dart
└── [feature_name]/
    └── [feature_name]_screen.dart
```

**Contoh: Menambahkan Payroll Screen**
```
lib/presentation/screens/payroll/
├── payroll_screen.dart
├── payroll_list_screen.dart
└── payroll_detail_screen.dart
```

**Template Screen:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PayrollScreen extends ConsumerWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payroll')),
      body: const Center(child: Text('Payroll Screen')),
    );
  }
}
```

---

### **3. MENAMBAHKAN LOGIC / BUSINESS LOGIC**

#### **Step 1: Create Domain Entity**
📍 **Lokasi**: `lib/domain/entities/`

**File**: `lib/domain/entities/payroll_entity.dart`
```dart
import 'base_entity.dart';
import 'company_entity.dart';

class Payroll extends CompanyEntity {
  final String employeeId;
  final double amount;
  // ... other fields

  const Payroll({
    required super.id,
    required super.companyId,
    required this.employeeId,
    required this.amount,
    required super.createdAt,
    super.updatedAt,
  });
}
```

#### **Step 2: Create Repository Interface**
📍 **Lokasi**: `lib/domain/repositories/`

**File**: `lib/domain/repositories/payroll_repository.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/payroll_entity.dart';
import 'base_repository.dart';

abstract class PayrollRepository extends BaseRepository {
  Future<Either<Failure, List<Payroll>>> getPayrolls(String employeeId);
  Future<Either<Failure, Payroll>> getPayrollById(String id);
}
```

#### **Step 3: Create Use Case**
📍 **Lokasi**: `lib/domain/usecases/`

**File**: `lib/domain/usecases/get_payrolls.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/payroll_entity.dart';
import '../repositories/payroll_repository.dart';
import 'base_usecase.dart';

class GetPayrolls extends UseCase<List<Payroll>, String> {
  final PayrollRepository repository;

  GetPayrolls(this.repository);

  @override
  Future<Either<Failure, List<Payroll>>> call(String employeeId) {
    return repository.getPayrolls(employeeId);
  }
}
```

---

### **4. MENAMBAHKAN API / DATA LAYER**

#### **Step 1: Create Data Model**
📍 **Lokasi**: `lib/data/models/`

**File**: `lib/data/models/payroll_model.dart`
```dart
import '../../domain/entities/payroll_entity.dart';
import 'base_model.dart';

class PayrollModel extends BaseModel<Payroll> {
  final String employeeId;
  final double amount;
  // ... other fields

  const PayrollModel({
    required super.id,
    required super.companyId,
    required this.employeeId,
    required this.amount,
    required super.createdAt,
    super.updatedAt,
  });

  factory PayrollModel.fromJson(Map<String, dynamic> json) {
    return PayrollModel(
      id: json['id'],
      companyId: json['companyId'],
      employeeId: json['employeeId'],
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'employeeId': employeeId,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  Payroll toEntity() {
    return Payroll(
      id: id,
      companyId: companyId,
      employeeId: employeeId,
      amount: amount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  PayrollModel fromEntity(Payroll entity) {
    return PayrollModel(
      id: entity.id,
      companyId: entity.companyId,
      employeeId: entity.employeeId,
      amount: entity.amount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
```

#### **Step 2: Create Remote Data Source**
📍 **Lokasi**: `lib/data/datasources/remote/`

**File**: `lib/data/datasources/remote/payroll_remote_datasource.dart`
```dart
import '../../../core/network/api_client.dart';
import '../../models/payroll_model.dart';
import '../base_datasource.dart';

class PayrollRemoteDataSource implements RemoteDataSource {
  final ApiClient apiClient;

  PayrollRemoteDataSource(this.apiClient);

  Future<List<PayrollModel>> getPayrolls(String employeeId) async {
    final response = await apiClient.get('/payrolls', queryParameters: {
      'employeeId': employeeId,
    });
    
    return (response.data as List)
        .map((json) => PayrollModel.fromJson(json))
        .toList();
  }

  Future<PayrollModel> getPayrollById(String id) async {
    final response = await apiClient.get('/payrolls/$id');
    return PayrollModel.fromJson(response.data);
  }
}
```

#### **Step 3: Create Local Data Source (Optional)**
📍 **Lokasi**: `lib/data/datasources/local/`

**File**: `lib/data/datasources/local/payroll_local_datasource.dart`
```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/payroll_model.dart';
import '../base_datasource.dart';

class PayrollLocalDataSource implements LocalDataSource {
  final SharedPreferences prefs;

  PayrollLocalDataSource(this.prefs);

  Future<void> cachePayrolls(List<PayrollModel> payrolls) async {
    // Cache logic
  }

  Future<List<PayrollModel>?> getCachedPayrolls() async {
    // Get cached data
    return null;
  }
}
```

#### **Step 4: Implement Repository**
📍 **Lokasi**: `lib/data/repositories/`

**File**: `lib/data/repositories/payroll_repository_impl.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/payroll_entity.dart';
import '../../domain/repositories/payroll_repository.dart';
import '../datasources/remote/payroll_remote_datasource.dart';
import '../datasources/local/payroll_local_datasource.dart';
import '../models/payroll_model.dart';

class PayrollRepositoryImpl implements PayrollRepository {
  final PayrollRemoteDataSource remoteDataSource;
  final PayrollLocalDataSource localDataSource;

  PayrollRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Payroll>>> getPayrolls(String employeeId) async {
    try {
      // Try remote first
      final models = await remoteDataSource.getPayrolls(employeeId);
      final entities = models.map((model) => model.toEntity()).toList();
      
      // Cache locally
      await localDataSource.cachePayrolls(models);
      
      return Right(entities);
    } catch (e) {
      // Try local cache on error
      try {
        final cached = await localDataSource.getCachedPayrolls();
        if (cached != null) {
          return Right(cached.map((m) => m.toEntity()).toList());
        }
      } catch (_) {}
      
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Payroll>> getPayrollById(String id) async {
    try {
      final model = await remoteDataSource.getPayrollById(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

---

### **5. MENAMBAHKAN STATE MANAGEMENT (RIVERPOD)**

📍 **Lokasi**: `lib/presentation/providers/`

**File**: `lib/presentation/providers/payroll_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payroll_entity.dart';
import '../../domain/repositories/payroll_repository.dart';
import '../../domain/usecases/get_payrolls.dart';
import '../../data/repositories/payroll_repository_impl.dart';
import '../../data/datasources/remote/payroll_remote_datasource.dart';
import '../../data/datasources/local/payroll_local_datasource.dart';
import '../providers/app_providers.dart';

// Repository Provider
final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  
  return PayrollRepositoryImpl(
    remoteDataSource: PayrollRemoteDataSource(apiClient),
    localDataSource: PayrollLocalDataSource(prefs),
  );
});

// Use Case Provider
final getPayrollsUseCaseProvider = Provider<GetPayrolls>((ref) {
  final repository = ref.watch(payrollRepositoryProvider);
  return GetPayrolls(repository);
});

// State Provider
final payrollsProvider = FutureProvider.family<List<Payroll>, String>((ref, employeeId) async {
  final useCase = ref.watch(getPayrollsUseCaseProvider);
  final result = await useCase.call(employeeId);
  
  return result.fold(
    (failure) => throw failure,
    (payrolls) => payrolls,
  );
});
```

---

### **6. MENGHUBUNGKAN SEMUA LAYER**

**File**: `lib/presentation/screens/payroll/payroll_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payroll_provider.dart';
import '../../domain/entities/payroll_entity.dart';

class PayrollScreen extends ConsumerWidget {
  final String employeeId;
  
  const PayrollScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payrollsAsync = ref.watch(payrollsProvider(employeeId));

    return Scaffold(
      appBar: AppBar(title: const Text('Payroll')),
      body: payrollsAsync.when(
        data: (payrolls) => ListView.builder(
          itemCount: payrolls.length,
          itemBuilder: (context, index) {
            final payroll = payrolls[index];
            return ListTile(
              title: Text('Amount: \$${payroll.amount}'),
              subtitle: Text('Date: ${payroll.createdAt}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

---

## 📋 Checklist Menambahkan Fitur Baru

### ✅ **Domain Layer**
- [ ] Create Entity di `lib/domain/entities/`
- [ ] Create Repository Interface di `lib/domain/repositories/`
- [ ] Create Use Cases di `lib/domain/usecases/`

### ✅ **Data Layer**
- [ ] Create Model di `lib/data/models/` (extend BaseModel)
- [ ] Create Remote Data Source di `lib/data/datasources/remote/`
- [ ] Create Local Data Source di `lib/data/datasources/local/` (optional)
- [ ] Implement Repository di `lib/data/repositories/`

### ✅ **Presentation Layer**
- [ ] Create Providers di `lib/presentation/providers/`
- [ ] Create Screen di `lib/presentation/screens/[feature]/`
- [ ] Create Widgets di `lib/presentation/widgets/` (jika perlu)

### ✅ **Testing**
- [ ] Test Use Cases
- [ ] Test Repository
- [ ] Test Providers
- [ ] Test UI

---

## 🎯 Quick Reference

| Yang Ingin Ditambahkan | Lokasi File |
|------------------------|-------------|
| **UI Widget (Reusable)** | `lib/shared/widgets/` |
| **UI Widget (Feature)** | `lib/presentation/widgets/` |
| **Screen/Page** | `lib/presentation/screens/[feature]/` |
| **Domain Entity** | `lib/domain/entities/` |
| **Repository Interface** | `lib/domain/repositories/` |
| **Use Case** | `lib/domain/usecases/` |
| **Data Model** | `lib/data/models/` |
| **Remote Data Source** | `lib/data/datasources/remote/` |
| **Local Data Source** | `lib/data/datasources/local/` |
| **Repository Implementation** | `lib/data/repositories/` |
| **Riverpod Provider** | `lib/presentation/providers/` |
| **Constants** | `lib/core/constants/` |
| **Utils** | `lib/core/utils/` atau `lib/shared/utils/` |

---

## 🔄 Flow Development

```
1. Domain Entity (Business Object)
   ↓
2. Repository Interface (Contract)
   ↓
3. Use Case (Business Logic)
   ↓
4. Data Model (JSON Serializable)
   ↓
5. Data Sources (API/Local)
   ↓
6. Repository Implementation
   ↓
7. Riverpod Provider
   ↓
8. Screen/UI
```

---

## 💡 Tips

1. **Always start with Domain Layer** - Define business logic first
2. **Use Base Classes** - Extend BaseEntity, BaseModel, BaseRepository
3. **Company Context** - Use CompanyEntity for multi-company features
4. **Error Handling** - Use Either<Failure, T> pattern
5. **Testing** - Test each layer independently
6. **Naming** - Follow existing patterns (Entity, Model, Repository, UseCase)

---

**Happy Coding! 🚀**