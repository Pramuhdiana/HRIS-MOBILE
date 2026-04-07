# SnackBar Helper Guide

## 📋 Overview

Aplikasi menggunakan `awesome_snackbar_content` package untuk menampilkan SnackBar yang lebih menarik dan informatif. Helper class `SnackBarHelper` menyediakan methods reusable untuk menampilkan berbagai jenis SnackBar.

## 🎨 Features

- ✅ **Success SnackBar** - Untuk pesan sukses
- ❌ **Error SnackBar** - Untuk pesan error
- ⚠️ **Warning SnackBar** - Untuk peringatan
- ℹ️ **Info SnackBar** - Untuk informasi

## 📝 Penggunaan

### Import

```dart
import 'package:hris_mobile_app/core/utils/snackbar_helper.dart';
```

### 1. Success SnackBar

Menampilkan pesan sukses dengan design hijau:

```dart
SnackBarHelper.showSuccess(
  context,
  title: 'Success!',
  message: 'Data berhasil disimpan',
);
```

### 2. Error SnackBar

Menampilkan pesan error dengan design merah:

```dart
SnackBarHelper.showError(
  context,
  title: 'Error',
  message: 'Terjadi kesalahan saat memproses data',
);
```

### 3. Warning SnackBar

Menampilkan peringatan dengan design kuning:

```dart
SnackBarHelper.showWarning(
  context,
  title: 'Warning',
  message: 'Pastikan semua data sudah diisi dengan benar',
);
```

### 4. Info SnackBar

Menampilkan informasi dengan design biru:

```dart
SnackBarHelper.showInfo(
  context,
  title: 'Info',
  message: 'Fitur ini akan segera tersedia',
);
```

## 💻 Contoh Lengkap

### Di Login Screen

```dart
import 'package:hris_mobile_app/core/utils/snackbar_helper.dart';
import 'package:hris_mobile_app/l10n/app_localizations.dart';

// Success message
SnackBarHelper.showSuccess(
  context,
  title: AppLocalizations.of(context)!.success,
  message: AppLocalizations.of(context)!.loginSuccess,
);

// Error message
SnackBarHelper.showError(
  context,
  title: AppLocalizations.of(context)!.error,
  message: 'Login failed: Invalid credentials',
);
```

### Di Form Validation

```dart
// Validasi form
if (!_formKey.currentState!.validate()) {
  SnackBarHelper.showWarning(
    context,
    title: 'Validation Error',
    message: 'Please fill all required fields',
  );
  return;
}

// Submit success
try {
  await submitForm();
  SnackBarHelper.showSuccess(
    context,
    title: 'Success',
    message: 'Form submitted successfully',
  );
} catch (e) {
  SnackBarHelper.showError(
    context,
    title: 'Error',
    message: e.toString(),
  );
}
```

### Di API Call

```dart
try {
  final response = await apiHelper.post(ApiEndpoints.saveData, data: data);
  SnackBarHelper.showSuccess(
    context,
    title: 'Success',
    message: 'Data saved successfully',
  );
} on Failure catch (e) {
  SnackBarHelper.showError(
    context,
    title: 'Error',
    message: e.message,
  );
}
```

## 🎯 Best Practices

### 1. **Gunakan Localization**
✅ **Benar:**
```dart
SnackBarHelper.showSuccess(
  context,
  title: AppLocalizations.of(context)!.success,
  message: AppLocalizations.of(context)!.loginSuccess,
);
```

❌ **Salah:**
```dart
SnackBarHelper.showSuccess(
  context,
  title: 'Success',
  message: 'Login successful',
);
```

### 2. **Pesan yang Jelas dan Informatif**
✅ **Benar:**
```dart
SnackBarHelper.showError(
  context,
  title: 'Login Failed',
  message: 'Invalid email or password. Please try again.',
);
```

❌ **Salah:**
```dart
SnackBarHelper.showError(
  context,
  title: 'Error',
  message: 'Failed',
);
```

### 3. **Gunakan Tipe yang Tepat**
- **Success** - Untuk operasi yang berhasil
- **Error** - Untuk kesalahan yang terjadi
- **Warning** - Untuk peringatan sebelum aksi
- **Info** - Untuk informasi umum

### 4. **Jangan Overuse**
Jangan menampilkan SnackBar terlalu sering, terutama untuk aksi yang tidak penting.

## 🔧 Material Banner (Alternative)

Jika ingin menggunakan Material Banner sebagai alternatif SnackBar:

```dart
SnackBarHelper.showMaterialBanner(
  context,
  title: 'Info',
  message: 'This is a material banner',
  contentType: ContentType.info,
);
```

**Note:** Material Banner akan tetap ditampilkan sampai user menutupnya secara manual.

## 📚 Package Reference

Package yang digunakan: [awesome_snackbar_content](https://pub.dev/packages/awesome_snackbar_content)

## ✅ Checklist

Saat menggunakan SnackBarHelper:

- [ ] Import `snackbar_helper.dart`
- [ ] Gunakan localization untuk title dan message
- [ ] Pilih tipe SnackBar yang sesuai (success/error/warning/info)
- [ ] Pastikan pesan jelas dan informatif
- [ ] Test di berbagai screen size

## 🎉 Benefits

1. **Consistent Design** - Semua SnackBar memiliki design yang konsisten
2. **Better UX** - Design yang lebih menarik dan informatif
3. **Reusable** - Mudah digunakan di seluruh aplikasi
4. **Type Safety** - Menggunakan ContentType untuk type safety
5. **Easy Maintenance** - Semua SnackBar logic di satu tempat
