/// Base Entity class for all domain entities
/// All entities should extend this for consistency
abstract class BaseEntity {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const BaseEntity({
    required this.id,
    required this.createdAt,
    this.updatedAt,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}

/// Entity with company context for multi-company support
abstract class CompanyEntity extends BaseEntity {
  final String companyId;
  
  const CompanyEntity({
    required super.id,
    required this.companyId,
    required super.createdAt,
    super.updatedAt,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is CompanyEntity &&
          companyId == other.companyId;
  
  @override
  int get hashCode => super.hashCode ^ companyId.hashCode;
}