# API Helper & Endpoints Guide

## 📋 Overview

Aplikasi menggunakan sistem terpusat untuk mengelola API endpoints dan helper methods yang reusable untuk semua operasi HTTP (GET, POST, PUT, DELETE).

## 🗂️ File Structure

### 1. **ApiEndpoints** (`lib/core/constants/api_endpoints.dart`)
File ini berisi semua URL/endpoints API yang digunakan di aplikasi.

### 2. **ApiHelper** (`lib/core/network/api_helper.dart`)
Helper class yang menyediakan methods reusable untuk operasi HTTP dengan error handling yang konsisten.

## 📝 Penggunaan

### Menggunakan ApiEndpoints

Semua endpoint API disimpan di `ApiEndpoints` class:

```dart
import 'package:hris_mobile_app/core/constants/api_endpoints.dart';

// Menggunakan endpoint langsung
final response = await apiHelper.get(ApiEndpoints.userProfile);

// Menggunakan endpoint dengan path parameters
final employeeId = '123';
final endpoint = ApiEndpoints.replacePathParams(
  ApiEndpoints.employeeDetail,
  {'id': employeeId},
);
final response = await apiHelper.get(endpoint);
```

### Menggunakan ApiHelper

#### 1. **GET Request**

```dart
import 'package:hris_mobile_app/core/network/api_helper.dart';
import 'package:hris_mobile_app/core/constants/api_endpoints.dart';

// Simple GET
final response = await apiHelper.get(ApiEndpoints.userProfile);

// GET dengan query parameters
final response = await apiHelper.get(
  ApiEndpoints.attendanceHistory,
  queryParameters: {
    'startDate': '2024-01-01',
    'endDate': '2024-01-31',
    'page': 1,
    'limit': 10,
  },
);
```

#### 2. **POST Request**

```dart
// POST dengan data
final response = await apiHelper.post(
  ApiEndpoints.applyLeave,
  data: {
    'leaveType': 'annual',
    'startDate': '2024-02-01',
    'endDate': '2024-02-05',
    'reason': 'Family vacation',
  },
);
```

#### 3. **PUT Request**

```dart
// PUT untuk update data
final response = await apiHelper.put(
  ApiEndpoints.updateProfile,
  data: {
    'name': 'John Doe',
    'phone': '081234567890',
  },
);
```

#### 4. **DELETE Request**

```dart
// DELETE request
final response = await apiHelper.delete(
  ApiEndpoints.replacePathParams(
    ApiEndpoints.leaveDetail,
    {'id': leaveId},
  ),
);
```

## 🔧 Membuat Data Source Baru

Contoh membuat data source baru menggunakan ApiHelper:

```dart
import 'package:hris_mobile_app/core/network/api_helper.dart';
import 'package:hris_mobile_app/core/constants/api_endpoints.dart';

class AttendanceDataSource {
  final ApiHelper _apiHelper;

  AttendanceDataSource(this._apiHelper);

  // Get today's attendance
  Future<Map<String, dynamic>> getTodayAttendance() async {
    return await _apiHelper.get(ApiEndpoints.attendanceToday);
  }

  // Clock in
  Future<Map<String, dynamic>> clockIn({
    required double latitude,
    required double longitude,
  }) async {
    return await _apiHelper.post(
      ApiEndpoints.clockIn,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Get attendance history
  Future<Map<String, dynamic>> getAttendanceHistory({
    required String startDate,
    required String endDate,
    int page = 1,
    int limit = 10,
  }) async {
    return await _apiHelper.get(
      ApiEndpoints.attendanceHistory,
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
        'page': page,
        'limit': limit,
      },
    );
  }
}
```

## 📍 Menambahkan Endpoint Baru

Untuk menambahkan endpoint baru, edit `api_endpoints.dart`:

```dart
class ApiEndpoints {
  // ... existing endpoints

  // Tambahkan endpoint baru di kategori yang sesuai
  static const String newEndpoint = '/ms-module/api/new-endpoint';
  
  // Atau dengan path parameter
  static const String newEndpointWithParam = '/ms-module/api/resource/{id}';
}
```

## 🎯 Best Practices

