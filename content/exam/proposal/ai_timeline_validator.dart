import 'dart:convert';

import '../config/exam_config.dart';
import '../experience/ai_timeline.dart';
import '../question/question.dart';
import 'question_validator.dart' show ContentIssue;

class ParsedAiTimelineEvents {
  const ParsedAiTimelineEvents(this.events, this.issues);

  final List<AiTimelineEvent> events;

  /// 読み込み（JSON 構文・必須項目）で見つかった問題。
  final List<ContentIssue> issues;
}

/// JSON Lines（1行1件）を読む。読めない行は [ParsedAiTimelineEvents.issues] に
/// 入れて続行する。
ParsedAiTimelineEvents parseAiTimelineEventsJsonl(String text) {
  final events = <AiTimelineEvent>[];
  final issues = <ContentIssue>[];
  final lines = const LineSplitter().convert(text);
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty || line.startsWith('//')) continue;
    try {
      final decoded = jsonDecode(line);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('1行は JSON オブジェクトが必要です');
      }
      events.add(AiTimelineEvent.fromJson(decoded));
    } on FormatException catch (e) {
      issues.add(ContentIssue('line:${i + 1}', 'parse', e.message));
    }
  }
  return ParsedAiTimelineEvents(events, issues);
}

/// 配信前の品質ゲート。必須項目の有無、difficultyの範囲、出典の有無などを
/// 検査する。
///
/// [exam] を渡すと、examId・subjectId が試験定義と整合するかも検査する。
List<ContentIssue> validateAiTimelineEvents(
  List<AiTimelineEvent> events, {
  ExamConfig? exam,
}) {
  final issues = <ContentIssue>[];
  void add(AiTimelineEvent e, String code, String message) =>
      issues.add(ContentIssue(e.eventId, code, message));

  final seenIds = <String>{};
  for (final e in events) {
    if (!seenIds.add(e.eventId)) {
      add(e, 'duplicate-id', 'eventId が重複しています');
    }

    if (e.title.trim().isEmpty) add(e, 'empty-title', 'title が空です');
    if (e.description.trim().isEmpty) {
      add(e, 'empty-description', 'description が空です');
    }
    if (e.year.trim().isEmpty) add(e, 'empty-year', 'year が空です');
    if (e.sourceRef.trim().isEmpty) add(e, 'no-source', '出典の説明がありません');
    if (e.contentVer.trim().isEmpty) {
      add(e, 'no-content-ver', 'contentVer がありません');
    }
    if (e.difficulty < 1 || e.difficulty > 5) {
      add(e, 'invalid-difficulty', 'difficulty は1〜5である必要があります');
    }

    if (exam != null) {
      if (e.examId != exam.examId) {
        add(
          e,
          'exam-mismatch',
          'examId(${e.examId}) が試験(${exam.examId})と一致しません',
        );
      }
      final subjectId = e.subjectId;
      if (subjectId != null && exam.subject(subjectId) == null) {
        add(e, 'unknown-subject', '未定義の subjectId: $subjectId');
      }
    }
  }
  return issues;
}
