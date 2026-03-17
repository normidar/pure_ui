# TTF テキストレンダリング実装計画

## 進捗

| Phase | 状態 | 完了日 |
|-------|------|--------|
| Phase 1: 基盤整備 | ✅ 完了 | 2026-03-17 |
| Phase 2: TTF パーサー | ✅ 完了 | 2026-03-17 |
| Phase 3: グリフラスタライザー | ✅ 完了 | 2026-03-17 |
| Phase 4: テキストシェーパー | ✅ 完了 | 2026-03-17 |
| Phase 5: テキストレイアウトエンジン | ✅ 完了 | 2026-03-17 |
| Phase 6: Canvas 統合 | ✅ 完了 | 2026-03-17 |
| Phase 7: マルチスタイルスパン | ✅ 完了 | 2026-03-17 |
| Phase 8: パフォーマンス最適化 | ✅ 完了 | 2026-03-17 |

---

## 概要

pure_ui で任意の TTF/OTF フォントファイルを使ってテキストを画像に描画できるようにする。
Flutter の `dart:ui` 互換 API（`ParagraphBuilder` → `Paragraph` → `Canvas.drawParagraph()`）を純 Dart で実装する。

---

## 現状整理

### 問題の根本

| ファイル | 行 | 問題 |
|----------|-----|------|
| `lib/text.dart` | 3432 | `ParagraphBuilder` ファクトリが `_NativeParagraphBuilder` を使っており Flutter エンジン必須 |
| `lib/pure_dart_implementations.dart` | 203-206 | `drawParagraph()` はコマンドを記録するだけで描画しない |
| `lib/pure_dart_implementations.dart` | 1540-1673 | `_processCommand()` に `drawParagraph` のケースがない |

### 利用可能な基盤

- **ピクセルバッファ**: `Uint8List`（RGBA 32bit、`(y * width + x) * 4` でアクセス）
- **パスラスタライズ**: `_rasterizeComplexPath()` がベジェ曲線→ポリゴン→スキャンライン塗りつぶしを実装済み
- **ヘルパー**: `_fillPolygon()`, `_strokePolyline()`, `_generateCubicBezierPoints()` 等が使える
- **`image` パッケージ**: 既存依存として利用可能

---

## アーキテクチャ設計

### コンポーネント構成

```
lib/
├── src/
│   └── text/
│       ├── ttf_parser.dart          # TTF/OTF ファイルのパーサー
│       ├── glyph_outline.dart       # グリフのアウトラインデータ構造
│       ├── font_metrics.dart        # フォントメトリクス（ascender, descender 等）
│       ├── text_shaper.dart         # 文字列→グリフ列変換（基本的なシェーピング）
│       ├── text_layout.dart         # テキストレイアウトエンジン（行折り返し、整列）
│       └── glyph_rasterizer.dart    # グリフアウトライン→ピクセル変換
├── pure_dart_implementations.dart   # _PureDartParagraph, _PureDartParagraphBuilder 追加
└── text.dart                        # ParagraphBuilder ファクトリ変更
```

### データフロー

```
ParagraphBuilder
  .pushStyle(TextStyle)          # スタイル（フォントファイルパス含む）をスタック積み
  .addText("Hello")              # テキストスパンを追加
  .build()                       # _PureDartParagraph を生成
    ↓
Paragraph.layout(constraints)   # テキストレイアウト計算
  → text_shaper: 文字→グリフID 変換
  → ttf_parser: グリフアウトライン取得
  → text_layout: 行分割, 各グリフの (x, y) 座標決定
    ↓
Canvas.drawParagraph(para, offset)
  → _processCommand() case drawParagraph:
  → glyph_rasterizer: グリフアウトライン → ピクセルバッファへ書き込み
```

---

## TextStyle のフォントファイル指定方法

Flutter の `TextStyle.fontFamily` はフォントファミリ名を受け取るが、pure_ui 環境にはフォントレジストリがない。
`FontLoader` API を追加し、名前→ファイルパスのマッピングを管理する：

```dart
// 使用例
await FontLoader.load('Noto', '/path/to/NotoSans-Regular.ttf');
await FontLoader.load('Noto', '/path/to/NotoSans-Bold.ttf', weight: FontWeight.bold);

final builder = ParagraphBuilder(ParagraphStyle(fontFamily: 'Noto'));
builder.addText('Hello');
final para = builder.build();
para.layout(ParagraphConstraints(width: 300));
canvas.drawParagraph(para, Offset(10, 10));
```

---

## 実装フェーズ

---

### Phase 1: 基盤整備（依存追加・インターフェース定義）

#### タスク 1.1: `pdf` パッケージ依存追加の評価と決定

