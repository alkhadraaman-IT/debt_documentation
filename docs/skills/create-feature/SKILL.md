---
name: create-feature
description: Build a new feature or screen following Clean Architecture and Bloc, with layer separation and shared core widgets. Use when asked to create a new feature or screen.
---

Follow PROJECT_RULES.md (including §0.1 on Git/PR/CI). Execute the steps in order.

## 0. Plan, clarify, and branch first
- Read docs/contracts/<feature>.md if it exists. If the contract is missing or unclear (endpoint contract, fields, business rules, expected behavior, design), ask concise questions and wait for answers before coding. Minor details: choose a default and state the assumption.
- Post a short plan: files to create/modify, and endpoints/entities involved.
- Create a branch: feature/<name>. Never work on main.

## 1. Shared widgets
- Check lib/core/widgets/ first and reuse what exists.
- If you need a NEW widget that will be reused across screens, create it in lib/core/widgets/ (this is explicitly allowed) and mention it in the summary.
- Use constants from CONSTANTS_FILE; no scattered string keys in the feature.

## 2. Domain (lib/features/<name>/domain/)
- Pure Entities (equatable only; no Flutter, Dio, or JSON).
- Repository interface returning Either<Failure, T>.
- One UseCase per operation, starting with AppLogger.log('🚀 Executing: <Name>UseCase').

## 3. Data (lib/features/<name>/data/)
- Models extend Entities, with fromMap/toMap.
- RemoteDataSource with the central Dio client: log function name, URL, and status code for every request (success or failure) via AppLogger.
- LocalDataSource only if the feature needs local storage (drift or flutter_secure_storage, whichever is already in pubspec.yaml).
- RepositoryImpl wires the sources and converts exceptions into Failures.

## 4. Presentation — logic (presentation/bloc/)
- event.dart, state.dart, bloc.dart (Bloc, never Cubit).
- State covers Initial, Loading, Loaded, Empty, Error, Offline.
- Log the handler name at the start of each event handler. The Bloc calls UseCases only.

## 5. Presentation — UI (pages/, widgets/)
- Main page with BlocProvider and BlocBuilder / BlocListener. No FutureBuilder, StreamBuilder, or setState for network data.
- Loading as Skeleton after 300ms; clear Empty, Error, Offline views.
- Every file under 150 lines: split into small widgets.
- flutter_screenutil for sizes, theme / THEME_EXTENSION colors, SafeArea, textScaler, RTL with LTR numbers/dates.
- All user-facing text in PRIMARY_LANGUAGE.

## 6. Wiring
- Register DataSources, Repositories, UseCases, and Bloc in DI_FILE (get_it).
- Add the route in ROUTER_DIR (go_router).

## 7. Verify locally
Run in order, fix everything, do not proceed if any fails:
1. dart format --set-exit-if-changed .
2. flutter analyze
3. flutter test

Add tests for UseCases and Bloc if missing.

## 8. Commit, push, open PR
- Commit with clear messages (feat(<name>): ...).
- Push the branch to origin.
- Open a Pull Request against main. Do NOT merge. The team lead merges.
- In the PR description, include: summary, files created/modified, new core widgets (if any), assumptions, open questions, and local check results (format/analyze/test = pass).
- If CI fails after the PR opens: read the failure log, fix, push to the same branch. Never open a second PR for the same feature.

## 9. Finish
- Allowed edits outside the feature folder: DI_FILE, router routes, and new shared widgets in lib/core/widgets/. Do not edit pubspec.yaml; if a package is missing, ask.
- Final message must include the PR URL and the same summary listed in the PR description.