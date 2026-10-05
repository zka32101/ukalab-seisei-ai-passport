# 今月のAI動向（決定41）

生成AIパスポートの画期的な機能⑥「今月のAI動向」用のデータ。`yourwish_kentei`（v0.10.0）に `AiNewsItem` モデルが実装されたため、`news.jsonl` はそのスキーマに準拠する配信データ。

## 現在のデータ（`news.jsonl`）

`news.jsonl` は3件。いずれもWeb検索で確認した一次情報（公式サイト・公式PDF）のみを根拠に、見出し・本文の転載ではなく自分の言葉で要約した。

1. `news-2026-03-0001`: 総務省・経済産業省「AI事業者ガイドライン」第1.2版（2026-03-31公表、ch3）
2. `news-2026-04-0001`: 個人情報保護法改正案の閣議決定（2026-04-07、ch4）
3. `news-2026-07-0001`: Anthropic「Claude Opus 5」発表（2026-07-24、ch2）

いずれも`relatedQuestionId`で既存`questions.jsonl`の関連問題（それぞれ`sap-0006`・`sap-0093`・`sap-0047`）と紐付けた。`ai_news_validator.dart`の検査項目（必須項目・`asOfDate`が`sourceDate`以降であること・examId/relatedQuestionIdの参照整合性）を手動で確認済み（この環境にはDart SDKが無いため実行はできていない）。

**注記**: 発表時期が2026年3〜7月とやや古く、「今月」の動向としては本来望ましくない。これは、この環境のWeb検索で一次情報を確度高く確認できたニュースを優先したため。実際の配信時は、運用フロー（毎週月曜の定期収集→運営者確認）に沿って、配信月に近い候補へ差し替える想定。

## `AiNewsItem` のフィールド（2026-10-05、実装確認済み）

当初提案した`News`（仮称）モデルとは異なるフィールド名・型で実装された。実際のスキーマ（`yourwish_kentei` の `lib/experience/ai_news.dart`）:

```json
{
  "newsItemId": "news-2026-03-0001",
  "examId": "seisei_ai_passport",
  "summary": "自分の言葉での1〜2文の要約（記事の転載はしない）",
  "sourceUrl": "https://www.soumu.go.jp/main_content/001064299.pdf",
  "sourceDate": "2026-03-31",
  "syllabusTag": "ch3",
  "isExamRelevant": true,
  "asOfDate": "2026-03-31",
  "relatedQuestionId": "sap-0006",
  "source": "original",
  "sourceRef": "総務省・経済産業省公式PDF（一次情報）",
  "contentVer": "2026.10.1"
}
```

提案時（`News`）との差分:
- `newsId` → `newsItemId`
- `headline` → `summary`
- `chapterTags`（配列） → `syllabusTag`（単数文字列。複数章にまたがる場合は主要な1章を選ぶ）
- `examRelevant` → `isExamRelevant`
- `asOf`（"2026年3月時点"のような日本語文言の文字列） → `asOfDate`（`DateTime`。`sourceDate`以降である必要がある）
- `relatedQuestionIds`（配列） → `relatedQuestionId`（単数、任意）
- `sourceDate`（`DateTime`。文字列のままで`DateTime.tryParse`可能な形式であればよい）

`proposal/news.dart`・`proposal/news_validator.dart`は、この実装確認前に作成した提案コードとして参考用に残す（実際に実装されたのは別のフィールド構成のため、提案コードそのものは取り込まれていない）。

## 運用フロー（決定41）

```
毎週月曜8:45(JST) クラウドの定期タスクが候補を収集
  → Google Drive の設計書フォルダに ukalab_AIニュース候補_YYYY-MM.md として追記
  → 運営者が確認・採否を決定
  → 月次の差分更新（データのみ）で配信
```

収集対象: GUGA・JDLA・経産省・総務省・文化庁・内閣府・個人情報保護委員会、主要AIベンダーの公式発表（一次情報）。

禁止事項: 記事本文・見出しの転載、有料記事・規約で禁止されたサイトの収集、未確認情報の掲載。

ホーム画面には3〜5件を表示（設計書§4b・画期的な機能⑥）。

## 現在の状態

- `yourwish_kentei`（v0.11.0）に `AiNewsItem` モデル・`validateAiNewsItems` 検証ロジックが実装済み。本リポジトリの`pubspec.yaml`もv0.11.0に更新済み
- CI（`.github/workflows/validate_content.yml`）に`--ai-news content/news/news.jsonl`を統合済み
- Google Drive に `ukalab_AIニュース候補_2026-10.md` を作成し、2026-10-03時点で手動収集した候補2件を記録（1件は一次情報で確認済み・運営者確認待ち、1件は二次情報のみで要一次情報差し替え）
- 毎週月曜の定期収集タスクが実際にこのフォルダへ出力しているかは、このアプリ側セッションのスコープ外のため未確認。重複を避けるため、定期タスクの運用状況を人間側で確認することが必要
