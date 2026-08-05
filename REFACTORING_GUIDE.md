# 🛠️ Siraty (سيرتي) — Production Refactoring & Migration Guide

This document outlines the step-by-step, feature-by-feature incremental refactoring plan for migrating **Siraty** to a production-ready Feature-First Clean Architecture without downtime, breaking changes, or full rewrites.

---

## 📌 Master Migration Principles
1. **Zero Downtime**: The application is live on Google Play. At every phase, `flutter build apk` and `flutter run` must compile and pass all manual user acceptance tests.
2. **Incremental Extraction**: Existing files are moved and refactored feature by feature. Old views remain operational until their refactored counterparts are validated.
3. **No Re-creation**: The codebase is refactored in-place.

---

## 🗓️ Refactoring Plan by Phases

---

### 🔹 Phase 1: Core Foundation, Theme, Router, & Dependency Injection

#### Goal
Establish the production foundation by setting up `GetIt` for Service Location, `GoRouter` for declarative navigation, Material 3 Theme system, and core error/network abstractions, while removing security risks.

#### Files Affected
- `[DELETE]` `upload-keystore.p12` (Security risk)
- `[MODIFY]` `.gitignore` (Add keystore exclusion rules)
- `[NEW]` `lib/core/services/service_locator.dart` (GetIt initialization)
- `[NEW]` `lib/core/router/app_router.dart` (GoRouter setup)
- `[NEW]` `lib/core/theme/app_theme.dart` (Material 3 configuration)
- `[NEW]` `lib/core/constants/app_colors.dart`, `app_constants.dart`, `app_assets.dart`
- `[MODIFY]` `lib/main.dart` (Initialize GetIt, Hive, and bind GoRouter)

#### Risks
- Navigation breakage if legacy routes (`Navigator.pushNamed`) are removed prematurely.

#### Validation Checklist
- [ ] `upload-keystore.p12` removed from tracking and added to `.gitignore`.
- [ ] App launches into `SplashView` via `GoRouter`.
- [ ] Material 3 theme applies correctly across all existing screens.
- [ ] `GetIt.instance` initializes cleanly without unhandled runtime exceptions.

#### Rollback Plan
Revert `lib/main.dart` to use original `MaterialApp(routes: ...)` configuration while retaining created `core/` helper classes.

---

### 🔹 Phase 2: Home Feature Refactoring

#### Goal
Migrate `HomeView` and `LastReadContainer` into `lib/features/home/` with clean presentation components and decoupled routing.

#### Files Affected
- `[MOVE & REFACTOR]` `lib/Presentation/Views/home_view.dart` $\rightarrow$ `lib/features/home/presentation/pages/home_page.dart`
- `[MOVE & REFACTOR]` `lib/Presentation/Widgets/home_body.dart` $\rightarrow$ `lib/features/home/presentation/widgets/home_body.dart`
- `[MOVE & REFACTOR]` `lib/Presentation/Widgets/last_read_container.dart` $\rightarrow$ `lib/features/home/presentation/widgets/last_read_card.dart`
- `[MOVE & REFACTOR]` `lib/Presentation/Widgets/custom_card.dart` $\rightarrow$ `lib/core/widgets/feature_card.dart`

#### Risks
- Inter-feature navigation links broken when tapping grid cards.

#### Validation Checklist
- [ ] Grid cards navigate correctly to Quran, Azkar, Sebha, and Azan using `GoRouter`.
- [ ] Last Read card renders surah name correctly when Quran data is loaded.

#### Rollback Plan
Restore original `lib/Presentation/Views/home_view.dart` routing target in `app_router.dart`.

---

### 🔹 Phase 3: Quran Feature Refactoring

#### Goal
Extract `quran` feature into Clean Architecture layers. Fix the critical **Last Read Index corruption bug** during search, and offload `quran.json` parsing to an isolate using `compute()`.

#### Files Affected
- `[NEW]` `lib/features/quran/domain/entities/surah_entity.dart`, `verse_entity.dart`
- `[NEW]` `lib/features/quran/domain/repositories/quran_repository.dart`
- `[NEW]` `lib/features/quran/domain/usecases/get_surahs_usecase.dart`, `update_last_read_usecase.dart`
- `[NEW]` `lib/features/quran/data/datasources/quran_local_data_source.dart` (Uses `compute()`)
- `[NEW]` `lib/features/quran/data/repositories/quran_repository_impl.dart`
- `[MOVE & REFACTOR]` `lib/Cubits/QuranCubit/*` $\rightarrow$ `lib/features/quran/presentation/cubit/*`
- `[MOVE & REFACTOR]` `lib/Presentation/Views/quran_view.dart`, `surah_view.dart` $\rightarrow$ `lib/features/quran/presentation/pages/*`
- `[MODIFY]` `lib/Presentation/Widgets/quran_view_body.dart` (Fix search index bug by passing `surah.surahNumber - 1` instead of list index)

#### Risks
- SharedPreferences key mismatch resulting in loss of user's saved last-read position.

#### Validation Checklist
- [ ] Searching for a Surah (e.g. "يس") and clicking it saves Surah Ya-Sin as last read (NOT Al-Fatiha).
- [ ] Large `quran.json` file parses smoothly without main thread frame drops.
- [ ] Equatable states prevent duplicate UI rebuilds.

