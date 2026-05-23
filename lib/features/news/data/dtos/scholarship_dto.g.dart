// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scholarship_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScholarshipResultDto _$ScholarshipResultDtoFromJson(
  Map<String, dynamic> json,
) => ScholarshipResultDto(
  totalCount: (json['total_count'] as num).toInt(),
  scholarships: (json['scholarships'] as List<dynamic>)
      .map((e) => ScholarshipResponseDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  lastUpdated: json['last_updated'] == null
      ? null
      : DateTime.parse(json['last_updated'] as String),
);

ScholarshipResponseDto _$ScholarshipResponseDtoFromJson(
  Map<String, dynamic> json,
) => ScholarshipResponseDto(
  id: (json['id'] as num).toInt(),
  category: json['category'] as String,
  title: json['title'] as String,
  contentSummary: json['content_summary'] as String?,
  downloadLink: json['download_link'] as String?,
);
