import 'dart:convert';

import 'package:dio/dio.dart';

const staticCourseCatalogUrl =
    'https://raw.githubusercontent.com/magic-pinecone/magic-pinecone-lite/115-1/courses.json';

class StaticCourseCatalogDataSource {
  StaticCourseCatalogDataSource({
    required this.dio,
    this.coursesUrl = staticCourseCatalogUrl,
  });

  final Dio dio;
  final String coursesUrl;

  Future<Map<String, dynamic>> loadCatalogJson() async {
    final response = await dio.getUri<Object>(Uri.parse(coursesUrl));
    return _decodeJsonObject(response.data);
  }

  Map<String, dynamic> _decodeJsonObject(Object? data) {
    final decoded = switch (data) {
      final Map<String, dynamic> value => value,
      final Map<Object?, Object?> value => Map<String, dynamic>.from(value),
      final String value => jsonDecode(value) as Map<String, dynamic>,
      _ => throw FormatException('Unexpected courses payload: $data'),
    };
    return decoded;
  }
}
