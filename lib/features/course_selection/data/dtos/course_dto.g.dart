// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseResultDto _$CourseResultDtoFromJson(Map<String, dynamic> json) =>
    CourseResultDto(
      totalCount: (json['total_count'] as num).toInt(),
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
      courses: (json['courses'] as List<dynamic>)
          .map((e) => CourseResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

CourseResponseDto _$CourseResponseDtoFromJson(Map<String, dynamic> json) =>
    CourseResponseDto(
      serialNo: json['serial_no'] as String,
      classNo: json['class_no'] as String,
      title: json['title'] as String,
      credit: (json['credit'] as num).toInt(),
      teachers:
          (json['teachers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      classTimes:
          (json['class_times'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      passwordCard: json['password_card'] as String?,
      limitCnt: (json['limit_cnt'] as num?)?.toInt(),
      admitCnt: (json['admit_cnt'] as num?)?.toInt(),
      waitCnt: (json['wait_cnt'] as num?)?.toInt(),
      collegeName: json['college_name'] as String?,
      departmentName: json['department_name'] as String?,
      courseType: json['course_type'] as String?,
    );
