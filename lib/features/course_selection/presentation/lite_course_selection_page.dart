import 'package:flutter/widgets.dart';
import 'package:magic_pinecone/features/course_selection/data/data_sources/course_selection_storage.dart';
import 'package:magic_pinecone/features/course_selection/presentation/course_selection_shell.dart';

class LiteCourseSelectionPage extends StatelessWidget {
  const LiteCourseSelectionPage({
    super.key,
    this.courseSelectionStorage,
    this.initialShareCode,
    this.showBackButton = false,
  });

  final CourseSelectionStorage? courseSelectionStorage;
  final String? initialShareCode;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return CourseSelectionShell(
      courseSelectionStorage: courseSelectionStorage,
      initialShareCode: initialShareCode,
      showBackButton: showBackButton,
    );
  }
}
