import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

Future<List<AiNewsItem>> loadAiNewsItems() async {
  final text = await rootBundle.loadString('content/news/news.jsonl');
  final parsed = parseAiNewsItemsJsonl(text);
  if (parsed.issues.isNotEmpty) {
    throw StateError('今月のAI動向データに不備があります: ${parsed.issues.first}');
  }
  final items = parsed.items.where((i) => !i.disabled).toList()
    ..sort((a, b) => b.asOfDate.compareTo(a.asOfDate));
  return items;
}

final aiNewsItemsProvider = FutureProvider<List<AiNewsItem>>(
  (ref) => loadAiNewsItems(),
);
