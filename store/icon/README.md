# アイコン（生成AIパスポート）

`app_common_kit` の `tools/icon_gen`（共通デザイン仕様 v0.4 §5 / 決定75）で生成した、生成AIパスポートのアプリアイコン案。

- 資格ID: `gen_ai_passport`（`app_common_kit` の `ukalab_palette.dart` に登録済み。ライト `#9A44CC` ／ダーク `#C28FE0`）
- 試験名の短縮表記: 「AIパス」
- シンボル: `chip`（既存サンプルのG検定が `network` を使っているため、視覚的な差別化のため別シンボルを選定）

## ファイル
- `icon_spec.json`: 生成に使ったspec（`icon_gen.py --spec` の入力）
- `gen_ai_passport_1024.png`: 1024px の角なし正方形（上段「うかラボ」／中央シンボル／下部に試験名）
- `gen_ai_passport_fg.png` / `gen_ai_passport_bg.png`: Android adaptive 用の前景・背景
- `gen_ai_passport_small_1024.png`: 最小サイズ用（上段省略・シンボル拡大）
- `layout.json`: 生成時のレイアウト情報

`check_icons.py` によるサイズ・コントラスト（4.5:1）・要素の重なり・端の余白・adaptive中央66%・最小サイズ版の検査はOK。

## 未着手
- `app_common_kit` 側の `tools/icon_gen/specs/sample.json` への `gen_ai_passport` 追加は、本リポジトリからはpush権限がないため未実施（app_common_kit側のセッション・PRで対応が必要）
- シンボル・短縮表記の最終案はユーザー確認待ち
- Android/iOSの実アイコンファイルへの反映（`flutter create` 後の `android/`・`ios/` ディレクトリへの配置）は、アプリ本体の実装着手後に行う