#### Rollback Plan
Re-point `quran` route to legacy `QuranView` and retain legacy `quran_service.dart`.

---

### 🔹 Phase 4: Azkar Feature Refactoring

#### Goal
Migrate `azkar` feature into Clean Architecture. Offload `adhkar.json` loading to isolates, sanitize error messages, and eliminate forced unwraps (`!`).

#### Files Affected
- `[NEW]` `lib/features/azkar/domain/entities/azkar_entity.dart`, `zekr_item_entity.dart`
- `[NEW]` `lib/features/azkar/domain/repositories/azkar_repository.dart`
- `[NEW]` `lib/features/azkar/domain/usecases/get_azkar_usecase.dart`
- `[NEW]` `lib/features/azkar/data/datasources/azkar_local_data_source.dart`
- `[NEW]` `lib/features/azkar/data/repositories/azkar_repository_impl.dart`
- `[MOVE & REFACTOR]` `lib/Cubits/AzkarCubit/*` $\rightarrow$ `lib/features/azkar/presentation/cubit/*`
- `[MOVE & REFACTOR]` `lib/Presentation/Views/azkar_view.dart`, `zekr_view.dart` $\rightarrow$ `lib/features/azkar/presentation/pages/*`

#### Risks
- Category search filtering failing due to string normalization or null handling.

#### Validation Checklist
- [ ] Category search returns matching Azkar accurately.
- [ ] Zero null assertion exceptions (`!`) on opening Zekr categories.
- [ ] Back navigation from Zekr details works seamlessly.

#### Rollback Plan
Revert `AzkarCubit` dependency registration in `GetIt` to legacy `AzkarService`.

---

### 🔹 Phase 5: Tasbeeh (Sebha) Feature Refactoring

#### Goal
Migrate `SebhaView` from transient `setState` to `SebhaCubit` with persistent local storage using `Hive`, and fix fragile stack alignment over `sebha2.png`.

#### Files Affected
- `[NEW]` `lib/features/sebha/domain/entities/tasbeeh_entity.dart`
- `[NEW]` `lib/features/sebha/presentation/cubit/sebha_cubit.dart`, `sebha_state.dart`
- `[MOVE & REFACTOR]` `lib/Presentation/Views/sebha_view.dart` $\rightarrow$ `lib/features/sebha/presentation/pages/sebha_page.dart`
- `[NEW]` `lib/features/sebha/presentation/widgets/sebha_counter_display.dart`

#### Risks
- UI misalignment if background graphic constraints are modified incorrectly.

#### Validation Checklist
- [ ] Counter increments correctly on tap and persists after exiting and re-opening the screen.
- [ ] Tasbeeh phrases cycle correctly after reaching count threshold (34).
- [ ] Reset button resets counter cleanly to 0.

#### Rollback Plan
Keep `SebhaView` stateful widget implementation as fallback.

---

### 🔹 Phase 6: Prayer (Azan) Feature Refactoring

#### Goal
Migrate `azan` feature to Clean Architecture using `Dio` API client via GetIt, remove forced null unwraps, add HTTP timeout handling, and sanitize error messages.

#### Files Affected
- `[NEW]` `lib/features/azan/domain/entities/azan_entity.dart`
- `[NEW]` `lib/features/azan/domain/repositories/azan_repository.dart`
- `[NEW]` `lib/features/azan/domain/usecases/get_azan_timings_usecase.dart`
- `[NEW]` `lib/features/azan/data/datasources/azan_remote_data_source.dart`
- `[NEW]` `lib/features/azan/data/repositories/azan_repository_impl.dart`
- `[MOVE & REFACTOR]` `lib/Cubits/AzanCubit/*` $\rightarrow$ `lib/features/azan/presentation/cubit/*`
- `[MOVE & REFACTOR]` `lib/Presentation/Views/azan_view.dart` $\rightarrow$ `lib/features/azan/presentation/pages/azan_page.dart`

#### Risks
- Network timeouts when querying AlAdhan API endpoint.

#### Validation Checklist
- [ ] City search fetches prayer times reliably without throwing unhandled `TypeError` on empty/null responses.
- [ ] Quick selection chips ('القدس', 'مكة', 'القاهرة') load prayer times cleanly.
- [ ] Times format accurately in 12-hour format with AM/PM indicators.

#### Rollback Plan
Fallback to legacy `AzanService` implementation.

---

### 🔹 Phase 7: Settings & Final Cleanup

#### Goal
Add app settings capability (theme toggle, calculation method selection), clean up legacy directories (`lib/Cubits`, `lib/Data`, `lib/Presentation`), and enforce 100% lint compliance.

#### Files Affected
- `[NEW]` `lib/features/settings/*`
- `[DELETE]` Legacy empty folders (`lib/Cubits`, `lib/Data`, `lib/Presentation`)
- `[MODIFY]` `analysis_options.yaml` (Enforce strict lint rules)

#### Risks
- Unused import errors across refactored files.

#### Validation Checklist
- [ ] `flutter analyze` returns zero issues.
- [ ] App builds cleanly in release mode (`flutter build apk --release`).
- [ ] All 6 features (Home, Quran, Azkar, Tasbeeh, Azan, Settings) operate with zero regressions.

#### Rollback Plan
Git restore affected feature entrypoints.
