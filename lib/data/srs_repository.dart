import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukalab_core/ukalab_core.dart';

const _prefsKey = 'srs_items_v1';
const _statsPrefsKey = 'srs_stats_v1';

/// 問題ID単位の解答回数・正解数（苦手分析に使う）。
class AnswerStat {
  const AnswerStat({
    required this.qid,
    required this.attempts,
    required this.correct,
  });

  final String qid;
  final int attempts;
  final int correct;

  Map<String, dynamic> toJson() =>
      {'qid': qid, 'attempts': attempts, 'correct': correct};

  factory AnswerStat.fromJson(Map<String, dynamic> j) => AnswerStat(
        qid: j['qid'] as String,
        attempts: j['attempts'] as int,
        correct: j['correct'] as int,
      );
}

/// 間隔反復（Leitner方式）の記録と、苦手分析用の解答統計。問題ID単位で保持する。
class SrsStore {
  const SrsStore(this.items, this.stats);

  final Map<String, SrsItem> items;
  final Map<String, AnswerStat> stats;

  List<SrsItem> due(DateTime now, {int? limit}) =>
      Srs.due(items.values, now, limit: limit);

  int get masteredCount =>
      items.values.where((i) => i.box >= Srs.maxBox).length;

  /// [Question.subjectId]ごとの解答済み正解数・解答数。解答済みの科目のみ含む
  /// （記録タブの苦手分析・模擬試験の苦手科目優先出題で共用する）。
  Map<String, (int correct, int total)> statsBySubject(
    List<Question> questions,
  ) {
    final correctBySubject = <String, int>{};
    final totalBySubject = <String, int>{};
    for (final q in questions) {
      final stat = stats[q.qid];
      if (stat == null) continue;
      correctBySubject[q.subjectId] = (correctBySubject[q.subjectId] ?? 0) + stat.correct;
      totalBySubject[q.subjectId] = (totalBySubject[q.subjectId] ?? 0) + stat.attempts;
    }
    return {
      for (final subjectId in totalBySubject.keys)
        subjectId: (correctBySubject[subjectId] ?? 0, totalBySubject[subjectId]!),
    };
  }
}

class SrsNotifier extends AsyncNotifier<SrsStore> {
  @override
  Future<SrsStore> build() async {
    final prefs = await SharedPreferences.getInstance();

    final rawItems = prefs.getString(_prefsKey);
    final items = rawItems == null || rawItems.isEmpty
        ? <String, SrsItem>{}
        : {
            for (final e in jsonDecode(rawItems) as List)
              (e as Map<String, dynamic>)['qid'] as String:
                  SrsItem.fromJson(e),
          };

    final rawStats = prefs.getString(_statsPrefsKey);
    final stats = rawStats == null || rawStats.isEmpty
        ? <String, AnswerStat>{}
        : {
            for (final e in jsonDecode(rawStats) as List)
              (e as Map<String, dynamic>)['qid'] as String:
                  AnswerStat.fromJson(e),
          };

    return SrsStore(items, stats);
  }

  /// 1問分の解答結果を記録し、端末に保存する。
  Future<void> recordAnswer({required String qid, required bool correct}) async {
    final current =
        state.valueOrNull ?? const SrsStore({}, {});
    final updatedItem = Srs.review(
      current.items[qid],
      qid: qid,
      correct: correct,
      now: DateTime.now(),
    );
    final items = {...current.items, qid: updatedItem};

    final previousStat = current.stats[qid];
    final updatedStat = AnswerStat(
      qid: qid,
      attempts: (previousStat?.attempts ?? 0) + 1,
      correct: (previousStat?.correct ?? 0) + (correct ? 1 : 0),
    );
    final stats = {...current.stats, qid: updatedStat};

    state = AsyncValue.data(SrsStore(items, stats));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode([for (final item in items.values) item.toJson()]),
    );
    await prefs.setString(
      _statsPrefsKey,
      jsonEncode([for (final stat in stats.values) stat.toJson()]),
    );
  }
}

final srsProvider = AsyncNotifierProvider<SrsNotifier, SrsStore>(SrsNotifier.new);
