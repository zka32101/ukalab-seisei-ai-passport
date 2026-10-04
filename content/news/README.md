# 今月のAI動向（決定41）

生成AIパスポートの画期的な機能⑥「今月のAI動向」用のデータ。**`yourwish_kentei` にはまだ専用モデルが無い**ため、本ディレクトリはアプリ側からのデータ仕様の提案と、手動収集した候補の置き場。

## 現在のデータ（`news.jsonl`、2026-10-04作成）

`news.jsonl` は3件。いずれもWeb検索で確認した一次情報（公式サイト・公式PDF）のみを根拠に、見出し・本文の転載ではなく自分の言葉で要約した。

1. `news-2026-03-0001`: 総務省・経済産業省「AI事業者ガイドライン」第1.2版（2026-03-31公表、ch3・ch4）
2. `news-2026-04-0001`: 個人情報保護法改正案の閣議決定（2026-04-07、ch4）
3. `news-2026-07-0001`: Anthropic「Claude Opus 5」発表（2026-07-24、ch2）

いずれも`relatedQuestionIds`で既存`questions.jsonl`の関連問題（それぞれ`sap-0006`・`sap-0093`・`sap-0047`）と紐付けた。`news_validator.dart`（`proposal/`）の検査項目（必須項目・日付形式・URL形式・chapterTags/relatedQuestionIdsの参照整合性）を手動で確認済み（この環境にはDart SDKが無いため実行はできていない）。

**注記**: 発表時期が2026年3〜7月とやや古く、「今月」の動向としては本来望ましくない。これは、この環境のWeb検索で一次情報を確度高く確認できたニュースを優先したため。実際の配信時は、運用フロー（毎週月曜の定期収集→運営者確認）に沿って、配信月に近い候補へ差し替える想定。

## 運用フロー（決定41）

```
毎週月曜8:45(JST) クラウドの定期タスクが候補を収集
  → Google Drive の設計書フォルダに ukalab_AIニュース候補_YYYY-MM.md として追記
  → 運営者が確認・採否を決定
  → 月次の差分更新（データのみ）で配信
```

収集対象: GUGA・JDLA・経産省・総務省・文化庁・内閣府・個人情報保護委員会、主要AIベンダーの公式発表（一次情報）。

禁止事項: 記事本文・見出しの転載、有料記事・規約で禁止されたサイトの収集、未確認情報の掲載。

## 配信データの仕様案（`news.jsonl`、未実装）

`yourwish_kentei` に `News`（仮称）モデルが実装されるまでの、アプリ側が必要とするフィールドの提案:

```json
{
  "newsId": "news-2026-10-0001",
  "examId": "seisei_ai_passport",
  "headline": "総務省・経産省がAI事業者ガイドライン第1.2版を公表。AIエージェント・Human-in-the-Loop・トレーサビリティを明確化。",
  "sourceUrl": "https://www.soumu.go.jp/main_content/001064299.pdf",
  "sourceDate": "2026-03-31",
  "asOf": "2026年3月時点",
  "chapterTags": ["ch3", "ch4"],
  "examRelevant": true,
  "relatedQuestionIds": ["sap-0079"],
  "source": "original",
  "sourceRef": "総務省公式PDF（一次情報）",
  "contentVer": "2026.10.0"
}
```

- `headline`: 自分の言葉での1〜2文の要約（記事の転載はしない）
- `asOf`: ホーム画面で必ず表示する「◯年◯月時点」の文言
- `chapterTags`: シラバスの章（`ch1`〜`ch5`）。複数可、関係なければ空配列
- `examRelevant`: 「試験に出そう」印の表示有無
- `relatedQuestionIds`: 任意。「最新動向問題」を紐づける場合に使用

ホーム画面には3〜5件を表示（設計書§4b・画期的な機能⑥）。

## 現在の状態

- `yourwish_kentei` 側にモデル・検証ロジックは未実装（`lib/term/term.dart` のような `lib/news/news.dart` 相当がまだ無い）。共通基盤側への提案・実装依頼が必要
- Google Drive に `ukalab_AIニュース候補_2026-10.md` を作成し、2026-10-03時点で手動収集した候補2件を記録（1件は一次情報で確認済み・運営者確認待ち、1件は二次情報のみで要一次情報差し替え）
- 毎週月曜の定期収集タスクが実際にこのフォルダへ出力しているかは、このアプリ側セッションのスコープ外のため未確認。重複を避けるため、定期タスクの運用状況を人間側で確認することが必要

## `yourwish_kentei` への実装提案（`proposal/`、2026-10-04）

`yourwish_kentei`（別リポジトリ、本セッションはread-onlyでクローン済み・push権限なし）の既存実装（`lib/term/term.dart`・`lib/content/term_validator.dart`）のパターンに忠実に、`News` モデルと検証関数のサンプル実装を作成した。

- `proposal/news.dart`: `News` クラス（上記の配信データ仕様案のフィールドに対応）。`fromJson`/`toJson`を実装。
- `proposal/news_validator.dart`: `parseNewsJsonl`（JSON Lines読み込み）・`validateNews`（配信前の品質ゲート）。`term_validator.dart`と同様に、`ExamConfig`・既存`Question`一覧を渡すと`examId`・`chapterTags`・`relatedQuestionIds`の整合性も検査する。

**位置づけ**: このリポジトリから `yourwish_kentei` へのpush権限はないため、そのまま `yourwish_kentei` へ取り込めるコード片として用意した（配置先は`yourwish_kentei`の`lib/news/news.dart`・`lib/content/news_validator.dart`相当、`lib/yourwish_kentei.dart`のexportにも追加が必要）。実際の取り込み・PR作成は`yourwish_kentei`側のセッション・権限で行う必要がある。

**未検証の注記**: この環境にはDart/Flutter SDKが無いため、コンパイル・テストは未実行（既存の`question_validator.dart`等の実装パターンを目視で忠実に模倣したのみ）。`yourwish_kentei`側で取り込む際に、`dart analyze`等での検証が必要。