- `pdf` パッケージ（pub.dev）の TrueType フォント実装（`lib/src/ttf/`）を調査
- ライセンス確認（Apache 2.0）
- 依存追加するか、コードを参考に独自実装するか判断
- `pubspec.yaml` に追加するなら `pdf: ^3.11.0` （または TrueType 部分のみ切り出し可能か確認）

**判断基準**: pdf パッケージが過剰に大きい場合は独自パーサーを実装（タスク 2.x）

#### タスク 1.2: `src/text/` ディレクトリとファイル作成（スケルトン）

各ファイルに空のクラス・インターフェースを定義する。

```dart
// glyph_outline.dart
class GlyphOutline {
  final List<GlyphContour> contours;
  final double advanceWidth;
  final double lsb; // left side bearing
  GlyphOutline({required this.contours, required this.advanceWidth, required this.lsb});
}

class GlyphContour {
  final List<GlyphPoint> points;
  GlyphContour(this.points);
}

class GlyphPoint {
  final double x, y;
  final bool onCurve; // true=直線端点, false=制御点
  GlyphPoint(this.x, this.y, this.onCurve);
}
```

```dart
// font_metrics.dart
class FontMetrics {
  final int unitsPerEm;
  final int ascender;
  final int descender;
  final int lineGap;
  final int capHeight;
  final int xHeight;
  FontMetrics({...});
}
```

#### タスク 1.3: `FontLoader` クラスを `lib/font_loader.dart` に追加

```dart
class FontLoader {
  static final Map<String, Map<FontWeight, String>> _registry = {};

  /// フォントファミリ名とファイルパスを登録する
  static Future<void> load(
    String family,
    String filePath, {
    FontWeight weight = FontWeight.normal,
    FontStyle style = FontStyle.normal,
  }) async { ... }

  /// 登録済みフォントのバイトデータを取得する
  static Uint8List? getFont(String family, FontWeight weight, FontStyle style);
}
```

#### タスク 1.4: `_PureDartParagraph` / `_PureDartParagraphBuilder` スケルトン作成

`lib/pure_dart_implementations.dart` に、`Paragraph` / `ParagraphBuilder` の全メソッドを持つが未実装の（`throw UnimplementedError()`）クラスを追加。

```dart
class _PureDartParagraphBuilder implements ParagraphBuilder {
  final ParagraphStyle _paragraphStyle;
  final List<_TextSpan> _spans = [];
  final List<TextStyle> _styleStack = [];

  _PureDartParagraphBuilder(this._paragraphStyle);

  @override
  void pushStyle(TextStyle style) { ... }

  @override
  void pop() { ... }

  @override
  void addText(String text) { ... }

  @override
  Paragraph build() => _PureDartParagraph(_spans, _paragraphStyle);
}

class _PureDartParagraph implements Paragraph {
  final List<_TextSpan> _spans;
  final ParagraphStyle _paragraphStyle;
  List<_LayoutLine> _layoutLines = [];

  @override
  void layout(ParagraphConstraints constraints) { ... }

  @override
  double get width => ...;
  // ... 他のプロパティ
}
```

#### タスク 1.5: `ParagraphBuilder` ファクトリを変更

`lib/text.dart`:
```dart
// 変更前
factory ParagraphBuilder(ParagraphStyle style) = _NativeParagraphBuilder;

// 変更後
factory ParagraphBuilder(ParagraphStyle style) = _PureDartParagraphBuilder;
```

#### Phase 1 テスト

**ファイル**: `test/text_rendering/phase1_skeleton_test.dart`

```dart
test('ParagraphBuilder can be instantiated', () {
  final builder = ParagraphBuilder(ParagraphStyle());
  expect(builder, isNotNull);
});

test('ParagraphBuilder.build() returns Paragraph', () {
  final builder = ParagraphBuilder(ParagraphStyle());
  builder.addText('Hello');
  final para = builder.build();
  expect(para, isA<Paragraph>());
});

test('Paragraph.layout() does not throw', () {
  final builder = ParagraphBuilder(ParagraphStyle());
  builder.addText('Hello');
  final para = builder.build();
  expect(() => para.layout(const ParagraphConstraints(width: 200)), returnsNormally);
});

test('FontLoader.load() registers font', () async {
  // テスト用フォントファイル（test/fixtures/に置く）
  await FontLoader.load('TestFont', 'test/fixtures/Roboto-Regular.ttf');
  expect(FontLoader.getFont('TestFont', FontWeight.normal, FontStyle.normal), isNotNull);
});
```

---

### Phase 2: TTF パーサー実装

#### タスク 2.1: TTF ファイル構造の読み込み（テーブルディレクトリ）

`lib/src/text/ttf_parser.dart`

TTF はテーブルベースのバイナリフォーマット。最低限必要なテーブル：

