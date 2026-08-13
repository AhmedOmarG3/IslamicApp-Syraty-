# Siraty (سيرتي)

Siraty is a live Arabic-first Flutter Islamic companion for Quran reading,
Azkar, prayer times, and Tasbeeh. The application is being improved through an
incremental, specification-driven workflow that protects existing users and
religious-content integrity.

## Start here

- Product description: `docs/PRODUCT.md`
- Complete product plan: `docs/MASTER_PLAN.md`
- Active roadmap: `docs/ROADMAP.md`
- Guided automatic workflow: `docs/AUTOPILOT.md`
- Current delivery state: `docs/PROGRESS.md`
- AI/developer rules: `AGENTS.md`
- Project constitution: `.specify/memory/constitution.md`
- Spec Kit workflow: `.agents/skills/`

## Development checks

```powershell
flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Spec-driven workflow

Start Codex from this repository and use:

```text
$speckit-specify <feature description>
$speckit-clarify
$speckit-plan
$speckit-tasks
$speckit-analyze
```

Implement only a reviewed small task group at a time. Read `AGENTS.md` before
modifying source code.

For guided continuous progress with one verified local commit and learning report
per task, invoke `$siraty-autopilot` using `docs/AUTOPILOT.md`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
