import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ukalab_seisei_ai_passport/main.dart';

// rootBundle.loadString は大きなファイル（questions.jsonl）を compute()
// （別Isolate）でデコードする。widget test 環境でそれを待つには
// tester.runAsync() でラップしてポーリングする必要がある
// （実アプリでは問題にならない）。1つのテストプロセス内で compute() を
// 複数回呼ぶと稀にハングするため、アプリの起動は1テストにまとめている。
Future<void> _waitUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 20; i++) {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
    if (tester.any(finder)) return;
  }
  await tester.pump();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'ホーム表示→学ぶタブで演習→記録タブに復習予定が反映される',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: UkalabSeiseiAiPassportApp()),
      );
      await tester.pump();

      final homeTitle = find.textContaining('収録問題数');
      await _waitUntilFound(tester, homeTitle);

      expect(find.textContaining('生成AIパスポート'), findsWidgets);
      expect(homeTitle, findsOneWidget);

      await tester.tap(find.text('学ぶ'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('第1問'), findsOneWidget);

      // 選択肢Aを選んで解答する（正誤は問わない。間隔反復の記録に使われる）。
      await tester.tap(find.text('A').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('記録'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('記録している問題: 1問'), findsOneWidget);
      expect(find.text('苦手分野'), findsOneWidget);

      // 苦手分野の行をタップすると、その科目の復習セッションに遷移する。
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('復習:'), findsOneWidget);
      expect(find.textContaining('第1問'), findsOneWidget);
    },
  );
}
