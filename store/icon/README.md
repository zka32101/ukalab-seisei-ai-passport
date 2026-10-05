# アイコン（生成AIパスポート）

`app_common_kit` の `tools/icon_gen`（共通デザイン仕様 v0.4 §5 / 決定75）で生成した、生成AIパスポートのアプリアイコン案。

- 資格ID: `gen_ai_passport`（`app_common_kit` の `ukalab_palette.dart` に登録済み。ライト `#9A44CC` ／ダーク `#C28FE0`）
- 試験名の短縮表記: 「AIパス」
- シンボル: `passport_ai`（2026-10-05、`sparkle`から変更。下記参照）

## シンボルの変更（2026-10-04、`chip` → `sparkle`）

当初 `chip` を選定していたが、`app_common_kit` を確認したところ **`chip` は既に `it_passport`（ITパスポート）に割り当て済み**であることが判明した（視覚的な差別化のために選んだはずが、実際には他資格と重複していた）。

`app_common_kit/tools/icon_gen/symbols/` には6種類のシンボル（chip・bars・network・bolt・yen・flask）しかなく、全て既存資格に割り当て済みで空きがなかったため、生成AIらしい新規シンボル `sparkle`（スパークル、大小2つの4方向の光の星）を提案・作成した。

- 提案先: `app_common_kit/tools/icon_gen/symbols/sparkle.svg`（本リポジトリでは `proposal/sparkle.svg` に配置）
- 既存シンボルと同じ規約（viewBox `-50 -50 100 100`、白塗り `fill="#fff"`）で作成。
- **2026-10-05 訂正**: 当初「`app_common_kit`に`sparkle.svg`が取り込み済み」と記録したが、これは誤り。実際には、このアプリ側セッションが過去に一時クローンしたローカルの`app_common_kit`リポジトリに、Gitで追跡されない（`git status`で`??`扱いの）ファイルとして置いたままのものだった。`git log --all`で全履歴を調べても`sparkle.svg`を追加したコミットは存在せず、`app_common_kit`のリモート（GitHub）には一切反映されていなかった。
- **2026-10-05 取り込み完了**: `app_common_kit`側に別セッションを作成して取り込みを依頼し、PR #44（`app_common_kit`、コミット`cf0dfad`・`608ce3b`）で`tools/icon_gen/symbols/sparkle.svg`・`tools/icon_gen/specs/sample.json`（`{"id": "gen_ai_passport", "short": "AIパス", "symbol": "sparkle"}`追加）の両方が実際にマージされたことを確認。本リポジトリの提案（`proposal/sparkle.svg`）と内容が完全一致。
- `app_common_kit` を一時的にクローンし、`icon_gen.py`・`check_icons.py` を実際に実行して検証済み（この環境にPIL・PyMuPDFがありレンダリング可能だった）。`sparkle`を含む7資格分のアイコンを生成し、`check_icons.py`は全件OK（サイズ・コントラスト4.5:1・要素の重なり・余白・adaptive中央66%・最小サイズ版・**他資格との見分け**を含む）。

## ファイル
- `icon_spec.json`: 生成に使ったspec（`icon_gen.py --spec` の入力）。シンボルは`passport_ai`に更新済み。
- `gen_ai_passport_1024.png`: 1024px の角なし正方形（上段「桜マーク＋うかラボ」／中央シンボル／下部に試験名）。最新テンプレート＋`passport_ai`シンボルで再生成済み。
- `gen_ai_passport_fg.png` / `gen_ai_passport_bg.png`: Android adaptive 用の前景・背景。前景は`passport_ai`シンボルで再生成済み。
- `gen_ai_passport_small_1024.png`: 最小サイズ用（上段省略・シンボル拡大）。`passport_ai`シンボルで再生成済み。
- `layout.json`: 生成時のレイアウト情報（`mark`＝桜マークの座標を含む）。
- `proposal/passport_ai.svg`: `app_common_kit`への提案シンボル（現行）。
- `proposal/sparkle.svg`: 旧シンボル（参考、`app_common_kit`のPR #44で取り込み済み。本資格では使用終了）。

