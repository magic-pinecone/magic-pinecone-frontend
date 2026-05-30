import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:prototype/features/course_selection/models/course_detail_models.dart';

abstract class CourseSupplementalDetailRepository {
  Future<CourseSupplementalDetail?> findBySerialNo(String serialNo);
}

class CourseSupplementalDetailCatalog {
  const CourseSupplementalDetailCatalog();

  CourseSupplementalDetail? findBySerialNo(String serialNo) {
    return _detailsBySerialNo[serialNo];
  }
}

const staticRemoteCourseDetailsBaseUrl =
    'https://raw.githubusercontent.com/magic-pinecone/magic-pinecone-lite/115-1/detail';

class StaticRemoteCourseSupplementalDetailRepository
    implements CourseSupplementalDetailRepository {
  StaticRemoteCourseSupplementalDetailRepository({
    required Dio dio,
    this.detailsBaseUrl = staticRemoteCourseDetailsBaseUrl,
  }) : _dio = dio;

  final Dio _dio;
  final String detailsBaseUrl;
  final Map<String, CourseSupplementalDetail?> _cache = {};

  @override
  Future<CourseSupplementalDetail?> findBySerialNo(String serialNo) async {
    final normalizedSerialNo = _normalizeSerialNo(serialNo);
    if (normalizedSerialNo.isEmpty) return null;
    if (_cache.containsKey(normalizedSerialNo)) {
      return _cache[normalizedSerialNo];
    }

    try {
      final response = await _dio.getUri<Object>(
        Uri.parse('$detailsBaseUrl/$normalizedSerialNo.json'),
      );
      final detail = CourseSupplementalDetail.fromJson(
        _decodeJsonObject(response.data),
      );
      _cache[normalizedSerialNo] = detail;
      return detail;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        _cache[normalizedSerialNo] = null;
        return null;
      }
      rethrow;
    }
  }

  Map<String, Object?> _decodeJsonObject(Object? data) {
    return switch (data) {
      final Map<String, Object?> value => value,
      final Map<Object?, Object?> value => Map<String, Object?>.from(value),
      final String value => jsonDecode(value) as Map<String, Object?>,
      _ => throw FormatException('Unexpected course detail payload: $data'),
    };
  }

  String _normalizeSerialNo(String serialNo) {
    final normalized = serialNo.trim();
    if (normalized.isEmpty) return '';
    if (RegExp(r'^\d+$').hasMatch(normalized) && normalized.length < 5) {
      return normalized.padLeft(5, '0');
    }
    return normalized;
  }
}

class StaticFallbackCourseSupplementalDetailRepository
    implements CourseSupplementalDetailRepository {
  const StaticFallbackCourseSupplementalDetailRepository({
    this.catalog = const CourseSupplementalDetailCatalog(),
  });

  final CourseSupplementalDetailCatalog catalog;

  @override
  Future<CourseSupplementalDetail?> findBySerialNo(String serialNo) async {
    return catalog.findBySerialNo(serialNo);
  }
}

final Map<String, CourseSupplementalDetail> _detailsBySerialNo = {
  for (final detail in _courseSupplementalDetails) detail.serialNo: detail,
};

const List<CourseSupplementalDetail> _courseSupplementalDetails = [
  CourseSupplementalDetail(
    serialNo: '00001',
    objectives:
        '本課程為基礎課程，修完本課程，學生應能:\n'
        '1.具有五十音聽說讀寫能力。\n'
        '2.流利表達自我介紹、日常問候語。\n'
        '3.習得日期時間、物品、地點等名詞及常用動詞語彙。會表達與生活相關的名詞句型與動詞句型。\n'
        '4.培養進一步向上學習的興趣。具備繼續學習進階日語的能力。',
    content:
        '以「大家的日本語初級I」為主要教材，課程範圍第1課到第5課。學習日常生活必備基本語彙及基本句型表達。\n'
        '1.發音：逐字練習五十音，加強個別發音及書寫練習。於發音課程中導入單字，學習日常問候語。\n'
        '2.各課：認識單字、理解句型、組合使用、個別口頭練習、分組會話演練。\n'
        '(1)第1課:我是學生。 ∕自我介紹。\n'
        '(2)第2課:那是甚麼? ∕是誰的呢?\n'
        '(3)第3課:我的學校。∕車站在哪裡呢?\n'
        '(4)第4課:幾點起床呢? ∕田中先生的一天。\n'
        '(5)第5課:去、來、回家。\n'
        '3.教學方式：認識單字、講解句型。使用圖片﹑實物及視聽教材輔助教學，以互動方式練習會話，熟練各課基本句型，反覆開口說日語。',
    books: '『大家的日本語初級１』改訂版（大新書局）',
    teachingMethod: '講授\n\n個別指導',
    gradingPolicy:
        '1.第 9週:期中考30％\n'
        '2.第16週:期末考30％\n'
        '3.平常考與出席課堂表現40％',
  ),
];
