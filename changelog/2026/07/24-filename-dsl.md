# Plan: ASC DSL in filename patterns

| Field | Value |
|-------|--------|
| **Date** | 2026-07-24 |
| **Status** | plan / review (not implemented; multi-shell groundwork WIP on branch) |
| **Scope** | ASC repo `/home/paul/Documents/asc` — filename grammar for subjects, actions, hooks, wraps; matching runtime actions; MAKE_TASKS_SHORTER abbreviations; **shell-agnostic runtime** (`ASC_SHELL`; multi-shell `inc` / `opt-inc` loaded by a **single dedicated include-loader hook**); primordial layout under `asc/asc/` |
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
3. Align **MAKE_TASKS_SHORTER** abbreviations (`arg`, `o`, `f`) with synonyms and **variable prefixes**.
4. Require that **`$action` files are explicitly created** (including when generated under `data/asc`) — no invisible “function-only” actions.
5. Leave room for **smart YAML defaults** (`*.hook.yml`) with future `asc.extendable` / `asc.overridable` knobs.
6. Keep the DSL / include runtime **shell-agnostic**: default `ASC_SHELL=bash`, alternate shells via filename / lookup conventions; **finish implementing** the multi-shell groundwork already on the branch.
7. Route multi-shell **`inc` / `opt-inc` loading through a single dedicated include-loader hook** driven by `ASC_SHELL` (bash default+fallback; shell-specific alternate only if present). Eager vs lazy kinds still apply.

