# Plan: ASC DSL in filename patterns

| Field | Value |
|-------|--------|
| **Date** | 2026-07-24 |
| **Status** | plan / review (not implemented) |
| **Scope** | ASC repo `/home/paul/Documents/asc` — filename grammar for subjects, actions, hooks, wraps; matching runtime actions; MAKE_TASKS_SHORTER abbreviations |
| **Related** | Prior idea `data/ideas/2026/07/23/dsl.md` (**syntax superseded** by this plan); `data/ideas/2026/07/23/wrappers-nest-bridges.md`; `docs/asc/organization.md` (subjects/actions/hooks); `docs/asc/wrappers.md`; `docs/asc/archive/hooks.md`; naming plan `changelog/2026/07/23-f-e-naming-convention.md` (`p_` / `o_` / `f_*`) |
| **Lifecycle** | Local review stub: `data/plans/review/2026-07-24-filename-dsl.md` (dir mostly gitignored — **this changelog is the tracked SoT**, same pattern as `23-f-e-naming-convention.md`). Move stub across `review` → `iterate` → `accepted` / `rejected` per `data/ideas/2026/07/23/idea-changelog-workflow.md`. |

---

## Context

ASC already treats **folders as subjects** and **files as actions**, with hooks as dotted / prefixed filename events (`*.hook.sh`, optional `-c yml`) and wraps as `*.wrap.sh`. Make shortcuts and synonyms (`lt`, `ll`, …) shorten operator surface; living docs still describe lookup mostly as dotted variants (`init.local.dev.hook.sh`).

Operators want a **filename DSL** so a single path under `$subject/$action/` can encode wrap stacks, nest chains, and arg/option payloads — and so each DSL construct maps to a concrete **matching action** (`wrap`, `nest`, `arg` / option semantics).

**This document is plan-only.** Do not implement parsers, generators, or new hook loaders until the plan is accepted and implementation is explicitly requested.

---

## Goals

1. Define a **filename grammar** for ASC DSL fragments used in paths under any `$subject` (and especially `$subject/$action/…`).
2. Bind each construct to a **matching action** name and semantics.
3. Align **MAKE_TASKS_SHORTER** abbreviations (`arg`, `o`, `f`) with synonyms and **variable prefixes**.
4. Require that **`$action` files are explicitly created** (including when generated under `data/asc`) — no invisible “function-only” actions.
5. Leave room for **smart YAML defaults** (`*.hook.yml`) with future `asc.extendable` / `asc.overridable` knobs.

Non-goals for this plan: shipping the parser; rewriting existing `*.hook.sh` trees; changing make synonym maps in code.

---

## Filename DSL grammar

Informal EBNF (filename / path fragment level; separators are literal characters in the name):

```text
fragment     := atom ( nest | wrap | args )* ( '.' token )* suffix?
atom         := name
name         := [A-Za-z0-9_-]+
nest         := '.' atom          # nester: foo.bar
wrap         := '(' fragment ')'  # wrapper: foo(bar)
args         := '[' arglist ']'
arglist      := arg ( ',' arg )*
arg          := positional | option
positional   := freeform          # no o- prefix
option       := 'o-' freeform     # option token
freeform     := [A-Za-z0-9_.-]+   # agnostic token (may itself nest/wrap in full grammar — see phases)
suffix       := '.' ( 'hook' | 'wrap' | … ) ( '.' variant )* ( '.' ext )
ext          := 'sh' | 'yml' | …
```

### Constructs → matching actions

| Construct | Shape | Matching action | Semantics |
|-----------|--------|-----------------|-----------|
| **Wrapper** | `foo(bar)` | `wrap` | Outer `foo` wraps inner `bar` (call/supervision stack). Same family as today’s `*.wrap.sh` / logged wrappers (`lt`, `ll`, …). |
| **Nester** | `foo.bar` | `nest` | `bar` is nested under / relative to `foo` (scope, subject nesting, or nested entry). Distinct from wrap — see wrappers-vs-nesters. |
| **Args (bracket list)** | `foo[…]` | `arg` (and option rules below) | Declares arguments for `foo`; list is ordered; members classified as positional vs option. |

#### Arg list variants

| Pattern | Matching action / rule | Notes |
|---------|------------------------|-------|
| `foo[bar]` | positional `arg(*)` | Agnostic / **freeform** synonym: single positional payload `bar`. |
| `foo[bar,o-option-bar]` | `option("o-*")` \| `arg(*)` | Mix: freeform positional + option token(s) prefixed `o-`. |
| `foo[bar,o-option-bar,bar_2,o-option_other-bar_2]` | `arg(o("o-*") \| *)` | Ordered list: each member is either an `o-*` option or a freeform positional (`*`). |

**Option token rule:** any bracket member starting with `o-` is an **option**; everything else in `[]` is a **positional / freeform** argument.

**Nest vs wrap (do not conflate):**

