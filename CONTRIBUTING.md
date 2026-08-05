# 🤝 Contributing to Siraty (سيرتي)

Thank you for contributing to **Siraty**! This guide details the development setup, pull request procedures, and code quality standards required for maintaining our production app.

---

## 🚀 Environment & Initial Setup

1. **Prerequisites**:
   - Flutter SDK `^3.5.0`
   - Dart SDK `^3.5.3`
   - Android Studio / VS Code with Flutter plugins

2. **Clone & Install Dependencies**:
   ```bash
   git clone https://github.com/AhmedOmarG3/IslamicApp-Siraty-.git
   cd siraty
   flutter pub get
   ```

3. **Verify Static Analysis**:
   ```bash
   flutter analyze
   ```

---

## 📋 Definition of Done (DoD)

Before any task or Pull Request is considered complete, it must meet all DoD criteria:

- [ ] Code passes `flutter analyze` with **zero warnings or errors**.
- [ ] Code strictly follows [PROJECT_STANDARDS.md](file:///d:/Flutter_Projects/siraty/PROJECT_STANDARDS.md) and [ARCHITECTURE.md](file:///d:/Flutter_Projects/siraty/ARCHITECTURE.md).
- [ ] No hardcoded strings, colors, or magic numbers introduced.
- [ ] Zero forced null unwraps (`!`) present in new or modified files.
- [ ] Existing features remain 100% functional (manual regression check).
- [ ] Code has been tested on both Android and iOS devices/emulators.

---

## 🔍 Pull Request (PR) Checklist & Code Review

When submitting a PR, ensure the description contains:
1. **Summary of Changes**: Concise summary of what was added, modified, or refactored.
2. **Affected Feature / Scope**: List of features touched (e.g., `features/quran`).
3. **Verification Steps**: Instructions on how to test the changes manually.
4. **Screenshots/Recordings**: Required for any UI modification or bug fix.

### Review Rules:
- All PRs require approval from the Senior Tech Lead before merging into `develop` or `main`.
- Self-approvals are strictly prohibited.
- PRs must maintain backward compatibility with stored user preferences.
