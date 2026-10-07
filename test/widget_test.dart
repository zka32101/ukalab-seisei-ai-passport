import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukalab_seisei_ai_passport/main.dart';

// rootBundle.loadString は大きなファイル（questions.jsonl）を compute()
// （別Isolate）でデコードする。widget test 環境でそれを待つには
// tester.runAsync() でラップしてポーリングする必要がある
// （実アプリでは問題にならない）。
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
  testWidgets('ホームから演習開始までの最短経路が動く', (WidgetTester tester) async {
    await tester.pumpWidget(const UkalabSeiseiAiPassportApp());
    await tester.pump();

    final startButton = find.widgetWithText(FilledButton, '演習を始める（10問）');
    await _waitUntilFound(tester, startButton);

    expect(find.textContaining('生成AIパスポート'), findsWidgets);
    expect(find.textContaining('問題データ'), findsOneWidget);
    expect(startButton, findsOneWidget);

    await tester.tap(startButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // ページ遷移アニメーション

    expect(find.textContaining('第1問'), findsOneWidget);
  });
}
