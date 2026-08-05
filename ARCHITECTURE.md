# 🏗️ Siraty (سيرتي) — System Architecture Guide

This document defines the production architectural standard for the **Siraty** Flutter application.

---

## 🎯 Core Architectural Principles

1. **Feature-First Organization**: Code is grouped by business domain/features (`quran`, `azkar`, `tasbeeh`, `azan`, `home`, `settings`) rather than by technical layers at the root.
2. **Clean Architecture**: Clear layer boundaries ensuring business rules are decoupled from UI frameworks, databases, and network APIs.
3. **SOLID Principles**:
   - **Single Responsibility Principle (SRP)**: Each class, Cubit, UseCase, and Widget has exactly one reason to change.
   - **Open/Closed Principle (OCP)**: Components are open for extension via contracts/interfaces, closed for modification.
   - **Liskov Substitution Principle (LSP)**: Data repository implementations are completely interchangeable via repository abstractions.
   - **Interface Segregation Principle (ISP)**: Clients depend only on specific, lean interfaces.
   - **Dependency Inversion Principle (DIP)**: High-level business logic (UseCases) depends on domain abstractions, not concrete low-level data sources.
4. **DRY (Don't Repeat Yourself)**: Shared visual components, gradient styles, search handlers, and date formatters are centralized in `core/`.
5. **KISS (Keep It Simple, Stupid)**: Avoid over-engineering. Use standard BLoC/Cubit primitives and straightforward data flows.
6. **YAGNI (You Aren't Gonna Need It)**: Implement only required, verified features and domain capabilities.

---

## 🛠️ Technology Stack

| Role | Technology | Selection Rationale |
| :--- | :--- | :--- |
| **Framework** | Flutter (SDK ^3.5.0) | Cross-platform production SDK |
| **Design System** | Material 3 | Modern design components, dynamic color scheme |
| **State Management** | Cubit (`flutter_bloc ^9.1.0`) | Lightweight, predictable state management without Event boilerplate |
| **Dependency Injection** | GetIt (`get_it ^7.7.0`) | Service locator for decoupled dependency resolution |
| **Routing** | GoRouter (`go_router ^14.0.0`) | Declarative, type-safe routing with deep linking support |
| **Local Persistence** | Hive (`hive_flutter ^1.1.0`) | High-performance, fast key-value storage for local caching & state |
| **HTTP Client** | Dio (`dio ^5.8.0`) | Powerful HTTP client with interceptors, timeouts, and error handling |

---

## 📁 Target Feature-First Clean Architecture

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_assets.dart
│   │   ├── app_colors.dart
│   │   └── app_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── api_client.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── services/
│   │   └── service_locator.dart (GetIt setup)
│   ├── theme/
│   │   └── app_theme.dart (Material 3)
│   ├── utils/
│   │   ├── date_formatter.dart
│   │   └── isolate_helper.dart
│   └── widgets/
│       ├── custom_app_bar.dart
│       ├── custom_card.dart
│       └── error_view.dart
└── features/
    ├── azan/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── azan_remote_data_source.dart
    │   │   │   └── azan_local_data_source.dart
    │   │   ├── models/
    │   │   │   └── azan_model.dart
    │   │   └── repositories/
    │   │       └── azan_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── azan_entity.dart
    │   │   ├── repositories/
    │   │   │   └── azan_repository.dart
    │   │   └── usecases/
    │   │       └── get_azan_timings_usecase.dart
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── azan_cubit.dart
    │       │   └── azan_state.dart
    │       ├── pages/
    │       │   └── azan_page.dart
    │       └── widgets/
    │           └── azan_card.dart
    ├── azkar/
    ├── home/
    ├── quran/
    ├── sebha/
    └── settings/
```

---

## 🔄 Data & Execution Flow Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                          PRESENTATION LAYER                            │
│   [Page / Widget] ──(User Action)──> [Cubit] ──(Emits State)──> [UI]  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Calls UseCase
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                            DOMAIN LAYER                                │
│   [UseCase / Interactor] ──(Invokes Contract)──> [Repository Interface]│
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Implemented By
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                             DATA LAYER                                 │
│   [Repository Impl] ───(Fetch Data)───> [Remote / Local DataSource]    │
│            │                                       │                   │
│            └─────────<──(Maps DTO to Entity)───────┘                   │
└────────────────────────────────────────────────────────────────────────┘
```

### Layer Dependency Rules:
1. **Presentation Layer** depends ONLY on **Domain Layer**.
2. **Data Layer** depends ONLY on **Domain Layer** (implements Domain Repository interfaces).
3. **Domain Layer** has ZERO external dependencies. It contains pure Dart entities, repository contracts, and UseCases.

---

## 🛡️ Error Handling & Result Pattern

- Data sources throw `ServerException` or `CacheException`.
- Repository implementations catch exceptions and map them to domain `Failure` instances.
- Methods return functional results or typed Failure states (e.g., `Result<T>` or `Either<Failure, T>`), ensuring Cubits never crash on unexpected runtime errors.
