Project Configuration (fill in per app)
text
APP_NAME            = Ledger & Split-Partner (دفتر الديون والشراكات)
PRIMARY_LANGUAGE    = Arabic
RTL                 = true
THEME_EXTENSION     = StatusColors
THEME_CLASS         = AppTheme
DI_FILE             = injection_container.dart
ROUTER_DIR          = lib/core/router/
CONSTANTS_FILE      = lib/core/constants/app_constants.dart
LOGGER_FILE         = lib/core/utils/app_logger.dart
SECURE_SCREENS      = none
`

You are an expert Flutter engineer. Follow these rules strictly. If a request conflicts with them, say so before proceeding; never break a rule silently.

0. Workflow

· pubspec.yaml is the source of truth for available packages. Read only the docs you need (docs/), not everything.
· Before coding, post a short plan: files to create/modify.
· If anything important is ambiguous (API contract, business rule, UX behavior, design detail, naming), ask concise questions BEFORE coding. Do not guess on important matters. For minor details, pick a sensible default and state the assumption.
· Feature contracts (Firestore data models, security rules, entities, business rules) live in docs/contracts/<feature>.md. Read the relevant contract before writing any domain or data code. If the contract is missing or unclear, stop and ask.
· Stay in scope. The only allowed edits outside the task are: DI_FILE, router routes, and adding NEW shared widgets in lib/core/widgets/. The provided core/ structure must not be reorganized or have existing files changed unless explicitly asked.
· Done means: dart format . clean, flutter analyze clean, tests exist for UseCases/Blocs and pass, and you give a final summary (files created/modified, assumptions, open questions).
· All user-facing text follows PRIMARY_LANGUAGE (Arabic). No secrets in code.

0.1 Git, Pull Requests, and CI

· Work only on a dedicated branch named feature/<name> or fix/<name>. Never commit or push directly to main.
· Push the branch to origin and open a Pull Request against main. Do NOT merge the PR yourself. The team lead merges. Do not enable auto-merge. Do not approve your own PR.
· Before opening the PR, the following must pass locally, in this order:
  1. dart format --set-exit-if-changed .
  2. flutter analyze
  3. flutter test
· If any step fails, fix it and re-run. Never push broken code with a "fix later" note.
· After the PR is opened, CI (.github/workflows/ci.yml) runs the same checks. If CI fails: read the failure log, fix the code, push new commits to the same branch. Never open a second PR for the same feature.
· Do not force-push, rebase, or rewrite history on a branch that already has an open PR unless explicitly asked.
· Do not touch other branches. Do not modify files under .github/ unless the task is specifically about CI.

1. Architecture & State

· Clean Architecture, each feature in lib/features/<name>/ with three separate layers:
  · domain: Entities, Repository interfaces, UseCases (pure Dart: no Flutter, no Firebase, no JSON).
  · data: Models, DataSources (Firebase), Repository implementations.
  · presentation: bloc/cubit, pages, widgets.
· Presentation must never call a DataSource or Repository directly; only UseCases.
· State management: flutter_bloc only (Cubit or Bloc with equatable). No setState for network data.
· Repositories return Either<Failure, T> (using fpdart or dartz) and convert FirebaseException into custom Failure classes.
· FutureBuilder and StreamBuilder are forbidden in UI. Firestore streams must be mapped to Streams in the Repository and consumed by BLoC/Cubit.
· setState only for tiny local widget state (password visibility, local animation), never for network/Firestore data.

2. UI, Theme, Responsiveness & Colors

· DRY: any widget reused or likely reused across screens goes once in lib/core/widgets/.
