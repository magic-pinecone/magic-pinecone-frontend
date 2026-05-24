import 'package:flutter/foundation.dart';
import 'package:prototype/features/course_selection/data/course_repository.dart';
import 'package:prototype/features/course_selection/models/course_schedule_models.dart';

class CourseSelectionController extends ChangeNotifier {
  CourseSelectionController({required CourseRepository repository})
    : _repository = repository;

  final CourseRepository _repository;

  List<CourseItem> _courses = const [];
  bool _isLoading = false;
  Object? _error;
  int _totalCount = 0;
  DateTime? _lastUpdated;
  String _keyword = '';
  String? _courseType;

  List<CourseItem> get courses => _courses;
  bool get isLoading => _isLoading;
  Object? get error => _error;
  int get totalCount => _totalCount;
  DateTime? get lastUpdated => _lastUpdated;
  String get keyword => _keyword;
  String? get courseType => _courseType;
  bool get hasActiveFilter => _keyword.isNotEmpty || _courseType != null;

  Future<void> load() {
    return search();
  }

  Future<void> search({String? keyword}) async {
    if (keyword != null) {
      _keyword = keyword.trim();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.searchCourses(
        keyword: _keyword,
        courseType: _courseType,
      );
      _courses = List.unmodifiable(result.courses);
      _totalCount = result.totalCount;
      _lastUpdated = result.lastUpdated;
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setCourseType(String? value) async {
    if (_courseType == value) return;
    _courseType = value;
    await search();
  }

  Future<void> clearFilters() async {
    if (!hasActiveFilter) return;
    _keyword = '';
    _courseType = null;
    await search();
  }
}
