# 🔍 Siraty Code Review Report

**Date:** 2026-09-08
**Scope:** 143 Dart files, ~20,400 lines. `flutter analyze` returns only 5 infos.

## ✅ What's good

- Solid Clean Architecture skeleton (data/domain/presentation per feature), DI via GetIt, router args safely casted with `RouteErrorPage` fallbacks (`app_router.dart:99-113`)
- Cubits use Equatable states; audio service properly cancels old stream subscriptions before re-subscribing (`quran_audio_service.dart:117-121`)
- Timer in `AzanCubit` cancelled on `close()`; splash timer checks `mounted`
- Zero `print()` statements, zero TODO/FIXME debt, decent test coverage for prayer calculation domain

---

## 🐛 Bugs (High)

**1. Favorites: initial load never notifies listeners**
`favorites_service.dart:57-64` — `_load()` sets `_items` but never calls `notifyListeners()`. `FavoritesPage.initState` (`favorites_page.dart:26`) fires `getFavorites()` unawaited; when it completes, the `ListenableBuilder` never rebuilds, so the page can render the empty state until some other action triggers a notify. Fix: call `notifyListeners()` at the end of `_load()`.

**2. Favorites: `clearAll()` read-modify-write race**
`favorites_service.dart:104-108` — `clearAll()` doesn't call `_load()` first, and all methods do read-modify-write without locking. A concurrent in-flight `_load()` can resurrect a cleared list. Fix: load once at startup, stop re-reading on every call.

**3. FavoritesService is a singleton outside DI**
`favorites_service.dart:49` — `FavoritesService.instance` bypasses GetIt, is a `ChangeNotifier` used as a hand-rolled Bloc, never disposed, and lives in `core/services` while being feature data.

**4. `use_build_context_synchronously` in `ayah_options_sheet.dart:256-257`**
`Navigator.pop(context)` + `ScaffoldMessenger` after `await toggleFavorite(...)` without a `mounted` check. Crash risk on slow IO.

## 🐛 Bugs (Medium)

**5. `AzanCubit._refreshAfterBoundary` has no error handling** (`azan_cubit.dart:113-128`)
Exception inside the 1-second ticker's boundary refresh → unhandled async error.

**6. Timezone risk in countdown logic** (`azan_cubit.dart:36-46`)
`DateTime.now()` mixed with stored prayer times; no test pinning DST/clock-change behavior.

**7. 53 silent `catch (_) {}` blocks**
`native_prayer_scheduler.dart` et al. — method-channel failures are invisible: alarms silently not scheduled. Add `debugPrint`.

---

## 🗑️ Dead / Unused Code

| Item | Location | Evidence |
|---|---|---|
| `CustomGradientCard` | `core/widgets/custom_card.dart` | 1 usage; overlaps `AppCard(gradientColors:...)` |
| `CustomButton` | `core/widgets/custom_button.dart` | 1 usage; 27-line InkWell wrapper |
| `CustomSearchAppBar` | `core/widgets/custom_search_bar.dart` | **0 usages** |
| `AppButton` | `core/widgets/app_button.dart` | 2 usages |
| `loadAzan({city, country})` | `azan_cubit.dart:60` | Legacy, params ignored, no callers |
| 5 unused asset constants | `core/constants/assets.dart:3-7` | quranIcon, tasbeehIcon, azkarIcon, prayingIcon, sebhaBackground — **0 usages** |
| `Dio` registration | `service_locator.dart:39` | Never injected; `tafsir_repository.dart:45` creates its own |

## 🔁 Duplicates / Inconsistencies

- **Two theme files:** `core/theme/app_theme.dart` is just `export 'theme.dart';` — delete it.
- **`App*` vs `Custom*` naming split:** AppCard/CustomGradientCard, AppButton/CustomButton — consolidate on `App*`.
- **Two spacing systems:** `AppSpacing` vs `AppDimensions` padding tokens (~27 vs ~24 usages, split).
- **~160 hardcoded `Color(0x...)` literals in features:** tasbeeh_page (21), prayer_page (16), home_sections_grid (16), home_daily_cards (15), splash_page.dart:66-73 (exact bg gradient hardcoded).

## 🏗️ Architecture & Scalability

- **Domain imports data (7 files):** `azan_state.dart:3` imports `data/models/azan_model.dart` — state exposes a data model, not an entity; `prayer_repository.dart` (domain) references data types.
- **33 presentation→data imports:** pages pull data models directly, and the router passes `AzkarModel`/`SurahModel` through `state.extra` — blocks deep links/cold-start restore, couples navigation to data models.
- **God pages:** hadith_page 731 lines, tasbeeh_page 690, hisn_al_muslim_page 653, surah_page 625.
- **`main.dart` bootstraps features directly** (`main.dart:14-28`).
- **Manual `setState` search filtering** (`quran_page.dart:27-31`) rebuilds the whole page per keystroke.

## 🧪 Testing Gaps

Only 9 test files (prayer calc + hadith). Zero coverage of: AzanCubit ticker/boundary logic, FavoritesService (which has the races above), router arg handling, audio service.

---

## 🎯 Priority action plan

1. **Fix now:** favorites notify bug (#1), mounted check (#4), try/catch (#5)
2. **Cleanup sprint:** delete `app_theme.dart`, `custom_search_bar.dart`, unused asset constants + images, `loadAzan`, Dio registration; merge `Custom*` widgets into `App*`
3. **Before next feature:** consolidate spacing, move 160 hardcoded colors into AppColors, extract domain models from state/router, add AzanCubit + FavoritesService tests
4. **Ongoing:** split the four 600+ line pages
