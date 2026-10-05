# アイコン（生成AIパスポート）

`app_common_kit` の `tools/icon_gen`（共通デザイン仕様 v0.4 §5 / 決定75）で生成した、生成AIパスポートのアプリアイコン案。

- 資格ID: `gen_ai_passport`（`app_common_kit` の `ukalab_palette.dart` に登録済み。ライト `#9A44CC` ／ダーク `#C28FE0`）
- 試験名の短縮表記: 「AIパス」
- シンボル: `sparkle`（新規提案、下記参照）

## シンボルの変更（2026-10-04、`chip` → `sparkle`）

当初 `chip` を選定していたが、`app_common_kit` を確認したところ **`chip` は既に `it_passport`（ITパスポート）に割り当て済み**であることが判明した（視覚的な差別化のために選んだはずが、実際には他資格と重複していた）。

`app_common_kit/tools/icon_gen/symbols/` には6種類のシンボル（chip・bars・network・bolt・yen・flask）しかなく、全て既存資格に割り当て済みで空きがなかったため、生成AIらしい新規シンボル `sparkle`（スパークル、大小2つの4方向の光の星）を提案・作成した。

- 提案先: `app_common_kit/tools/icon_gen/symbols/sparkle.svg`（本リポジトリでは `proposal/sparkle.svg` に配置）
- 既存シンボルと同じ規約（viewBox `-50 -50 100 100`、白塗り `fill="#fff"`）で作成。
- **2026-10-05 訂正**: 当初「`app_common_kit`に`sparkle.svg`が取り込み済み」と記録したが、これは誤り。実際には、このアプリ側セッションが過去に一時クローンしたローカルの`app_common_kit`リポジトリに、Gitで追跡されない（`git status`で`??`扱いの）ファイルとして置いたままのものだった。`git log --all`で全履歴を調べても`sparkle.svg`を追加したコミットは存在せず、`app_common_kit`のリモート（GitHub）には一切反映されていなかった。
- **2026-10-05 取り込み完了**: `app_common_kit`側に別セッションを作成して取り込みを依頼し、PR #44（`app_common_kit`、コミット`cf0dfad`・`608ce3b`）で`tools/icon_gen/symbols/sparkle.svg`・`tools/icon_gen/specs/sample.json`（`{"id": "gen_ai_passport", "short": "AIパス", "symbol": "sparkle"}`追加）の両方が実際にマージされたことを確認。本リポジトリの提案（`proposal/sparkle.svg`）と内容が完全一致。
- `app_common_kit` を一時的にクローンし、`icon_gen.py`・`check_icons.py` を実際に実行して検証済み（この環境にPIL・PyMuPDFがありレンダリング可能だった）。`sparkle`を含む7資格分のアイコンを生成し、`check_icons.py`は全件OK（サイズ・コントラスト4.5:1・要素の重なり・余白・adaptive中央66%・最小サイズ版・**他資格との見分け**を含む）。

## ファイル
- `icon_spec.json`: 生成に使ったspec（`icon_gen.py --spec` の入力）。シンボルは`sparkle`に更新済み。
- `gen_ai_passport_1024.png`: 1024px の角なし正方形（上段「うかラボ」／中央シンボル／下部に試験名）。`sparkle`シンボルで再生成済み。
- `gen_ai_passport_fg.png` / `gen_ai_passport_bg.png`: Android adaptive 用の前景・背景。再生成済み。
- `gen_ai_passport_small_1024.png`: 最小サイズ用（上段省略・シンボル拡大）。再生成済み。
- `layout.json`: 生成時のレイアウト情報（シンボル変更後も座標は同一、固定比率のため変化なし）。
- `proposal/sparkle.svg`: `app_common_kit`への提案シンボル。

`check_icons.py` によるサイズ・コントラスト（4.5:1）・要素の重なり・端の余白・adaptive中央66%・最小サイズ版の検査はOK。

**2026-10-05 確定**: シンボル（`sparkle`）・短縮表記（「AIパス」）はユーザー確認済みで最終案として確定。

## 未着手
- Android/iOSの実アイコンファイルへの反映（`flutter create` 後の `android/`・`ios/` ディレクトリへの配置）は、アプリ本体の実装着手後に行う
