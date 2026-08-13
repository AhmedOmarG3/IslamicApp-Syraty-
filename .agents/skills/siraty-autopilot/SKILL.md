---
name: siraty-autopilot
description: Guide Siraty development continuously from the master roadmap through one Spec Kit release and task at a time. Use when Ahmed asks to start, continue, resume, or automatically progress Siraty work; select the next safe spec/task, run the required Spec Kit stage, implement only one task, verify it, create a local atomic commit, update progress and learning logs, explain the exact prompt and work performed, then continue until a safety pause or release gate is reached.
---

# Siraty Guided Autopilot

Read `AGENTS.md`, product/roadmap/autopilot/progress documents, the constitution,
active spec artifacts, relevant code/tests, and Git diff. Read
`references/stage-prompts.md` when changing a Spec Kit stage.

## State machine

1. Select the next incomplete release from `docs/PROGRESS.md`.
2. Run `$speckit-specify` if no spec exists.
3. Run `$speckit-clarify` for unresolved ambiguity.
4. Run `$speckit-plan` if no plan exists.
5. Run `$speckit-tasks` if no task list exists.
6. Run `$speckit-checklist` and `$speckit-analyze` before implementation.
7. Select exactly one safe unblocked task.
8. Implement, verify, document, and commit it.
9. Repeat while safe; after the release gate, start the next release spec.

Reuse valid artifacts instead of regenerating them.

## One task, one commit

Before each task, announce ID/outcome, expected files, assumptions, risks,
acceptance criteria, verification commands, and exact prompt. Split oversized
tasks in `tasks.md`. Run focused checks, formatting, `flutter analyze` for Dart
changes, relevant tests, `git diff --check`, and staged-diff review. Never commit
a failing task.

After completion, update `tasks.md`, create a learning entry, update
`docs/PROGRESS.md`, stage only task files, review the staged diff, and create one
local Conventional Commit containing the task ID. Never include unrelated user
changes. Never amend, reset, rebase, push, tag, or publish without explicit request.

## Teach after every task

Report outcome, exact prompt, decisions, files, tests, commit, what Ahmed should
practice, one self-check question, and the next task. Continue automatically
unless a pause condition applies.

## Pause conditions

Pause before verified religious-content changes; unresolved prayer/religious
defaults; permissions, analytics, ads, auth, payments, cloud data, or consequential
dependencies; package/signing/routes/persisted-key/schema/migration changes;
destructive operations; push/PR/tag/publish/Play actions; materially different
visual choices; unexplained out-of-scope failures; or constitution conflicts.

Create `docs/learning/<release>/<task-id>-<short-name>.md` from the task template.
