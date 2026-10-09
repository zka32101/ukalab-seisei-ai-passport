import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ukalab_core/ukalab_core.dart';

Future<List<BoundaryScenario>> loadBoundaryScenarios() async {
  final text =
      await rootBundle.loadString('content/exam/boundary_scenarios.jsonl');
  final parsed = parseBoundaryScenariosJsonl(text);
  if (parsed.issues.isNotEmpty) {
    throw StateError('境界線スライダーのデータに不備があります: ${parsed.issues.first}');
  }
  return parsed.scenarios.where((s) => !s.disabled).toList();
}

final boundaryScenariosProvider = FutureProvider<List<BoundaryScenario>>(
  (ref) => loadBoundaryScenarios(),
);
