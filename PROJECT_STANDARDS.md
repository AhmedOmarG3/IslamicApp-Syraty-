# 📏 Siraty (سيرتي) — Project Coding Standards & Guidelines

This document outlines mandatory coding conventions, standards, and code quality benchmarks for all development on the **Siraty** codebase.

---

## 🔤 1. Naming Conventions

| Category | Standard | Example |
| :--- | :--- | :--- |
| **Files & Folders** | `lower_snake_case` | `quran_view.dart`, `azan_remote_data_source.dart` |
| **Classes & Enums** | `PascalCase` | `SurahModel`, `AzanCubit`, `QuranState` |
| **Variables & Methods**| `camelCase` | `lastReadIndex`, `fetchAzanTimes()` |
| **Constants** | `camelCase` with `k` prefix or `lowerCamelCase` inside constant classes | `kPrimaryColor`, `AppColors.primaryGreen` |
| **Route Names** | `lower_snake_case` path format | `/quran_details`, `/azkar` |

---

## 🧩 2. Widget & Method Size Limits

- **Methods**: Maximum **20 lines of code**. If a method exceeds 20 lines, decompose it into private helper functions with single responsibilities.
- **Widgets**: Maximum **80 lines of code** per Widget class. Decompose complex layout trees into reusable, extracted `StatelessWidget` files in `widgets/`.
- **Classes**: Maximum **150 lines of code** per file. If a file exceeds this limit, extract models, helpers, or child widgets into separate files.

---

## 🚫 3. Elimination of Magic Numbers & Strings

- **No Inline Strings**: All user-facing Arabic strings, asset paths, and storage keys must be referenced via constants or localization files:
  - Asset Paths: `AppAssets.quranIcon`
  - Constants: `AppConstants.lastReadIndexKey`
  - Colors: `AppColors.primaryTeal`
- **No Inline Offsets/Sizes**: Standardize padding, spacing, border radii, and icon sizes in `AppSpacing` and `AppTheme`.

---

## 🔒 4. Model Immutability & Safety

- All Data Models and Domain Entities must be immutable (`@immutable` annotation).
- All instance variables must be declared `final`.
- Implement `copyWith()`, `operator ==`, `hashCode`, and `toString()` (or use `Equatable` / `Freezed`).

```dart
// Preferred Model Pattern
@immutable
class VerseEntity extends Equatable {
  final int chapter;
  final int verse;
  final String text;

  const VerseEntity({
    required this.chapter,
    required this.verse,
    required this.text,
  });

  @override
  List<Object?> get props => [chapter, verse, text];
}
```

---

## 🛡️ 5. Null Safety & Strong Typing

- **Zero Forced Unwrapping (`!`)**: Never use the `!` operator. Always handle nullable values safely using default fallback values, null-coalescing operators (`??`), or `if-let` checks:
  ```dart
  // BAD
  final name = zekr.category!;
  
  // GOOD
  final name = zekr.category ?? 'بدون عنوان';
  ```
- **Strict Strong Typing**: Never use `dynamic` unless interacting with un-typed legacy APIs. Always declare explicit types for parameters and return values.

---

## 🎨 6. Material 3 Theme Standards

- All widget styling must derive directly from `Theme.of(context).colorScheme` and `Theme.of(context).textTheme`.
- Hardcoded color values (`Color(0xFF004B40)`) in UI files are strictly prohibited. Use centralized theme extensions or `AppColors`.
