import 'package:prototype/features/course_selection/models/course_schedule_models.dart';

const timetablePeriods = [
  '1',
  '2',
  '3',
  '4',
  'Z',
  '5',
  '6',
  '7',
  '8',
  '9',
  'A',
  'B',
  'C',
];

const timetableWeekDays = ['一', '二', '三', '四', '五', '六', '日'];

const mockScheduledCourses = [
  ScheduledCourse(
    name: '計算機概論',
    dayIndex: 0,
    startPeriodIndex: 1,
    length: 3,
    location: '工程五館 A207',
  ),
  ScheduledCourse(
    name: '體育',
    dayIndex: 1,
    startPeriodIndex: 3,
    length: 2,
    location: '依仁堂體育館',
    category: '選修',
  ),
  ScheduledCourse(
    name: '微積分 I',
    dayIndex: 2,
    startPeriodIndex: 5,
    length: 2,
    location: '鴻經館 M116',
  ),
  ScheduledCourse(
    name: '物理實驗',
    dayIndex: 4,
    startPeriodIndex: 9,
    length: 3,
    location: '科學二館 S214',
  ),
];