| テーブル | 用途 |
|---------|------|
| `head` | ユニット数/em、フォントバージョン |
| `hhea` | 水平メトリクス（ascender, descender, lineGap） |
| `maxp` | グリフ総数 |
| `cmap` | 文字コード → グリフID マッピング |
| `hmtx` | グリフの水平メトリクス（advanceWidth, lsb） |
| `loca` | グリフオフセットテーブル |
| `glyf` | グリフアウトラインデータ |
| `OS/2` | capHeight, xHeight, Unicode レンジ |
| `kern` | カーニングテーブル（オプション） |

```dart
class TtfParser {
  final ByteData _data;
  final Map<String, int> _tableOffsets = {};

  TtfParser(Uint8List bytes) : _data = ByteData.sublistView(bytes);

  void _parseTableDirectory() { ... }
  FontMetrics parseFontMetrics() { ... }
  Map<int, int> parseCmap() { ... }         // codePoint → glyphId
  GlyphOutline? parseGlyph(int glyphId) { ... }
  double getAdvanceWidth(int glyphId) { ... }
}
```

実装ステップ:
1. オフセットテーブル（最初の 12 バイト）のパース
2. テーブルレコード（各テーブルの tag, checksum, offset, length）
3. 各テーブルへのアクセサ実装

#### タスク 2.2: `cmap` テーブルパース（文字コード→グリフID）

- Format 4（BMP Unicode, 最も一般的）の実装
- Format 12（Full Unicode, 補助文字対応）もサポート
- 出力: `Map<int, int>` (codePoint → glyphId)

#### タスク 2.3: `glyf` テーブルパース（グリフアウトライン）

- `loca` テーブルからグリフのオフセット取得
- Simple glyph: 輪郭点の座標と on-curve/off-curve フラグ
- Composite glyph: 複数グリフの合成（アクセント付き文字等）
- TrueType の 2次ベジェ曲線（Quadratic Bézier）を `GlyphOutline` に変換
- 座標は font unit → em 正規化（0.0〜1.0 スケール）

```dart
// TrueType は 2次ベジェ (Quadratic Bézier) を使用
// Flutter の Path は 3次ベジェ (Cubic Bézier) を使用
// 変換: Q(P0, P1, P2) → C(P0, P0+2/3*(P1-P0), P2+2/3*(P1-P2), P2)
```

#### タスク 2.4: `hmtx` テーブルパース（メトリクス）

- グリフごとの `advanceWidth`（次のグリフまでの水平距離）
- `lsb`（left side bearing）
- `FontMetrics` クラスへの格納

#### タスク 2.5: `kern` テーブルパース（カーニング, オプション）

- Format 0 のペアカーニング
- `getKerning(int glyphId1, int glyphId2) → double`
- 存在しない場合は 0 を返す（多くのフォントは GPOS を使うが初期実装は kern のみ）

#### タスク 2.6: `TtfFont` クラス（統合インターフェース）

```dart
class TtfFont {
  final TtfParser _parser;
  final Map<int, int> _cmapCache = {};
  final Map<int, GlyphOutline?> _glyphCache = {};

  static TtfFont load(Uint8List bytes) { ... }

  int? getGlyphId(int codePoint);
  GlyphOutline? getGlyphOutline(int glyphId);
  double getAdvanceWidth(int glyphId, double fontSize);
  double getKerning(int glyphId1, int glyphId2, double fontSize);
  FontMetrics get metrics;
}
```

#### Phase 2 テスト

**ファイル**: `test/text_rendering/ttf_parser_test.dart`

テスト用フォント: Roboto-Regular.ttf または Noto Sans（OFL ライセンス）を `test/fixtures/` に配置

```dart
late TtfFont font;

setUpAll(() {
  final bytes = File('test/fixtures/Roboto-Regular.ttf').readAsBytesSync();
  font = TtfFont.load(bytes);
});

test('parseFontMetrics returns valid unitsPerEm', () {
  expect(font.metrics.unitsPerEm, greaterThan(0));
  expect(font.metrics.unitsPerEm, anyOf(1000, 2048)); // 一般的な値
});

test('parseFontMetrics ascender > 0, descender < 0', () {
  expect(font.metrics.ascender, greaterThan(0));
  expect(font.metrics.descender, lessThan(0));
});

test('getGlyphId returns valid id for ASCII characters', () {
  final idA = font.getGlyphId('A'.codeUnitAt(0));
  final idZ = font.getGlyphId('Z'.codeUnitAt(0));
  expect(idA, isNotNull);
  expect(idZ, isNotNull);
  expect(idA, isNot(equals(idZ)));
});

test('getGlyphId returns null for unmapped codepoint', () {
  final id = font.getGlyphId(0xFFFFFF); // 存在しない文字
  expect(id, isNull);
});

test('getGlyphOutline returns contours for letter A', () {
  final glyphId = font.getGlyphId('A'.codeUnitAt(0))!;
  final outline = font.getGlyphOutline(glyphId);
  expect(outline, isNotNull);
  expect(outline!.contours, isNotEmpty);
});

test('getAdvanceWidth returns positive value', () {
  final glyphId = font.getGlyphId('A'.codeUnitAt(0))!;
  final advance = font.getAdvanceWidth(glyphId, 16.0);
  expect(advance, greaterThan(0));
});

test('composite glyph (e.g. é) is resolved correctly', () {
  final id = font.getGlyphId('é'.codeUnitAt(0)); // U+00E9
  if (id != null) {
    final outline = font.getGlyphOutline(id);
    expect(outline, isNotNull);
  }
});
```

