import 'package:magic_pinecone/core/navigation/app_routes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_navigation_state.g.dart';

@Riverpod(keepAlive: true)
class ActiveAppTab extends _$ActiveAppTab {
  @override
  AppTab build() => AppTab.home;

  void setTab(AppTab tab) {
    state = tab;
  }
}
