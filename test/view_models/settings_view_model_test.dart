import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/features/settings/domain/models/settings_models.dart';
import 'package:magic_pinecone/features/settings/domain/repository/settings_repository.dart';
import 'package:magic_pinecone/features/settings/presentation/view_models/settings_view_model.dart';

void main() {
  test('SettingsViewModel exposes repository data and theme state', () {
    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          const FakeSettingsRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(settingsViewModelProvider.notifier);
    final state = container.read(settingsViewModelProvider);

    expect(state.snapshot.appName, 'Magic Pinecone');
    expect(state.snapshot.appVersion, '0.1.0+1');
    expect(state.snapshot.statusItems, hasLength(1));

    expect(state.omitWeekendsOnTimetable, isTrue);
    notifier.setOmitWeekendsOnTimetable(false);
    expect(
      container.read(settingsViewModelProvider).omitWeekendsOnTimetable,
      isFalse,
    );

    notifier.updateBackendBaseUrl('localhost:8000');
    expect(
      container.read(settingsViewModelProvider).backendBaseUrlError,
      isNotNull,
    );

    notifier.updateBackendBaseUrl('http://127.0.0.1:8000/');
    expect(
      container.read(settingsViewModelProvider).backendBaseUrlError,
      isNull,
    );
  });
}

class FakeSettingsRepository implements SettingsRepository {
  const FakeSettingsRepository();

  @override
  SettingsSnapshot loadSettings() {
    return const SettingsSnapshot(
      appName: 'Magic Pinecone',
      appVersion: '0.1.0+1',
      summary: '目前版本聚焦在行動端展示。',
      statusItems: [SettingsStatusItem(label: '首頁與快速功能已串成實際流程')],
    );
  }
}
