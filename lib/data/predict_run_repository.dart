import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ukalab_core/ukalab_core.dart';

Future<List<PredictRunScenario>> loadPredictRunScenarios() async {
  final text =
      await rootBundle.loadString('content/exam/predict_run_scenarios.jsonl');
  final parsed = parsePredictRunScenariosJsonl(text);
  if (parsed.issues.isNotEmpty) {
    throw StateError('予測→実行のデータに不備があります: ${parsed.issues.first}');
  }
  return parsed.scenarios.where((s) => !s.disabled).toList();
}

final predictRunScenariosProvider = FutureProvider<List<PredictRunScenario>>(
  (ref) => loadPredictRunScenarios(),
);
