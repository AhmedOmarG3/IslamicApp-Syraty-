# 🔀 Siraty (سيرتي) — Git Workflow & Release Protocol

This document establishes the Git branching, committing, and release release protocols for maintaining production stability of **Siraty**.

---

## 🌿 Branching Strategy

We follow a structured **Git Flow** variant optimized for mobile app production delivery:

```
 main (Production Releases: v1.0.3+4)
  │
  ├── develop (Staging / Integration)
  │    │
  │    ├── feature/quran-audio-player
  │    ├── refactor/azkar-clean-arch
  │    └── bugfix/last-read-index-search
  │
  └── hotfix/v1.0.4-keystore-security
```

### Branch Naming Conventions:
- `feature/<feature-name>`: New user-facing capabilities (e.g., `feature/qibla-compass`).
- `refactor/<feature-name>`: Architectural cleanups without functional changes (e.g., `refactor/tasbeeh-cubit`).
- `bugfix/<issue-name>`: Non-urgent bug fixes aimed at `develop` (e.g., `bugfix/search-filter-index`).
- `hotfix/<version-name>`: Emergency production bug fixes branched directly from `main`.

---

## 📝 Commit Message Format (Conventional Commits)

All commit messages must adhere to the **Conventional Commits** specification:

```
<type>(<scope>): <short description>
```

### Allowed Types:
- `feat`: A new feature for the user.
- `fix`: A bug fix for the user or system.
- `refactor`: Code changes that neither fix a bug nor add a feature.
- `docs`: Documentation changes (`AI_RULES.md`, `ARCHITECTURE.md`).
- `style`: Formatting, missing semi-colons, lint rule updates.
- `perf`: A code change that improves performance.
- `sec`: Security improvements or secret removal.

### Examples:
```bash
git commit -m "fix(quran): fix last read surah index corruption during search"
git commit -m "sec(android): remove release keystore from root and update gitignore"
git commit -m "refactor(tasbeeh): migrate sebha widget state to SebhaCubit and Hive"
```

---

## 🏷️ Versioning & Release Protocol

- Follow **Semantic Versioning (SemVer)** formatted as `MAJOR.MINOR.PATCH+BUILD`.
- Version updates occur in `pubspec.yaml` and `android/app/build.gradle`.
- Release commits on `main` must be tagged with `vMAJOR.MINOR.PATCH` (e.g., `v1.0.3`).

---

## 🔐 Keystore & Secrets Security

- **NEVER** commit signing keys (`*.p12`, `*.jks`, `key.properties`) to Git repositories.
- Keep keystores in secure CI/CD environment variables or encrypted developer key stores.