---

### Phase 3: グリフラスタライザー実装

#### タスク 3.1: グリフアウトラインの `Path` 変換

`lib/src/text/glyph_rasterizer.dart`

```dart
Path glyphOutlineToPath(GlyphOutline outline, double fontSize, double x, double y) {
  final scale = fontSize / font.metrics.unitsPerEm;
  final path = Path();
  for (final contour in outline.contours) {
    // TrueType 2次ベジェ → Path の cubicTo（3次ベジェ）に変換
    // on-curve 点と off-curve 点を処理
  }
  return path;
}
```

TrueType 2次ベジェ変換ルール:
- on-curve 間に off-curve が 1 つ → `quadraticBezierTo`（Path に追加）
- on-curve 間に off-curve が 2 つ連続 → 間の点を on-curve として補間

#### タスク 3.2: グリフのピクセルバッファへの直接レンダリング

既存の `_rasterizeComplexPath()` を活用：
- `glyphOutlineToPath()` で生成した `Path` を既存のラスタライザーに渡す
- `Paint` を生成（`color` は `TextStyle.color` から）
- フォントサイズに応じたスケール変換（`Matrix4` の積み）

```dart
void rasterizeGlyph(
  GlyphOutline outline,
  TtfFont font,
  double fontSize,
  Color color,
  Offset position,
  Uint8List pixels,
  int canvasWidth,
  int canvasHeight,
) { ... }
```

#### タスク 3.3: アンチエイリアシング

既存の `_drawCircleAt()` はアンチエイリアスを実装済み。グリフラスタライズにも適用：
- サブピクセルカバレッジ計算（または MSAA: 4x スーパーサンプリング）
- アルファブレンディング: `dst_alpha = src_alpha + dst_alpha * (1 - src_alpha)`

#### タスク 3.4: カラー適用とアルファブレンド

```dart
void _blendPixel(Uint8List pixels, int idx, Color color, double coverage) {
  final srcA = (color.alpha / 255.0) * coverage;
  final dstA = pixels[idx + 3] / 255.0;
  final outA = srcA + dstA * (1 - srcA);
  if (outA == 0) return;
  pixels[idx]     = ((color.red   * srcA + pixels[idx]     * dstA * (1 - srcA)) / outA).round();
  pixels[idx + 1] = ((color.green * srcA + pixels[idx + 1] * dstA * (1 - srcA)) / outA).round();
  pixels[idx + 2] = ((color.blue  * srcA + pixels[idx + 2] * dstA * (1 - srcA)) / outA).round();
  pixels[idx + 3] = (outA * 255).round();
}
```

#### Phase 3 テスト

**ファイル**: `test/text_rendering/glyph_rasterizer_test.dart`

```dart
test('single glyph A renders non-zero pixels', () {
  final pixels = Uint8List(64 * 64 * 4); // 64x64 透明バッファ
  final font = TtfFont.load(File('test/fixtures/Roboto-Regular.ttf').readAsBytesSync());
  final glyphId = font.getGlyphId('A'.codeUnitAt(0))!;
  final outline = font.getGlyphOutline(glyphId)!;

  rasterizeGlyph(outline, font, 32.0, Color(0xFF000000), Offset(8, 8), pixels, 64, 64);

  // ピクセルが 1 つ以上書き込まれている
  final nonZero = pixels.where((b) => b > 0).length;
  expect(nonZero, greaterThan(0));
});

test('glyph I is narrower than glyph W', () {
  // レンダリング後の非透明ピクセルの水平幅を比較
  ...
});

test('color is applied correctly to glyph', () {
  // 赤(0xFFFF0000)でグリフ描画後、赤チャンネルのみが非ゼロであることを確認
  ...
});

test('alpha blending works on non-transparent background', () {
  // 白背景に黒グリフを描画した場合、グレーのアンチエイリアスが生成される
  ...
});

test('glyphOutlineToPath produces valid Path', () {
  final font = TtfFont.load(...);
  final glyphId = font.getGlyphId('A'.codeUnitAt(0))!;
  final outline = font.getGlyphOutline(glyphId)!;
  final path = glyphOutlineToPath(outline, 16.0, 0, 0);
  // Path が空でないことを確認（bounds をチェック）
  final bounds = path.getBounds();
  expect(bounds.width, greaterThan(0));
});
```

