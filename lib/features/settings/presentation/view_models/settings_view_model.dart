import 'package:magic_pinecone/features/settings/domain/models/settings_models.dart';
import 'package:magic_pinecone/features/settings/domain/usecases/load_settings_use_case.dart';
import 'package:magic_pinecone/features/settings/domain/usecases/update_backend_url_use_case.dart';
import 'package:magic_pinecone/features/settings/domain/usecases/update_theme_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_view_model.g.dart';

class SettingsState {
  const SettingsState({
    required this.snapshot,
    this.backendBaseUrlError,
    this.omitWeekendsOnTimetable = true,
  });

  final SettingsSnapshot snapshot;
  final String? backendBaseUrlError;
  final bool omitWeekendsOnTimetable;

  SettingsState copyWith({
    SettingsSnapshot? snapshot,
    String? backendBaseUrlError,
    bool? omitWeekendsOnTimetable,
    bool clearBackendBaseUrlError = false,
  }) {
    return SettingsState(
      snapshot: snapshot ?? this.snapshot,
      backendBaseUrlError: clearBackendBaseUrlError
          ? null
          : (backendBaseUrlError ?? this.backendBaseUrlError),
      omitWeekendsOnTimetable:
          omitWeekendsOnTimetable ?? this.omitWeekendsOnTimetable,
    );
  }
}

@riverpod
class SettingsViewModel extends _$SettingsViewModel {
  @override
  SettingsState build() {
    final snapshot = ref.watch(loadSettingsUseCaseProvider).execute();
    return SettingsState(snapshot: snapshot);
  }

  void setOmitWeekendsOnTimetable(bool enabled) {
    state = state.copyWith(omitWeekendsOnTimetable: enabled);
  }

  void toggleTheme() {
    ref.read(updateThemeUseCaseProvider).toggleTheme();
  }

  void setDarkMode(bool enabled) {
    ref.read(updateThemeUseCaseProvider).setDarkMode(enabled);
  }

  void updateBackendBaseUrl(String value) {
    final success = ref.read(updateBackendUrlUseCaseProvider).updateUrl(value);
    if (success) {
      state = state.copyWith(clearBackendBaseUrlError: true);
    } else {
      state = state.copyWith(backendBaseUrlError: '請輸入 http 或 https 開頭的網址');
    }
  }

  void resetBackendBaseUrl() {
    ref.read(updateBackendUrlUseCaseProvider).reset();
    state = state.copyWith(clearBackendBaseUrlError: true);
  }
}
