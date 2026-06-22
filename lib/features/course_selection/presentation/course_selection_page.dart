import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_pinecone/features/course_selection/course_selection_providers.dart';
import 'package:magic_pinecone/features/course_selection/data/data_sources/course_selection_storage.dart';
import 'package:magic_pinecone/features/course_selection/domain/repository/course_supplemental_detail_repository.dart';
import 'package:magic_pinecone/features/course_selection/presentation/course_selection_shell.dart';

class CourseSelectionPage extends StatelessWidget {
  const CourseSelectionPage({
    super.key,
    this.courseSupplementalDetailRepository,
    this.courseSelectionStorage,
    this.initialShareCode,
    this.showBackButton = false,
  });

  final CourseSupplementalDetailRepository? courseSupplementalDetailRepository;
  final CourseSelectionStorage? courseSelectionStorage;
  final String? initialShareCode;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final child = CourseSelectionShell(
      title: '課程查詢',
      navigationMode: CourseSelectionNavigationMode.drawer,
      showSettingsDestination: false,
      extraDestination: CourseSelectionExtraDestination(
        icon: const Icon(Icons.smart_toy_outlined),
        selectedIcon: const Icon(Icons.smart_toy),
        label: 'AI 選課小幫手',
        builder: (_) => const _CourseHelperChatView(),
      ),
      courseSelectionStorage: courseSelectionStorage,
      initialShareCode: initialShareCode,
      showBackButton: showBackButton,
    );

    final supplementalDetailRepository = courseSupplementalDetailRepository;
    if (supplementalDetailRepository == null) {
      return child;
    }

    return ProviderScope(
      overrides: [
        courseSupplementalDetailRepositoryProvider.overrideWithValue(
          supplementalDetailRepository,
        ),
      ],
      child: child,
    );
  }
}

class _CourseHelperChatView extends StatefulWidget {
  const _CourseHelperChatView();

  @override
  State<_CourseHelperChatView> createState() => _CourseHelperChatViewState();
}

class _CourseHelperChatViewState extends State<_CourseHelperChatView> {
  final InMemoryChatController _chatController = InMemoryChatController(
    messages: [
      TextMessage(
        id: 'helper-welcome',
        authorId: 'course-helper',
        createdAt: DateTime(2026),
        text: '你好，我是 AI 選課小幫手。可以先告訴我你的系級、想修的領域、可上課時段，或想避開的課程限制。',
      ),
    ],
  );
  int _messageSequence = 0;

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chat(
      chatController: _chatController,
      currentUserId: 'student',
      backgroundColor: colorScheme.surface,
      onMessageSend: _sendMessage,
      resolveUser: (id) async {
        return switch (id) {
          'course-helper' => User(id: id, name: 'AI 選課小幫手'),
          _ => User(id: id, name: '我'),
        };
      },
    );
  }

  void _sendMessage(String text) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final now = DateTime.now().toUtc();
    _messageSequence += 1;
    unawaited(
      _chatController.insertMessage(
        TextMessage(
          id: 'student-$_messageSequence',
          authorId: 'student',
          createdAt: now,
          text: trimmedText,
        ),
      ),
    );

    _messageSequence += 1;
    unawaited(
      _chatController.insertMessage(
        TextMessage(
          id: 'helper-$_messageSequence',
          authorId: 'course-helper',
          createdAt: now.add(const Duration(milliseconds: 1)),
          text:
              '我先記下你的需求：「$trimmedText」。之後可以在這裡接上後端或 AI API，依照課程查詢資料幫你篩選衝堂、學分與名額。',
        ),
      ),
    );
  }
}
