/// Company Context for Multi-Company HRIS Support
/// This manages the current company context throughout the app
class CompanyContext {
  final String companyId;
  final String companyName;
  final String? companyLogo;
  final Map<String, dynamic>? settings;
  
  const CompanyContext({
    required this.companyId,
    required this.companyName,
    this.companyLogo,
    this.settings,
  });
  
  CompanyContext copyWith({
    String? companyId,
    String? companyName,
    String? companyLogo,
    Map<String, dynamic>? settings,
  }) {
    return CompanyContext(
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      settings: settings ?? this.settings,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyContext &&
          runtimeType == other.runtimeType &&
          companyId == other.companyId;
  
  @override
  int get hashCode => companyId.hashCode;
  
  @override
  String toString() => 'CompanyContext(companyId: $companyId, companyName: $companyName)';
}