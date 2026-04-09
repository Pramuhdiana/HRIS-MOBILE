import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/failures.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/profile_api_provider.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/liquid_glass_scaffold.dart';

const _genderApiMale = 'Laki-laki';
const _genderApiFemale = 'Perempuan';
const _maritalSingle = 'Lajang';
const _maritalMarried = 'Menikah';

const _religionApiValues = [
  'Islam',
  'Kristen',
  'Katolik',
  'Hindu',
  'Buddha',
  'Konghucu',
  'Lainnya',
];

DateTime? _parseBirthDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final iso = DateTime.tryParse(raw);
  if (iso != null) return iso;
  for (final pattern in ['dd/MM/yyyy', 'yyyy-MM-dd', 'dd-MM-yyyy']) {
    try {
      return DateFormat(pattern).parseStrict(raw.trim());
    } catch (_) {}
  }
  return null;
}

String? _normalizeGenderApi(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final s = raw.toLowerCase().trim();
  if (s == 'pria' || s.contains('laki') || s == 'm') return _genderApiMale;
  if (s == 'wanita' ||
      s.contains('perempuan') ||
      s == 'p' ||
      s.contains('female')) {
    return _genderApiFemale;
  }
  if (s.contains('male')) return _genderApiMale;
  return null;
}

bool _isMarriedRaw(String? raw) {
  if (raw == null || raw.isEmpty) return false;
  final s = raw.toLowerCase();
  return s.contains('menikah') || s.contains('married');
}

String _normalizeMaritalApi(String? raw) {
  return _isMarriedRaw(raw) ? _maritalMarried : _maritalSingle;
}

String _initialReligionApi(String? raw) {
  if (raw == null || raw.isEmpty) return 'Islam';
  for (final v in _religionApiValues) {
    if (v.toLowerCase() == raw.toLowerCase()) return v;
  }
  return 'Lainnya';
}

String _religionLabel(AppLocalizations l10n, String api) {
  return switch (api) {
    'Islam' => l10n.profileReligionIslam,
    'Kristen' => l10n.profileReligionProtestant,
    'Katolik' => l10n.profileReligionCatholic,
    'Hindu' => l10n.profileReligionHindu,
    'Buddha' => l10n.profileReligionBuddhist,
    'Konghucu' => l10n.profileReligionConfucian,
    'Lainnya' => l10n.profileReligionOther,
    _ => api,
  };
}

/// Form edit profil lengkap — email hanya baca; sisanya sesuai biodata HRIS.
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(profileApiProvider);

    return LiquidGlassScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.editProfile,
          style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 48,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  l10n.serverError,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(profileApiProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.refresh),
                ),
              ],
            ),
          ),
        ),
        data: (profile) => _EditProfileForm(initial: profile),
      ),
    );
  }
}

class _EditProfileForm extends ConsumerStatefulWidget {
  const _EditProfileForm({required this.initial});

  final ProfileApiData? initial;

  @override
  ConsumerState<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _birthPlaceController;
  late final TextEditingController _birthDateDisplayController;
  late final TextEditingController _domicileController;
  late final TextEditingController _ktpController;
  late final TextEditingController _childrenController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyPhoneController;

  late String _genderValue;
  late String _religionValue;
  late String _maritalValue;
  DateTime? _birthDate;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _nameController = TextEditingController(text: p?.name ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _birthPlaceController = TextEditingController(text: p?.birthPlace ?? '');
    _domicileController = TextEditingController(text: p?.domicileAddress ?? '');
    _ktpController = TextEditingController(text: p?.ktpAddress ?? '');
    _childrenController = TextEditingController(text: p?.childCountRaw ?? '');
    _emergencyNameController = TextEditingController(
      text: p?.emergencyContactName ?? '',
    );
    _emergencyPhoneController = TextEditingController(
      text: p?.emergencyContactPhone ?? '',
    );
    _birthDate = _parseBirthDate(p?.birthDateRaw);
    _birthDateDisplayController = TextEditingController();

    final g = _normalizeGenderApi(p?.genderRaw);
    _genderValue = g ?? _genderApiMale;

    _religionValue = _initialReligionApi(p?.religionRaw);
    _maritalValue = _normalizeMaritalApi(p?.maritalStatusRaw);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBirthDateLabel();
  }

