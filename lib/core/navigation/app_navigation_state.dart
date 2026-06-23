import 'package:magic_pinecone/core/navigation/app_routes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_navigation_state.g.dart';

@Riverpod(keepAlive: true)
AppTab initialActiveAppTab(Ref ref) => AppTab.home;

@Riverpod(keepAlive: true)
class ActiveAppTab extends _$ActiveAppTab {
  @override
  AppTab build() => ref.watch(initialActiveAppTabProvider);

  void setTab(AppTab tab) {
    state = tab;
  }
}