---

### Phase 4: テキストシェーパー実装

#### タスク 4.1: 文字列→グリフ列変換

`lib/src/text/text_shaper.dart`

```dart
class ShapedGlyph {
  final int glyphId;
  final double advanceWidth; // px 単位（fontSize 適用済み）
  final double xOffset;      // カーニング等の調整
  final double yOffset;
  final TextStyle style;
  ShapedGlyph({...});
}

List<ShapedGlyph> shapeText(String text, TextStyle style, TtfFont font) {
  final glyphs = <ShapedGlyph>[];
  final fontSize = style.fontSize ?? 14.0;

  for (int i = 0; i < text.length; i++) {
    final codePoint = text.codeUnitAt(i);
    // サロゲートペア処理
    final glyphId = font.getGlyphId(codePoint) ?? font.getGlyphId(0xFFFD)!; // .notdef
    final advance = font.getAdvanceWidth(glyphId, fontSize);

    // カーニング
    double kernAdj = 0;
    if (i > 0) {
      final prevGlyphId = glyphs.last.glyphId;
      kernAdj = font.getKerning(prevGlyphId, glyphId, fontSize);
    }

    glyphs.add(ShapedGlyph(glyphId: glyphId, advanceWidth: advance + kernAdj, ...));
  }
  return glyphs;
}
```

#### タスク 4.2: サロゲートペア・絵文字対応

```dart
// Dart の String は UTF-16。サロゲートペアの codePoint を正しく取得する
int fullCodePoint(String text, int index) {
  final unit = text.codeUnitAt(index);
  if (unit >= 0xD800 && unit <= 0xDBFF && index + 1 < text.length) {
    final low = text.codeUnitAt(index + 1);
    if (low >= 0xDC00 && low <= 0xDFFF) {
      return 0x10000 + ((unit - 0xD800) << 10) + (low - 0xDC00);
    }
  }
  return unit;
}
```

#### タスク 4.3: `letterSpacing`, `wordSpacing` の適用

- `TextStyle.letterSpacing`: 各グリフの `advanceWidth` に加算
- `TextStyle.wordSpacing`: スペース文字（U+0020）の advanceWidth に加算

#### Phase 4 テスト

**ファイル**: `test/text_rendering/text_shaper_test.dart`

```dart
test('shapeText returns one ShapedGlyph per character', () {
  final font = TtfFont.load(...);
  final style = TextStyle(fontSize: 16.0);
  final glyphs = shapeText('ABC', style, font);
  expect(glyphs.length, 3);
});

test('all advance widths are positive', () {
  final glyphs = shapeText('Hello', TextStyle(fontSize: 16.0), font);
  for (final g in glyphs) {
    expect(g.advanceWidth, greaterThan(0));
  }
});

test('letterSpacing increases advance width', () {
  final base = shapeText('A', TextStyle(fontSize: 16.0), font);
  final spaced = shapeText('A', TextStyle(fontSize: 16.0, letterSpacing: 5.0), font);
  expect(spaced.first.advanceWidth, greaterThan(base.first.advanceWidth));
});

test('surrogate pair codepoint is resolved correctly', () {
  // U+1F600 😀 (requires surrogate pair in Dart String)
  final text = '😀';
  final glyphs = shapeText(text, TextStyle(fontSize: 16.0), font);
  expect(glyphs.length, 1); // 1 グリフ（サロゲートペアを 1 文字として）
});
```

---

### Phase 5: テキストレイアウトエンジン実装

#### タスク 5.1: 行分割アルゴリズム

`lib/src/text/text_layout.dart`

```dart
class LayoutLine {
  final List<ShapedGlyph> glyphs;
  final double width;       // 実際の行幅
  final double baseline;    // キャンバス座標系でのベースライン Y
  final double ascent;
  final double descent;
  LayoutLine({...});
}

List<LayoutLine> layoutText(
  List<_TextSpan> spans,
  TtfFont font,
  ParagraphStyle paragraphStyle,
  ParagraphConstraints constraints,
) {
  // 1. 各スパンをシェーピング → ShapedGlyph 列に変換
  // 2. maxWidth を超えたら改行（greedy アルゴリズム）
  // 3. \n でも強制改行
  // 4. TextAlign に応じた X オフセット計算
}
```

#### タスク 5.2: 行の高さ計算

```dart
// 1 行の高さ = ascender + |descender| + lineGap（font unit からスケール）
// TextStyle.height が指定されている場合: fontSize * height
double lineHeight(FontMetrics metrics, double fontSize, double? styleHeight) {
  if (styleHeight != null) return fontSize * styleHeight;
  final scale = fontSize / metrics.unitsPerEm;
  return (metrics.ascender - metrics.descender + metrics.lineGap) * scale;
}
```

