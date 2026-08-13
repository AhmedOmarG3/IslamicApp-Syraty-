# Stage prompts

Specify: `$speckit-specify Create the specification for [RELEASE] using AGENTS.md, docs/PRODUCT.md, docs/MASTER_PLAN.md, docs/ROADMAP.md, and the constitution. Define outcomes, journeys, failure/offline/stale states, Arabic RTL/accessibility, religious integrity, compatibility, acceptance criteria, and release gate. Do not write code.`

Clarify: `$speckit-clarify Review [RELEASE] for choices affecting users, religious integrity, time/location, migration, permissions, privacy, offline behavior, accessibility, or release safety. Resolve from evidence; pause only for material choices.`

Plan: `$speckit-plan Inspect the real Siraty code and create the technical plan for [RELEASE], including architecture, data flow, UI states, compatibility, migration, tests, observability, performance, rollout, and rollback. Avoid a rewrite.`

Tasks: `$speckit-tasks Generate dependency-aware tasks for [RELEASE]. Each implementation task must fit one focused local commit and name verification evidence. Put safety tests first.`

Quality: `$speckit-checklist Check correctness, religious integrity, offline/failure behavior, RTL/accessibility, compatibility, and release safety.` Then `$speckit-analyze` for artifact contradictions, missing criteria, oversized tasks, and release gaps.

Implement: `$speckit-implement Implement only [TASK ID: TITLE]. List files, assumptions, risks, acceptance criteria, and verification commands first. Preserve unrelated changes. Verify, update task/progress/learning artifacts, stage only task files, review the staged diff, and create one local Conventional Commit containing the task ID. Show Ahmed the prompt, decisions, diff summary, tests, commit, self-check, and next task; continue only if no autopilot pause condition applies.`
