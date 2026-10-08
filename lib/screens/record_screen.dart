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
    final subjectNames = {
      for (final s in examData.value!.exam.subjects) s.subjectId: s.name,
    };
    final weakSubjects = _weakSubjects(questions, store, subjectNames);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
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
          if (weakSubjects.isNotEmpty) ...[
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('苦手分野', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            for (final s in weakSubjects)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(s.name, style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    Text(
                      '${(s.accuracy * 100).round()}%（${s.correct}/${s.total}問）',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SubjectAccuracy {
  const _SubjectAccuracy({
    required this.name,
    required this.correct,
    required this.total,
  });

  final String name;
  final int correct;
  final int total;

  double get accuracy => correct / total;
}

/// 解答済みの科目のうち、正答率が低い順に最大3件を返す。
List<_SubjectAccuracy> _weakSubjects(
  List<Question> questions,
  SrsStore store,
  Map<String, String> subjectNames,
) {
  final correctBySubject = <String, int>{};
  final totalBySubject = <String, int>{};
  for (final q in questions) {
    final stat = store.stats[q.qid];
    if (stat == null) continue;
    correctBySubject[q.subjectId] = (correctBySubject[q.subjectId] ?? 0) + stat.correct;
    totalBySubject[q.subjectId] = (totalBySubject[q.subjectId] ?? 0) + stat.attempts;
  }

  final subjects = [
    for (final subjectId in totalBySubject.keys)
      _SubjectAccuracy(
        name: subjectNames[subjectId] ?? subjectId,
        correct: correctBySubject[subjectId] ?? 0,
        total: totalBySubject[subjectId]!,
      ),
  ]..sort((a, b) => a.accuracy.compareTo(b.accuracy));

  return subjects.take(3).toList();
}