#### タスク 5.3: `TextAlign` の適用

```dart
double xOffsetForLine(LayoutLine line, double maxWidth, TextAlign align) {
  return switch (align) {
    TextAlign.left   => 0.0,
    TextAlign.right  => maxWidth - line.width,
    TextAlign.center => (maxWidth - line.width) / 2,
    TextAlign.justify => 0.0, // TODO: ジャスティファイは Phase 5 拡張
    _ => 0.0,
  };
}
```

#### タスク 5.4: `maxLines` と `ellipsis` の処理

- `ParagraphStyle.maxLines` を超えたら残りの行を切り捨て
- `ParagraphStyle.ellipsis` が設定されている場合、最終行の末尾に省略記号を挿入
  - 省略記号を挿入しても maxWidth を超えないよう末尾グリフを削除

#### タスク 5.5: `Paragraph` プロパティの計算

`layout()` 完了後に以下を計算:
- `width`: `constraints.width`
- `height`: 全行の高さの合計
- `longestLine`: 最大行幅
- `alphabeticBaseline`: 第 1 行のベースライン位置
- `minIntrinsicWidth`: 最も長い単語 1 つが入る最小幅
- `maxIntrinsicWidth`: 折り返しなしの全幅

#### Phase 5 テスト

**ファイル**: `test/text_rendering/text_layout_test.dart`

```dart
test('single line text does not wrap when width is sufficient', () {
  final para = buildParagraph('Hello', width: 500);
  para.layout(const ParagraphConstraints(width: 500));
  expect(para.computeLineMetrics().length, 1);
});

test('long text wraps to multiple lines', () {
  final longText = 'This is a long text that should wrap to multiple lines.';
  final para = buildParagraph(longText, width: 100);
  para.layout(const ParagraphConstraints(width: 100));
  expect(para.computeLineMetrics().length, greaterThan(1));
});

test('newline character forces line break', () {
  final para = buildParagraph('Line1\nLine2', width: 500);
  para.layout(const ParagraphConstraints(width: 500));
  expect(para.computeLineMetrics().length, 2);
});

test('height is positive after layout', () {
  final para = buildParagraph('Hello', width: 200);
  para.layout(const ParagraphConstraints(width: 200));
  expect(para.height, greaterThan(0));
});

test('maxLines limits number of lines', () {
  final longText = 'a b c d e f g h i j k l m n o p q r s t u v w x y z';
  final para = buildParagraph(longText, width: 50, maxLines: 2);
  para.layout(const ParagraphConstraints(width: 50));
  expect(para.computeLineMetrics().length, lessThanOrEqualTo(2));
});

test('textAlign center places text in center', () {
  final para = buildParagraph('Hi', width: 200, textAlign: TextAlign.center);
  para.layout(const ParagraphConstraints(width: 200));
  final metrics = para.computeLineMetrics();
  // 中央配置の場合、left > 0 であるはず（短いテキストなら）
  expect(metrics.first.left, greaterThan(0));
});

test('alphabeticBaseline is positive and less than height', () {
  final para = buildParagraph('Hello', width: 200);
  para.layout(const ParagraphConstraints(width: 200));
  expect(para.alphabeticBaseline, greaterThan(0));
  expect(para.alphabeticBaseline, lessThan(para.height));
});

test('ellipsis is appended when text exceeds maxLines', () {
  // didExceedMaxLines が true になることを確認
  final para = buildParagraph('This is a very long text', width: 50, maxLines: 1, ellipsis: '...');
  para.layout(const ParagraphConstraints(width: 50));
  expect(para.didExceedMaxLines, isTrue);
});
```

---

### Phase 6: Canvas への統合

#### タスク 6.1: `_processCommand()` に `drawParagraph` ケースを追加

`lib/pure_dart_implementations.dart`

```dart
case _DrawCommandType.drawParagraph:
  final paragraph = args[0] as _PureDartParagraph;
  final offset = args[1] as Offset;
  _renderParagraph(paragraph, offset, pixels, width, height, transform);
  break;
```

#### タスク 6.2: `_renderParagraph()` の実装

```dart
void _renderParagraph(
  _PureDartParagraph paragraph,
  Offset offset,
  Uint8List pixels,
  int canvasWidth,
  int canvasHeight,
  Matrix4 transform,
) {
  for (final line in paragraph.layoutLines) {
    for (final glyph in line.glyphs) {
      final outline = glyph.font.getGlyphOutline(glyph.glyphId);
      if (outline == null) continue;

      final glyphX = offset.dx + glyph.x;
      final glyphY = offset.dy + glyph.y; // baseline 基準

      rasterizeGlyph(
        outline,
        glyph.font,
        glyph.style.fontSize ?? 14.0,
        glyph.style.color ?? const Color(0xFF000000),
        Offset(glyphX, glyphY),
        pixels,
        canvasWidth,
        canvasHeight,
      );
    }
  }
}
```