- `foo.bar` → **nest** (structure / ownership / nested subject plane).
- `foo(bar)` → **wrap** (runtime supervision / launch stack).
- Earlier raw idea (`data/ideas/2026/07/23/dsl.md`) swapped these punctuation roles (`.` = wrap, `()` = nest). **This plan is SoT;** that idea is historical and should be marked superseded when docs are updated.

---

## MAKE_TASKS_SHORTER abbreviations

Proposed shortening map entries (name illustrative; wire into the same synonym / make-shortening machinery as `ASC_SYNONYMS` / existing `lt`/`ll` maps when implementing):

| Key | Expansion | Synonyms | Variable prefix |
|-----|-----------|----------|-----------------|
| `arg` | argument | positional arg, positional argument | `p_` |
| `o` | option | option, optional arg, optional argument | `o_` |
| `f` | function | entry point, action (workflow-equivalent) | **none** |

### Variable prefix rules

| Class | Prefix | Rule |
|-------|--------|------|
| Argument (positional / freeform) | `p_` | Shell locals / params for DSL positionals (aligns with naming plan + organization ideas). |
| Option | `o_` | Shell locals / params for `o-*` DSL options (aligns with `changelog/2026/07/23-f-e-naming-convention.md`). |
| Function / entry point / action | *(none)* | Do **not** invent a `f_` *variable* prefix for actions. From a workflow standpoint, “function”, “entry point”, and “action” name the **same operable unit**. |

### Explicit `$action` files (hard rule)

Corresponding **`$action` files must be explicitly created**, even when generated under `data/asc/`:

- Discovery remains “files = actions” (`docs/asc/organization.md`).
- Generated trees may *emit* action files, but must not invent callable make/hooks that have no on-disk `$subject/$action…` artifact.
- `f` / function / entry-point abbreviations shorten **task names**, not a hidden symbol table.

**Note:** The separate naming-convention plan uses `f_*` for **shell utility functions** (`u_*` → `f_*`). That is a **code symbol** prefix, not a filename-DSL / make-task variable prefix. Do not confuse `MAKE_TASKS_SHORTER[f]` (no action var prefix) with `f_*` utility renames.

---

## Concrete examples (any `$subject` dir)

Paths are illustrative; exact lookup roots stay `asc/`, extensions, contrib, extend (and overrides).

### 1. Simple wrapped source hook (custom shell)

```text
$subject/$action/source(code).available.hook.sh
```

- `source(code)` → **wrap** (`source` wraps `code`).
- Trailing `.available.hook.sh` → hook event / variant surface (existing hook naming).
- `.sh` → custom wrapper implementation (sourceable shell).

### 2. Logged-thread style stack with nests + args (custom shell)

```text
$subject/$action/lt(agent[role-prompt-analyst].start[loop.heartbeat](data[inbox].unread).start.hook.sh
```

Interpretation (intent; balance/paren nesting to be formalized in Phase 1 grammar tests):

| Fragment | Action |
|----------|--------|
| `lt(…)` | **wrap** — logged-thread (or synonym) wraps the inner chain |
| `agent[role-prompt-analyst]` | **arg** — positional freeform `role-prompt-analyst` on `agent` |
| `agent[…].start` | **nest** — `start` nested under `agent[…]` |
| `start[loop.heartbeat]` | **arg** + inner **nest** `loop.heartbeat` as freeform / nested token inside brackets |
| `…(data[inbox].unread)` | **wrap** of nested `data[inbox].unread` |
| `data[inbox]` | **arg** positional `inbox` on `data` |
| `.start.hook.sh` | hook suffix / phase |

If the script is a **custom wrapper**, keep **`.hook.sh`**.

### 3. Same shape with smart YAML defaults

```text
$subject/$action/lt(agent[role-prompt-analyst].start[loop.heartbeat](data[inbox].unread).start.hook.yml
```

- Same DSL filename meaning as (2).
- **`.yml`** → use **smart defaults** instead of a hand-written shell body.
- **TODO (open):** `asc.extendable` + `asc.overridable` (names TBD) so YAML hooks can declare whether project extend/override layers may refine defaults — complements today’s `scripts/asc/extend` / `scripts/asc/override` and `-c yml` hook lookup.

---

## Alignment with existing conventions

| Existing | How this plan fits |
|----------|-------------------|
| Subjects = folders, actions = files | DSL lives *in* action/hook filenames; does not replace folder subjects. |
| `*.hook.sh` / `hook -c yml` | Suffix `.hook.sh` vs `.hook.yml` chooses impl style; DSL is the *stem*. |
| `*.wrap.sh`, logged wrappers `lt`/`ll`/… | `foo(bar)` **wrap** should resolve toward wrap scripts / make wrap stacks. |
| Nested subjects / `.asc_subjects_ignore` | `foo.bar` **nest** should map toward nest/nested-extension semantics (`docs/asc/wrappers.md` § nested). |
| `p_` / `o_` naming plan | Bracket positionals → `p_*`; `o-*` tokens → `o_*`. |
| `data/asc/` generated state | May generate files; still must materialize explicit `$action` artifacts. |
| Variant dotted hooks today (`init.local.dev.hook.sh`) | Remain valid; DSL adds `()`, `[]`, and richer stems — precedence vs pure variant dots is an open task. |

