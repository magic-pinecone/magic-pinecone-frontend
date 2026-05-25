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
    required this.contentSummary,
    this.downloadLink,
  });

  final int id;
  final String category;
  final String title;
  @JsonKey(fromJson: _contentSummaryFromJson)
  final String contentSummary;
  final String? downloadLink;

  factory ScholarshipResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ScholarshipResponseDtoFromJson(json);
}

String _contentSummaryFromJson(Object? value) {
  return switch (value) {
    null => '',
    final String summary => summary,
    final Map<String, dynamic> fields =>
      fields.entries
          .map((entry) => '${entry.key}: ${entry.value ?? ''}')
          .join('\n'),
    final Map<Object?, Object?> fields =>
      fields.entries
          .map((entry) => '${entry.key}: ${entry.value ?? ''}')
          .join('\n'),
    _ => value.toString(),
  };
}
