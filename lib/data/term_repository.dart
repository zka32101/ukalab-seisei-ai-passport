import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

Future<List<Term>> loadTerms() async {
  final text = await rootBundle.loadString('content/exam/terms.jsonl');
  final parsed = parseTermsJsonl(text);
  if (parsed.issues.isNotEmpty) {
    throw StateError('用語データに不備があります: ${parsed.issues.first}');
  }
  return parsed.terms.where((t) => !t.disabled).toList();
}

final termsProvider = FutureProvider<List<Term>>((ref) => loadTerms());
