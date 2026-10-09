import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ukalab_core/ukalab_core.dart';

Future<List<MisconceptionScenario>> loadMisconceptionScenarios() async {
  final text =
      await rootBundle.loadString('content/exam/teach_mascot_scenarios.jsonl');
  final parsed = parseMisconceptionScenariosJsonl(text);
  if (parsed.issues.isNotEmpty) {
    throw StateError('推しの答案添削データに不備があります: ${parsed.issues.first}');
  }
  return parsed.scenarios.where((s) => !s.disabled).toList();
}

final misconceptionScenariosProvider =
    FutureProvider<List<MisconceptionScenario>>(
  (ref) => loadMisconceptionScenarios(),
);
