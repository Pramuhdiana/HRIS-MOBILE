import '../../domain/entities/base_entity.dart';

/// Base Model class for all data models
/// Models should extend this and implement fromJson/toJson
abstract class BaseModel<T extends BaseEntity> {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BaseModel({required this.id, required this.createdAt, this.updatedAt});

  /// Convert JSON to Model
  /// Must be implemented in subclasses as factory constructor
  // ignore: unintended_html_in_doc_comment
  /// Example: factory ModelName.fromJson(Map<String, dynamic> json) => ModelName(...)

  /// Convert Model to JSON
  Map<String, dynamic> toJson();

  /// Convert Model to Domain Entity
  T toEntity();

  /// Convert Domain Entity to Model
  BaseModel<T> fromEntity(T entity);
}
