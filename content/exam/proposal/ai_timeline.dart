import '../question/question.dart' show QuestionSource;
import '../src/json_util.dart';

/// AIの歴史と最新動向タイムライン（画期的な機能④）の出来事カテゴリ。
enum AiTimelineCategory {
  /// 概念・用語の誕生（例: ダートマス会議）。
  concept,

  /// AIブームの時期。
  boom,

  /// AIの冬（停滞期）。
  winter,

  /// 技術的なブレークスルー。
  techBreakthrough,

  /// モデル・サービスのリリース。
  modelRelease,
}

String categoryJsonName(AiTimelineCategory c) {
  switch (c) {
    case AiTimelineCategory.concept:
      return 'concept';
    case AiTimelineCategory.boom:
      return 'boom';
    case AiTimelineCategory.winter:
      return 'winter';
    case AiTimelineCategory.techBreakthrough:
      return 'tech-breakthrough';
    case AiTimelineCategory.modelRelease:
      return 'model-release';
  }
}

/// AIの歴史と最新動向タイムライン（画期的な機能④、企画設計書§5）の1件の出来事。
///
/// 体験: 年表上に出来事を並べ、時系列でAIの発展を振り返る。月次更新で
/// 最新の出来事を追加する運用を想定（運営者確認・差分更新はアプリの外で
/// 行い、ここは配信するデータの構造だけを持つ）。
class AiTimelineEvent {
  const AiTimelineEvent({
    required this.eventId,
    required this.examId,
    required this.topicId,
    required this.year,
    required this.title,
    required this.description,
    required this.category,
    required this.source,
    required this.sourceRef,
    required this.contentVer,
    this.subjectId,
    this.difficulty = 3,
    this.disabled = false,
  });

  final String eventId;
  final String examId;

  /// null なら分野を問わない。
  final String? subjectId;

  final String topicId;

  /// 出来事が起きた年（例: "1956"。"1950年代末〜1960年代"のような範囲の
  /// 自由記述も可。年表上の並び順はデータ投入順に従う）。
  final String year;

  final String title;
  final String description;
  final AiTimelineCategory category;

  final QuestionSource source;
  final String sourceRef;

  /// 1〜5。
  final int difficulty;
  final String contentVer;
  final bool disabled;

  factory AiTimelineEvent.fromJson(Map<String, dynamic> j) {
    final eventId = reqString(j, 'eventId', 'aiTimelineEvent');
    final where = 'aiTimelineEvent[$eventId]';

    final sourceName = reqString(j, 'source', where);
    final source = QuestionSource.values.where((s) => s.name == sourceName);
    if (source.isEmpty) {
      fail(where, '"source" は original / statute / licensed のいずれか');
    }

    final categoryName = reqString(j, 'category', where);
    final category = AiTimelineCategory.values.where(
      (c) => categoryJsonName(c) == categoryName,
    );
    if (category.isEmpty) {
      fail(
        where,
        '"category" は concept / boom / winter / tech-breakthrough / '
        'model-release のいずれか',
      );
    }

    return AiTimelineEvent(
      eventId: eventId,
      examId: reqString(j, 'examId', where),
      subjectId: optString(j, 'subjectId', where),
      topicId: reqString(j, 'topicId', where),
      year: reqString(j, 'year', where),
      title: reqString(j, 'title', where),
      description: reqString(j, 'description', where),
      category: category.first,
      source: source.first,
      sourceRef: reqString(j, 'sourceRef', where),
      difficulty: optInt(j, 'difficulty', where, 3),
      contentVer: reqString(j, 'contentVer', where),
      disabled: j['disabled'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'examId': examId,
        if (subjectId != null) 'subjectId': subjectId,
        'topicId': topicId,
        'year': year,
        'title': title,
        'description': description,
        'category': categoryJsonName(category),
        'source': source.name,
        'sourceRef': sourceRef,
        'difficulty': difficulty,
        'contentVer': contentVer,
        if (disabled) 'disabled': true,
      };
}
