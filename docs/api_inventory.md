# API Inventory & Coverage (P0 audit)

Status of the `dart:ui` ↔ `pure_ui` switching architecture
(see `pure_ui_switching_architecture_plan.md`). This is the P0 audit
deliverable and the running coverage tracker.

## Target versions (plan §11 resolution)

| Item | Decision |
|---|---|
| Flutter (for `dart_ui_adapter`) | `>=3.0.0` (mise pins 3.44.2 for dev) |
| Dart SDK | `^3.5.0` (workspace tooling needs 3.6+, root pins `>=3.11.0`) |
| `Color` model | Wide-gamut: `Color.from`, `withValues`, double `a/r/g/b` channels (matches current pure_ui) |
| `pure_ui` ↔ interface coupling | **Adapter** (`pure_ui_adapter`), not direct `implements` — keeps pure_ui's standalone drop-in untouched (plan §2.1 option, §6.0) |
| Switch granularity | Global default **and** `Zone` scope (`UiBackend.runWith`) |
| Package names | `dart_ui_interface` / `dart_ui_wrapper` / `dart_ui_adapter` / `pure_ui_adapter` / `dart_ui_conformance` |

## Packages

| Package | Flutter | Role | State |
|---|:---:|---|---|
| `dart_ui_interface` | ✗ | value types, enums, `UiBackend`, abstract resource types, top-level fns | ✅ implemented + tested |
| `pure_ui_adapter` | ✗ | `PureUiBackend` (adapts pure_ui) | ✅ implemented + tested |
| `dart_ui_wrapper` | ✗ | `ui.dart` drop-in surface + switch API | ✅ implemented |
| `dart_ui_adapter` | ✔ | `DartUiBackend` (adapts `dart:ui`) | ⚠️ implemented (drawing + text + shaders + filters), **untested here** (needs Flutter SDK) |
| `dart_ui_conformance` | dev | backend-agnostic parity tests | ✅ green on pure_ui backend (drawing + shaders + text) |

## Coverage matrix

Legend: ✅ routed through `UiBackend` and conformance-tested · 🟡 defined but not
yet wired · ⛔ out of scope / `UnsupportedError` on at least one backend.

### Value types (interface layer, concrete, `const` preserved — §1.3)
`Offset` ✅ · `Size` ✅ · `Rect` ✅ · `RRect` ✅ · `Radius` ✅ · `Color` ✅
· `Shadow` ✅ · `LineMetrics` ✅ · `ParagraphConstraints` ✅
· `RSTransform` 🟡 · `RSuperellipse` 🟡

### Enums / constant classes (interface layer, explicit mapping — §4.2)
`BlendMode` ✅ · `PaintingStyle` ✅ · `StrokeCap` ✅ · `StrokeJoin` ✅ ·
`BlurStyle` ✅ · `FilterQuality` ✅ · `Clip` 🟡 · `ClipOp` ✅ ·
`PathFillType` ✅ · `PathOperation` 🟡 · `VertexMode` ✅ · `PointMode` ✅ ·
`TileMode` ✅ · `PixelFormat` ✅ · `ImageByteFormat` ✅ ·
`TextAlign` ✅ · `TextDirection` ✅ · `TextBaseline` ✅ ·
`TextDecoration` ✅ · `TextDecorationStyle` ✅ · `TextLeadingDistribution` ✅ ·
`FontStyle` ✅ · `FontWeight` ✅

