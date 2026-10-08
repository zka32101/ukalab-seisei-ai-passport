import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

Future<List<FailureCase>> loadFailureCases() async {
  final text =
      await rootBundle.loadString('content/exam/failure_gallery_cases.jsonl');
  final parsed = parseFailureCasesJsonl(text);
  if (parsed.issues.isNotEmpty) {
    throw StateError('学習の失敗図鑑データに不備があります: ${parsed.issues.first}');
  }
  return parsed.cases.where((c) => !c.disabled).toList();
}

final failureCasesProvider = FutureProvider<List<FailureCase>>(
  (ref) => loadFailureCases(),
);
