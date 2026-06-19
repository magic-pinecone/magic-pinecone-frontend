import 'package:dio/dio.dart';
import 'package:magic_pinecone/core/app/app_backend_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:magic_pinecone/core/app/app_backend_config.dart'
    show appBackendConfigControllerProvider;
export 'package:magic_pinecone/core/app/app_theme.dart'
    show appThemeControllerProvider;

part 'app_providers.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio();
  final baseUrl = ref.read(appBackendConfigControllerProvider);
  dio.options.baseUrl = baseUrl;

  ref.listen<String>(appBackendConfigControllerProvider, (previous, next) {
    dio.options.baseUrl = next;
  });
  return dio;
}
