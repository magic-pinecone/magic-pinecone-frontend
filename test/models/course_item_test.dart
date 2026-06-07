import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/features/course_selection/domain/models/course_schedule_models.dart';

void main() {
  group('CourseItem', () {
    test('courseTypeText normalizes backend and raw course type values', () {
      expect(_course(courseType: 'REQUIRED').courseTypeText, '必修');
      expect(_course(courseType: 'required').courseTypeText, '必修');
      expect(_course(courseType: 'ELECTIVE').courseTypeText, '選修');
      expect(_course(courseType: 'elective').courseTypeText, '選修');
      expect(_course(courseType: '必修').courseTypeText, '必修');
      expect(_course(courseType: '選修').courseTypeText, '選修');
      expect(_course(courseType: 'UNKNOWN').courseTypeText, '未知');
      expect(_course().courseTypeText, '未分類');
    });

    test('passwordCardText maps backend codes and hides no-card hints', () {
      expect(_course(passwordCard: 'NONE').passwordCardText, '無');
      expect(_course(passwordCard: 'none').passwordCardText, '無');
      expect(_course(passwordCard: 'OPTIONAL').passwordCardText, '部分');
      expect(_course(passwordCard: 'optional').passwordCardText, '部分');
      expect(_course(passwordCard: 'ALL').passwordCardText, '全部');
      expect(_course(passwordCard: 'all').passwordCardText, '全部');
      expect(_course().passwordCardText, '無');

      expect(_course(passwordCard: 'NONE').showsPasswordCardHint, isFalse);
      expect(_course().showsPasswordCardHint, isFalse);
      expect(_course(passwordCard: 'OPTIONAL').showsPasswordCardHint, isTrue);
      expect(_course(passwordCard: 'ALL').showsPasswordCardHint, isTrue);
    });
  });
}

CourseItem _course({String? courseType, String? passwordCard}) {
  return CourseItem(
    serialNo: '12345',
    classNo: 'CS101',
    title: '程式設計',
    credit: 3,
    teachers: const [],
    classTimes: const [],
    passwordCard: passwordCard,
    courseType: courseType,
  );
}
