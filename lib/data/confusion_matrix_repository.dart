import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

Future<List<ConfusionMatrixScenario>> loadConfusionMatrixScenarios() async {
  final text = await rootBundle
      .loadString('content/exam/confusion_matrix_scenarios.jsonl');
  final parsed = parseConfusionMatrixScenariosJsonl(text);
  if (parsed.issues.isNotEmpty) {
    throw StateError('評価指標ラボのデータに不備があります: ${parsed.issues.first}');
  }
  return parsed.scenarios.where((s) => !s.disabled).toList();
}

final confusionMatrixScenariosProvider =
    FutureProvider<List<ConfusionMatrixScenario>>(
  (ref) => loadConfusionMatrixScenarios(),
);
