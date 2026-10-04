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

`questions.jsonl` は400問（1章60／2章90／3章90／4章110／5章50）で、**提案配分（`…企画設計書_v0_3差分` 参照）に全章到達済み**。ただし**本番配信用の確定版ではない**。すべて `source: original`（シラバスの学習項目・キーワードに基づく自作）。

本番化までに必要な作業:
1. 類似チェック: 実施済み（qid重複・prompt完全一致なし。SequenceMatcher類似度0.6以上は22件あるが、いずれも「〜として最も適切なものはどれか」等の定型文が似ているだけで実質的な重複なし）。**運営者による内容確認は未着手**。
2. GUGA公式サイトでの最終シラバス・過去問の利用条件の確認: 2026-10-04に公式サイト調査済み（詳細は`…シラバス確認_v1_1.md`の後継版を参照）。
   - シラバス: 保有中の新シラバス（2027年2月適用・5章構成・3章がAIエージェント独立）は公式最新版（`https://guga.or.jp/assets/syllabus.pdf`）と一致確認。**解消**。
   - 受験規約: 「受験規約」という名称の文書はなく、`/outline`の禁止事項アコーディオンが実体。禁止対象は「受験者の行為」（問題の複製・開示・漏えい、試験後のSNS投稿、撮影・録画・共有、AIツールへの送信）で、学習アプリでの類似問題作成・要約紹介への明記はない。ただし「試験で見た問題を再現した問題」は複製・開示に該当するおそれがある、との整理。本リポジトリの方針（`source: original`、シラバス学習項目に基づく独自作成）はこの整理と整合。
   - 例題: 公式サンプルは3問公開。利用条件の記載なし→転載するならGUGAへの事前確認が必要（本リポジトリでは転載していないため対応不要）。
   - **新たな未確認事項**: 倫理規定（個人会員向け）第7条・8条により非公式であることの明記が必要（ルートREADMEに記載済みのため対応済みと考えられるが、アプリ名・ストア掲載文言についても要確認）。また「生成AIパスポート」という名称・商標の使用許諾は未確認のまま。
3. 分野バランス: topicIdは400問すべてユニークで、章内の偏りはなし。
   なお出題バランスの点検で、正解選択肢の位置（`answerIndex`）が393/400問で先頭（0番目）に偏っている不備を発見。選択肢の並びをシャッフルして修正済み（0:104／1:88／2:104／3:104に均等化。qid・prompt・explanation等は変更なし）。

## 用語データの状態

`terms.jsonl` は68語（1章12／2章15／3章15／4章16／5章10）。「用語マップ」機能（画期的な機能⑤、G検定・ITパスポートと部品共通）向けの初期データで、本番配信用の確定版ではない。各用語は①ひとこと（headline）②正確な意味（definition）③たとえ話（analogy）④紛らわしい用語との違い（commonMistake）⑤関連用語（relatedTermIds）⑥関連問題（relatedQuestionIds、`questions.jsonl` のqidを参照）の構成。シラバス全5章から主要な用語を抽出したもので、68語すべてで①〜⑥の構成要素（analogy・commonMistake含む）を作成済み。termId重複・相互参照（relatedTermIds／relatedQuestionIds）の整合性も確認済み。なお「残りの拡充」（シラバス全体のうちまだ抽出していない用語の追加）は未着手。

## 検証方法（配信前・CI）

`yourwish_kentei` の検証CLIを使う。

```bash
dart run yourwish_kentei:validate_content content/exam/seisei_ai_passport.json content/exam/questions.jsonl
```

問題が1件でもあれば終了コード1。チェック内容（出典必須・ID重複・選択肢数・正解の一意性 等）は `yourwish_kentei` の `question_validator.dart` を参照。用語データ（`terms.jsonl`）の検証CLIは `validate_content` にはまだ組み込まれていないため、別途 `validateTerms`（`term_validator.dart`）を呼ぶコードが必要（現状は本リポジトリのCIに未統合）。

この環境には Dart/Flutter SDK が無いため、本リポジトリでは未実行。`flutter pub get` 可能な開発環境（Windows・英語パス推奨。`ukalab_共通基盤_各資格アプリ向けガイド_v0_2.md` §6 参照）で実行して確認すること。