---

## Implementation phases (for later coding)

### Phase 0 — Accept / freeze grammar

- [ ] Accept or amend this plan (review → iterate → accepted).
- [ ] Freeze punctuation SoT (`()` = wrap, `.` = nest, `[]` = args) vs superseded `dsl.md` idea.
- [ ] Decide interaction with today’s dotted **variant** filenames (same `.` character).
- [ ] Name and sketch `asc.extendable` / `asc.overridable` (or reject names).

### Phase 1 — Spec + tests (no production wiring)

- [ ] Formal grammar + lexer rules (escaping, allowed chars, max depth).
- [ ] Golden filename → AST fixtures (include the three examples above).
- [ ] Document AST → matching actions (`wrap` / `nest` / `arg` / option).

### Phase 2 — Runtime matching actions

- [ ] Implement or map to existing `wrap` / nest helpers.
- [ ] Bind bracket members to `p_*` / `o_*` in calling scope.
- [ ] Ensure make/task shortening understands `arg` / `o` / `f` synonyms.

### Phase 3 — Hook loaders + YAML smart defaults

- [ ] Teach hook discovery to parse DSL stems (or pre-normalize to cache keys).
- [ ] `.hook.yml` smart-default loader; stub extendable/overridable policy.
- [ ] Cache layout: prefer readable paths under `data/asc/…` if regenerating caches (see organization.md ideal cache shape).

### Phase 4 — Explicit action materialization

- [ ] Generator / builder: always emit concrete `$action` files when DSL expands entry points.
- [ ] Refuse “function-only” make targets with no file artifact.
- [ ] Docs: organization + wrappers + hooks; mark old `dsl.md` punctuation superseded.

### Phase 5 — Verification

- [ ] Unit tests on parser; hook dry-run (`-t`) lists DSL paths.
- [ ] Smoke: custom `.hook.sh` vs `.hook.yml` defaults.
- [ ] `make reinit` / `make cc` after registry changes.
- [ ] Grep/docs gates for SoT punctuation and prefix rules.

---

## Risks / safety notes

| Risk | Notes |
|------|--------|
| `.` overload | Nest DSL vs existing variant dots — ambiguous without precedence rules. |
| Shell-hostile filenames | `()`, `[]` in paths can break naive scripts; need quoting conventions and maybe encoded cache names. |
| Superseding `dsl.md` | Agents may follow old idea; changelog + idea banner required when accepted. |
| Confusing `f` abbrev with `f_*` utilities | Document both namespaces in living docs when implementing. |
| Generated-only actions | Violates explicit-file rule; treat as bug. |
| Plan-only | Do not land parser/loader changes until accepted + requested. |

**Safety:** do not hand-edit gitignored generated caches as SoT; regenerate. Do not implement in nested/foreign repos from this work tree.

---

## Open questions

1. **Variant dots vs nest dots:** same character — require a delimiter, reserved suffix zone (`.hook` / `.wrap`), or parse right-to-left from known suffixes?
2. **Nested DSL inside `[]` / `()`:** allow full fragments recursively in v1, or only flat tokens first?
3. **`asc.extendable` / `asc.overridable`:** file-level YAML keys, entity `.able.yml`, or hook metadata?
4. **MAKE_TASKS_SHORTER wiring:** new global map vs extend `ASC_SYNONYMS`?
5. **Example (2) paren balance:** confirm canonical spelling of the long `lt(agent…` example before locking fixtures.
6. **Relation to make `e:` / `a:` notation:** keep both, or eventually express CLI args with the same `[]` / `o-` grammar?
7. **Should `wrap` / `nest` become first-class subjects/actions** (`asc/wrap/`, `asc/nest/`) or stay internal matcher verbs?

---

## Open tasks (summary)

- [ ] Review this plan; move to `data/plans/iterate/` or `accepted/` / `rejected/`
- [ ] Update or banner `data/ideas/2026/07/23/dsl.md` as superseded on accept
- [ ] Phase 0 decisions (especially `.` ambiguity + YAML extend/override names)
- [ ] Implement only after explicit go-ahead (Phases 1–5)

---

## Appendix — Quick reference card

```text
foo(bar)                         → wrap
foo.bar                          → nest
foo[bar]                         → arg(*) freeform / positional  → p_
foo[bar,o-option-bar]            → option(o-*) | arg(*)          → o_ / p_
foo[a,o-x,b,o-y]                 → arg(o("o-*") | *)             → ordered mix

MAKE_TASKS_SHORTER:
  arg → argument (p_)
  o   → option   (o_)
  f   → function / entry point / action  (no var prefix; explicit $action file)
```
