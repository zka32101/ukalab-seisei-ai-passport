import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  testWidgets('ホーム表示から学ぶタブで演習が始まる', (WidgetTester tester) async {
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
  });
}
