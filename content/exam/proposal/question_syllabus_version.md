# `Question`・`ExamConfig`への`syllabusVersion`追加提案

## 背景

GUGA公式サイトで2027年試験向けシラバスの「大幅改訂」が告知された（2026-10-01〜02付、詳細は`ukalab_生成AIパスポート_シラバス確認_v1_2差分（GUGA公式サイト確認結果）.md`参照）。これに伴い、公式テキストの発行元もGUGAから翔泳社に変更される。

出題範囲の詳細（どの章・トピックが追加・削除されるか）はまだ確認できておらず、問題データの作り直しは時期尚早。一方で、今のうちに「どのシラバス版に基づく問題か」を区別できる仕組みを用意しておけば、改訂内容が確定した際に新旧の問題を機械的に判別・入れ替えできる。

`yourwish_kentei`の`Question`・`ExamConfig`には現在、コンテンツの更新タイムスタンプ（`contentVer`）はあるが、教育内容としての「シラバス版」を表すフィールドが無い。`contentVer`とは独立した軸として追加を提案する。

- `contentVer`: このデータ行がいつ作成・更新されたか（コンテンツ管理）
- `syllabusVersion`（本提案）: この問題がどのシラバス版の出題範囲に基づくか（教育内容）

## 提案するフィールド

### `Question`

```dart
class Question {
  const Question({
    // ...既存の引数...
    this.syllabusVersion,
  });

  // ...既存フィールド...

  /// この問題が前提とするシラバスの版（例: "2027-02" = GUGA公式シラバス
  /// 「2027年2月試験より適用」版）。null なら examId の [ExamConfig.syllabusVersion]
  /// に従う（どちらも null なら区別しない＝旧来どおり）。
  final String? syllabusVersion;

  factory Question.fromJson(Map<String, dynamic> j) {
    // ...既存の処理...
    return Question(
      // ...既存の引数...
      syllabusVersion: optString(j, 'syllabusVersion', where),
    );
  }

  Map<String, dynamic> toJson() => {
        // ...既存のキー...
        if (syllabusVersion != null) 'syllabusVersion': syllabusVersion,
      };
}
```

### `ExamConfig`

```dart
class ExamConfig {
  const ExamConfig({
    // ...既存の引数...
    this.syllabusVersion,
  });

  // ...既存フィールド...

  /// 試験全体の既定シラバス版。個々の [Question.syllabusVersion] が null の
  /// 場合はこの値を前提とする。
  final String? syllabusVersion;

  factory ExamConfig.fromJson(Map<String, dynamic> j) {
    // ...既存の処理...
    return ExamConfig(
      // ...既存の引数...
      syllabusVersion: optString(j, 'syllabusVersion', where),
    );
  }

  Map<String, dynamic> toJson() => {
        // ...既存のキー...
        if (syllabusVersion != null) 'syllabusVersion': syllabusVersion,
      };
}
```

いずれも既存フィールドへの追加のみ（新しいnullableフィールド）で、既存の`fromJson`/`toJson`・`validateQuestions`等に破壊的変更はない。

## バリデーションの提案（任意、`question_validator.dart`）

`exam`を渡して検証する既存のパターン（`exam-mismatch`等）に倣い、以下を追加できる:

- `Question.syllabusVersion`が非nullで、`ExamConfig.syllabusVersion`も非nullのとき、両者が異なっていても**エラーにはしない**（新シラバス移行期に新旧混在を許容するため）。警告（`code: 'syllabus-version-mismatch'`）程度に留めるのが望ましい。

## 本リポジトリ側での適用方針

- 現行の`questions.jsonl`（400問）全件に`syllabusVersion: "2027-02"`（現在確認できているGUGA公式シラバス「2027年2月試験より適用」版）を設定する
- `seisei_ai_passport.json`（`ExamConfig`）にも同じ値を設定する
- 改訂後のシラバス（出題範囲の詳細が確認でき次第）で問題を追加・置き換える際は、新しい識別子（例: 実際の適用時期に基づく値）を使う。これにより新旧の問題が`syllabusVersion`で機械的に区別できる
- 出題範囲の精査・問題データの作り直し・教材方針（公式テキストの出版元変更を踏まえた参照方針）は、いずれも運営者の判断が必要なため本リポジトリでは未着手

## 未着手

- `yourwish_kentei`側への実際のIssue起票・型実装
- 出題範囲の詳細確認（GUGA公式シラバスPDFの本文照合）
- 教材方針（公式テキストの出版元変更への対応）
