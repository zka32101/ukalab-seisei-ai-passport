import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import '../data/exam_repository.dart';
import '../data/srs_repository.dart';
import 'learn_screen.dart';

/// 「記録」タブ: 間隔反復（Leitner方式）で復習時期が来た問題を表示する。
class RecordScreen extends ConsumerWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examData = ref.watch(examDataProvider);
    final srs = ref.watch(srsProvider);

    if (examData.hasError || srs.hasError) {
      return const EmptyState(message: '記録を読み込めませんでした。');
    }
    final questions = examData.valueOrNull?.activeQuestions;
    final store = srs.valueOrNull;
    if (questions == null || store == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (store.items.isEmpty) {
      return const EmptyState(
        icon: Icons.insights_outlined,
        message: '学習の記録はこれから。「学ぶ」タブで演習を進めると、ここに復習の予定が表示されます。',
      );
    }

    final byQid = {for (final q in questions) q.qid: q};
    final dueQuestions = [
      for (final item in store.due(DateTime.now()))
        if (byQid[item.qid] != null) byQid[item.qid]!,
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insights_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              dueQuestions.isEmpty ? '復習の予定はありません' : '復習の予定: ${dueQuestions.length}問',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '記録している問題: ${store.items.length}問（定着済み: ${store.masteredCount}問）',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (dueQuestions.isNotEmpty) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('復習')),
                      body: LearnScreen(
                        questions: questions,
                        priorityQids: [for (final q in dueQuestions) q.qid],
                        mode: PracticeMode.weak,
                      ),
                    ),
                  ),
                ),
                child: const Text('復習を始める'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
