import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:prototype/features/course_selection/data/dtos/course_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'course_api_service.g.dart';

@RestApi(parser: Parser.FlutterCompute)
abstract class CourseApiService {
  factory CourseApiService(Dio dio, {String? baseUrl}) = _CourseApiService;
  @GET('/course')
  Future<CourseResultDto> getCourse({
    @Query('title') String? keyword,
    @Query('class_no') String? classNo,
    @Query('serial_no') String? serialNo,
    @Query('department_id') String? departmentId,
    @Query('college_id') String? collegeId,
    @Query('course_type') String? courseType,
    @Query('credits') List<int>? credits,
    @Query('has_vacancy') bool? hasVacancy,
    @Query('class_times') List<String>? classTimes,
    @Query('skip') int? offset,
    @Query('limit') int? limit,
  });
}

CourseResultDto deserializeCourseResultDto(Map<String, dynamic> json) =>
    CourseResultDto.fromJson(json);