#### タスク 6.3: テキストデコレーション描画

`TextStyle.decoration` に応じて下線・打ち消し線・上線を描画：
- `TextDecoration.underline`: ベースライン+1px に水平線
- `TextDecoration.lineThrough`: グリフ中央（x-height の半分）に水平線
- `TextDecoration.overline`: ascender に水平線
- `decorationColor`, `decorationThickness`, `decorationStyle` も考慮

#### タスク 6.4: テキストシャドウ描画

`TextStyle.shadows` が設定されている場合：
- 各シャドウについてグリフを先に描画（オフセット・ぼかし適用）
- ぼかしは Gaussian blur（`blurRadius`）→ 既存の `image` パッケージの `gaussianBlur` 利用可能

#### Phase 6 テスト（統合テスト）

**ファイル**: `test/text_rendering/canvas_text_integration_test.dart`

```dart
Future<_PureDartImage> renderText(String text, {
  double fontSize = 16.0,
  Color color = const Color(0xFF000000),
  double canvasWidth = 200,
  double canvasHeight = 60,
}) async {
  await FontLoader.load('Test', 'test/fixtures/Roboto-Regular.ttf');

  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasWidth, canvasHeight));

  final builder = ParagraphBuilder(
    ParagraphStyle(fontFamily: 'Test', fontSize: fontSize),
  );
  builder.pushStyle(TextStyle(color: color, fontSize: fontSize));
  builder.addText(text);
  final para = builder.build();
  para.layout(ParagraphConstraints(width: canvasWidth));
  canvas.drawParagraph(para, const Offset(0, 0));

  return await recorder.endRecording().toImage(canvasWidth.toInt(), canvasHeight.toInt());
}

test('drawParagraph produces non-transparent pixels', () async {
  final image = await renderText('Hello');
  final pixels = await image.toByteData();
  final nonZeroAlpha = List.generate(image.width * image.height, (i) => pixels!.getUint8(i * 4 + 3))
      .where((a) => a > 0)
      .length;
  expect(nonZeroAlpha, greaterThan(0));
  image.dispose();
});

test('text color red produces only red channel pixels', () async {
  final image = await renderText('A', color: Color(0xFFFF0000));
  final pixels = await image.toByteData();
  bool hasRedPixel = false;
  for (int i = 0; i < image.width * image.height; i++) {
    final r = pixels!.getUint8(i * 4);
    final g = pixels.getUint8(i * 4 + 1);
    final b = pixels.getUint8(i * 4 + 2);
    if (r > 128 && g < 64 && b < 64) {
      hasRedPixel = true;
      break;
    }
  }
  expect(hasRedPixel, isTrue);
  image.dispose();
});

test('larger font produces taller rendered area', () async {
  final small = await renderText('A', fontSize: 12, canvasHeight: 100);
  final large = await renderText('A', fontSize: 32, canvasHeight: 100);

  int countNonTransparent(Image img) { ... }
  expect(countNonTransparent(large), greaterThan(countNonTransparent(small)));
});

test('multiple drawParagraph calls stack correctly', () async {
  await FontLoader.load('Test', 'test/fixtures/Roboto-Regular.ttf');
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 200, 100));

  for (final (text, y) in [('Line1', 0.0), ('Line2', 30.0)]) {
    final builder = ParagraphBuilder(ParagraphStyle(fontFamily: 'Test'));
    builder.addText(text);
    final para = builder.build();
    para.layout(const ParagraphConstraints(width: 200));
    canvas.drawParagraph(para, Offset(0, y));
  }

  final image = await recorder.endRecording().toImage(200, 100);
  expect(image.width, 200);
  image.dispose();
});

test('drawParagraph respects Canvas transform (translate)', () async {
  // translate 後にテキストを描画し、正しい位置にピクセルがあることを確認
  ...
});
```

---

### Phase 7: マルチスタイルスパン対応

#### タスク 7.1: `pushStyle` / `pop` によるスタイルスタック

複数スタイルのテキスト（太字 + 通常の混在等）を 1 つの Paragraph に含められるようにする。

```dart
void main() {
  final builder = ParagraphBuilder(ParagraphStyle(fontFamily: 'Noto'));
  builder.addText('Normal ');
  builder.pushStyle(TextStyle(fontWeight: FontWeight.bold));
  builder.addText('Bold');
  builder.pop();
  builder.addText(' Normal again');
  final para = builder.build();
}
```

実装:
- `_TextSpan` に `TextStyle` を保持させる
- `pushStyle` は現在スタックの top と merge したスタイルを積む
- `pop` はスタックから取り出す
- `build()` 時点のスタイルスタック状態でスパンを確定