Non-goals for this plan: shipping the full DSL parser; rewriting existing `*.hook.sh` trees wholesale; changing make synonym maps in code; implementing non-bash shell bodies in v1 (convention + lookup first).

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
suffix       := ( '.' shell_id )? '.' ( 'hook' | 'wrap' | 'inc' | 'opt-inc' | … ) ( '.' variant )* ( '.' ext )
shell_id     := 'zsh' | 'posix' | 'powershell' | 'cmder' | …   # omitted ⇒ ASC_SHELL default (bash)
ext          := 'sh' | 'yml' | 'ps1' | …                       # ext policy for non-sh shells still open
```

**Shell in the suffix (locked):** `shell_id` sits **before** the include kind (`inc` / `opt-inc`), not after it.

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
asc/asc/utils/shell.posix.opt-inc.sh
asc/asc/core.zsh.inc.sh
asc/asc/utils/shell.powershell.opt-inc.sh   # ext policy still open (e.g. .ps1)
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
| Eager `*.inc.sh` / lazy `*.opt-inc.sh` | Include bodies loaded by a **single include-loader hook** (locked). Multi-shell: try `*.$ASC_SHELL.(opt-)inc.sh` if present; else unqualified bash set (default + fallback). Primordial: eager core at `asc/asc/*.inc.sh`, lazy utils at `asc/asc/utils/*.opt-inc.sh`. Timing: phase 60 `ASC_INC`, phase 90 caller opt-inc, colocated seed before `*.hook.sh`. |
| Bootstrap phases 10–90 | Phase 20 + 90 (and hook opt-inc seeding) must complete WIP path move + shell-aware selection **inside the include-loader hook**. |
| `asc.shell` in specimen YAML | Groundwork for `ASC_SHELL`; wire through instance init / globals. |
| Core under `asc/asc/` (+ `utils/`) | **Settled layout** (`f971316`); finish bootstrap rewire to these paths. |
| `*.hook.sh` event hooks | Distinct from `inc` / `opt-inc` include files. Event hooks stay `hook()` / most-specific; includes are selected only by the dedicated include-loader hook — do not call every include a hook. |
| `asc/asc/hook.inc.sh` | An eager **include** (hook *utilities*), loaded like other `*.inc.sh` via the include-loader hook — not “a hook implementation” by virtue of the `.inc.sh` suffix. |

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

### Phase 0b — Complete multi-shell groundwork (already pushed)

- [ ] Finish WIP from `648a4d7` / `8f3faa8` / `f971316`: bootstrap rewire to settled paths, `ASC_SHELL` export, **include-loader hook** with shell-specific alternate + bash fallback, docs — see [Multi-shell groundwork](#multi-shell-groundwork-already-pushed).
- [ ] Restore working bash bootstrap against unqualified `asc/asc/*.inc.sh` + `asc/asc/utils/*.opt-inc.sh` (eager/lazy includes via loader hook).
- [ ] Do **not** treat multi-shell as closed until phase-20/90 + discovery smoke pass.
- [ ] Keep phase timing (`ASC_INC`, phase 90, colocated opt-inc seed); centralize shell selection in the **single** include-loader hook.

### Phase 1 — Spec + tests (no production DSL wiring)

- [ ] Formal grammar + lexer rules (escaping, allowed chars, max depth; shell_id in suffix).
- [ ] Golden filename → AST fixtures (include the three examples above + one shell-qualified include).
- [ ] Document AST → matching actions (`wrap` / `nest` / `arg` / option).

### Phase 2 — Runtime matching actions

- [ ] Implement or map to existing `wrap` / nest helpers.
- [ ] Bind bracket members to `p_*` / `o_*` in calling scope.
- [ ] Ensure make/task shortening understands `arg` / `o` / `f` synonyms.

### Phase 3 — Hook loaders + YAML smart defaults

- [ ] Teach hook discovery to parse DSL stems (or pre-normalize to cache keys).
- [ ] Ensure the **include-loader hook** respects `ASC_SHELL` when resolving eager/lazy includes and seeded opt-inc bodies.
- [ ] `.hook.yml` smart-default loader; stub extendable/overridable policy.
- [ ] Cache layout: prefer readable paths under `data/asc/…` if regenerating caches (see organization.md ideal cache shape).

### Phase 4 — Explicit action materialization

- [ ] Generator / builder: always emit concrete `$action` files when DSL expands entry points.
- [ ] Refuse “function-only” make targets with no file artifact.
- [ ] Docs: organization + wrappers + hooks + bootstrap multi-shell; document single include-loader hook + `ASC_SHELL` selection; mark old `dsl.md` punctuation superseded.

### Phase 5 — Verification

- [ ] Unit tests on parser; hook dry-run (`-t`) lists DSL paths.
- [ ] Smoke: custom `.hook.sh` vs `.hook.yml` defaults; bash bootstrap after groundwork completion.
- [ ] Smoke: shell-qualified **hook-impl** include lookup for at least one non-default `ASC_SHELL` (file present / missing fallback).
- [ ] `make reinit` / `make cc` after registry changes.
- [ ] Grep/docs gates for SoT punctuation, prefix rules, `ASC_SHELL` / suffix convention, and `inc`/`opt-inc` = hook implementation.

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
6. **Relation to make `e:` / `a:` notation:** keep both, or eventually express CLI args with the same `[]` / `o-` grammar?
7. **Should `wrap` / `nest` become first-class subjects/actions** (`asc/wrap/`, `asc/nest/`) or stay internal matcher verbs?
8. **Extension for non-sh shells:** suffix order is locked (`*.powershell.opt-inc.sh`); still open whether powershell/cmder may use `.ps1` (or parallel trees) instead of `.sh`.
9. **Fallback:** if `ASC_SHELL=zsh` (or posix/…) and only unqualified `.opt-inc.sh` / `.inc.sh` exists, load it or fail closed?
10. **`yaml.opt-inc.sh` placement:** leave at `asc/asc/yaml.opt-inc.sh`, move under `utils/`, or promote to eager `*.inc.sh`?
11. **Windows shells:** map `powershell` / `cmder` to which ext and bootstrap entry (separate `bootstrap.ps1` later)?
12. **`inc`/`opt-inc` vs `hook()` discovery:** framing as hook implementations is locked; loaders stay bootstrap `ASC_INC` / phase 90 / colocated seed. Should any `inc`/`opt-inc` also participate in `hook()` / `u_hook_most_specific()` path walks (beyond today’s colocated opt-inc seed), or keep loaders strictly separate from event `*.hook.sh`?
13. **Override / most-specific for includes:** do eager `*.inc.sh` hook implementations gain the same override / most-specific weight rules as event hooks, or keep today’s `ASC_INC` + `u_autoload_override` only?

---

## Open tasks (summary)

- [ ] Review this plan; move to `data/plans/iterate/` or `accepted/` / `rejected/`
- [ ] Update or banner `data/ideas/2026/07/23/dsl.md` as superseded on accept
- [ ] Phase 0 decisions (especially `.` ambiguity, YAML extend/override names, fallback SoT; shell suffix order is frozen)
- [ ] **Complete multi-shell groundwork** already pushed (`648a4d7`, `8f3faa8`, `f971316`) — Phase 0b
- [ ] Implement DSL only after explicit go-ahead (Phases 1–5)

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

ASC_SHELL (default bash) — shell segment before inc / opt-inc;
inc / opt-inc = hook implementations (eager vs lazy):
  *.inc.sh / *.opt-inc.sh                 → bash hook impl (unqualified)
  *.zsh.inc.sh / *.zsh.opt-inc.sh         → zsh hook impl
  *.posix.inc.sh / *.posix.opt-inc.sh     → posix hook impl
  *.powershell.opt-inc.sh                 → powershell (same pattern)
  # NOT *.opt-inc.posix.sh (superseded order)
  # load: ASC_INC (eager) | phase 90 / colocated seed (lazy)

Primordial layout (settled) — hook implementations:
  asc/asc/{core,global,hook,autoload}.inc.sh     → eager
  asc/asc/utils/{array,fs,shell,string}.opt-inc.sh → lazy
```
