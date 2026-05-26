import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:prototype/features/news/data/dtos/scholarship_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'scholarship_api_service.g.dart';

@RestApi(parser: Parser.FlutterCompute)
abstract class ScholarshipApiService {
  factory ScholarshipApiService(Dio dio, {String? baseUrl}) =
      _ScholarshipApiService;

  @GET('/scholarship')
  Future<ScholarshipResultDto> fetchScholarships({
    @Query('title') String? title,
    @Query('category') String? category,
    @Query('skip') int skip = 0,
    @Query('limit') int limit = 100,
  });
}

ScholarshipResultDto deserializeScholarshipResultDto(
        Map<String, dynamic> json) =>
    ScholarshipResultDto.fromJson(json);
