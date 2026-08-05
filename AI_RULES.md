# 🤖 Siraty (سيرتي) — AI Assistant Engineering Rules

This document establishes strict operational rules, constraints, and guidelines for AI coding assistants (including Claude, Gemini, Cursor, Copilot, and Antigravity) operating on the **Siraty** production codebase.

---

## 🛑 Strict Rules: What the AI Should NEVER Do

1. **NEVER Rewrite the Whole Project**: Do NOT propose or execute full codebase rewrites. All work must be strictly incremental and maintain backward compatibility.
2. **NEVER Break Existing Functionality**: Existing features (Quran reader, Azkar, Tasbeeh counter, Azan timings) must remain 100% operational during and after any changes.
3. **NEVER Change Unrelated Files**: Do NOT touch files outside the explicit scope of the current task. Limit edits to the specific target feature.
4. **NEVER Mix Business Logic with UI**: Keep `Widget.build()` methods strictly declarative. No HTTP calls, JSON parsing, or direct local storage access inside UI widgets.
5. **NEVER Add Unnecessary Dependencies**: Do NOT add new third-party packages to `pubspec.yaml` without explicit architectural justification and tech lead approval.
6. **NEVER Duplicate Code**: Do NOT copy-paste widget structures, search listeners, or gradient cards. Refactor shared components into `core/widgets/` or feature-level shared widgets.
7. **NEVER Generate Overly Large Files**: Files must remain focused and concise. Widgets should not exceed 100 lines; Cubits should not exceed 150 lines.
8. **NEVER Modify More Than One Feature at a Time**: Work in isolation on a single feature branch/module per refactoring step.

---

## ✅ Mandatory Rules: What the AI Should ALWAYS Do

1. **ALWAYS Explain the Plan Before Coding**: Present a clear, step-by-step implementation plan detailing what changes will be made and why before executing code modifications.
2. **ALWAYS List Affected Files**: Explicitly list all files to be created, modified, or moved before making changes.
3. **ALWAYS Refactor Incrementally**: Execute refactoring in small, atomic, testable commits/steps rather than large multi-file diffs.
4. **ALWAYS Preserve Backward Compatibility**: Ensure route arguments, storage keys (`SharedPreferences` / `Hive`), and asset paths remain compatible with existing app installs.
5. **ALWAYS Reuse Existing Code**: Check `core/` and existing shared widgets before writing custom helper classes or UI containers from scratch.
6. **ALWAYS Prefer Composition Over Inheritance**: Build flexible UI and logic by composing small widgets and domain components.
7. **ALWAYS Build Reusable & Small Widgets**: Extract repetitive UI structures into dedicated `StatelessWidget` files.
8. **ALWAYS Keep Cubits Focused**: One Cubit per feature responsibility. Keep Cubits lean by delegating business operations to Domain UseCases.
9. **ALWAYS Keep Repositories Clean**: Repositories must contractually map data source models into immutable domain entities.
10. **ALWAYS Use Dependency Injection**: Register and resolve all Cubits, Repositories, DataSources, and Services using `GetIt`. Never use `new ServiceName()` directly inside Cubits or UI.

---

## 🔍 Pre-Execution Checklist for AI Assistants

Before outputting code or modifying files, the AI must verify:
- [ ] Am I editing only the designated feature files?
- [ ] Have I avoided direct instantiation of services/cubits inside UI or Cubits?
- [ ] Have I used strong typing, `const` constructors, and `final` variable declarations?
- [ ] Have I ensured zero forced null unwraps (`!`)?
- [ ] Have I verified that no existing app routes or features are broken?
