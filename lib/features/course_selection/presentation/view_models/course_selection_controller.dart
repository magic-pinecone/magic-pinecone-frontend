import 'package:flutter/foundation.dart';
import 'package:prototype/features/course_selection/data/course_schedule_repository.dart';
import 'package:prototype/features/course_selection/models/course_schedule_models.dart';

class CourseSelectionController extends ChangeNotifier {
  CourseSelectionController({required CourseScheduleRepository repository}) {
    final schedule = repository.loadSchedule();
    _courses = List.unmodifiable(schedule.courses);
    _weekDays = List.unmodifiable(schedule.weekDays);
    _periods = List.unmodifiable(schedule.periods);
  }

  late final List<ScheduledCourse> _courses;
  late final List<String> _weekDays;
  late final List<String> _periods;

  bool _showWeekends = false;

  List<ScheduledCourse> get courses => _courses;
  List<String> get periods => _periods;
  bool get showWeekends => _showWeekends;

  List<String> get visibleDays =>
      _showWeekends ? _weekDays : _weekDays.sublist(0, 5);

  void setShowWeekends(bool value) {
    if (_showWeekends == value) return;
    _showWeekends = value;
    notifyListeners();
  }
}