### 1. **Selalu Gunakan ApiEndpoints**
❌ **Jangan:**
```dart
final response = await apiHelper.get('/ms-auth/api/auth/login');
```

✅ **Gunakan:**
```dart
final response = await apiHelper.get(ApiEndpoints.login);
```

### 2. **Gunakan ApiHelper untuk Semua Request**
ApiHelper sudah menangani:
- Error handling yang konsisten
- Response format checking
- Status code validation
- Network error handling

### 3. **Path Parameters**
Gunakan `replacePathParams` untuk endpoint dengan path parameters:

```dart
// ✅ Benar
final endpoint = ApiEndpoints.replacePathParams(
  ApiEndpoints.employeeDetail,
  {'id': employeeId},
);

// ❌ Salah
final endpoint = ApiEndpoints.employeeDetail.replaceAll('{id}', employeeId);
```

### 4. **Error Handling**
ApiHelper sudah menangani semua error types:
- `NetworkFailure` - Network/connection errors
- `UnauthorizedFailure` - 401 errors
- `NotFoundFailure` - 404 errors
- `ServerFailure` - Other server errors
- `PermissionFailure` - 403 errors

Catch error di provider/notifier:

```dart
try {
  final response = await _apiHelper.get(ApiEndpoints.userProfile);
  // Handle success
} on Failure catch (e) {
  // Handle error
  print('Error: ${e.message}');
}
```

## 📚 Contoh Lengkap

### Data Source
```dart
import 'package:hris_mobile_app/core/network/api_helper.dart';
import 'package:hris_mobile_app/core/constants/api_endpoints.dart';

class LeaveDataSource {
  final ApiHelper _apiHelper;

  LeaveDataSource(this._apiHelper);

  Future<Map<String, dynamic>> getLeaveBalance() async {
    return await _apiHelper.get(ApiEndpoints.leaveBalance);
  }

  Future<Map<String, dynamic>> applyLeave({
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    return await _apiHelper.post(
      ApiEndpoints.applyLeave,
      data: {
        'leaveType': leaveType,
        'startDate': startDate,
        'endDate': endDate,
        'reason': reason,
      },
    );
  }

  Future<Map<String, dynamic>> getLeaveHistory({
    int page = 1,
    int limit = 10,
  }) async {
    return await _apiHelper.get(
      ApiEndpoints.leaveHistory,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
  }

  Future<Map<String, dynamic>> getLeaveDetail(String leaveId) async {
    return await _apiHelper.get(
      ApiEndpoints.replacePathParams(
        ApiEndpoints.leaveDetail,
        {'id': leaveId},
      ),
    );
  }
}
```

### Provider
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hris_mobile_app/core/network/api_helper.dart';
import 'package:hris_mobile_app/presentation/providers/app_providers.dart';

final leaveDataSourceProvider = Provider<LeaveDataSource>((ref) {
  final apiHelper = ref.watch(apiHelperProvider);
  return LeaveDataSource(apiHelper);
});
```

## 🔍 Response Format

ApiHelper mengharapkan response format:

```json
{
  "status": 1,
  "message": "ok",
  "data": {
    // Response data
  }
}
```

- `status: 1` = Success
- `status != 1` = Error (akan throw ServerFailure dengan message)

Jika response tidak memiliki field `status`, akan dianggap success jika status code 2xx.

## ✅ Checklist

Saat membuat data source baru:

- [ ] Import `ApiHelper` dan `ApiEndpoints`
- [ ] Tambahkan endpoint ke `ApiEndpoints` jika belum ada
- [ ] Gunakan `ApiHelper` methods (get, post, put, delete)
- [ ] Handle errors dengan try-catch `Failure`
- [ ] Gunakan `replacePathParams` untuk path parameters
- [ ] Test dengan API logger enabled

## 🎉 Benefits

1. **Centralized URLs** - Semua endpoint di satu tempat
2. **Consistent Error Handling** - Error handling yang sama di semua tempat
3. **Reusable Code** - Tidak perlu duplikasi kode
4. **Easy Maintenance** - Mudah update endpoint atau error handling
5. **Type Safety** - Menggunakan constants, mengurangi typo
