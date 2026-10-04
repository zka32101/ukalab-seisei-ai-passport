import 'dart:convert';

import '../config/exam_config.dart';
import '../news/news.dart';
import '../question/question.dart';
import 'question_validator.dart' show ContentIssue;

class ParsedNews {
  const ParsedNews(this.news, this.issues);

  final List<News> news;

  /// 読み込み（JSON 構文・必須項目）で見つかった問題。
  final List<ContentIssue> issues;
}

/// JSON Lines（1行1件）を読む。読めない行は [ParsedNews.issues] に入れて続行する。
ParsedNews parseNewsJsonl(String text) {
  final news = <News>[];
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
      news.add(News.fromJson(decoded));
    } on FormatException catch (e) {
      issues.add(ContentIssue('line:${i + 1}', 'parse', e.message));
    }
  }
  return ParsedNews(news, issues);
}

final _dateFormat = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// 配信前の品質ゲート（決定41）。必須項目の有無、日付形式、
/// chapterTags・relatedQuestionIds のリンク切れなどを検査する。
///
/// [exam] を渡すと、examId・chapterTags が試験定義と整合するかも検査する。
/// [questions] を渡すと、relatedQuestionIds の参照先が実在するかも検査する。
List<ContentIssue> validateNews(
  List<News> newsList, {
  ExamConfig? exam,
  List<Question>? questions,
}) {
  final issues = <ContentIssue>[];
  void add(News n, String code, String message) =>
      issues.add(ContentIssue(n.newsId, code, message));

  final questionIds = questions?.map((q) => q.qid).toSet();

  final seenIds = <String>{};
  for (final n in newsList) {
    if (!seenIds.add(n.newsId)) add(n, 'duplicate-id', 'newsId が重複しています');

    if (n.headline.trim().isEmpty) add(n, 'empty-headline', 'headline が空です');
    if (n.sourceUrl.trim().isEmpty) {
      add(n, 'empty-source-url', 'sourceUrl が空です');
    } else if (!n.sourceUrl.startsWith('http://') &&
        !n.sourceUrl.startsWith('https://')) {
      add(n, 'invalid-source-url', 'sourceUrl は http(s) で始まるURLが必要です');
    }
    if (!_dateFormat.hasMatch(n.sourceDate)) {
      add(n, 'invalid-source-date', 'sourceDate は YYYY-MM-DD 形式が必要です');
    }
    if (n.asOf.trim().isEmpty) add(n, 'empty-as-of', 'asOf が空です');
    if (n.sourceRef.trim().isEmpty) add(n, 'no-source', '出典の説明がありません');
    if (n.source == QuestionSource.licensed &&
        (n.license == null || n.license!.trim().isEmpty)) {
      add(n, 'no-license', 'licensed のニュースには許諾の記録(license)が必要です');
    }
    if (n.source == QuestionSource.statute &&
        (n.lawVersion == null || n.lawVersion!.trim().isEmpty)) {
      add(n, 'no-law-version', 'statute のニュースには lawVersion が必要です');
    }
    if (n.contentVer.trim().isEmpty) add(n, 'no-content-ver', 'contentVer がありません');

    if (questionIds != null) {
      for (final relatedId in n.relatedQuestionIds) {
        if (!questionIds.contains(relatedId)) {
          add(n, 'unknown-related-question', '未定義の関連問題qid: $relatedId');
        }
      }
    }

    if (exam != null) {
      if (n.examId != exam.examId) {
        add(n, 'exam-mismatch', 'examId(${n.examId}) が試験(${exam.examId})と一致しません');
      }
      for (final tag in n.chapterTags) {
        if (exam.subject(tag) == null) {
          add(n, 'unknown-chapter-tag', '未定義の chapterTag: $tag');
        }
      }
    }
  }
  return issues;
}
