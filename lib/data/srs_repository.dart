import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

const _prefsKey = 'srs_items_v1';

/// 間隔反復（Leitner方式）の記録。問題ID単位で保持する。
class SrsStore {
  const SrsStore(this.items);

  final Map<String, SrsItem> items;

  List<SrsItem> due(DateTime now, {int? limit}) =>
      Srs.due(items.values, now, limit: limit);

  int get masteredCount =>
      items.values.where((i) => i.box >= Srs.maxBox).length;
}

class SrsNotifier extends AsyncNotifier<SrsStore> {
  @override
  Future<SrsStore> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return const SrsStore({});
    final list = (jsonDecode(raw) as List)
        .map((e) => SrsItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return SrsStore({for (final item in list) item.qid: item});
  }

  /// 1問分の解答結果を記録し、端末に保存する。
  Future<void> recordAnswer({required String qid, required bool correct}) async {
    final current = state.valueOrNull ?? const SrsStore({});
    final updated = Srs.review(
      current.items[qid],
      qid: qid,
      correct: correct,
      now: DateTime.now(),
    );
    final items = {...current.items, qid: updated};
    state = AsyncValue.data(SrsStore(items));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode([for (final item in items.values) item.toJson()]),
    );
  }
}

final srsProvider = AsyncNotifierProvider<SrsNotifier, SrsStore>(SrsNotifier.new);