#### タスク 7.2: スタイルが異なるスパンの行分割処理

行分割は複数スパンをまたいで計算する必要がある。
スパン境界で折り返しが発生した場合の処理を実装。

#### Phase 7 テスト

**ファイル**: `test/text_rendering/multi_style_test.dart`

```dart
test('bold text uses bold font variant', () async {
  await FontLoader.load('Test', 'test/fixtures/Roboto-Regular.ttf');
  await FontLoader.load('Test', 'test/fixtures/Roboto-Bold.ttf', weight: FontWeight.bold);

  final builder = ParagraphBuilder(ParagraphStyle(fontFamily: 'Test'));
  builder.pushStyle(TextStyle(fontWeight: FontWeight.bold));
  builder.addText('Bold');
  final para = builder.build();
  para.layout(const ParagraphConstraints(width: 200));

  // Bold テキストは Regular より幅が広い
  final builderRegular = ParagraphBuilder(ParagraphStyle(fontFamily: 'Test'));
  builderRegular.addText('Bold');
  final paraRegular = builderRegular.build();
  paraRegular.layout(const ParagraphConstraints(width: 200));

  expect(para.longestLine, greaterThan(paraRegular.longestLine));
});

test('mixed style span widths sum correctly', () {
  final builder = ParagraphBuilder(ParagraphStyle(fontFamily: 'Test'));
  builder.addText('Hello ');
  builder.pushStyle(TextStyle(fontSize: 24.0));
  builder.addText('Big');
  final para = builder.build();
  para.layout(const ParagraphConstraints(width: 500));
  expect(para.longestLine, greaterThan(0));
});
```

---

### Phase 8: パフォーマンス最適化

#### タスク 8.1: グリフキャッシュ

同じフォント・サイズのグリフは一度ラスタライズしたら `Map<GlyphCacheKey, Uint8List>` にキャッシュ。

```dart
class GlyphCache {
  final Map<String, Uint8List> _cache = {};
  String _key(String fontFamily, int glyphId, double fontSize, Color color) =>
    '$fontFamily-$glyphId-$fontSize-${color.value}';
}
```

#### タスク 8.2: `TtfFont` のロード済みキャッシュ

同じファイルパスのフォントを `FontLoader` 内でキャッシュし、複数回パースしない。

#### タスク 8.3: アウトライン変換キャッシュ

`GlyphOutline` → `Path` 変換結果をキャッシュ（フォントサイズごとに保持）。

---

## テスト用フィクスチャ

`test/fixtures/` に以下を配置（OFL ライセンス フォント）:

| ファイル | 用途 |
|---------|------|
| `Roboto-Regular.ttf` | 基本テスト |
| `Roboto-Bold.ttf` | マルチスタイルテスト |
| `NotoSans-Regular.ttf` | Unicode・日本語テスト |

取得方法:
```bash
# Google Fonts から取得 (OFL ライセンス)
curl -L "https://fonts.gstatic.com/s/roboto/v32/KFOmCnqEu92Fr1Mu4mxKKTU1Kg.woff2" -o test/fixtures/Roboto-Regular.ttf
```

---

## 実装順序サマリー

```
Phase 1: 基盤整備（依存・インターフェース・ファクトリ変更）  ← まずここ
  └─ ParagraphBuilder が pure Dart を向くようになる

Phase 2: TTF パーサー（バイナリ解析）
  └─ フォントファイルからグリフアウトラインを取得できる

Phase 3: グリフラスタライザー（アウトライン→ピクセル）
  └─ 単体グリフが正しく描画できる

Phase 4: テキストシェーパー（文字列→グリフ列）
  └─ 文字列をグリフ座標に変換できる

Phase 5: テキストレイアウトエンジン（行折り返し・整列）
  └─ 複数行・TextAlign が機能する

Phase 6: Canvas 統合（drawParagraph でピクセルに書き込む）  ← ここで動作確認できる
  └─ Canvas.drawParagraph() が実際に画像を生成する

Phase 7: マルチスタイルスパン対応
  └─ pushStyle/pop が機能する

Phase 8: パフォーマンス最適化
  └─ キャッシュ導入
```

---

## 懸念点・制約

| 項目 | 内容 |
|------|------|
| HarfBuzz 相当のシェーピング | アラビア語・インド系文字の複雑なシェーピングは対応外（Latin/日本語/CJK は対応） |
| GPOS/GSUB テーブル | OpenType の高度な機能は初期実装では未対応（kern テーブルのみ） |
| CFF フォント | PostScript ベースの CFF グリフ（.otf の一部）は対応外（TrueType glyf のみ） |
| フォントファイル配布 | エンドユーザーがフォントファイルを用意する必要がある |
| テキスト選択・IME | pure_ui はキャンバス描画のみのため範囲外 |
