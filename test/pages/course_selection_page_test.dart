import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/features/course_selection/data/course_repository.dart';
import 'package:prototype/features/course_selection/data/course_selection_storage.dart';
import 'package:prototype/features/course_selection/data/course_share_codec.dart';
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
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(repository.requests.last.classNo, 'CS');
    expect(repository.requests.last.serialNo, '12345');
    expect(repository.requests.last.departmentName, '資訊工程');
    expect(repository.requests.last.collegeName, '電機資訊');
    expect(find.text('課號：CS'), findsOneWidget);
    expect(find.text('流水號：12345'), findsOneWidget);
    expect(find.text('系所：資訊工程'), findsOneWidget);
    expect(find.text('學院：電機資訊'), findsOneWidget);
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

  testWidgets('CourseSelectionPage loads more courses', (tester) async {
    final repository = FakeCourseRepository(
      results: [
        const CourseSearchResult(
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
          ],
        ),
        const CourseSearchResult(
          totalCount: 2,
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

    expect(find.text('載入更多'), findsOneWidget);
    await tester.tap(find.text('載入更多'));
    await tester.pumpAndSettle();

    expect(find.text('資料結構'), findsOneWidget);
    expect(repository.requests.last.offset, 1);
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

      await tester.tap(find.byTooltip('篩選'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse,
      );
      await tester.tap(find.text('只顯示可加入目前課表的課程'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue,
      );
      await tester.tap(find.text('完成'));
      await tester.pumpAndSettle();

      expect(find.text('衝堂課程'), findsNothing);
      expect(find.text('可加入課程'), findsOneWidget);
      expect(find.text('顯示 1 / 3 門課程'), findsOneWidget);
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
    expect(find.text('總學分 3'), findsOneWidget);
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

    expect(find.text('總學分 5'), findsOneWidget);
    expect(find.text('衝堂 1 格'), findsOneWidget);
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

    final code = await storage.readShareCode();
    expect(code, isNotNull);
    expect(const CourseShareCodec().decodeSerialNos(code!), ['12345']);
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

    expect(find.text('總學分 3'), findsOneWidget);
    expect(find.text('程式設計'), findsOneWidget);
  });

  testWidgets(
    'CourseSelectionPage restores timetable courses from share code',
    (tester) async {
      final storage = MemoryCourseSelectionStorage();
      await storage.writeShareCode(
        const CourseShareCodec().encodeSerialNos(const ['99999']),
      );

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

      expect(find.text('總學分 3'), findsOneWidget);
      expect(
        const CourseShareCodec().decodeSerialNos(
          (await storage.readShareCode())!,
        ),
        ['12345'],
      );
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
    await tester.tap(find.text('已選 1 個時段'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('清除').last);
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
      expect(find.text('CS101 / 00001'), findsOneWidget);
      expect(find.text('課程目標'), findsOneWidget);
      expect(find.textContaining('五十音聽說讀寫能力'), findsOneWidget);
      expect(find.text('指定用書'), findsOneWidget);
      expect(find.textContaining('大家的日本語初級１'), findsOneWidget);
      expect(find.text('課程詳細資訊'), findsNothing);
      expect(find.byTooltip('關閉'), findsOneWidget);
    },
  );
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
  final String? courseType;
  final List<int>? credits;
  final bool? hasVacancy;
  final List<String>? classTimes;
  final int offset;
  final int limit;
}
