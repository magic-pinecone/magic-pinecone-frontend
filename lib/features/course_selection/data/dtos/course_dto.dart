import 'package:json_annotation/json_annotation.dart';

part 'course_dto.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class CourseResultDto {
  const CourseResultDto({
    required this.totalCount,
    required this.lastUpdated,
    required this.courses,
  });

  final int totalCount;
  final DateTime? lastUpdated;
  final List<CourseResponseDto> courses;

  factory CourseResultDto.fromJson(Map<String, dynamic> json) =>
      _$CourseResultDtoFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class CourseResponseDto {
  const CourseResponseDto({
    required this.serialNo,
    required this.classNo,
    required this.title,
    required this.credit,
    required this.teachers,
    required this.classTimes,
    this.passwordCard,
    this.limitCnt,
    this.admitCnt,
    this.waitCnt,
    this.collegeId,
    this.departmentId,
    this.courseType,
  });
  final String serialNo;
  final String classNo;
  final String title;
  final int credit;
  final String? passwordCard;
  @JsonKey(defaultValue: <String>[])
  final List<String> teachers;
  @JsonKey(defaultValue: <String>[])
  final List<String> classTimes;
  final int? limitCnt;
  final int? admitCnt;
  final int? waitCnt;
  final String? collegeId;
  final String? departmentId;
  final String? courseType;

  factory CourseResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CourseResponseDtoFromJson(json);
}
