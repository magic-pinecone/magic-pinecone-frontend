import 'package:flutter/foundation.dart';
import 'package:prototype/features/course_selection/data/course_repository.dart';
import 'package:prototype/features/course_selection/models/course_schedule_models.dart';

class CourseSelectionController extends ChangeNotifier {
  CourseSelectionController({required CourseRepository repository})
    : _repository = repository;

  static const defaultPageSize = 50;

  final CourseRepository _repository;

  List<CourseItem> _courses = const [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  Object? _error;
  int _totalCount = 0;
  DateTime? _lastUpdated;
  String _keyword = '';
  String _classNo = '';
  String _serialNo = '';
  String _departmentName = '';
  String _collegeName = '';
  String _instructor = '';
  String? _courseType;
  final Set<int> _credits = {};
  bool? _hasVacancy;
  final Set<String> _classTimes = {};
  int _offset = 0;
  final int _limit = defaultPageSize;

  List<CourseItem> get courses => _courses;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  Object? get error => _error;
  int get totalCount => _totalCount;
  DateTime? get lastUpdated => _lastUpdated;
  String get keyword => _keyword;
  String get classNo => _classNo;
  String get serialNo => _serialNo;
  String get departmentName => _departmentName;
  String get collegeName => _collegeName;
  String get instructor => _instructor;
  String? get courseType => _courseType;
  List<int> get credits => List.unmodifiable(_sortedCredits);
  bool hasCredit(int credit) => _credits.contains(credit);
  bool? get hasVacancy => _hasVacancy;
  List<String> get classTimes => List.unmodifiable(_sortedClassTimes);
  int get offset => _offset;
  int get limit => _limit;
  bool get hasMoreCourses => _courses.length < _totalCount;
  int get activeFilterCount {
    return [
      _keyword.isNotEmpty,
      _classNo.isNotEmpty,
      _serialNo.isNotEmpty,
      _departmentName.isNotEmpty,
      _collegeName.isNotEmpty,
      _instructor.isNotEmpty,
      _courseType != null,
      _credits.isNotEmpty,
      _hasVacancy != null,
      _classTimes.isNotEmpty,
    ].where((isActive) => isActive).length;
  }

  bool get hasActiveFilter => activeFilterCount > 0;

  Future<void> load() {
    return search();
  }

  Future<void> search({
    String? keyword,
    String? classNo,
    String? serialNo,
    String? departmentName,
    String? collegeName,
    String? instructor,
  }) async {
    if (keyword != null) {
      _keyword = keyword.trim();
    }
    if (classNo != null) {
      _classNo = classNo.trim();
    }
    if (serialNo != null) {
      _serialNo = serialNo.trim();
    }
    if (departmentName != null) {
      _departmentName = departmentName.trim();
    }
    if (collegeName != null) {
      _collegeName = collegeName.trim();
    }
    if (instructor != null) {
      _instructor = instructor.trim();
    }

    _offset = 0;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.searchCourses(
        keyword: _keyword,
        classNo: _classNo,
        serialNo: _serialNo,
        departmentName: _departmentName,
        collegeName: _collegeName,
        instructor: _instructor,
        courseType: _courseType,
        credits: _sortedCredits,
        hasVacancy: _hasVacancy,
        classTimes: _sortedClassTimes,
        offset: _offset,
        limit: _limit,
      );
      _courses = List.unmodifiable(result.courses);
      _totalCount = result.totalCount;
      _lastUpdated = result.lastUpdated;
      _offset = _courses.length;
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyFilters({
    required String classNo,
    required String serialNo,
    required String departmentName,
    required String collegeName,
    required String instructor,
    required String? courseType,
    required Iterable<int> credits,
    required bool? hasVacancy,
    required Iterable<String> classTimes,
  }) async {
    _classNo = classNo.trim();
    _serialNo = serialNo.trim();
    _departmentName = departmentName.trim();
    _collegeName = collegeName.trim();
    _instructor = instructor.trim();
    _courseType = courseType;
    _credits
      ..clear()
      ..addAll(credits);
    _hasVacancy = hasVacancy;
    _classTimes
      ..clear()
      ..addAll(classTimes);
    await search();
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !hasMoreCourses) return;

    _isLoadingMore = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.searchCourses(
        keyword: _keyword,
        classNo: _classNo,
        serialNo: _serialNo,
        departmentName: _departmentName,
        collegeName: _collegeName,
        instructor: _instructor,
        courseType: _courseType,
        credits: _sortedCredits,
        hasVacancy: _hasVacancy,
        classTimes: _sortedClassTimes,
        offset: _offset,
        limit: _limit,
      );
      _courses = List.unmodifiable([..._courses, ...result.courses]);
      _totalCount = result.totalCount;
      _lastUpdated = result.lastUpdated;
      _offset = _courses.length;
    } catch (error) {
      _error = error;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> setCourseType(String? value) async {
    if (_courseType == value) return;
    _courseType = value;
    await search();
  }

  Future<void> toggleCredit(int value) async {
    if (!_credits.add(value)) {
      _credits.remove(value);
    }
    await search();
  }

  Future<void> setHasVacancy(bool? value) async {
    if (_hasVacancy == value) return;
    _hasVacancy = value;
    await search();
  }

  Future<void> toggleClassTime(String value) async {
    if (!_classTimes.add(value)) {
      _classTimes.remove(value);
    }
    await search();
  }

  Future<void> setClassTimes(Iterable<String> values) async {
    final nextValues = values.toSet();
    if (setEquals(_classTimes, nextValues)) return;
    _classTimes
      ..clear()
      ..addAll(nextValues);
    await search();
  }

  Future<void> clearClassTimes() async {
    if (_classTimes.isEmpty) return;
    _classTimes.clear();
    await search();
  }

  Future<void> clearFilters() async {
    if (!hasActiveFilter) return;
    _keyword = '';
    _classNo = '';
    _serialNo = '';
    _departmentName = '';
    _collegeName = '';
    _instructor = '';
    _courseType = null;
    _credits.clear();
    _hasVacancy = null;
    _classTimes.clear();
    await search();
  }

  Future<List<CourseItem>> findCoursesBySerialNos(
    Iterable<String> serialNos,
  ) async {
    final uniqueSerialNos = {
      for (final serialNo in serialNos)
        if (serialNo.trim().isNotEmpty) serialNo.trim(),
    };
    final coursesBySerialNo = {
      for (final course in _courses) course.serialNo: course,
    };

    for (final serialNo in uniqueSerialNos) {
      if (coursesBySerialNo.containsKey(serialNo)) continue;

      final result = await _repository.searchCourses(
        serialNo: serialNo,
        limit: 10,
      );
      for (final course in result.courses) {
        if (course.serialNo == serialNo) {
          coursesBySerialNo[serialNo] = course;
          break;
        }
      }
    }

    return [
      for (final serialNo in uniqueSerialNos) ?coursesBySerialNo[serialNo],
    ];
  }

  List<int> get _sortedCredits {
    return _credits.toList()..sort();
  }

  List<String> get _sortedClassTimes {
    return _classTimes.toList()..sort();
  }
}
