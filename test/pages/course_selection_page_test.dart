import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/features/course_selection/data/course_repository.dart';
import 'package:prototype/features/course_selection/data/course_selection_storage.dart';
import 'package:prototype/features/course_selection/data/course_share_codec.dart';
import 'package:prototype/features/course_selection/data/course_supplemental_detail_catalog.dart';
import 'package:prototype/features/course_selection/models/course_detail_models.dart';
import 'package:prototype/features/course_selection/models/course_schedule_models.dart';
import 'package:prototype/features/course_selection/presentation/course_selection_page.dart';
import 'package:prototype/features/course_selection/presentation/view_models/course_selection_controller.dart';

void main() {
  testWidgets('CourseSelectionPage renders loaded courses', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(
            repository: FakeCourseRepository(
              result: const CourseSearchResult(
                totalCount: 1,
                courses: [
                  CourseItem(
                    serialNo: '12345',
                    classNo: 'CS101',
                    title: '程式設計',
                    credit: 3,
                    passwordCard: 'OPTIONAL',
                    teachers: ['王小明'],
                    classTimes: ['1-1', '1-2'],
                    admitCount: 42,
                    limitCount: 60,
                    collegeName: '電機資訊學院',
                    departmentName: '資訊工程學系',
                    courseType: 'REQUIRED',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('課程查詢'), findsOneWidget);
    expect(find.text('程式設計'), findsOneWidget);
    expect(find.text('CS101 · 3 學分 · 王小明'), findsOneWidget);
    expect(find.text('電機資訊學院 / 資訊工程學系'), findsOneWidget);
    expect(find.text('42 / 60'), findsOneWidget);
    expect(find.text('部分'), findsOneWidget);
    expect(find.text('顯示 1 / 1 門課程'), findsOneWidget);
  });

  testWidgets(
    'CourseSelectionPage keeps search controls fixed while scrolling',
    (tester) async {
      final courses = List<CourseItem>.generate(
        24,
        (index) => CourseItem(
          serialNo: '${10000 + index}',
          classNo: 'CS$index',
          title: '課程 $index',
          credit: 3,
          teachers: const ['王小明'],
          classTimes: const ['1-1'],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CourseSelectionPage(
            controller: CourseSelectionController(
              repository: FakeCourseRepository(
                result: CourseSearchResult(
                  totalCount: courses.length,
                  courses: courses,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final advancedFilterButton = find.widgetWithText(OutlinedButton, '進階查詢');
      final resultSummary = find.text('顯示 24 / 24 門課程');
      final buttonTopBefore = tester.getTopLeft(advancedFilterButton).dy;
      final summaryTopBefore = tester.getTopLeft(resultSummary).dy;

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -360));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(advancedFilterButton).dy, buttonTopBefore);
      expect(tester.getTopLeft(resultSummary).dy, summaryTopBefore);
    },
  );

  testWidgets('CourseSelectionPage uses a split workspace on wide screens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(
            repository: FakeCourseRepository(
              result: const CourseSearchResult(
                totalCount: 2,
                courses: [
                  CourseItem(
                    serialNo: '12345',
                    classNo: 'CS101',
                    title: '程式設計',
                    credit: 3,
                    teachers: ['王小明'],
                    classTimes: ['1-1'],
                  ),
                  CourseItem(
                    serialNo: '12346',
                    classNo: 'CS102',
                    title: '資料結構',
                    credit: 3,
                    teachers: ['王小明'],
                    classTimes: ['1-2'],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('切換課程工具'), findsNothing);
    expect(find.byType(VerticalDivider), findsOneWidget);
    expect(find.text('週一'), findsOneWidget);
    expect(find.text('週五'), findsOneWidget);
    expect(find.text('程式設計'), findsOneWidget);
    expect(find.text('資料結構'), findsOneWidget);
  });

  testWidgets('CourseSelectionPage shows drawer menu at tab root', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(
            repository: FakeCourseRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('切換課程工具'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('CourseSelectionPage shows back button when pushed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          showBackButton: true,
          controller: CourseSelectionController(
            repository: FakeCourseRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
    expect(find.byTooltip('切換課程工具'), findsNothing);
  });

  testWidgets('CourseSelectionPage searches by submitted keyword', (
    tester,
  ) async {
    final repository = FakeCourseRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(repository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(SearchBar), '資料結構');
    await tester.tap(find.byTooltip('搜尋'));
    await tester.pumpAndSettle();

    expect(repository.requests.last.keyword, '資料結構');
  });

  testWidgets('CourseSelectionPage applies advanced text filters', (
    tester,
  ) async {
    final repository = FakeCourseRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(repository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('進階查詢'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '課號'), 'CS');
    await tester.enterText(find.widgetWithText(TextField, '流水號'), '12345');
    await tester.enterText(find.widgetWithText(TextField, '系所'), '資訊工程');
    await tester.enterText(find.widgetWithText(TextField, '學院'), '電機資訊');
    await tester.enterText(find.widgetWithText(TextField, '授課教師'), '王小明');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(repository.requests.last.classNo, 'CS');
    expect(repository.requests.last.serialNo, '12345');
    expect(repository.requests.last.departmentName, '資訊工程');
    expect(repository.requests.last.collegeName, '電機資訊');
    expect(repository.requests.last.instructor, '王小明');
    expect(find.text('課號：CS'), findsOneWidget);
    expect(find.text('流水號：12345'), findsOneWidget);
    expect(find.text('系所：資訊工程'), findsOneWidget);
    expect(find.text('學院：電機資訊'), findsOneWidget);
    expect(find.text('授課教師：王小明'), findsOneWidget);
    expect(find.text('清除全部'), findsOneWidget);
  });

  testWidgets(
    'CourseSelectionPage shows advanced filters dialog on wide screens',
    (tester) async {
      final repository = FakeCourseRepository();

      await tester.binding.setSurfaceSize(const Size(1000, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: CourseSelectionPage(
            controller: CourseSelectionController(repository: repository),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, '進階查詢'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('進階查詢'), findsWidgets);
      expect(find.text('上課時段'), findsOneWidget);
      expect(find.text('平日'), findsOneWidget);
      expect(find.text('全週'), findsOneWidget);
      expect(find.text('選擇上課時段'), findsNothing);

      await tester.tap(find.byTooltip('一 1'));
      await tester.pumpAndSettle();

      expect(find.text('套用查詢'), findsOneWidget);
      await tester.tap(find.text('套用查詢'));
      await tester.pumpAndSettle();

      expect(repository.requests.last.classTimes, ['1-1']);
    },
  );

  testWidgets(
    'CourseSelectionPage shows local filters dialog on wide screens',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: CourseSelectionPage(
            controller: CourseSelectionController(
              repository: FakeCourseRepository(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('檢視選項'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('檢視選項'), findsWidgets);
      expect(find.text('只顯示本頁可加入課表的課程'), findsOneWidget);
      expect(find.text('只顯示已加入課表的課程'), findsOneWidget);

      await tester.tap(find.text('完成'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    },
  );

  testWidgets('CourseSelectionPage closes advanced filters without applying', (
    tester,
  ) async {
    final repository = FakeCourseRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(repository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final requestCountBeforeSheet = repository.requests.length;

    await tester.tap(find.text('進階查詢'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '課號'), 'CS');
    await tester.tap(find.byTooltip('關閉'));
    await tester.pumpAndSettle();

    expect(repository.requests, hasLength(requestCountBeforeSheet));
    expect(find.text('課號：CS'), findsNothing);
  });

  testWidgets('CourseSelectionPage clears visible filter summary', (
    tester,
  ) async {
    final repository = FakeCourseRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(repository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(SearchBar), '資料結構');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('關鍵字：資料結構'), findsOneWidget);
    await tester.tap(find.text('清除全部'));
    await tester.pumpAndSettle();

    expect(repository.requests.last.keyword, isEmpty);
    expect(find.text('關鍵字：資料結構'), findsNothing);
  });

  testWidgets('CourseSelectionPage navigates result pages', (tester) async {
    final repository = FakeCourseRepository(
      results: [
        const CourseSearchResult(
          totalCount: 51,
          courses: [
            CourseItem(
              serialNo: '12345',
              classNo: 'CS101',
              title: '程式設計',
              credit: 3,
              teachers: ['王小明'],
              classTimes: ['1-1'],
            ),
          ],
        ),
        const CourseSearchResult(
          totalCount: 51,
          courses: [
            CourseItem(
              serialNo: '12346',
              classNo: 'CS102',
              title: '資料結構',
              credit: 3,
              teachers: ['王小明'],
              classTimes: ['1-2'],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(repository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('下一頁'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    await tester.tap(find.text('下一頁'));
    await tester.pumpAndSettle();

    expect(find.text('資料結構'), findsOneWidget);
    expect(
      repository.requests.last.offset,
      CourseSelectionController.defaultPageSize,
    );
  });

  testWidgets(
    'CourseSelectionPage locally filters timetable-compatible courses',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CourseSelectionPage(
            controller: CourseSelectionController(
              repository: FakeCourseRepository(
                result: const CourseSearchResult(
                  totalCount: 2,
                  courses: [
                    CourseItem(
                      serialNo: '12344',
                      classNo: 'CS100',
                      title: '已加入課程',
                      credit: 3,
                      teachers: ['王小明'],
                      classTimes: ['1-2'],
                    ),
                    CourseItem(
                      serialNo: '12345',
                      classNo: 'CS101',
                      title: '衝堂課程',
                      credit: 3,
                      teachers: ['王小明'],
                      classTimes: ['1-2'],
                    ),
                    CourseItem(
                      serialNo: '12346',
                      classNo: 'CS102',
                      title: '可加入課程',
                      credit: 3,
                      teachers: ['王小明'],
                      classTimes: ['4-1'],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, '加入').first);
      await tester.pumpAndSettle();

      expect(find.text('衝堂課程', skipOffstage: false), findsOneWidget);
      expect(find.text('可加入課程', skipOffstage: false), findsOneWidget);

      await tester.tap(find.byTooltip('檢視選項'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile).first).value,
        isFalse,
      );
      await tester.tap(find.text('只顯示本頁可加入課表的課程'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile).first).value,
        isTrue,
      );
      await tester.tap(find.text('完成'));
      await tester.pumpAndSettle();

      expect(find.text('衝堂課程'), findsNothing);
      expect(find.text('可加入課程'), findsOneWidget);
      expect(find.text('顯示 1 / 3 門課程'), findsOneWidget);
    },
  );

  testWidgets('CourseSelectionPage locally filters selected courses', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(
            repository: FakeCourseRepository(
              result: const CourseSearchResult(
                totalCount: 3,
                courses: [
                  CourseItem(
                    serialNo: '12344',
                    classNo: 'CS100',
                    title: '已選課程',
                    credit: 3,
                    teachers: ['王小明'],
                    classTimes: ['1-1'],
                  ),
                  CourseItem(
                    serialNo: '12345',
                    classNo: 'CS101',
                    title: '未選課程',
                    credit: 3,
                    teachers: ['王小明'],
                    classTimes: ['2-1'],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '加入').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('檢視選項'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('只顯示已加入課表的課程'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    expect(find.text('已選課程'), findsOneWidget);
    expect(find.text('未選課程'), findsNothing);
    expect(find.text('顯示 1 / 1 門課程'), findsOneWidget);
  });

  testWidgets(
    'CourseSelectionPage hides load more while local filter is active',
    (tester) async {
      final repository = FakeCourseRepository(
        result: const CourseSearchResult(
          totalCount: 2,
          courses: [
            CourseItem(
              serialNo: '12344',
              classNo: 'CS100',
              title: '已選課程',
              credit: 3,
              teachers: ['王小明'],
              classTimes: ['1-1'],
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CourseSelectionPage(
            controller: CourseSelectionController(repository: repository),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('下一頁'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, '加入'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('檢視選項'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('只顯示已加入課表的課程'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('完成'));
      await tester.pumpAndSettle();

      expect(find.text('下一頁'), findsNothing);
      expect(repository.requests, hasLength(1));
    },
  );

  testWidgets('CourseSelectionPage switches to the old timetable from menu', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(
            repository: FakeCourseRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('切換課程工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('課表'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('重新整理'), findsNothing);
    expect(find.text('週一'), findsOneWidget);
    expect(find.text('週五'), findsOneWidget);
  });

  testWidgets('CourseSelectionPage opens AI course helper chat from menu', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(
            repository: FakeCourseRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('切換課程工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AI 選課小幫手'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('重新整理'), findsNothing);
    expect(find.textContaining('我是 AI 選課小幫手'), findsOneWidget);
  });

  testWidgets('CourseSelectionPage syncs selected course to timetable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(
            repository: FakeCourseRepository(
              result: const CourseSearchResult(
                totalCount: 1,
                courses: [
                  CourseItem(
                    serialNo: '12345',
                    classNo: 'CS101',
                    title: '程式設計',
                    credit: 3,
                    passwordCard: 'OPTIONAL',
                    teachers: ['王小明'],
                    classTimes: ['1-1', '1-2'],
                    courseType: 'REQUIRED',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final syncButton = find.widgetWithText(FilledButton, '加入');
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -220));
    await tester.pumpAndSettle();
    await tester.tap(syncButton);
    await tester.pumpAndSettle();

    expect(find.text('已加入'), findsOneWidget);

    await tester.tap(find.byTooltip('切換課程工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('課表'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('重新整理'), findsNothing);
    expect(find.text('3 學分'), findsOneWidget);
    expect(find.text('無衝堂'), findsOneWidget);
    expect(find.text('程式設計'), findsOneWidget);

    await tester.tap(find.text('程式設計'));
    await tester.pumpAndSettle();

    expect(find.text('課號'), findsOneWidget);
    expect(find.text('CS101 / 12345'), findsOneWidget);
    expect(find.text('授課教師'), findsOneWidget);
  });

  testWidgets('CourseSelectionPage shows timetable conflict hint', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(
            repository: FakeCourseRepository(
              result: const CourseSearchResult(
                totalCount: 2,
                courses: [
                  CourseItem(
                    serialNo: '12345',
                    classNo: 'CS101',
                    title: '程式設計',
                    credit: 3,
                    teachers: ['王小明'],
                    classTimes: ['1-1', '1-2'],
                  ),
                  CourseItem(
                    serialNo: '12346',
                    classNo: 'CS102',
                    title: '資料結構',
                    credit: 2,
                    teachers: ['王小明'],
                    classTimes: ['1-2'],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '加入').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '加入').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('切換課程工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('課表'));
    await tester.pumpAndSettle();

    expect(find.text('5 學分'), findsOneWidget);
    expect(find.text('衝堂 1 節'), findsOneWidget);
  });

  testWidgets('CourseSelectionPage copies timetable share link', (
    tester,
  ) async {
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          final arguments = call.arguments as Map<dynamic, dynamic>;
          copiedText = arguments['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(
            repository: FakeCourseRepository(
              result: const CourseSearchResult(
                totalCount: 1,
                courses: [
                  CourseItem(
                    serialNo: '12345',
                    classNo: 'CS101',
                    title: '程式設計',
                    credit: 3,
                    teachers: ['王小明'],
                    classTimes: ['1-1'],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '加入'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('切換課程工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('課表'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('分享課表'));
    await tester.pumpAndSettle();

    expect(copiedText, isNotNull);
    final code = Uri.parse(copiedText!).queryParameters['c'];
    expect(code, isNotNull);
    expect(const CourseShareCodec().decodeSerialNos(code!), ['12345']);
    expect(find.textContaining('已複製分享連結'), findsOneWidget);
  });

  testWidgets('CourseSelectionPage persists selected timetable courses', (
    tester,
  ) async {
    final storage = MemoryCourseSelectionStorage();

    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          courseSelectionStorage: storage,
          controller: CourseSelectionController(
            repository: FakeCourseRepository(
              result: const CourseSearchResult(
                totalCount: 1,
                courses: [
                  CourseItem(
                    serialNo: '12345',
                    classNo: 'CS101',
                    title: '程式設計',
                    credit: 3,
                    teachers: ['王小明'],
                    classTimes: ['1-1'],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '加入'));
    await tester.pumpAndSettle();

    expect(await storage.readShareCode(), isNull);
    expect(find.byTooltip('儲存課表'), findsOneWidget);

    await tester.tap(find.byTooltip('儲存課表'));
    await tester.pumpAndSettle();

    final code = await storage.readShareCode();
    expect(code, isNotNull);
    expect(const CourseShareCodec().decodeSerialNos(code!), ['12345']);
    expect(find.text('已儲存課表'), findsOneWidget);
  });

  testWidgets('CourseSelectionPage restores timetable courses from storage', (
    tester,
  ) async {
    final storage = MemoryCourseSelectionStorage();
    await storage.writeShareCode(
      const CourseShareCodec().encodeSerialNos(const ['12345']),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          courseSelectionStorage: storage,
          controller: CourseSelectionController(
            repository: FakeCourseRepository(
              result: const CourseSearchResult(
                totalCount: 1,
                courses: [
                  CourseItem(
                    serialNo: '12345',
                    classNo: 'CS101',
                    title: '程式設計',
                    credit: 3,
                    teachers: ['王小明'],
                    classTimes: ['1-1'],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('切換課程工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('課表'));
    await tester.pumpAndSettle();

    expect(find.text('3 學分'), findsOneWidget);
    expect(find.text('程式設計'), findsOneWidget);
  });

  testWidgets(
    'CourseSelectionPage previews share code without overwriting storage',
    (tester) async {
      final storage = MemoryCourseSelectionStorage();
      final storedCode = const CourseShareCodec().encodeSerialNos(const [
        '99999',
      ]);
      await storage.writeShareCode(storedCode);

      await tester.pumpWidget(
        MaterialApp(
          home: CourseSelectionPage(
            courseSelectionStorage: storage,
            initialShareCode: const CourseShareCodec().encodeSerialNos(const [
              '12345',
            ]),
            controller: CourseSelectionController(
              repository: FakeCourseRepository(
                result: const CourseSearchResult(
                  totalCount: 1,
                  courses: [
                    CourseItem(
                      serialNo: '12345',
                      classNo: 'CS101',
                      title: '程式設計',
                      credit: 3,
                      teachers: ['王小明'],
                      classTimes: ['1-1'],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('切換課程工具'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('課表'));
      await tester.pumpAndSettle();

      expect(find.text('3 學分'), findsOneWidget);
      expect(find.text('預覽'), findsOneWidget);
      expect(find.text('儲存'), findsOneWidget);
      expect(await storage.readShareCode(), storedCode);

      await tester.tap(find.text('儲存'));
      await tester.pumpAndSettle();

      expect(
        const CourseShareCodec().decodeSerialNos(
          (await storage.readShareCode())!,
        ),
        ['12345'],
      );
      expect(find.text('儲存'), findsNothing);
      expect(find.text('已儲存課表'), findsOneWidget);
    },
  );

  testWidgets('CourseSelectionPage applies filter chips', (tester) async {
    final repository = FakeCourseRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(repository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('進階查詢'));
    await tester.pumpAndSettle();
    final requestCountBeforeDraft = repository.requests.length;

    await tester.ensureVisible(find.text('已額滿'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('已額滿'));
    await tester.pumpAndSettle();

    expect(repository.requests, hasLength(requestCountBeforeDraft));
    expect(find.text('已額滿'), findsWidgets);

    final classTimeButton = find.text('選擇上課時段', skipOffstage: false);
    await tester.ensureVisible(classTimeButton);
    await tester.pumpAndSettle();
    await tester.tap(classTimeButton);
    await tester.pumpAndSettle();
    expect(find.text('平日'), findsOneWidget);

    await tester.tap(find.text('全週'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('一 1'));
    await tester.pumpAndSettle();

    expect(repository.requests, hasLength(requestCountBeforeDraft));
    await tester.tap(find.text('套用').last);
    await tester.pumpAndSettle();

    expect(repository.requests, hasLength(requestCountBeforeDraft));
    await tester.tap(find.text('套用查詢'));
    await tester.pumpAndSettle();

    expect(repository.requests.last.hasVacancy, isFalse);
    expect(repository.requests.last.classTimes, ['1-1']);

    await tester.tap(find.text('進階查詢'));
    await tester.pumpAndSettle();
    final selectedClassTimeButton = find.text('已選 1 個時段', skipOffstage: false);
    await tester.ensureVisible(selectedClassTimeButton);
    await tester.pumpAndSettle();
    await tester.tap(selectedClassTimeButton);
    await tester.pumpAndSettle();
    final clearClassTimesButton = find.text('清除').last;
    await tester.ensureVisible(clearClassTimesButton);
    await tester.pumpAndSettle();
    await tester.tap(clearClassTimesButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('套用').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('套用查詢'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('套用查詢'));
    await tester.pumpAndSettle();

    expect(repository.requests.last.classTimes, isEmpty);
  });

  testWidgets('CourseSelectionPage shows course details sheet', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(
            repository: FakeCourseRepository(
              result: const CourseSearchResult(
                totalCount: 1,
                courses: [
                  CourseItem(
                    serialNo: '00001',
                    classNo: 'CS101',
                    title: '程式設計',
                    credit: 3,
                    passwordCard: 'ALL',
                    teachers: ['王小明'],
                    classTimes: ['1-1', '1-2'],
                    admitCount: 42,
                    limitCount: 60,
                    waitCount: 3,
                    collegeName: '電機資訊學院',
                    departmentName: '資訊工程學系',
                    courseType: 'REQUIRED',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('程式設計'));
    await tester.pumpAndSettle();

    expect(find.text('課號'), findsOneWidget);
    expect(find.text('CS101 / 00001'), findsOneWidget);
    expect(find.text('選課人數'), findsOneWidget);
    expect(find.text('42 / 60 · 候補 3'), findsWidgets);
    expect(find.text('密碼卡'), findsOneWidget);
    expect(find.text('全部'), findsWidgets);
    expect(find.text('課程詳細資訊'), findsOneWidget);
    expect(find.text('課程目標'), findsNothing);
  });

  testWidgets(
    'CourseSelectionPage shows course details dialog on wide screens',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final distributionConditions = List<CourseDistributionCondition>.generate(
        36,
        (index) => CourseDistributionCondition(
          priority: index + 1,
          rule: '學制:限學士班，並符合第 ${index + 1} 項分發條件。',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CourseSelectionPage(
            controller: CourseSelectionController(
              repository: FakeCourseRepository(
                result: const CourseSearchResult(
                  totalCount: 1,
                  courses: [
                    CourseItem(
                      serialNo: '00098',
                      classNo: 'CS101',
                      title: '程式設計',
                      credit: 3,
                      passwordCard: 'ALL',
                      teachers: ['王小明'],
                      classTimes: ['1-1', '1-2'],
                      admitCount: 42,
                      limitCount: 60,
                      waitCount: 3,
                      courseType: 'REQUIRED',
                    ),
                  ],
                ),
              ),
            ),
            courseSupplementalDetailRepository: _FakeSupplementalRepository(
              CourseSupplementalDetail(
                serialNo: '00098',
                objectives: '修習本課程同學可以培養深層閱讀理解能力',
                content: '課程內容',
                books: '短篇故事/線上資源',
                teachingMethod: '講授',
                gradingPolicy: '期中考30%',
                distributionConditions: distributionConditions,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(
        tester
            .getSize(find.byKey(const ValueKey('course-details-dialog-body')))
            .height,
        680.0,
      );
      expect(find.text('課號'), findsOneWidget);
      expect(find.text('CS101 / 00098'), findsOneWidget);
      expect(find.text('分發條件'), findsOneWidget);
      expect(find.textContaining('1：學制:限學士班'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('course-primary-details-scroll')),
        findsOneWidget,
      );
      expect(find.text('課程目標'), findsOneWidget);
      expect(find.textContaining('深層閱讀理解能力'), findsOneWidget);
      expect(find.text('指定用書'), findsOneWidget);
      expect(find.textContaining('短篇故事'), findsOneWidget);
      expect(find.text('課程詳細資訊'), findsNothing);
      expect(find.byTooltip('關閉'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('分發條件')).dx,
        lessThan(tester.getTopLeft(find.text('課程目標')).dx),
      );
    },
  );
}

class _FakeSupplementalRepository
    implements CourseSupplementalDetailRepository {
  const _FakeSupplementalRepository(this.detail);

  final CourseSupplementalDetail detail;

  @override
  Future<CourseSupplementalDetail?> findBySerialNo(String serialNo) async {
    return serialNo == detail.serialNo ? detail : null;
  }
}

class FakeCourseRepository implements CourseRepository {
  FakeCourseRepository({
    this.result = const CourseSearchResult(totalCount: 0, courses: []),
    this.error,
    List<CourseSearchResult>? results,
  }) : _results = List<CourseSearchResult>.of(results ?? const []);

  final CourseSearchResult result;
  final Object? error;
  final List<CourseSearchResult> _results;
  final List<CourseSearchRequest> requests = [];

  @override
  Future<CourseSearchResult> searchCourses({
    String? keyword,
    String? classNo,
    String? serialNo,
    String? departmentName,
    String? collegeName,
    String? instructor,
    String? courseType,
    List<int>? credits,
    bool? hasVacancy,
    List<String>? classTimes,
    int offset = 0,
    int limit = 100,
  }) async {
    requests.add(
      CourseSearchRequest(
        keyword: keyword,
        classNo: classNo,
        serialNo: serialNo,
        departmentName: departmentName,
        collegeName: collegeName,
        instructor: instructor,
        courseType: courseType,
        credits: credits,
        hasVacancy: hasVacancy,
        classTimes: classTimes,
        offset: offset,
        limit: limit,
      ),
    );
    if (error != null) throw error!;
    if (_results.isNotEmpty) return _results.removeAt(0);
    return result;
  }
}

class CourseSearchRequest {
  const CourseSearchRequest({
    this.keyword,
    this.classNo,
    this.serialNo,
    this.departmentName,
    this.collegeName,
    this.instructor,
    this.courseType,
    this.credits,
    this.hasVacancy,
    this.classTimes,
    required this.offset,
    required this.limit,
  });

  final String? keyword;
  final String? classNo;
  final String? serialNo;
  final String? departmentName;
  final String? collegeName;
  final String? instructor;
  final String? courseType;
  final List<int>? credits;
  final bool? hasVacancy;
  final List<String>? classTimes;
  final int offset;
  final int limit;
}
