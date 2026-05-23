import 'package:json_annotation/json_annotation.dart';

part 'scholarship_dto.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class ScholarshipResultDto {
  const ScholarshipResultDto({
    required this.totalCount,
    required this.scholarships,
    this.lastUpdated,
  });

  final int totalCount;
  final DateTime? lastUpdated;
  final List<ScholarshipResponseDto> scholarships;

  factory ScholarshipResultDto.fromJson(Map<String, dynamic> json) =>
      _$ScholarshipResultDtoFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class ScholarshipResponseDto {
  const ScholarshipResponseDto({
    required this.id,
    required this.category,
    required this.title,
    this.contentSummary,
    this.downloadLink,
  });

  final int id;
  final String category;
  final String title;
  final String? contentSummary;
  final String? downloadLink;

  factory ScholarshipResponseDto.fromJson(Map<String, Object?> json) =>
      _$ScholarshipResponseDtoFromJson(json);
}
