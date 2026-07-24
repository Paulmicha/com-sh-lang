# Plan: ASC DSL in filename patterns

| Field | Value |
|-------|--------|
| **Date** | 2026-07-24 |
| **Status** | plan / review (not implemented; multi-shell groundwork WIP on branch) |
| **Scope** | ASC repo `/home/paul/Documents/asc` — filename grammar for subjects, actions, hooks, wraps; matching runtime actions; MAKE_TASKS_SHORTER abbreviations; **shell-agnostic runtime** (`ASC_SHELL`; multi-shell `inc` / `opt-inc` loaded by a **single dedicated include-loader hook**); primordial layout under `asc/asc/`; **tests as first-class deliverables** (shunit2 / `make test-asc`; cases may themselves be nest/wrap DSL steps); **Cursor rules** so agent-produced ASC edits respect all locked naming conventions |
| **Related** | Prior idea `data/ideas/2026/07/23/dsl.md` (**syntax superseded** by this plan); `data/ideas/2026/07/23/wrappers-nest-bridges.md`; `data/ideas/2026/07/23/genericity-taxonomy.md`; `docs/asc/organization.md` (subjects/actions/hooks); `docs/asc/wrappers.md`; `docs/asc/archive/hooks.md`; naming plan `changelog/2026/07/23-f-e-naming-convention.md` (`p_` / `o_` / `f_*`); WIP on `naming-convention-changelog`: `648a4d7` (begin multi shell), `8f3faa8` (utilities → `asc/asc/`), `f971316` (**final primordial layout**: eager `*.inc.sh` core + `asc/asc/utils/*.opt-inc.sh`) |
| **Lifecycle** | Local review stub: `data/plans/review/2026-07-24-filename-dsl.md` (dir mostly gitignored — **this changelog is the tracked SoT**, same pattern as `23-f-e-naming-convention.md`). Move stub across `review` → `iterate` → `accepted` / `rejected` per `data/ideas/2026/07/23/idea-changelog-workflow.md`. |

---

## Context

ASC already treats **folders as subjects** and **files as actions**, with hooks as dotted / prefixed filename events (`*.hook.sh`, optional `-c yml`) and wraps as `*.wrap.sh`. Make shortcuts and synonyms (`lt`, `ll`, …) shorten operator surface; living docs still describe lookup mostly as dotted variants (`init.local.dev.hook.sh`).

Operators want a **filename DSL** so a single path under `$subject/$action/` can encode wrap stacks, nest chains, and arg/option payloads — and so each DSL construct maps to a concrete **matching action** (`wrap`, `nest`, `arg` / option semantics).

The same filename / include surface must stay **shell-generic**: today’s default runtime is bash, but bootstrap `inc` / `opt-inc` (and eventually DSL suffixes) must be selected by **`ASC_SHELL`** (zsh, posix, powershell, cmder, …) without forking the subject/action model.

**Locked decision — single include-loader hook (not “includes are hooks”):** there is **one dedicated hook** that loads includes. Include files themselves are **not** hook implementations (plural). That loader hook resolves bodies by **`ASC_SHELL`**:

1. **Specific alternate (if it exists):** load `*.$ASC_SHELL.inc.sh` / `*.$ASC_SHELL.opt-inc.sh` (e.g. `*.zsh.inc.sh`, `*.posix.opt-inc.sh`).
2. **Bash = default + fallback:** when `ASC_SHELL=bash`, or when the shell-specific alternate is missing, load the bash include set.

**On-disk bash/default+fallback form:** keep unqualified `*.inc.sh` / `*.opt-inc.sh` as the bash set (primordial layout stays as-is). Shell segment still sits **before** `inc` / `opt-inc` for alternates (`name.<shell>.inc.sh`). Eager (`inc`) vs lazy (`opt-inc`) load timing still applies (when the loader hook runs / which kind it requests).