### Resource types (abstract + factory dispatch — §4.3)
| Type | State |
|---|---|
| `Paint` | ✅ all getters/setters incl. `shader`/`colorFilter`/`imageFilter`/`maskFilter` |
| `Path` | ✅ moveTo/lineTo/curves/arc/add*/contains/bounds/shift/transform |
| `Canvas` | ✅ draw{Rect,RRect,DRRect,Oval,Circle,Arc,Line,Path,Image,ImageRect,ImageNine,Points,Color,Paint,Picture,Paragraph,RawAtlas,Vertices,Shadow}, save/restore/transform/clip* |
| `PictureRecorder` | ✅ |
| `Picture` | ✅ toImage/toImageSync/dispose |
| `Image` | ✅ width/height/clone/isCloneOf/toByteData/dispose |
| `Shader` / `Gradient` | ✅ linear/radial/sweep (pure_ui + dart:ui) |
| `ImageShader` | 🟡 |
| `ColorFilter` | ✅ (dart:ui) · ⛔ pure_ui throws — no engine to call |
| `ImageFilter` (blur) | ✅ (dart:ui) · ⛔ pure_ui throws |
| `MaskFilter` (blur) | ✅ both backends |
| `Vertices` | ✅ (dart:ui) · ⛔ pure_ui throws — rasterizer has no handler |
| `FragmentProgram` / `FragmentShader` | ⛔ pure_ui throws |
| `ParagraphBuilder` / `Paragraph` | ✅ both backends |
| `TextStyle` / `ParagraphStyle` / `StrutStyle` | ✅ data classes in interface |
| `FontLoader` | ✅ `Future<void> FontLoader.load(family, bytes)` on both |
| `PathMetric(s)` / `Tangent` | 🟡 |
| `Codec` / `FrameInfo` / `ImageDescriptor` / `ImmutableBuffer` | 🟡 |

### Top-level functions (§4.4)
`lerpDouble` ✅ · `clampDouble` ✅ · `decodeImageFromPixels` ✅ (backend) ·
`instantiateImageCodec` / `decodeImageFromList` 🟡

### `BackendFeature` capability flags
`drawing`, `imageCodec`, `text`, `shaders`, `atlas` — true on both backends.
`imageFilters`, `vertices`, `drawShadow`, `fragmentShaders` — false on pure_ui,
true on dart:ui. Gate optional features with
`UiBackend.instance.supports(BackendFeature.X)`.

### Out of scope (§4.5)
`PlatformDispatcher`, `FlutterView`, `window`, `Display`, `Semantics*`,
`PointerData*`, `KeyData`, `ChannelBuffers`.

## pure_ui current coverage (audit notes)

`pure_ui` already mirrors `dart:ui` closely: it ships an internal abstract /
concrete split (`Canvas`/`_PureDartCanvas`, `Path`/`_PureDartPath`,
`Picture`, `PictureRecorder`, `Codec`, `ImageDescriptor`) plus concrete
`Paint`, `Image`, full text pipeline (`Paragraph*`, TTF shaping/layout) and
`Gradient`/`Shader`/`ImageShader`. `FragmentProgram`/`FragmentShader` exist as
stubs over `NativeFieldWrapperClass1`. The wide-gamut `Color` is already in
place. This made the **adapter** approach low-risk: the interface mirrors
`dart:ui`, and `pure_ui_adapter` translates value types at the boundary only.

A few apparent capabilities in pure_ui are stub-only and require honest
rejection from `pure_ui_adapter`:

- `Paint.colorFilter=` and `Paint.imageFilter=` route through native FFI
  (`ColorFilter::Create` / `ImageFilter::Create`) that isn't resolvable in a
  plain Dart VM, so `PureUiBackend` throws `UnsupportedError` on
  `createColorFilterMode` / `createColorFilterMatrix` / `createBlurFilter`.
- `Canvas.drawVertices` and `Canvas.drawShadow` get recorded as commands but
  the rasterizer has no handler — both throw on the pure_ui adapter rather
  than rendering nothing.
- `Vertices(...)` extends `NativeFieldWrapperClass1`; its constructor calls an
  external init that doesn't resolve in plain Dart — refused via
  `createVertices`.

These are reported through `BackendFeature.supports(...)` so portable code can
branch up front.

## Next steps (plan §12 horizontal expansion)
1. Image codecs (`instantiateImageCodec`, `Codec`, `FrameInfo`).
2. ImageShader (Image-backed `Shader`).
3. Run conformance under Flutter against `DartUiBackend`; add golden tests
   with tolerance (§7.2).
4. Reimplement pure_ui's `drawVertices` / `drawShadow` / `ColorFilter` /
   `ImageFilter` in pure Dart so `PureUiBackend` can drop the `UnsupportedError`
   refusals.
5. CI lint: forbid direct `import 'dart:ui'` outside `dart_ui_adapter` (§6.3).
