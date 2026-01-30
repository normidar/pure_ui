# CLAUDE.md - Pure UI Codebase Guide for AI Assistants

This guide provides comprehensive information about the Pure UI repository structure, development workflows, and conventions for AI assistants and developers.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Repository Structure](#repository-structure)
3. [Development Environment Setup](#development-environment-setup)
4. [Code Conventions and Style](#code-conventions-and-style)
5. [Testing Practices](#testing-practices)
6. [Build and Deployment](#build-and-deployment)
7. [Architecture and Key Components](#architecture-and-key-components)
8. [Common Workflows](#common-workflows)
9. [Dependencies and Versions](#dependencies-and-versions)
10. [CI/CD and Automation](#cicd-and-automation)
11. [Tips and Best Practices](#tips-and-best-practices)

---

## Project Overview

### What is Pure UI?

**Pure UI** is a pure Dart implementation of Flutter's `dart:ui` Canvas API that works in environments outside Flutter (servers, CLI, batch processing). It provides complete Canvas drawing capabilities without requiring a Flutter runtime.

**Key Purpose:** Enable Canvas-based graphics programming in pure Dart environments, allowing the same drawing code to work in Flutter apps and standalone Dart applications.

**Repository:** https://github.com/normidar/pure_ui

**Current Version:** 0.1.4 (MIT License, 2025)

### Core Capabilities

- ✅ Complete Canvas API with drawing operations (lines, circles, rects, paths, arcs)
- ✅ Path support with Bézier curves (quadraticBezierTo, cubicTo)
- ✅ Canvas transformations (translate, rotate, scale, skew, save/restore)
- ✅ Clipping operations (rect clips and path clips)
- ✅ Color management with ARGB color support
- ✅ PNG image export via `exportImage()` helper
- ✅ Picture recording and playback for deferred rendering
- ✅ Proper resource disposal patterns with dispose()
- ✅ Gradient painting (linear, radial, sweep)

### Planned Features

- Text drawing functionality
- Extended image blend modes
- Performance optimizations
- Improved anti-aliasing algorithms

---

## Repository Structure

### Top-Level Files and Directories

```
/home/user/pure_ui/
├── .fvmrc                      # Flutter Version Manager config (v3.35.2)
├── .github/
│   ├── workflows/
│   │   └── check.yml           # CI/CD pipeline (analyze, validate)
│   └── dependabot.yml          # Automated dependency updates config
├── .gitignore                  # Git ignore patterns
├── .vscode/settings.json       # VSCode editor configuration
├── lib/                        # Source code (26,112 lines, ~962 KB)
├── test/                       # Test files (1,882 lines, ~70 KB)
├── example/                    # Example implementation
├── Makefile                    # Build and development automation
├── pubspec.yaml                # Dart package manifest
├── build.yaml                  # Build runner configuration
├── README.md                   # User-facing documentation
├── CHANGELOG.md                # Release history and version notes
├── LICENSE                     # MIT License
└── CLAUDE.md                   # This file - AI assistant guide
```

### lib/ Directory - Source Code Organization

The main library is organized as a single `dart.ui` library with 21 part files:

```
lib/
├── pure_ui.dart                # Main library entry point (~33 lines)
├── annotations.dart            # Native/FFI annotations (~50 lines)
├── geometry.dart               # Geometric types (Rect, Offset, Size, etc.) (~2,100 lines)
├── painting.dart               # Core painting API - LARGEST FILE (~10,000 lines)
│                               # Contains: Paint, Canvas, Path, Color, Gradient, etc.
├── pure_dart_implementations.dart  # Pure Dart implementations (~1,900 lines)
│                               # Contains: _PureDartCanvas, _DrawCommand, _PureDartImage
├── compositing.dart            # Scene and render tree operations (~1,200 lines)
├── text.dart                   # Text rendering stubs (~4,700 lines)
├── platform_dispatcher.dart    # Platform information access (~4,000 lines)
├── semantics.dart              # Accessibility/semantics support (~2,500 lines)
├── pointer.dart                # Pointer events and input (~550 lines)
├── channel_buffers.dart        # Platform channel communication (~850 lines)
├── window.dart                 # Window and view management (~1,600 lines)
├── hash.dart                   # Hashing utilities (~400 lines)
├── dart_ui.dart                # Platform-specific overrides (~300 lines)
└── [10 more supporting files]  # Various other modules
```

### test/ Directory - Test Organization

```
test/
├── pure_ui_test.dart           # Basic type and color tests
├── complex_canvas_test.dart    # Advanced drawing and transformations
├── types_integration_test.dart # Comprehensive type system tests
├── picture_recorder_test.dart  # Picture recording functionality
├── cubic_to_test.dart          # Cubic Bézier curve tests
├── drawpath_color_bug_test.dart # Path color regression tests
├── gradient_test.dart          # Gradient painting tests
└── k_line_test.dart            # K-line chart rendering tests
```

---

## Development Environment Setup

### Prerequisites

1. **Dart SDK:** 3.3.0 or later
2. **Flutter:** 3.35.2 (managed via FVM)
3. **FVM (Flutter Version Manager):** For managing Flutter versions
4. **VSCode:** Recommended editor with Dart extension

### Initial Setup

```bash
# 1. Clone the repository
git clone https://github.com/normidar/pure_ui.git
cd pure_ui

# 2. Install FVM (if not already installed)
brew install fvm  # macOS
# or use your OS's package manager

# 3. Get Dart dependencies
dart pub get
# or
fvm flutter pub get

# 4. Build the library (runs build_runner)
make build
# or manually:
dart run build_runner build --delete-conflicting-outputs
```

### VSCode Configuration

The project includes VSCode settings (`.vscode/settings.json`) that configure:

- **Flutter SDK:** Path to FVM-managed Flutter (`.fvm/versions/3.35.2`)
- **Auto-formatting:** Format on save enabled
- **Code actions:** Auto-organize imports and sort members on save
- **File naming:** Classes are automatically renamed when files are renamed

### Essential Make Commands

```bash
# Analysis and quality checks
make analyze              # Run dart analyze (linting)
make format               # Format Dart code
make ci                   # Run all CI checks (analyze + format)

# Building
make build                # Run build_runner with --delete-conflicting-outputs

# Publishing
make pub_publish_dry_run  # Dry run publish to pub.dev
make pub_publish          # Publish to pub.dev

# Dependency management
make add_dependency <pkg> # Add a pub.dev dependency

# Git utilities
make git_branch_clean     # Remove stale local branches
make git_create_tag <tag> # Create and push a git tag

# Quick reference
make help                 # Display all available commands
```

---

## Code Conventions and Style

### Naming Conventions (Dart Standard)

| Type | Format | Example |
|------|--------|---------|
| Classes | PascalCase | `PictureRecorder`, `Canvas`, `Path` |
| Private Classes | `_PascalCase` | `_DrawCommand`, `_PureDartCanvas` |
| Methods/Functions | camelCase | `drawCircle()`, `save()`, `restore()` |
| Variables/Constants | camelCase | `isRecording`, `strokeWidth`, `color` |
| Private Variables | `_camelCase` | `_commands`, `_width` |
| Enums | PascalCase | `PaintingStyle`, `BlendMode` |
| Enum Values | camelCase (lowercase) | `PaintingStyle.fill` |
| Constants | camelCase | `defaultStrokeWidth = 1.0` |

### File Organization

1. **Library Structure:** All code is part of the single `dart.ui` library
   ```dart
   library dart.ui;

   part 'painting.dart';
   part 'geometry.dart';
   // ... other parts
   ```

2. **Part Convention:** Use `part of 'pure_ui.dart'` in part files
   ```dart
   part of 'pure_ui.dart';

   class MyClass {
     // implementation
   }
   ```

3. **Imports:** Group imports:
   - dart: imports first
   - package: imports second
   - relative imports last

4. **Documentation:** Use triple-slash (`///`) for public API documentation
   ```dart
   /// Draws a circle at ([cx], [cy]) with [radius].
   ///
   /// This method respects the current [Paint] and transformation matrix.
   void drawCircle(double cx, double cy, double radius) {
     // ...
   }
   ```

### Code Style Guidelines

- **Formatting:** Use `dart format` for automatic formatting
- **Line Length:** Soft limit of 80 characters (enforced by formatter)
- **Indentation:** 2 spaces (Dart standard)
- **Linting:** Follow Dart's default lint rules (configured via `analysis_options.yaml` if needed)
- **Copyright Headers:** Use BSD 3-Clause style comments for new files
- **Imports:** Use `dart pub get` to manage dependencies

### Class and Method Organization

Within classes, organize members in this order:
1. Static members and constants
2. Fields/instance variables (private first, then public)
3. Constructors
4. Named constructors
5. Getters and setters
6. Public methods (in logical groups)
7. Private methods (in logical groups)

---

## Testing Practices

### Testing Framework

- **Framework:** `package:test` (Dart's standard unit testing framework)
- **Runner:** `dart test` or `make test`
- **Coverage:** 8 comprehensive test files covering major features

### Test File Organization

Each test file should:
1. Import testing packages and the code under test
2. Use `group()` for organizing related tests
3. Use `test()` for individual test cases
4. Support async tests with `() async {}`

### Example Test Structure

```dart
import 'package:test/test.dart';
import 'package:pure_ui/pure_ui.dart';

void main() {
  group('Canvas Drawing', () {
    late ui.PictureRecorder recorder;
    late ui.Canvas canvas;

    setUp(() {
      recorder = ui.PictureRecorder();
      canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 200, 200));
    });

    tearDown(() {
      recorder.endRecording().dispose();
    });

    test('drawCircle draws a circle', () async {
      final paint = ui.Paint()..color = ui.Color.fromARGB(255, 255, 0, 0);
      canvas.drawCircle(const ui.Offset(100, 100), 50, paint);

      final picture = recorder.endRecording();
      final image = await picture.toImage(200, 200);

      expect(image.width, 200);
      expect(image.height, 200);

      image.dispose();
    });
  });
}
```

### Common Test Patterns

1. **Picture Recording Tests:**
   ```dart
   final recorder = ui.PictureRecorder();
   final canvas = ui.Canvas(recorder, bounds);
   // Draw operations
   final picture = recorder.endRecording();
   final image = await picture.toImage(width, height);
   ```

2. **Image Comparison:** Tests export images and verify dimensions/content

3. **Resource Cleanup:** Always dispose images and recorders
   ```dart
   tearDown(() {
     image.dispose();
     recorder.endRecording().dispose();
   });
   ```

4. **Color/Type Validation:** Test that colors, transforms, and types are correct

### Running Tests

```bash
# Run all tests
dart test

# Run specific test file
dart test test/pure_ui_test.dart

# Run tests matching a pattern
dart test -k "drawCircle"

# Run with verbose output
dart test -v
```

---

## Build and Deployment

### Build System

**Tool:** `build_runner` (Dart's code generation tool)

**Configuration:** `build.yaml`
```yaml
builders:
  auto_exporter|auto_exporter:
    enabled: true
    options:
      output: lib/pure_ui.dart
```

**Purpose:** Automatically generates the main library file from part files

### Building

```bash
# Standard build (recommended)
make build

# Manual build
dart run build_runner build --delete-conflicting-outputs

# Watch mode for development
dart run build_runner watch
```

### Publishing to pub.dev

1. **Dry Run (validates without publishing):**
   ```bash
   make pub_publish_dry_run
   ```

2. **Actual Publishing:**
   ```bash
   make pub_publish
   ```

3. **Version Management:**
   - Update version in `pubspec.yaml`
   - Update `CHANGELOG.md`
   - Create git tag with `make git_create_tag v0.1.5`
   - Publish via `make pub_publish`

### Release Process

1. Update version number in `pubspec.yaml`
2. Add entry to top of `CHANGELOG.md`
3. Create a git commit with the version bump
4. Create a git tag: `git tag v0.1.5`
5. Push tag: `git push origin v0.1.5`
6. Run `dart pub publish` (or `make pub_publish`)

---

## Architecture and Key Components

### Core Architecture

**Pure UI** follows a layered architecture:

```
┌─────────────────────────────────────┐
│  Public API Layer (painting.dart)   │
│  Canvas, Paint, Path, Color, etc.   │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│ Implementation Layer                │
│ _PureDartCanvas (pure_dart_impl)    │
│ _DrawCommand, _PureDartImage        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Rendering Engine                   │
│  Picture recording, image export    │
└─────────────────────────────────────┘
```

### Key Classes and Their Roles

#### Public API (painting.dart)

| Class | Purpose |
|-------|---------|
| `Canvas` | Main drawing API (drawCircle, drawRect, drawPath, etc.) |
| `Paint` | Defines style (color, stroke width, style, etc.) |
| `Path` | Vector path with drawing primitives |
| `Color` | ARGB color representation |
| `Rect` | Axis-aligned rectangle |
| `Offset` | 2D point/vector |
| `Size` | Width/height dimensions |
| `Matrix4` | 4x4 transformation matrix |
| `PictureRecorder` | Records drawing operations |
| `Picture` | Playable recording of drawings |

#### Implementation (pure_dart_implementations.dart)

| Class | Purpose |
|-------|---------|
| `_PureDartCanvas` | Pure Dart Canvas implementation |
| `_DrawCommand` | Individual drawing operation |
| `_PureDartImage` | In-memory image representation |
| `_CommandRecorder` | Records drawing commands |

### Data Flow

1. **Recording:** User calls `Canvas.drawX()` → command is recorded
2. **Storage:** Commands stored in `_drawCommands` list
3. **Playback:** `Picture.toImage()` → iterates commands → executes rendering
4. **Export:** `exportImage()` → encodes PNG using `image` package

---

## Common Workflows

### Adding a New Drawing Operation

1. **Define the method in Canvas class (painting.dart):**
   ```dart
   void drawCustomShape(Offset center, double radius, Paint paint) {
     // Implementation
   }
   ```

2. **Create implementation in _PureDartCanvas:**
   ```dart
   @override
   void drawCustomShape(Offset center, double radius, Paint paint) {
     _drawCommands.add(_DrawCommand(
       type: 'drawCustomShape',
       args: [center, radius, paint],
     ));
   }
   ```

3. **Add execution in _executeDrawCommands:**
   ```dart
   case 'drawCustomShape':
     _actuallyDrawCustomShape(args[0], args[1], args[2]);
     break;
   ```

4. **Add tests in test/custom_shape_test.dart**

### Modifying Existing Drawing Behavior

1. Locate the method in `painting.dart` (public API)
2. Find corresponding implementation in `pure_dart_implementations.dart`
3. Update both the API and implementation consistently
4. Update or add tests to cover the change
5. Run `make ci` to validate

### Adding Dependencies

1. Add to `pubspec.yaml`:
   ```yaml
   dependencies:
     new_package: ^1.0.0
   ```

2. Or use make command:
   ```bash
   make add_dependency new_package
   ```

3. Run `dart pub get`
4. Run `make ci` to ensure no conflicts

### Fixing Bugs

1. Create a test that reproduces the bug (test should fail initially)
2. Fix the implementation to make the test pass
3. Run `make ci` to validate all tests pass
4. Commit with message: "Fix: [description of bug]"

---

## Dependencies and Versions

### Production Dependencies

| Package | Version | Purpose | Usage |
|---------|---------|---------|-------|
| `meta` | >=1.16.0 <2.0.0 | Dart annotations | `@Native`, `@pragma` for optimizations |
| `ffi` | ^2.1.0 | Foreign Function Interface | Future native code integration |
| `collection` | ^1.17.0 | Collection extensions | Advanced list/map/set utilities |
| `vector_math` | ^2.1.4 | Vectors and matrices | `Matrix4` for transforms, `Vector3` for operations |
| `image` | ^4.1.7 | Image processing | PNG encoding for `exportImage()` |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `test` | any | Unit testing framework |

### Dart SDK Requirement

- **Minimum:** 3.3.0
- **Latest tested:** 3.35.2 (via FVM in `.fvmrc`)

### Upgrading Dependencies

```bash
# Check for updates
dart pub upgrade --dry-run

# Apply updates
dart pub upgrade

# Update specific package
dart pub upgrade package_name
```

---

## CI/CD and Automation

### GitHub Actions Workflow (check.yml)

**Triggers:** Push to any branch, pull requests

**Steps:**

1. **Checkout Code** (actions/checkout@v6)
   - Fetches repository code

2. **Setup FVM**
   - Installs Flutter Version Manager

3. **Cache Flutter** (actions/cache@v5)
   - Caches Flutter installation for faster builds

4. **Install Flutter via FVM**
   - Uses `.fvmrc` to determine version (3.35.2)

5. **Install Dependencies**
   - Runs `dart pub get`

6. **Analyze Code**
   - Runs `dart analyze` for linting

7. **Validate No Uncommitted Changes** (Optional)
   - Ensures all changes are committed

### Dependency Automation (dependabot.yml)

- **GitHub Actions:** Weekly updates
- **Pub Packages:** Monthly updates
- Creates pull requests for dependency updates

### Branch Protection Rules

- All CI checks must pass before merging
- Code review may be required

---

## Tips and Best Practices

### Do's ✅

1. **Run make ci before committing**
   ```bash
   make ci
   # Runs analyze and format checks
   ```

2. **Write tests for new functionality**
   - Include unit tests in `test/` directory
   - Test both basic cases and edge cases

3. **Use meaningful commit messages**
   - Format: `[Type]: [Description]`
   - Types: Fix, Feature, Refactor, Test, Docs, Chore
   - Example: `Fix: Handle null offset in drawPath`

4. **Keep changes focused**
   - One feature/fix per commit
   - Easier to review and revert if needed

5. **Update CHANGELOG.md**
   - Document user-facing changes
   - One entry per version/release

6. **Check pub.dev for package conflicts**
   - Verify naming doesn't conflict with existing packages
   - Check dependency compatibility

7. **Test across Dart versions**
   - Minimum supported: 3.3.0
   - Current: 3.35.2

### Don'ts ❌

1. **Don't commit without running make ci**
   - Ensures code style consistency

2. **Don't break backward compatibility without discussion**
   - Consider SemVer (Semantic Versioning)
   - Major.Minor.Patch: major for breaking changes

3. **Don't forget to dispose resources**
   - Always dispose images after use
   - Always dispose recorders

4. **Don't add files to pubspec.yaml manually without running pub get**
   - Always use `dart pub add` or `make add_dependency`

5. **Don't ignore test failures**
   - All tests must pass before merging
   - Add tests for bug fixes

6. **Don't hardcode paths or platform-specific code**
   - Write platform-agnostic code where possible
   - Use Dart's cross-platform abstractions

### Performance Considerations

1. **Canvas operations:** Direct drawing is fastest
2. **Picture recording:** Useful for deferred rendering
3. **Image export:** PNG encoding is the bottleneck
4. **Color operations:** Use integer operations where possible
5. **Transforms:** Matrix4 operations are pre-computed

### Debugging Tips

1. **Print debug info:**
   ```dart
   print('Canvas state: $_drawCommands.length commands');
   ```

2. **Test individual drawing operations:**
   ```dart
   final recorder = ui.PictureRecorder();
   final canvas = ui.Canvas(recorder, bounds);
   canvas.drawCircle(...);
   // Inspect the command
   ```

3. **Export intermediate images:**
   ```dart
   final image = await picture.toImage(width, height);
   final png = await exportImage(image);
   // Save for inspection
   ```

4. **Use VSCode debugger:**
   - Set breakpoints in code
   - Run tests with debugging enabled
   - Inspect variables and call stacks

---

## Common Issues and Solutions

### Issue: Tests fail with "Connection refused"

**Cause:** Attempting to access platform-specific code from pure Dart

**Solution:** Use stubs provided in `platform_dispatcher.dart` and `window.dart`

### Issue: PNG export produces incorrect colors

**Cause:** Color space or gamma issues in encoding

**Solution:** Check Paint.color values and image bit depth in `image` package

### Issue: Transforms not applying correctly

**Cause:** Matrix multiplication order or save/restore imbalance

**Solution:** Verify `canvas.save()` and `canvas.restore()` calls are balanced

### Issue: Build runner fails to generate exports

**Cause:** Circular part dependencies or incorrect `part of` declarations

**Solution:** Run `dart run build_runner clean && dart run build_runner build`

---

## Contributing Guidelines

When contributing to Pure UI:

1. **Fork** the repository on GitHub
2. **Create** a feature branch: `git checkout -b feature/your-feature`
3. **Make** your changes following code conventions
4. **Test** thoroughly with `dart test`
5. **Format** code with `make format`
6. **Analyze** with `make analyze`
7. **Commit** with descriptive messages
8. **Push** to your fork
9. **Create** a Pull Request with description of changes

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Added/updated tests
- [ ] All tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings generated
```

---

## Quick Reference

### Essential Commands

```bash
# Setup
dart pub get
make build

# Development
make analyze            # Check code quality
make format             # Format code
make ci                 # Run all checks
dart test               # Run tests

# Publishing
make pub_publish_dry_run
make pub_publish
make git_create_tag v0.1.5
```

### Key Files by Purpose

| Need | File(s) |
|------|---------|
| Public API | `lib/painting.dart` |
| Implementation | `lib/pure_dart_implementations.dart` |
| Types | `lib/geometry.dart` |
| Tests | `test/*.dart` |
| Examples | `example/main.dart` |
| Configuration | `pubspec.yaml`, `build.yaml` |
| CI/CD | `.github/workflows/check.yml` |

### Documentation Resources

- **User Docs:** `README.md`
- **API Docs:** Inline `///` comments in source
- **Version History:** `CHANGELOG.md`
- **Dev Guide:** This file (`CLAUDE.md`)

---

## Version Information

- **Pure UI Version:** 0.1.4
- **Dart SDK:** 3.3.0+
- **Flutter:** 3.35.2 (via FVM)
- **Last Updated:** 2025-01-30

For questions or updates to this guide, please refer to the main README.md or GitHub repository.

---

*This guide is maintained for AI assistants and developers working on Pure UI. It should be updated whenever significant changes to the project structure or workflows occur.*
