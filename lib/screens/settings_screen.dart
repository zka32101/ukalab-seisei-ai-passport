import 'package:flutter/material.dart';

import 'purchase_section.dart';

/// 「設定」タブ。課金・広告・通知の設定は後続。
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        PurchaseSection(),
        Divider(height: 32),
        ListTile(
          title: Text('このアプリについて'),
          subtitle: Text(
            '「うかラボ 生成AIパスポート」は、GUGA（一般社団法人生成AI活用普及協会）とは'
            '無関係に開発・運営する非公式の学習アプリです。問題はすべて独自に作成しています。',
          ),
        ),
        Divider(height: 1),
        ListTile(
          title: Text('バージョン'),
          subtitle: Text('0.1.0'),
        ),
      ],
    );
  }
}
