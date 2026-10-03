# 試験データ（生成AIパスポート）

- `seisei_ai_passport.json`: ExamConfig（試験定義）。`yourwish_kentei` の `ExamConfig.fromJson` で読む。
- `questions.jsonl`: 問題データ（JSON Lines、1行1問）。
- `terms.jsonl`: 専門用語の解説データ（決定50、JSON Lines、1行1用語）。`yourwish_kentei` の `Term.fromJson` で読む。

## シラバスの版について

GUGA公式シラバス「2027年2月試験より適用」版に基づく章構成（ch1〜ch5）を `subjectId` に採用している。
詳細は Google Drive の設計書を参照:
- `ukalab_生成AIパスポート_シラバス確認_v1_1.md`（新旧シラバス比較、章別の学習項目）
- `ukalab_生成AIパスポート_企画設計書_v0_3差分（新シラバス対応）.md`（問題量配分・画期的な機能の章対応）

## 現在の問題データの状態

`questions.jsonl` は368問（1章60／2章79／3章80／4章99／5章50）。最終目標（約400問、提案配分: 1章60／2章90／3章90／4章110／5章50）に向けた拡充の途中段階で、**本番配信用の確定版ではない**。すべて `source: original`（シラバスの学習項目・キーワードに基づく自作）。1章・5章は目標到達済み。

本番化までに必要な作業（未着手）:
1. 章別の目標問題数まで拡充を続ける（`…企画設計書_v0_3差分` 参照）
2. 各問題を類似チェック・運営者確認のフローに通す
3. GUGA公式サイトでの最終シラバス・過去問の利用条件の確認（`…シラバス確認_v1_1.md` の未決事項を参照）

## 用語データの状態

`terms.jsonl` は68語（1章12／2章15／3章15／4章16／5章10）。「用語マップ」機能（画期的な機能⑤、G検定・ITパスポートと部品共通）向けの初期データで、本番配信用の確定版ではない。各用語は①ひとこと（headline）②正確な意味（definition）③たとえ話（analogy）④紛らわしい用語との違い（commonMistake）⑤関連用語（relatedTermIds）⑥関連問題（relatedQuestionIds、`questions.jsonl` のqidを参照）の構成。シラバス全5章から主要な用語を抽出したもので、残りの拡充は未着手。

## 検証方法（配信前・CI）

`yourwish_kentei` の検証CLIを使う。

```bash
dart run yourwish_kentei:validate_content content/exam/seisei_ai_passport.json content/exam/questions.jsonl
```

問題が1件でもあれば終了コード1。チェック内容（出典必須・ID重複・選択肢数・正解の一意性 等）は `yourwish_kentei` の `question_validator.dart` を参照。用語データ（`terms.jsonl`）の検証CLIは `validate_content` にはまだ組み込まれていないため、別途 `validateTerms`（`term_validator.dart`）を呼ぶコードが必要（現状は本リポジトリのCIに未統合）。

この環境には Dart/Flutter SDK が無いため、本リポジトリでは未実行。`flutter pub get` 可能な開発環境（Windows・英語パス推奨。`ukalab_共通基盤_各資格アプリ向けガイド_v0_2.md` §6 参照）で実行して確認すること。