  void _syncBirthDateLabel() {
    final loc = Localizations.localeOf(context).toString();
    _birthDateDisplayController.text = _birthDate != null
        ? DateFormat.yMMMMd(loc).format(_birthDate!)
        : '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthPlaceController.dispose();
    _birthDateDisplayController.dispose();
    _domicileController.dispose();
    _ktpController.dispose();
    _childrenController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  bool get _isMarried => _maritalValue == _maritalMarried;

  Future<void> _pickBirthDate() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate: now,
      helpText: l10n.profileSelectDate,
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _syncBirthDateLabel();
      });
    }
  }

  String? _validateName(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.profileNameRequired;
    return null;
  }

  String? _validateChildren(String? value, AppLocalizations l10n) {
    if (!_isMarried) return null;
    final t = value?.trim() ?? '';
    if (t.isEmpty) return null;
    final n = int.tryParse(t);
    if (n == null || n < 0) return l10n.profileInvalidChildren;
    return null;
  }

  String? _validateBirth(AppLocalizations l10n) {
    if (_birthDate == null) return l10n.profileBirthDateRequired;
    return null;
  }

  Future<void> _onSave() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final birthErr = _validateBirth(l10n);
    if (birthErr != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(birthErr)));
      return;
    }

    setState(() => _saving = true);
    try {
      final ds = ref.read(profileDataSourceProvider);
      final iso = DateFormat('yyyy-MM-dd').format(_birthDate!);
      final emergencyName = _emergencyNameController.text.trim();
      final emergencyPhone = _emergencyPhoneController.text.trim();
      final emergencyContact = () {
        if (emergencyName.isEmpty && emergencyPhone.isEmpty) return '';
        if (emergencyName.isEmpty) return emergencyPhone;
        if (emergencyPhone.isEmpty) return emergencyName;
        return '$emergencyName - $emergencyPhone';
      }();
      await ds.updateProfile(
        nama: _nameController.text.trim(),
        email: _emailController.text.trim(),
        noHp: _phoneController.text.trim(),
        jk: _genderValue,
        agama: _religionValue,
        tempatLahir: _birthPlaceController.text.trim(),
        tglLahirIso: iso,
        alamatDom: _domicileController.text.trim(),
        alamatKtp: _ktpController.text.trim(),
        status: _maritalValue,
        jmlAnak: _isMarried
            ? int.tryParse(_childrenController.text.trim()) ?? 0
            : 0,
        kontakDarurat: emergencyContact,
      );
      ref.invalidate(profileApiProvider);
      if (!mounted) return;
      context.pop();
      final rootCtx = AppRouter.navigatorKey.currentContext;
      if (rootCtx != null && rootCtx.mounted) {
        SnackBarHelper.showSuccess(
          rootCtx,
          title: l10n.success,
          message: l10n.profileUpdateSuccess,
        );
      }
    } on Failure catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, title: l10n.error, message: e.message);
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(
        context,
        title: l10n.error,
        message: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
    IconData? icon,
    bool readOnly = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null
          ? Icon(icon, color: AppColors.primary, size: AppDimensions.iconS)
          : null,
      filled: true,
      fillColor: readOnly
          ? Colors.white.withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.72),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      floatingLabelStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingM,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Text(
        title,
        style: AppTypography.h6.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF16365F),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingL,
              AppDimensions.paddingS,
              AppDimensions.paddingL,
              AppDimensions.paddingXL,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.profileEditFormSubtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                    LiquidGlassCard(
                      borderRadius: AppDimensions.radiusXL,
                      blurSigma: 24,
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _sectionTitle(l10n.profileSectionPersonal),
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: _fieldDecoration(
                              label: l10n.fullName,
                              icon: Icons.person_outline_rounded,
                            ),
                            validator: (v) => _validateName(v, l10n),
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          TextFormField(
                            controller: _emailController,
                            readOnly: true,
                            enableInteractiveSelection: true,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            decoration: _fieldDecoration(
                              label: l10n.email,
                              hint: l10n.profileEmailLockedHint,
                              icon: Icons.mail_lock_outlined,
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          DropdownButtonFormField<String>(
                            value: _genderValue,
                            decoration: _fieldDecoration(
                              label: l10n.profileGender,
                              icon: Icons.wc_rounded,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: _genderApiMale,
                                child: Text(l10n.profileGenderMale),
                              ),
                              DropdownMenuItem(
                                value: _genderApiFemale,
                                child: Text(l10n.profileGenderFemale),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _genderValue = v);
                              }
                            },
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          DropdownButtonFormField<String>(
                            value: _religionValue,
                            decoration: _fieldDecoration(
                              label: l10n.profileReligion,
                              icon: Icons.account_balance_outlined,
                            ),
                            items: _religionApiValues
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(_religionLabel(l10n, v)),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _religionValue = v);
                              }
                            },
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          TextFormField(
                            controller: _birthPlaceController,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: _fieldDecoration(
                              label: l10n.profileBirthPlace,
                              icon: Icons.place_outlined,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          TextFormField(
                            controller: _birthDateDisplayController,
                            readOnly: true,
                            onTap: _pickBirthDate,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration:
                                _fieldDecoration(
                                  label: l10n.profileBirthDate,
                                  hint: l10n.profileSelectDate,
                                  icon: Icons.cake_outlined,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.calendar_month_rounded,
                                    ),
                                    color: AppColors.primary,
                                    onPressed: _pickBirthDate,
                                  ),
                                ),
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          DropdownButtonFormField<String>(
                            value: _maritalValue,
                            decoration: _fieldDecoration(
                              label: l10n.profileMaritalStatus,
                              icon: Icons.favorite_outline,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: _maritalSingle,
                                child: Text(l10n.profileMaritalSingle),
                              ),
                              DropdownMenuItem(
                                value: _maritalMarried,
                                child: Text(l10n.profileMaritalMarried),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  _maritalValue = v;
                                  if (!_isMarried) {
                                    _childrenController.clear();
                                  }
                                });
                              }
                            },
                          ),
                          if (_isMarried) ...[
                            const SizedBox(height: AppDimensions.paddingM),
                            TextFormField(
                              controller: _childrenController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              decoration: _fieldDecoration(
                                label: l10n.profileChildrenCount,
                                icon: Icons.child_care_outlined,
                              ),
                              validator: (v) => _validateChildren(v, l10n),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    LiquidGlassCard(
                      borderRadius: AppDimensions.radiusXL,
                      blurSigma: 24,
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _sectionTitle(l10n.profileSectionContact),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: _fieldDecoration(
                              label: l10n.phoneNumber,
                              icon: Icons.phone_android_rounded,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          TextFormField(
                            controller: _emergencyNameController,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: _fieldDecoration(
                              label: l10n.profileEmergencyContactName,
                              icon: Icons.contact_emergency_outlined,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          TextFormField(
                            controller: _emergencyPhoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: _fieldDecoration(
                              label: l10n.profileEmergencyContactPhone,
                              icon: Icons.phone_in_talk_outlined,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          TextFormField(
                            controller: _domicileController,
                            minLines: 2,
                            maxLines: 4,
                            textCapitalization: TextCapitalization.sentences,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: _fieldDecoration(
                              label: l10n.profileDomicileAddress,
                              icon: Icons.home_work_outlined,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          TextFormField(
                            controller: _ktpController,
                            minLines: 2,
                            maxLines: 4,
                            textCapitalization: TextCapitalization.sentences,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: _fieldDecoration(
                              label: l10n.profileKtpAddress,
                              icon: Icons.badge_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.28),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: FilledButton(
                        onPressed: _saving ? null : _onSave,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingM,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusM,
                            ),
                          ),
                          minimumSize: const Size(
                            double.infinity,
                            AppDimensions.buttonHeightL,
                          ),
                        ),
                        child: _saving
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: AppColors.textOnPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.paddingM),
                                  Text(
                                    l10n.profileSaving,
                                    style: AppTypography.buttonMedium,
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.save_rounded, size: 22),
                                  const SizedBox(width: AppDimensions.paddingS),
                                  Text(
                                    l10n.save,
                                    style: AppTypography.buttonMedium,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
