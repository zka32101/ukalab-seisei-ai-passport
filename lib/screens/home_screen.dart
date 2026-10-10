import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ukalab_core/ukalab_core.dart';

import '../data/disclaimer_store.dart';
import 'ai_news_screen.dart';
import 'boundary_screen.dart';
import 'confusion_matrix_screen.dart';
import 'failure_gallery_screen.dart';
import 'predict_run_screen.dart';
import 'premium_practice_cards.dart';
import 'route_planner_screen.dart';
import 'teach_mascot_screen.dart';
import 'term_map_screen.dart';

class _ExperienceEntry {
  const _ExperienceEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.builder,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// 体験の所要時間の目安（分）。選びやすさのためのバッジに使う。
  final int minutes;
  final WidgetBuilder builder;
}

final _experienceEntries = [
  _ExperienceEntry(
    icon: Icons.auto_awesome,
    title: '推しの答案を添削',
    subtitle: 'よくある誤解を見つけて、正しい答えに差し替えよう',
    minutes: 3,
    builder: (_) => const TeachMascotScreen(),
  ),
  _ExperienceEntry(
    icon: Icons.show_chart,
    title: '学習の失敗図鑑',
    subtitle: '学習曲線から症状を見抜き、正しい対策を選ぼう',
    minutes: 3,
    builder: (_) => const FailureGalleryScreen(),
  ),
  _ExperienceEntry(
    icon: Icons.hub_outlined,
    title: '用語マップ',
    subtitle: 'AIの歴史の系譜や、用語どうしのつながりを見る',
    minutes: 5,
    builder: (_) => const TermMapScreen(),
  ),
  _ExperienceEntry(
    icon: Icons.tune,
    title: '境界線スライダー',
    subtitle: '条件を切り替えて、判定が変わる境目を体験しよう',
    minutes: 4,
    builder: (_) => const BoundaryScreen(),
  ),
  _ExperienceEntry(
    icon: Icons.grid_on,
    title: '評価指標ラボ',
    subtitle: '混同行列を動かして、正解率・適合率・再現率を見てみよう',
    minutes: 5,
    builder: (_) => const ConfusionMatrixScreen(),
  ),
  _ExperienceEntry(
    icon: Icons.science_outlined,
    title: '温度の実験室',
    subtitle: '先に答えを予測してから、計算結果とのズレを確かめよう',
    minutes: 4,
    builder: (_) => const PredictRunScreen(),
  ),
  _ExperienceEntry(
    icon: Icons.checklist,
    title: '今日やる3つ',
    subtitle: '弱点と配点から、今日取り組むべき科目を3つ提案',
    minutes: 2,
    builder: (_) => const RoutePlannerScreen(),
  ),
];

/// 「ホーム」タブ。推し・コインは後続で追加。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    required this.exam,
    required this.questionCount,
    this.questions = const [],
  });

  final ExamConfig exam;
  final int questionCount;

  /// 弱点ドリル・試験直前モードの出題元（解答履歴と突き合わせる）。
  final List<Question> questions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final disclaimerSeen = ref.watch(disclaimerSeenProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('うかラボ 生成AIパスポート', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          if (disclaimerSeen)
            InkWell(
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('このアプリについて'),
                  content: const Text(
                    '生成AIパスポート試験対策（GUGA・一般社団法人生成AI活用普及協会とは無関係の非公式アプリ）',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('閉じる'),
                    ),
                  ],
                ),
              ),
              child: Text(
                '非公式アプリについて',
                style: theme.textTheme.bodySmall?.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          else
            Text(
              '生成AIパスポート試験対策（GUGA・一般社団法人生成AI活用普及協会とは無関係の非公式アプリ）',
              style: theme.textTheme.bodySmall,
            ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('収録問題数', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text('$questionCount問', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(
                    '「学ぶ」タブで演習、「模擬」タブで本番形式の採点ができます。',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          if (!disclaimerSeen)
            Builder(
              builder: (context) {
                // 非公式アプリ表示を見た合図。次回起動時はリンク表示に折りたたむ。
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => ref.read(disclaimerSeenProvider.notifier).markSeen(),
                );
                return const SizedBox.shrink();
              },
            ),
          const KitSectionHeader(title: '今日のおすすめ'),
          PremiumPracticeCards(exam: exam, questions: questions),
          const KitSectionHeader(title: '最新情報'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('今月のAI動向'),
              subtitle: const Text('一次情報にもとづく最新動向を、自分の言葉での要約で'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AiNewsScreen())),
            ),
          ),
          const KitSectionHeader(title: '体験で理解する'),
          for (final entry in _experienceEntries) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(entry.icon),
                title: Text(entry.title),
                subtitle: Text(entry.subtitle),
                trailing: MinutesBadge(minutes: entry.minutes),
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: entry.builder)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
