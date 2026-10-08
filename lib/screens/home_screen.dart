import 'package:flutter/material.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import 'teach_mascot_screen.dart';

/// 「ホーム」タブ。推し・コインは後続で追加。
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.exam, required this.questionCount});

  final ExamConfig exam;
  final int questionCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('うかラボ 生成AIパスポート', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
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
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('推しの答案を添削'),
              subtitle: const Text('よくある誤解を見つけて、正しい答えに差し替えよう'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TeachMascotScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
