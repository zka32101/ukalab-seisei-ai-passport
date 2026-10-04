import '../question/question.dart' show QuestionSource;
import '../src/json_util.dart';

/// 「今月のAI動向」機能（決定41・画期的な機能⑥）のニュース1件。
///
/// 毎週の自動収集 → 運営者確認 → 月次の差分更新で配信する想定（決定41）。
class News {
  const News({
    required this.newsId,
    required this.examId,
    required this.headline,
    required this.sourceUrl,
    required this.sourceDate,
    required this.asOf,
    required this.source,
    required this.sourceRef,
    required this.contentVer,
    this.chapterTags = const [],
    this.examRelevant = false,
    this.relatedQuestionIds = const [],
    this.license,
    this.lawVersion,
    this.disabled = false,
  });

  final String newsId;
  final String examId;

  /// 自分の言葉での1〜2文の要約（記事本文・見出しの転載はしない）。
  final String headline;

  /// 一次情報の出典URL。
  final String sourceUrl;

  /// 出典の発表日（YYYY-MM-DD）。
  final String sourceDate;

  /// ホーム画面に必ず表示する「◯年◯月時点」の文言。
  final String asOf;

  /// シラバスの章（ch1〜ch5）。複数可、関係なければ空配列。
  final List<String> chapterTags;

  /// 「試験に出そう」印の表示有無。
  final bool examRelevant;

  /// 任意。「最新動向問題」を紐づける場合に使用。
  final List<String> relatedQuestionIds;

  final QuestionSource source;

  /// 出典の説明（一次情報のPDF名など）。必須。
  final String sourceRef;

  /// source が licensed のときの許諾の記録。
  final String? license;

  /// source が statute のときの法令の版。
  final String? lawVersion;
  final String contentVer;
  final bool disabled;

  factory News.fromJson(Map<String, dynamic> j) {
    final newsId = reqString(j, 'newsId', 'news');
    final where = 'news[$newsId]';

    final sourceName = reqString(j, 'source', where);
    final source = QuestionSource.values.where((s) => s.name == sourceName);
    if (source.isEmpty) {
      fail(where, '"source" は original / statute / licensed のいずれか');
    }

    return News(
      newsId: newsId,
      examId: reqString(j, 'examId', where),
      headline: reqString(j, 'headline', where),
      sourceUrl: reqString(j, 'sourceUrl', where),
      sourceDate: reqString(j, 'sourceDate', where),
      asOf: reqString(j, 'asOf', where),
      chapterTags: _stringList(j, 'chapterTags', where),
      examRelevant: j['examRelevant'] == true,
      relatedQuestionIds: _stringList(j, 'relatedQuestionIds', where),
      source: source.first,
      sourceRef: reqString(j, 'sourceRef', where),
      license: optString(j, 'license', where),
      lawVersion: optString(j, 'lawVersion', where),
      contentVer: reqString(j, 'contentVer', where),
      disabled: j['disabled'] == true,
    );
  }

  static List<String> _stringList(
    Map<String, dynamic> j,
    String key,
    String where,
  ) {
    final v = j[key];
    if (v == null) return const [];
    if (v is! List || v.any((e) => e is! String)) {
      fail(where, '"$key" は文字列の配列が必要です');
    }
    return List<String>.from(v);
  }

  Map<String, dynamic> toJson() => {
        'newsId': newsId,
        'examId': examId,
        'headline': headline,
        'sourceUrl': sourceUrl,
        'sourceDate': sourceDate,
        'asOf': asOf,
        if (chapterTags.isNotEmpty) 'chapterTags': chapterTags,
        if (examRelevant) 'examRelevant': true,
        if (relatedQuestionIds.isNotEmpty)
          'relatedQuestionIds': relatedQuestionIds,
        'source': source.name,
        'sourceRef': sourceRef,
        if (license != null) 'license': license,
        if (lawVersion != null) 'lawVersion': lawVersion,
        'contentVer': contentVer,
        if (disabled) 'disabled': true,
      };
}