**Groundwork already pushed (WIP, incomplete):** see [Multi-shell groundwork](#multi-shell-groundwork-already-pushed). Completing that wiring is **in scope for this plan** (before or alongside DSL parser work) — not a separate abandoned experiment.

**This document is plan-only for the DSL parser / loaders.** Do not implement parsers, generators, or new hook loaders until the plan is accepted and implementation is explicitly requested. Completing the already-pushed multi-shell groundwork is an explicit work item below; still do not expand it until go-ahead.

---

## Goals

1. Define a **filename grammar** for ASC DSL fragments used in paths under any `$subject` (and especially `$subject/$action/…`).
2. Bind each construct to a **matching action** name and semantics.
3. Align **MAKE_TASKS_SHORTER** abbreviations (`arg`, `o`, `b`, `f`, plus illustrative `llv-get` / `llv-set`) with synonyms and **variable prefixes** (`p_` / `o_` / `b_` / none for actions).
4. Require that **`$action` files are explicitly created** (including when generated under `data/asc`) — no invisible “function-only” actions.
5. Leave room for **smart YAML defaults** (`*.hook.yml`) with future `asc.extendable` / `asc.overridable` knobs; **`slot` lives in the YAML hook definition** (not in the filename-DSL stem).
6. Express **relations / fields** in the filename DSL with the **locked complete mapping** below; resolve via `$action.able.yml` to `$subject.$action`; keep distinct from the first-`-` intra-token split.
7. Keep the DSL / include runtime **shell-agnostic**: default `ASC_SHELL=bash`, alternate shells via filename / lookup conventions; **finish implementing** the multi-shell groundwork already on the branch.
8. Route multi-shell **`inc` / `opt-inc` loading through a single dedicated include-loader hook** driven by `ASC_SHELL` (bash default+fallback; shell-specific alternate only if present). Eager vs lazy kinds still apply.
9. **Create tests as part of implementation** (not an afterthought): shunit2 cases under the existing ASC harness (`make test-asc` → `asc/test/asc/*.test.sh`), including grammar/AST goldens and runtime nest/wrap/arg smoke. Test steps themselves may be expressed with the same DSL — **nest** (`foo.bar`) or **wrap** (`foo(bar)`) — including arg/synonym patterns such as `log.level_get` / `log.level_set` and shorter forms `llv-get` / `llv-set`.
10. **Cursor rules** (project-local `.cursor/rules/*.mdc`): any Cursor-produced modification under this ASC repo must respect **all naming conventions locked by this plan** (and the related `f_*` / `e_*` / `o_*` naming plan where symbols apply) — before Phase 1+ coding, not as a docs afterthought.

Non-goals for this plan: shipping the full DSL parser; rewriting existing `*.hook.sh` trees wholesale; changing make synonym maps in code; implementing non-bash shell bodies in v1 (convention + lookup first); inventing a huge new rules essay. Do **not** invent a parallel test runner — extend `docs/asc/testing.md` / `asc/test/` conventions.

---

## Filename DSL grammar

Informal EBNF (filename / path fragment level; separators are literal characters in the name):

```text
fragment     := atom ( nest | wrap | args | relation )* ( '.' token )* suffix?
atom         := name
name         := [A-Za-z0-9_-]+
nest         := '.' atom          # nester: foo.bar
wrap         := '(' fragment ')'  # wrapper: foo(bar)
args         := '[' arglist ']'
arglist      := arg ( ',' arg )*
arg          := positional | boolean | option
positional   := freeform          # no o- / b- prefix
boolean      := 'b-' freeform     # boolean flag token
option       := 'o-' freeform     # option token
relation     := field_rel | triple_rel
field_rel    := '(' field_subj ')' '--' '(' field_obj ')'
# locked field form:
#   (field.able.subject)--(field.able.object)
triple_rel   := '(' triple_subj ')' '--' '(' triple_pred ')' '--' '(' triple_obj ')'
# locked triple form (the rest):
#   (triple.able.subject)--(triple.able.predicate)--(triple.able.object)
field_subj   := freeform          # field.able.subject
field_obj    := freeform          # field.able.object
triple_subj  := freeform          # triple.able.subject
triple_pred  := freeform          # triple.able.predicate
triple_obj   := freeform          # triple.able.object
freeform     := [A-Za-z0-9_.-]+   # agnostic token (may itself nest/wrap in full grammar — see phases)
suffix       := ( '.' shell_id )? '.' ( 'hook' | 'wrap' | 'inc' | 'opt-inc' | … ) ( '.' variant )* ( '.' ext )
shell_id     := 'zsh' | 'posix' | 'powershell' | 'cmder' | …   # omitted ⇒ ASC_SHELL default (bash)
ext          := 'sh' | 'yml' | 'ps1' | …                       # ext policy for non-sh shells still open
```

**Shell in the suffix (locked):** `shell_id` sits **before** the include kind (`inc` / `opt-inc`), not after it.

**Hyphen / underscore layers (locked — do not conflate):**

| Surface | Shape | Role |
|---------|-------|------|
| **First `-`** (single hyphen inside a token) | `head-tail`, `o-…`, `b-…` | Intra-token head/tail split — **not** a relation construct; replaces the superseded same-word `_` rule. **Positional meaning is locked.** |
| **Optional `_`** (prefix in `$action` stem — **position matters**) | `$subject_$action…` / `$object_$action…` | Soft reading of a leading `_`-separated segment as `$subject` or `$object`, then `$action` (see below). **Not** a same-word / head-tail separator; **not** folder nest; **not** a relation. |
| **Field `--`** | `(field.able.subject)--(field.able.object)` | **Field** relation (two able members) |
| **Triple `--`…`--`** | `(triple.able.subject)--(triple.able.predicate)--(triple.able.object)` | **Triple** / the rest (three able members) |

**First `-` separator policy (locked — replaces “same-word separator”):** do **not** invent a special same-word separator rule (the superseded idea `data/ideas/2026/07/23/dsl.md` proposed `_` for that). Compound key/value (and similar head/tail) splits **inside** freeform / prefixed tokens are read from the **position of the first `-`**: left of the first hyphen = head/key; right = remainder/value (further single `-` in the remainder are literal content, not a second separator class). This policy applies **inside** tokens; it does **not** compete with relation `--` delimiters between `(…)` able members.

#### Optional `_` prefix in `$action` naming (locked intent — not enforced)

Because first-`-` already owns positional head/tail meaning, `_` is **free** for a different, softer role. The `_`-separated **prefix in `$action`** (**position matters**) **can** (not must / not enforced) mean:

```text
$subject / $object _ $action . (variants)? . (hook|inc|opt-inc)? . sh
```

I.e. an optional reading of an `$action` filename / stem where:

1. A **leading** `_`-separated segment is `$subject` or `$object`,
2. then `$action`,
3. then optional dotted **variants**, then optional **`hook` / `inc` / `opt-inc`**, then **`.sh`**.

**Position matters:** only a leading `_` prefix on the `$action` stem carries this soft reading. Later `_` inside the action name (or inside a first-`-` remainder) may stay ordinary multi-word glue / literal content unless the author intends the prefix reading.

**Contrast with relations (do not conflate):**

| Construct | Delimiter | Role |
|-----------|-----------|------|
| **Relations** | `--` between `(…)` able members | Locked **field** / **triple** able mapping → `$action.able.yml` → `$subject.$action` |
| **Optional `_`** | `_` inside `$action` naming | Soft **prefix** reading (`$subject` / `$object` then `$action`) — **not** a replacement for relations |

Do **not** require `_` anywhere; do **not** revive the superseded same-word `_` rule — that job stays with first `-`. Do **not** treat this `_` rule as a relation construct or as folder / DSL `.` nest.

Illustrative shapes (intent only — not enforced):

| Filename / stem | Soft `$action`-prefix reading |
|-----------------|-------------------------------|
| `db_dump.sh` | `$subject`/`$object` `db` + `$action` `dump` |
| `remote_sync.hook.sh` | prefix `remote` + action `sync` + `.hook.sh` |
| `host_setup.local.opt-inc.sh` | prefix `host` + action `setup` + variant `local` + `.opt-inc.sh` |

**Most minimal implementation (prefer this — docs / convention first, not Phase 1–3 DSL parser):**

1. **Docs + convention only (default next step):** lock the `$action`-prefix reading above; when living docs are touched, one short note — no new runtime.
2. **No parser obligation:** do not add a filename-DSL lexer rule that *requires* `_` = `$subject`/`$object` prefix.
3. **No conflation** with first-`-` head/tail or with relation `--`.

**Explicitly do NOT build yet:**

- No mandatory `_` = subject/object prefix in the DSL lexer.
- No mass rename of existing action stems to force the prefix pattern.
- No hierarchy resolver or make-target rewriting from `_` splits.
- No conflation with first-`-` or with relation `--`.

#### Historical / peer-subject note (demoted — not the locked `_` SoT)

Earlier drafts elaborated `_` as a soft **sub-`$subject` / remote-family** hint on **peer subject IDs** (e.g. `remote_db`, `remote_asc`, contrib `remote_traefik` beside `remote`). That reading is **demoted**: it may still describe how some flat subject/extension folder names look today, but it is **not** the locked optional-`_` intent for this plan.

- **Locked SoT for `_`:** soft **prefix in `$action`** naming (`$subject` / `$object` `_` `$action` …) — see above.
- **Peer IDs like `remote_db`:** historical / discoverability footnote only — flat compound subject IDs, not the `$action`-prefix rule. Folder nest stays path segments (`remote_db/remote/…`); DSL nest stays `.`.
- Do **not** treat every `_` in an action stem as a subject/object prefix (`db_dump` may still be ordinary multi-word glue when the author does not intend the soft reading).

Illustrative (from the same idea file’s examples, punctuation roles updated to this plan’s SoT):

| Token | First `-` split | Meaning |
|-------|-----------------|---------|
| `retention-5m` | `retention` \| `5m` | key/value style freeform (single `-`) |
| `b-oneline` | (after `b-` prefix) `oneline` | boolean flag `oneline` — idea form `instance-giw[log,b-oneline]` |
| `o-s-gpt` | (after `o-` prefix) `s` \| `gpt` | option head `s`, value `gpt` |

So `instance-giw[log,b-oneline]` needs no `_`-as-same-word rule: `instance` / `giw` relates on the first `-` in the atom; `b-oneline` is a boolean member. Optional `_` remains available for the soft `$action`-prefix reading above — never as a mandatory same-word separator, never as a `--` relation.

#### Relations / fields (locked — mapping complete)

**The mapping is now really complete.** Locked filename-DSL forms:

**1. Fields**

```text
(field.able.subject)--(field.able.object)
```

**2. Triples / the rest**

```text
(triple.able.subject)--(triple.able.predicate)--(triple.able.object)
```

| Form | Members | Role |
|------|---------|------|
| Field | `(field.able.subject)` `--` `(field.able.object)` | Field relation between two able refs |
| Triple | `(triple.able.subject)` `--` `(triple.able.predicate)` `--` `(triple.able.object)` | Full relation triple (predicate is **`triple.able.predicate`**, not bare `triple.predicate`) |

**YAML mapping (locked, consistent):** both forms are **mappable to `$subject.$action` via `$action.able.yml`** (capability / relation YAML colocated with the action — same family as entity `.able` ideas). Exact schema keys TBD in Phase 1–3; stems resolve through **`$action.able.yml`**, not a parallel ad-hoc namespace.

| Filename DSL | Resolves toward |
|--------------|-----------------|
| `(field.able.subject)--(field.able.object)` | Field entry on `$subject/$action` via `$action.able.yml` |
| `(triple.able.subject)--(triple.able.predicate)--(triple.able.object)` | Triple on `$subject/$action` via `$action.able.yml` |
| `$subject.$action` | Nest path whose actionable contract may include that `.able.yml` |

**Superseded (do not use as SoT):** bare `--` field without `(field.able.…)` members; bare `--relation--` / `foo--rel--bar`; incomplete `(triple.able.subject)--(triple.predicate)--(triple.able.object)` (missing `.able` on predicate); idea `dsl.md` sketches `relations : '--' (key-val) or '--foobar--' (triple)`.

**Include loading (locked):** a **single dedicated hook** loads `inc` / `opt-inc` files. Those files are include bodies, **not** hook implementations themselves. `hook` / `wrap` remain distinct kinds in the same suffix zone; `inc` = eager include; `opt-inc` = lazy / on-demand include (caller phase 90 and/or colocated seeding before `*.hook.sh` event bodies — see `docs/asc/organization.md`, `docs/asc/archive/bootstrap.md`, `u_hook_opt_inc_append_candidates` in `asc/asc/hook.inc.sh`).

| Form | Pattern | Meaning |
|------|---------|---------|
| Bash default + fallback | `*.inc.sh`, `*.opt-inc.sh` (unqualified) | Bash include set — used when `ASC_SHELL=bash` **and** as fallback when a shell-specific alternate is missing |
| Shell-specific alternate | `*.$ASC_SHELL.inc.sh`, `*.$ASC_SHELL.opt-inc.sh` | Loaded **only if it exists** (e.g. `*.zsh.inc.sh`, `*.posix.opt-inc.sh`) |

**Superseded sketch:** do **not** use `*.opt-inc.<shell>.sh` / `utilities.opt-inc.posix.sh` (shell segment after `opt-inc`). Canonical order for alternates is `name.<shell>.inc.sh` / `name.<shell>.opt-inc.sh`.

**Loader-hook lookup (locked fallback):**

```text
include_loader_hook(ASC_SHELL, kind ∈ {inc, opt-inc}):
  candidate := *.$ASC_SHELL.<kind>.sh          # e.g. *.zsh.inc.sh
  if candidate exists → source candidate
  else → source unqualified *.<kind>.sh        # bash default + fallback
```

When `ASC_SHELL=bash`, the unqualified bash set is the target (no need for a separate `*.bash.inc.sh` rename of primordial files). Alternates are never invented: missing file → bash fallback.

### Constructs → matching actions

| Construct | Shape | Matching action | Semantics |
|-----------|--------|-----------------|-----------|
| **Wrapper** | `foo(bar)` | `wrap` | Outer `foo` wraps inner `bar` (call/supervision stack). Same family as today’s `*.wrap.sh` / logged wrappers (`lt`, `ll`, …). |
| **Nester** | `foo.bar` | `nest` | `bar` is nested under / relative to `foo` (scope, subject nesting, or nested entry). Distinct from wrap — see wrappers-vs-nesters. |
| **Args (bracket list)** | `foo[…]` | `arg` (and boolean / option rules below) | Declares arguments for `foo`; list is ordered; members classified as positional, boolean, or option. |
| **Field** | `(field.able.subject)--(field.able.object)` | via `$action.able.yml` | Locked field form; maps to `$subject.$action`. |
| **Triple (the rest)** | `(triple.able.subject)--(triple.able.predicate)--(triple.able.object)` | via `$action.able.yml` | Locked complete triple; predicate is `triple.able.predicate`. |
| **Slot** | *(not a filename stem construct)* | YAML hook definition | **Locked:** `slot` is declared on the **`*.hook.yml` definition**, not as a bracket payload in the filename DSL. Superseded idea form `ollama-exec[slot]` must not be used. |

#### Arg list variants

| Pattern | Matching action / rule | Notes |
|---------|------------------------|-------|
| `foo[bar]` | positional `arg(*)` | Agnostic / **freeform** synonym: single positional payload `bar`. |
| `foo[b-oneline]` | boolean `b-*` | Boolean flag token(s) prefixed `b-` (idea example: `…[log,b-oneline]`). |
| `foo[bar,o-option-bar]` | `option("o-*")` \| `arg(*)` | Mix: freeform positional + option token(s) prefixed `o-`. |
| `foo[bar,b-flag,o-option-bar]` | `arg(*)` \| `b-*` \| `o-*` | Ordered mix of positional, boolean, and option members. |
| `foo[bar,o-option-bar,bar_2,o-option_other-bar_2]` | `arg(o("o-*") \| b("b-*") \| *)` | Ordered list: each member is `o-*`, `b-*`, or freeform positional (`*`). |

**Bracket member classification (locked):**

1. Starts with `b-` → **boolean** argument / flag.
2. Starts with `o-` → **option** (named).
3. Else → **positional / freeform** argument.

**Slot (locked — YAML hook definition, not filename DSL):**

- `slot` describes a fillable hole / horizontal attach point on a **YAML hook** (`*.hook.yml` fields — exact key names TBD in Phase 3).
- Do **not** encode `slot` as a bracket arg in the filename stem (superseded: `…(ollama-exec[slot])` in `data/ideas/2026/07/23/dsl.md`).
- **Wrapper vs slot:** wrap stacks stay filename / wrap-runtime (vertical supervision); slots stay YAML-hook definition (horizontal fill). Distinct from builder template slots in `docs/asc/builder.md` (scaffold hydration) — do not conflate those make/`slotable` notes with this DSL lock.

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
| `b` | boolean | boolean arg, boolean option, boolean flag | `b_` |
| `f` | function | entry point, action (workflow-equivalent) | **none** |
| `llv-get` | `log.level_get` | log level get, level_get | **none** (action synonym) |
| `llv-set` | `log.level_set` | log level set, level_set | **none** (action synonym) |

### Variable prefix rules

| Class | Prefix | Rule |
|-------|--------|------|
| Argument (positional / freeform) | `p_` | Shell locals / params for DSL positionals (aligns with naming plan + organization ideas). |
| Option | `o_` | Shell locals / params for `o-*` DSL options (aligns with `changelog/2026/07/23-f-e-naming-convention.md`). |
| Boolean | `b_` | Shell locals / params for `b-*` DSL boolean args / flags (same local-param pattern as `p_` / `o_`). |
| Function / entry point / action | *(none)* | Do **not** invent a `f_` *variable* prefix for actions. From a workflow standpoint, “function”, “entry point”, and “action” name the **same operable unit**. |

### Explicit `$action` files (hard rule)

Corresponding **`$action` files must be explicitly created**, even when generated under `data/asc/`:

- Discovery remains “files = actions” (`docs/asc/organization.md`).
- Generated trees may *emit* action files, but must not invent callable make/hooks that have no on-disk `$subject/$action…` artifact.
- `f` / function / entry-point abbreviations shorten **task names**, not a hidden symbol table.

**Note:** The separate naming-convention plan uses `f_*` for **shell utility functions** (`u_*` → `f_*`). That is a **code symbol** prefix, not a filename-DSL / make-task variable prefix. Do not confuse `MAKE_TASKS_SHORTER[f]` (no action var prefix) with `f_*` utility renames.

---

## Shell genericity (`ASC_SHELL` + single include-loader hook)

The DSL must be able to express **what ASC does today** (bash as default shell) while remaining **implementation-generic** across shells. Filename grammar, subject/action layout, and bootstrap include kinds (`inc` / `opt-inc`) stay the same; **one dedicated hook** loads those include files; **which body** depends on `ASC_SHELL` (bash default+fallback; shell-specific alternate only if present).

### `ASC_SHELL`

| Rule | Detail |
|------|--------|
| Default | `ASC_SHELL=bash` (current behavior; unqualified include files) |
| Source of truth (config) | Instance / specimen YAML already sketches `asc.shell` / `includes.default.shell` (see groundwork) |
| Runtime export | Wire YAML → exported `ASC_SHELL` (and keep overrideable from env) |
| Alternates (illustrative) | `zsh`, `posix`, `powershell`, `cmder`, … — especially relevant on non-bash hosts |
| Constraint | The **include-loader hook** must select include files by `ASC_SHELL` without hard-coding only bash paths forever |

### Filename convention for shell-specific includes (`inc` / `opt-inc`)

**Locked** path pattern — shell segment **before** `inc` / `opt-inc` for alternates. Bash keeps unqualified files as default+fallback:

```text
# Bash default + fallback (ASC_SHELL=bash, or alternate missing) — unqualified:
asc/asc/utils/shell.opt-inc.sh
asc/asc/core.inc.sh

# Specific alternate (ASC_SHELL=<shell>) — name.<shell>.(opt-)inc.sh — only if exists:
asc/asc/utils/shell.zsh.opt-inc.sh
asc/asc/core.zsh.inc.sh
asc/asc/utils/shell.powershell.opt-inc.sh   # ext policy still open (e.g. .ps1)

# Special future artifact (not a normal ASC_SHELL alternate — see Future next-step):
asc/asc/utils/shell.ideal.opt-inc.sh
```

| `ASC_SHELL` | Loader hook prefers | Fallback if missing |
|-------------|---------------------|---------------------|
| `bash` (default) | unqualified `*.inc.sh` / `*.opt-inc.sh` | *(already the bash set)* |
| `zsh` / `posix` / `powershell` / … | `*.$ASC_SHELL.inc.sh` / `*.$ASC_SHELL.opt-inc.sh` if present | unqualified bash set |

Same idea can apply later to event hooks / wraps when they gain shell bodies; for **includes**, only this single loader hook performs the selection.

### Primordial layout (settled in `f971316`)

Core lives under the **`asc` subject** (`asc/asc/…`) — not a separate `asc/shell/` subject for utilities.

| Kind | Path pattern | Role |
|------|--------------|------|
| Eager core | `asc/asc/{core,global,hook,autoload}.inc.sh` | Bootstrap-critical **includes** (`*.inc.sh` → `ASC_INC` via loader hook); `asc.opt-inc.sh` **renamed → `core.inc.sh`** (avoid subject/action name clash with subject `asc`) |
| Lazy utils | `asc/asc/utils/{array,fs,shell,string}.opt-inc.sh` | Optional **includes** under nested `utils/` (lazy `opt-inc`) |
| Other (current) | `asc/asc/yaml.opt-inc.sh` | Still at subject root as lazy `*.opt-inc.sh` (not moved into `utils/` in this push) |

**Decided:** keep helpers under `asc/asc/` (+ `utils/` nest); do **not** reintroduce `asc/shell/` as the home for these files. Suffix convention + `ASC_SHELL` resolution via the **single include-loader hook** remain the hard multi-shell rules. Do **not** treat each include file as a hook: keep eager `ASC_INC` (phase 60), lazy caller opt-inc (phase 90), and colocated opt-inc seeding into hook caches before `*.hook.sh` event bodies — with shell selection centralized in that loader hook.

### Bootstrap `inc` / `opt-inc` refactor (multi-shell via loader hook)

Today’s model (eager `*.inc.sh` → `ASC_INC`; lazy phase-90 `*.opt-inc.sh`) must be refactored so discovery:

1. Resolves **`ASC_SHELL`** early (phase 10 / pre-utilities; default `bash`).
2. Uses the **single include-loader hook** to pick bodies by **`ASC_SHELL`**: try `*.$ASC_SHELL.inc.sh` / `*.$ASC_SHELL.opt-inc.sh` if present; else unqualified bash `*.inc.sh` / `*.opt-inc.sh` (default + fallback).
3. Stops assuming only `#!/usr/bin/env bash`, `BASH_SOURCE`, and `shopt` for all future shells — bash remains the reference implementation; other shells get parallel entry/bootstrap later.
4. Updates phase **20** (core includes) and phase **90** (caller opt-inc) — and hook-cache opt-inc seeding — to the **settled** paths (`asc/asc/*.inc.sh`, `asc/asc/utils/*.opt-inc.sh`) + locked `.<shell>.(opt-)inc` alternate suffix rules, all going through the loader hook’s selection.
5. Keeps **genericity of implementation**: same subject/action/`inc`/`opt-inc` taxonomy; shell is a dimension of filename / loader-hook lookup, not a fork of ASC’s organization model.

---

## Multi-shell groundwork (already pushed)

Branch `naming-convention-changelog` (ahead of `main`) already started this. **Complete implementing that WIP** as part of this plan (before treating multi-shell as “done”).

| Commit | What landed | Still incomplete |
|--------|-------------|------------------|
| `648a4d7` *wip: begin multi shell support* | `SPECIMEN.env.yml`: `asc.shell: bash` (+ TODO); `SPECIMEN.remote_instances.yml`: `includes.default.shell: bash` wired into env includes; intermediate rename toward `asc/shell/utilities.opt-inc.sh` | No `ASC_SHELL` export; bootstrap still bash-only; no `.{shell}.opt-inc` / `.{shell}.inc` lookup |
| `8f3faa8` *wip: move utilities to asc/asc (primordial genericity)* | Core utilities relocated under `asc/asc/*.opt-inc.sh`; removed `utilities` from `asc/.asc_subjects_ignore` so `asc` can be a real subject | Superseded path layout by `f971316`; bootstrap still pointed at old `asc/utilities/` |
| `f971316` *wip: update primordial implementation* | **Final primordial layout:** eager `asc/asc/{core,global,hook,autoload}.inc.sh` (`asc` → **`core`**); lazy `asc/asc/utils/{array,fs,shell,string}.opt-inc.sh`; plan doc updated for shell genericity | **`asc/bootstrap/20-utilities.bootstrap-inc.sh` still sources `asc/utilities/*.sh`** (paths gone — bootstrap broken until rewired); no `ASC_SHELL` export; no shell-qualified lookup; phase 90 / docs / caches still describe old `utilities/` + flat layout |

**Completion work (explicit):**

- [ ] Rewire bootstrap phase 20 (and any other hard-coded `asc/utilities/…` refs) to settled paths: eager `asc/asc/*.inc.sh` + lazy `asc/asc/utils/*.opt-inc.sh` (and `yaml.opt-inc.sh` as appropriate).
- [ ] Introduce **`ASC_SHELL`** (default `bash`) from env / `asc.shell` YAML; document override order.
- [ ] Implement the **single include-loader hook**: try `*.$ASC_SHELL.inc.sh` / `*.$ASC_SHELL.opt-inc.sh` if present; else unqualified bash `*.inc.sh` / `*.opt-inc.sh` (default + fallback). Wire into eager `inc` + lazy `opt-inc` (+ hook-seeded opt-inc).
- [x] Decide final home for shell utilities — **settled:** `asc/asc/utils/shell.opt-inc.sh` (not `asc/shell/…`).
- [x] Split primordial eager vs lazy — **settled:** core/global/hook/autoload → `*.inc.sh`; array/fs/shell/string → `utils/*.opt-inc.sh`; rename `asc` → `core`.
- [x] Frame loading via **one include-loader hook** + `ASC_SHELL` (includes are **not** hook implementations themselves); bash = default + fallback.
- [ ] Smoke: `. asc/bootstrap.sh` works again on bash; dry-run / notes for posix (and later powershell/cmder) lookup without requiring full ports yet.
- [ ] Update living docs (`docs/asc/organization.md`, bootstrap archive, hooks archive) for multi-shell include suffixes + primordial layout + single loader-hook semantics.

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

### 3. Same shape with smart YAML defaults (+ slot on the YAML def)

```text
$subject/$action/lt(agent[role-prompt-analyst].start[loop.heartbeat](data[inbox].unread).start.hook.yml
```

- Same DSL filename meaning as (2).
- **`.yml` → smart defaults** instead of a hand-written shell body.
- **`slot` (locked):** declare any slot / fill metadata **inside this YAML hook definition**, not as a bracket token like the superseded `ollama-exec[slot]` idea form.
- **TODO (open):** `asc.extendable` + `asc.overridable` (names TBD) so YAML hooks can declare whether project extend/override layers may refine defaults — complements today’s `scripts/asc/extend` / `scripts/asc/override` and `-c yml` hook lookup.

### 4. Tests as nest / wrap DSL steps (illustrative)

Tests are **in scope for implementation**, not a post-merge chore. They run under the existing harness (`make test-asc` → hook `test`/`asc` → shunit2 batches in `asc/test/asc/*.test.sh`; see `docs/asc/testing.md`). New DSL coverage should land as additional `*.test.sh` cases (and generated `test-asc-*` make targets after `reinit`) — **do not** introduce a separate self-test / bats / pytest runner.

Beyond ordinary shunit2 assertions, **test steps themselves** can be encoded with the filename DSL so exercises look like real operator paths:

| Pattern | Construct | Intent |
|---------|-----------|--------|
| `test.dsl_parse` | **nest** | Nested test action under subject `test` (grammar/AST case). |
| `test(dsl_parse)` | **wrap** | Wrap a parse step inside the `test` supervision / batch stack. |
| `assert(wrap(log.level_get))` | **wrap** nest chain | Assert around a wrapped log-level get. |
| `test.assert(log.level_set[debug])` | **nest** + **wrap** + **arg** | Nested assert that wraps a level-set with positional `debug`. |

**Log-level get/set + short synonyms** (illustrative actions / make shortcuts — wire into the same synonym / MAKE_TASKS_SHORTER surface as `lt`/`ll` when implementing):

| Long form (nest) | Short synonym | Matching idea |
|------------------|---------------|---------------|
| `log.level_get` | `llv-get` | Get current log level (nest: `level_get` under `log`) |
| `log.level_set` | `llv-set` | Set log level (nest: `level_set` under `log`) |

Example **filename / step** shapes for those actions (paths illustrative under any `$subject/$action/` or as make entry stems):

```text
# Nest form (structure): log owns level_get / level_set
log.level_get.hook.sh
log.level_set[debug].hook.sh          # arg: positional freeform "debug"

# Wrap form: outer wrapper supervises the nested get/set
ll(log.level_get).hook.sh             # logged wrapper around nest
lt(log.level_set[info]).hook.sh

# Short synonyms as atom names (MAKE_TASKS_SHORTER / ASC_SYNONYMS style)
llv-get.hook.sh                       # ≡ log.level_get
llv-set[warn].hook.sh                 # ≡ log.level_set[warn]

# Tests expressed as nest / wrap of those steps
test(log.level_get).hook.sh           # wrap: test wraps level get
test.llv-get.hook.sh                  # nest: llv-get nested under test
assert(llv-set[debug]).hook.sh        # wrap: assert wraps short set
test.assert(log.level_get).hook.sh    # nest + wrap: test.assert wraps get
test(ll(llv-get)).hook.sh             # wrap stack: test → ll → short get
```

Interpretation cheat-sheet:

| Fragment | Action |
|----------|--------|
| `log.level_get` | **nest** — `level_get` under subject/action plane `log` |
| `log.level_set[debug]` | **nest** + **arg** — positional `debug` on `level_set` |
| `llv-get` / `llv-set` | **synonym atoms** — shorter make/task names for the same get/set |
| `test(…)` / `assert(…)` / `ll(…)` | **wrap** — outer step supervises inner fragment |
| `test.llv-get` | **nest** — short get nested under `test` |

Parser / runtime fixtures in Phase 1–2 must include at least: one nest-only test path, one wrap-only test path, one mixed nest+wrap+arg path, and the `log.level_*` ↔ `llv-*` synonym pair.

---

## Alignment with existing conventions

| Existing | How this plan fits |
|----------|-------------------|
| Subjects = folders, actions = files | DSL lives *in* action/hook filenames; does not replace folder subjects. |
| `*.hook.sh` / `hook -c yml` | Suffix `.hook.sh` vs `.hook.yml` chooses impl style; DSL is the *stem*. |
| `*.wrap.sh`, logged wrappers `lt`/`ll`/… | `foo(bar)` **wrap** should resolve toward wrap scripts / make wrap stacks. |
| Nested subjects / `.asc_subjects_ignore` | `foo.bar` **nest** should map toward nest/nested-extension semantics (`docs/asc/wrappers.md` § nested). |
| `p_` / `o_` / `b_` naming | Bracket positionals → `p_*`; `o-*` → `o_*`; `b-*` → `b_*`. |
| `data/asc/` generated state | May generate files; still must materialize explicit `$action` artifacts. |
| Variant dotted hooks today (`init.local.dev.hook.sh`) | Remain valid; DSL adds `()`, `[]`, and richer stems — precedence vs pure variant dots is an open task. |
| First `-` (not same-word `_`) | Compound head/tail via **first hyphen** position inside tokens; superseded idea’s “same word separator : `_`” is **not** adopted. Distinct from relation `--` between `(…)` able members. |
| Optional `_` (prefix in `$action`) | `_`-separated **prefix in `$action`** (**position matters**) **can** read as `$subject` / `$object` `_` `$action` `. (variants)? . (hook\|inc\|opt-inc)? . sh` — not enforced; not a relation; not a replacement for `--` field/triple forms. Peer IDs like `remote_db` are a demoted historical note only. |
| Relations / fields (mapping complete) | Fields: `(field.able.subject)--(field.able.object)`. Triples: `(triple.able.subject)--(triple.able.predicate)--(triple.able.object)`. Map via `$action.able.yml` → `$subject.$action`. |
| YAML `*.hook.yml` / slot | **Slot** is a YAML hook-definition concern; smart defaults + extendable/overridable stay on `.hook.yml`. Builder `docs/asc/builder.md` § slots is a separate scaffold concept. |
| Eager `*.inc.sh` / lazy `*.opt-inc.sh` | Include bodies loaded by a **single include-loader hook** (locked). Multi-shell: try `*.$ASC_SHELL.(opt-)inc.sh` if present; else unqualified bash set (default + fallback). Primordial: eager core at `asc/asc/*.inc.sh`, lazy utils at `asc/asc/utils/*.opt-inc.sh`. Timing: phase 60 `ASC_INC`, phase 90 caller opt-inc, colocated seed before `*.hook.sh`. |
| Bootstrap phases 10–90 | Phase 20 + 90 (and hook opt-inc seeding) must complete WIP path move + shell-aware selection **inside the include-loader hook**. |
| `asc.shell` in specimen YAML | Groundwork for `ASC_SHELL`; wire through instance init / globals. |
| Core under `asc/asc/` (+ `utils/`) | **Settled layout** (`f971316`); finish bootstrap rewire to these paths. |
| `*.hook.sh` event hooks | Distinct from `inc` / `opt-inc` include files. Event hooks stay `hook()` / most-specific; includes are selected only by the dedicated include-loader hook — do not call every include a hook. |
| `asc/asc/hook.inc.sh` | An eager **include** (hook *utilities*), loaded like other `*.inc.sh` via the include-loader hook — not “a hook implementation” by virtue of the `.inc.sh` suffix. |
| `make test-asc` / shunit2 | Existing harness (`docs/asc/testing.md`, `asc/test/asc/*.test.sh`, `asc/vendor/shunit2`). DSL work adds cases here; optional DSL-encoded test *steps* use nest/wrap grammar above. |
| `lt` / `ll` logged wrappers | Same family as wrap stacks in test examples (`ll(log.level_get)`, `lt(log.level_set[…])`). |
| Synonyms / make shortening | `llv-get` / `llv-set` illustrate short atoms expanding to `log.level_get` / `log.level_set` (nest forms); wire with `arg`/`o`/`b`/`f` when implementing. |
| Cursor rules (home / ATB) | Home tip uses `~/.cursor/rules/*.mdc` (`cwt.mdc`, `global.mdc`, …); ATB uses **project-local** `Documents/ATB/.cursor/rules/*.mdc`. **ASC repo has no `.cursor/rules/` yet** — add project-local rules here (same `.mdc` + YAML frontmatter + `globs` pattern). Home MVP plan separately renames tip `cwt.mdc` → `asc.mdc`; that is tip cutover, not a substitute for ASC-repo naming rules. |

---

## Implementation phases (for later coding)

### Phase 0 — Accept / freeze grammar (+ shell SoT)

- [ ] Accept or amend this plan (review → iterate → accepted).
- [ ] Freeze punctuation SoT (`()` = wrap, `.` = nest, `[]` = args) vs superseded `dsl.md` idea.
- [ ] Decide interaction with today’s dotted **variant** filenames (same `.` character).
- [ ] Name and sketch `asc.extendable` / `asc.overridable` (or reject names).
- [x] Freeze **shell suffix** convention: unqualified `*.inc.sh` / `*.opt-inc.sh` = bash default+fallback; alternates `*.$ASC_SHELL.inc.sh` / `*.$ASC_SHELL.opt-inc.sh` (shell segment **before** kind — not `*.opt-inc.<shell>.sh`).
- [x] Freeze **include loading:** **one dedicated include-loader hook** selects bodies by `ASC_SHELL`; include files are **not** hook implementations (plural).
- [x] Freeze **fallback** policy: missing shell-specific alternate → unqualified bash set (default + fallback).
- [x] Freeze **`ASC_SHELL`** default (`bash`) and YAML key sketch (`asc.shell`) — export wiring still TODO.
- [x] Freeze **primordial layout** (`f971316`): `asc/asc/*.inc.sh` eager core + `asc/asc/utils/*.opt-inc.sh`; `core` not `asc` for the core include file.
- [x] Freeze **slot** home: YAML hook definition (`*.hook.yml`) — not filename-DSL bracket payload (`…[slot]` superseded).
- [x] Freeze **boolean** class: `b-` tokens in `[]`; MAKE_TASKS_SHORTER `b` → boolean; variable prefix **`b_`** (parallel to `p_` / `o_`).
- [x] Freeze **first `-` separator policy:** no same-word `_` rule; head/tail from position of the first hyphen (intra-token only).
- [x] Freeze **optional `_` prefix in `$action` naming:** `_`-separated leading segment **can** (not enforced) mean `$subject` / `$object` `_` `$action` `. (variants)? . (hook|inc|opt-inc)? . sh`; **position matters**; does **not** revive same-word `_`; first `-` keeps positional head/tail; **not** a relation / not a replacement for `--` able forms. See [Optional `_` prefix in `$action` naming](#optional-_-prefix-in-action-naming-locked-intent--not-enforced).
- [x] Freeze **remote-family / peer-subject `_` elaboration as demoted:** `remote_db` / `remote_asc` / `remote_traefik` are historical peer-ID notes only — not the locked optional-`_` SoT. See [Historical / peer-subject note](#historical--peer-subject-note-demoted--not-the-locked-_-sot).
- [x] Freeze **minimal `_` implementation approach:** docs/convention first for the `$action`-prefix reading; **no** DSL parser rule, renames, or mandatory splits. See same section (“Most minimal implementation” / “do NOT build yet”).
- [x] Freeze **relations / fields (mapping complete):** `(field.able.subject)--(field.able.object)`; `(triple.able.subject)--(triple.able.predicate)--(triple.able.object)`; via `$action.able.yml` → `$subject.$action` (distinct from first-`-` and from optional `_`).

### Phase 0a — Optional `_` `$action`-prefix note (docs-first)

**When:** can land anytime after Phase 0 accept; **orthogonal** to multi-shell Phase 0b and **before** Phase 1 DSL parser work. Prefer docs-only.

- [ ] Living-docs note: optional `_` prefix in `$action` naming **can** read as `$subject` / `$object` `_` `$action` … (not enforced; position matters); contrast with `--` relations; first `-` unchanged.
- [ ] Do **not** fold this into Phase 1–3 filename-DSL lexer work.
- [ ] Do **not** revive peer-subject / remote-family `_` as the locked SoT (demoted note only).

### Phase 0b — Complete multi-shell groundwork (already pushed)

- [ ] Finish WIP from `648a4d7` / `8f3faa8` / `f971316`: bootstrap rewire to settled paths, `ASC_SHELL` export, **include-loader hook** with shell-specific alternate + bash fallback, docs — see [Multi-shell groundwork](#multi-shell-groundwork-already-pushed).
- [ ] Restore working bash bootstrap against unqualified `asc/asc/*.inc.sh` + `asc/asc/utils/*.opt-inc.sh` (eager/lazy includes via loader hook).
- [ ] Do **not** treat multi-shell as closed until phase-20/90 + discovery smoke pass.
- [ ] Keep phase timing (`ASC_INC`, phase 90, colocated opt-inc seed); centralize shell selection in the **single** include-loader hook.

### Phase 0c — Cursor rules (naming conventions)

**When:** after Phase 0 freezes (grammar / shell SoT) and preferably after or alongside Phase 0b path/`ASC_SHELL` locks; **before Phase 1** so Cursor-produced tests and later runtime code already follow conventions.

**Where (align with existing conventions):** create **project-local** `.cursor/rules/` under this ASC repo (same pattern as `Documents/ATB/.cursor/rules/`). Use short `.mdc` file(s) with YAML frontmatter (`description`, `globs`, `alwaysApply: false`). Suggested start: `.cursor/rules/naming.mdc` (or `asc-naming.mdc`) with globs covering ASC shell surfaces, e.g. `asc/**/*.sh`, `scripts/asc/**/*.sh`, plus any make/docs globs only if needed. Do **not** invent a large essay — point at this changelog + `23-f-e-naming-convention.md` as SoT and list hard enforcement bullets.

**Rule must enforce (sketch — locked items from this plan + related naming plan):**

- Filename DSL punctuation: `()` = **wrap**, `.` = **nest**, `[]` = **args**; `b-*` = boolean; `o-*` = options; else positional.
- Variable prefixes in DSL / calling scope: positionals → `p_`; options → `o_`; booleans → `b_`; no `f_` *variable* prefix for actions / entry points.
- Symbol prefixes (when touching bootstrapped utilities / exports — see `changelog/2026/07/23-f-e-naming-convention.md`): utilities `f_*` (from `u_*`); exports `e_*`; CLI option storage `o_*`; special-case `hookms` (not `f_hook_most_specific`).
- Compound tokens: relate on **first `-`** (no same-word `_` separator rule); distinct from relation `--` between `(…)` able members. Optional `_` **can** (not enforced) be a **leading `$action` prefix** reading `$subject` / `$object` `_` `$action` `. (variants)? . (hook|inc|opt-inc)? . sh` — position matters; never same-word head/tail; never a replacement for `--` relations.
- **Relations / fields (mapping complete):** `(field.able.subject)--(field.able.object)`; `(triple.able.subject)--(triple.able.predicate)--(triple.able.object)`; map via `$action.able.yml` to `$subject.$action`.
- **Slot** only in **YAML hook definitions** (`*.hook.yml`) — never as `…[slot]` in filename stems.
- Include suffixes: unqualified `*.inc.sh` / `*.opt-inc.sh` = bash default + fallback; alternates `*.$ASC_SHELL.inc.sh` / `*.$ASC_SHELL.opt-inc.sh` (shell segment **before** kind).
- **Single include-loader hook** loads includes by `ASC_SHELL`; include files are **not** hook implementations.
- MAKE_TASKS_SHORTER / synonyms: `arg` / `o` / `b` / `f`, plus `llv-get` / `llv-set` ↔ `log.level_get` / `log.level_set` when wiring shortcuts.
- Explicit `$action` files (no invisible function-only actions).
- Tests only via existing harness: `make test-asc` → `asc/test/asc/*.test.sh` (shunit2) — no parallel runners.
- Primordial layout: eager `asc/asc/*.inc.sh`, lazy `asc/asc/utils/*.opt-inc.sh` (`core` not `asc` for the core include).

**Checklist:**

- [ ] Add `.cursor/rules/` + thin naming `.mdc` (frontmatter + globs + bullet enforcement list; link SoT changelogs).
- [ ] Optionally note in rule body that home tip `cwt.mdc` → `asc.mdc` (MVP cutover) is separate and must not contradict ASC-repo locks.
- [ ] Refresh rule bullets if Phase 0/0b decisions amend locked items; keep rule thin through Phases 1–5.

### Phase 1 — Spec + **tests first** (no production DSL wiring)

Writing tests is a **required deliverable of this phase**, not deferred to “verification later.”

- [ ] Formal grammar + lexer rules (escaping, allowed chars, max depth; shell_id in suffix).
- [ ] Golden filename → AST fixtures (examples 1–3 above + one shell-qualified include + **example 4 nest/wrap test steps**).
- [ ] Document AST → matching actions (`wrap` / `nest` / `arg` / option).
- [ ] **Create** shunit2 cases under `asc/test/asc/` (e.g. `filename_dsl.test.sh` or split parser/synonym cases) following `docs/asc/testing.md` — same batch as `make test-asc` / `u_test_batch_exec`; helpers via `asc/test/test.inc.sh`. After `reinit`, expect generated `test-asc-*` targets.
- [ ] Fixture matrix must cover:
  - nest-only (`foo.bar`, `log.level_get`)
  - wrap-only (`foo(bar)`, `test(log.level_get)`)
  - mixed nest + wrap + args (`test.assert(log.level_set[debug])`, `ll(log.level_get)`)
  - boolean + option members (`foo[b-oneline]`, `foo[bar,b-flag,o-x]`)
  - first `-` splits (`retention-5m`, `instance-giw` / `b-oneline`)
  - field / triple (`(field.able.subject)--(field.able.object)`, `(triple.able.subject)--(triple.able.predicate)--(triple.able.object)`) → `$action.able.yml` mapping notes
  - synonym atoms `llv-get` / `llv-set` ↔ `log.level_get` / `log.level_set`
- [ ] Tests may *describe* nest/wrap **filename patterns** as expected stems even before runtime wiring (assert parse → AST / action map). Optional: later phases execute those stems as real hooks once loaders exist.

### Phase 2 — Runtime matching actions (+ keep tests green)

- [ ] Implement or map to existing `wrap` / nest helpers.
- [ ] Bind bracket members to `p_*` / `o_*` / `b_*` in calling scope (booleans parallel to options/positionals).
- [ ] Ensure make/task shortening understands `arg` / `o` / `b` / `f` **and** illustrative `llv-get` / `llv-set` ↔ `log.level_*` synonyms.
- [ ] Extend Phase 1 shunit2 cases with runtime smoke for nest/wrap resolution (still `asc/test/asc/*.test.sh`).

### Phase 3 — Hook loaders + YAML smart defaults

- [ ] Teach hook discovery to parse DSL stems (or pre-normalize to cache keys).
- [ ] Ensure the **include-loader hook** respects `ASC_SHELL` when resolving eager/lazy includes and seeded opt-inc bodies.
- [ ] `.hook.yml` smart-default loader; stub extendable/overridable policy; **define `slot` (and related) fields on the YAML hook definition** — not on filename stems.
- [ ] Cache layout: prefer readable paths under `data/asc/…` if regenerating caches (see organization.md ideal cache shape).
- [ ] Add/extend tests: hook dry-run (`-t`) lists DSL paths including nest/wrap test stems and `llv-*` synonyms; YAML fixtures cover slot-on-yml (and assert no `…[slot]` filename forms).

### Phase 4 — Explicit action materialization

- [ ] Generator / builder: always emit concrete `$action` files when DSL expands entry points (including synonym expansions that materialize `log.level_*` or short `llv-*` action files as decided).
- [ ] Refuse “function-only” make targets with no file artifact.
- [ ] Docs: organization + wrappers + hooks + bootstrap multi-shell + **testing** (DSL fixtures / nest-wrap test steps); document single include-loader hook + `ASC_SHELL` selection; mark old `dsl.md` punctuation superseded.
- [ ] Confirm Phase 0c Cursor rule still matches living docs / locked SoT (amend bullets only; no prose rewrite of the rule into a second SoT).

### Phase 5 — Verification (gate on the test suite)

- [ ] Full `make test-asc` green for new DSL cases; hook dry-run (`-t`) lists DSL paths.
- [ ] Confirm nest/wrap **test-step** examples and `llv-get` / `llv-set` synonym fixtures from Phase 1 still pass against runtime.
- [ ] Smoke: custom `.hook.sh` vs `.hook.yml` defaults; bash bootstrap after groundwork completion.
- [ ] Smoke: shell-specific alternate include lookup for at least one non-default `ASC_SHELL` (file present → alternate; missing → bash fallback).
- [ ] `make reinit` / `make cc` after registry / test-case cache changes.
- [ ] Grep/docs gates for SoT punctuation, prefix rules, `ASC_SHELL` / suffix convention, single include-loader hook semantics (includes ≠ hook implementations), and testing harness alignment (`make test-asc` only).
- [ ] Confirm project-local Cursor naming rule(s) still present under `.cursor/rules/` and match locked conventions (Phase 0c).

---

## Risks / safety notes

| Risk | Notes |
|------|--------|
| `.` overload | Nest DSL vs existing variant dots vs optional `.<shell_id>.` before include kind — ambiguous without precedence rules. |
| Shell-hostile filenames | `()`, `[]` in paths can break naive scripts; need quoting conventions and maybe encoded cache names. |
| Superseding `dsl.md` | Agents may follow old idea; changelog + idea banner required when accepted. |
| Confusing `f` abbrev with `f_*` utilities | Document both namespaces in living docs when implementing. |
| Generated-only actions | Violates explicit-file rule; treat as bug. |
| Broken bootstrap (WIP) | Utils moved + renamed; phase 20 still points at `asc/utilities/` — must complete groundwork before other runtime work. |
| Bash-only assumptions | `BASH_SOURCE`, `shopt`, shebangs — multi-shell is lookup-first; full ports are later. |
| Plan-only (DSL) | Do not land parser/loader changes until accepted + requested. |

**Safety:** do not hand-edit gitignored generated caches as SoT; regenerate. Do not implement in nested/foreign repos from this work tree.

---

## Open questions

1. **Variant dots vs nest dots:** same character — require a delimiter, reserved suffix zone (`.hook` / `.wrap` / `.opt-inc` / `.inc`), or parse right-to-left from known suffixes?
2. **Nested DSL inside `[]` / `()`:** allow full fragments recursively in v1, or only flat tokens first?
3. **`asc.extendable` / `asc.overridable`:** file-level YAML keys, entity `.able.yml`, or hook metadata?
4. **MAKE_TASKS_SHORTER wiring:** new global map vs extend `ASC_SYNONYMS`?
5. **Example (2) paren balance:** confirm canonical spelling of the long `lt(agent…` example before locking fixtures.
6. **Relation to make `e:` / `a:` notation:** keep both, or eventually express CLI args with the same `[]` / `o-` / `b-` grammar?
7. **Should `wrap` / `nest` become first-class subjects/actions** (`asc/wrap/`, `asc/nest/`) or stay internal matcher verbs?
8. **Extension for non-sh shells:** suffix order is locked (`*.powershell.opt-inc.sh`); still open whether powershell/cmder may use `.ps1` (or parallel trees) instead of `.sh`.
9. **Include-loader hook identity:** exact subject/action name and where it lives (e.g. under `asc/…`) — wire into phase 60 / 90 without duplicating today’s `ASC_INC` / caller opt-inc entry points.
10. **`yaml.opt-inc.sh` placement:** leave at `asc/asc/yaml.opt-inc.sh`, move under `utils/`, or promote to eager `*.inc.sh`?
11. **Windows shells:** map `powershell` / `cmder` to which ext and bootstrap entry (separate `bootstrap.ps1` later)?
12. **Explicit `*.bash.inc.sh`:** keep unqualified-only as bash default+fallback, or also accept/emit `*.bash.inc.sh` as an optional alias of the bash set?
13. **Colocated opt-inc seed:** should foreign-subject `*.opt-inc.sh` seeding beside `*.hook.sh` also go through the same include-loader hook’s `ASC_SHELL` selection, or stay path-literal until Phase 0b?
14. **`llv-get` / `llv-set`:** keep hyphenated short atoms (first `-` splits `llv` / `get`), or prefer underscored `llv_get` / `llv_set` to match `level_get` style and `[A-Za-z0-9_-]+` naming consistently?
15. **DSL-encoded test steps:** should nest/wrap test filenames live under `asc/test/…` as real hook stems, or stay as fixture strings inside ordinary `*.test.sh` until a dedicated test-subject DSL layout exists?
16. **YAML `slot` field shape:** exact key(s) / nesting under `*.hook.yml` (and relation to builder `slotable` in `docs/asc/builder.md` — keep distinct).
17. **`b_` stacking with `e_*`:** if boolean locals are also exported, same open stacking question as `o_` / `e_` in the naming-convention plan.
18. **`$action.able.yml` schema:** exact keys for `(field.able.subject)--(field.able.object)` vs `(triple.able.subject)--(triple.able.predicate)--(triple.able.object)`; path relative to `$subject/$action`; overlap with entity `.able` / `asc.extendable` naming.
19. **Optional `_` `$action`-prefix split:** first `_` only (`db_dump` → `db` + `dump`) vs more segments? When is the soft `$subject` vs `$object` reading intended vs ordinary multi-word glue?
20. **Peer-subject IDs with `_` (demoted):** keep `remote_db`-style flat IDs as-is forever, or eventually align with folder/DSL nest — orthogonal to the locked `$action`-prefix `_` rule?

---

## Open tasks (summary)

- [ ] Review this plan; move to `data/plans/iterate/` or `accepted/` / `rejected/`
- [ ] Update or banner `data/ideas/2026/07/23/dsl.md` as superseded on accept
- [ ] Phase 0 decisions (especially `.` ambiguity, YAML extend/override names, include-loader hook identity; shell suffix order + bash fallback are frozen)
- [ ] **Complete multi-shell groundwork** already pushed (`648a4d7`, `8f3faa8`, `f971316`) — Phase 0b
- [ ] **Phase 0a** (optional `_`): living-docs note for `$action`-prefix reading (`$subject` / `$object` `_` `$action` …); remote-family peer IDs demoted — **not** DSL parser work
- [ ] **Cursor rules** (Phase 0c): project-local `.cursor/rules/*.mdc` enforcing locked naming / DSL (`b-`/`o-`/`p_`, first `-`, optional `_` `$action`-prefix reading, field/triple able forms / `$action.able.yml`, slot-in-yml) / include-loader / MAKE_TASKS_SHORTER / test harness — before Phase 1 coding
- [ ] Implement DSL only after explicit go-ahead (Phases 1–5), **including** shunit2 / `make test-asc` cases and nest/wrap + `llv-*` fixtures from Phase 1 onward

---

## Appendix — Quick reference card

```text
foo(bar)                         → wrap
foo.bar                          → nest
foo[bar]                         → arg(*) freeform / positional  → p_
foo[b-oneline]                   → boolean(b-*)                  → b_
foo[bar,o-option-bar]            → option(o-*) | arg(*)          → o_ / p_
foo[a,b-flag,o-x]                → arg(*) | b-* | o-*            → ordered mix
retention-5m / instance-giw      → first '-' splits head | tail  (no same-word '_' rule)
db_dump / remote_sync.hook.sh    → optional '_' prefix in $action (position matters, not enforced):
                                 → $subject/$object _ $action . (variants)? . (hook|inc|opt-inc)? . sh
# relations are '--' able forms — optional '_' is NOT a relation replacement
# peer IDs like remote_db = demoted historical note only (not locked '_' SoT)
(field.able.subject)--(field.able.object)
                                 → field → $action.able.yml → $subject.$action
(triple.able.subject)--(triple.able.predicate)--(triple.able.object)
                                 → triple (the rest) → $action.able.yml
# mapping complete — no bare -- / --relation-- / triple.predicate SoT
slot                             → YAML hook definition only (not foo[slot])

# Test steps (same grammar):
test(log.level_get)              → wrap(test, nest(log, level_get))
test.llv-get                     → nest(test, llv-get)
assert(llv-set[debug])           → wrap(assert, arg(llv-set, debug))
ll(log.level_set[info])          → wrap(ll, nest+arg(log.level_set[info]))

MAKE_TASKS_SHORTER:
  arg     → argument (p_)
  o       → option   (o_)
  b       → boolean  (b_)
  f       → function / entry point / action  (no var prefix; explicit $action file)
  llv-get → log.level_get
  llv-set → log.level_set

Tests (existing harness — do not invent another):
  make test-asc → asc/test/asc/*.test.sh (shunit2)
  Phase 1 creates cases; Phases 2–5 keep them green

ASC_SHELL (default bash) — single include-loader hook:
  try *.$ASC_SHELL.inc.sh / *.$ASC_SHELL.opt-inc.sh if exists
  else *.inc.sh / *.opt-inc.sh                 → bash (default + fallback)
  # alternates e.g. *.zsh.inc.sh / *.posix.opt-inc.sh
  # NOT *.opt-inc.posix.sh (superseded order)
  # includes are NOT hook implementations; one hook loads them
  # timing: ASC_INC (eager) | phase 90 / colocated seed (lazy)

Primordial layout (settled) — include files:
  asc/asc/{core,global,hook,autoload}.inc.sh     → eager
  asc/asc/utils/{array,fs,shell,string}.opt-inc.sh → lazy
```

---

## Future next-step (deferred — not Phase 0b required)

**Idea:** make `asc/asc/utils/shell.ideal.opt-inc.sh` a file that **receives pull requests**, so that in this file (wherever the repo locates it) we can discover whether some action has a **"universal" (shell-agnostic)** implementation.

**Open question:** `limit.able` / `scope.able` ?

Frame: future idea / next step only — do **not** treat as current Phase 0b required work unless it later fits cleanly as deferred groundwork.