`check_icons.py` によるサイズ・コントラスト（4.5:1）・要素の重なり・端の余白・adaptive中央66%・最小サイズ版・他資格との見分けの検査はOK。

**2026-10-05 確定**: シンボル（`passport_ai`）・短縮表記（「AIパス」）はユーザー確認済みで最終案として確定。

## シンボルの変更（2026-10-05、`sparkle` → `passport_ai`）

`sparkle`は生成AIらしさは表現できていたが、「AIパスポート」という資格そのものを象徴するデザインではなかった（どの生成AI系資格にも使えそうな汎用的な意匠だった）。そこで、パスポート＋生成AI（地球規模でつながるネットワーク）を組み合わせた、本資格専用のシンボル `passport_ai` を新規デザインした。

- 意匠: パスポート本体（白い角丸四角形）の中に地球儀（経線・緯線）を配置し、そこからネットワークの接続線とノードが下に伸びる構成。右上に生成AIを示すスパークルを添えた。「世界と生成AIでつながるパスポート」のイメージ。
- 検討の過程: 当初Canva（MCPツール経由）で画像生成を試みたが、`generate-image`が生成する高解像度画像（1264×1264相当）をMCP経由で取得する手段がなく、取得できたのは200×200のJPEGサムネイルのみだった。アイコンサイズに拡大するとノイズ・ギザギザが目立ち実用に耐えなかったため、同じ構図を手作業の高解像度SVGとして自作する方針に切り替えた。
- 提案先: `app_common_kit/tools/icon_gen/symbols/passport_ai.svg`（本リポジトリでは `proposal/passport_ai.svg` に配置）。既存シンボルと同じ規約（viewBox `-50 -50 100 100`、白塗り `fill="#fff"`、背景色で中抜きする部分は `__BG__`）で作成。
- 旧シンボル`sparkle`（`app_common_kit`のPR #44でマージ済み）は、本資格での使用を終了。`app_common_kit`側のファイル自体は残置（他資格が将来使う可能性を妨げないため、削除は依頼しない）。

## 「うかラボ」ロゴへの桜マーク追加（2026-10-05、テンプレート更新に追従）

`app_common_kit`側で、シリーズ共通のデザイン変更として「うかラボ」の左に合格の象徴となる桜マーク（`symbols/sakura.svg`）を追加する`icon_gen.py`の更新があった（コミット`9403e4b`「feat(icon_gen): 「うかラボ」の左に桜のマークを追加」）。本リポジトリのアイコンもこれに合わせて再生成した。

- `app_common_kit`の最新コミット（`fd55d21`、PR #48マージ後）を取得し、`icon_gen.py --spec icon_spec.json --out <dir> --font <NotoSansCJK-Bold.ttc>`で再生成
- 全資格分（`tools/icon_gen/specs/sample.json`）もあわせて生成し、`check_icons.py`で他資格との見分け等を含めて検証（OK）
- 変更があったのは`gen_ai_passport_1024.png`（桜マーク追加）・`gen_ai_passport_fg.png`（座標計算の調整に伴う再生成だが見た目は同一）・`layout.json`（`mark`座標の追加）のみ。`gen_ai_passport_bg.png`・`gen_ai_passport_small_1024.png`は変化なし（桜マークは上段「うかラボ」表示時のみ描画されるため）
- 同時に追加された「中央のシンボルをPNG画像で差し込める（`symbol_image`）」機能（コミット`750b5a7`）は、既存のSVGシンボル（`sparkle`）方式に影響しない任意機能のため、本リポジトリでは未使用

## 未着手
- Android/iOSの実アイコンファイルへの反映（`flutter create` 後の `android/`・`ios/` ディレクトリへの配置）は、アプリ本体の実装着手後に行う
