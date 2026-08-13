# Siraty Guided Autopilot

Start Codex in this repository and run:

```text
$siraty-autopilot Start or resume Siraty from repository state. Progress through
the next Spec Kit stage, then complete one safe task at a time. After every task,
verify it, update progress and the learning log, create one local commit, teach
me what was done and show the exact prompt, then continue until a pause condition
or release gate. Never include unrelated changes and never push or publish.
```

Sequence:

```text
Select release → Specify → Clarify → Plan → Tasks → Checklist → Analyze
→ Implement one task → Verify → Learn → Commit → Next task → Release gate
→ Next release specification
```

Pause for material product/design choices, religious changes, permissions/privacy/
dependencies, migrations, destructive operations, unexplained external failures,
and external actions such as push or release.

One completed task equals one focused local commit. Every task also creates
`docs/learning/<release>/<task>.md` with its prompt, decisions, code explanation,
tests, risks, commit, and a small exercise.

Control prompts:

```text
$siraty-autopilot Finish and commit the current task, then pause.
```

```text
$siraty-autopilot Explain the current spec, plan, and next task as a lesson. Do
not edit or commit anything.
```

```text
$siraty-autopilot Resume from docs/PROGRESS.md and repository evidence.
```
