import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/features/course_selection/course_selection_providers.dart';
import 'package:magic_pinecone/features/course_selection/data/repositories/course_repository_impl.dart';

void main() {
  test('course providers keep static catalog as default frontend source', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(courseRepositoryProvider),
      isA<StaticCourseCatalogRepository>(),
    );
    expect(
      container.read(backendCourseRepositoryProvider),
      isA<BackendCourseRepository>(),
    );
  });
}
