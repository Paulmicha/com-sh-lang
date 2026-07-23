# TODO ideas log (inbox) 2026-07-23-16-15 dump - since - 2026-07-15

Thinking about builder / blueprints and a DSL for describing needs expressed in ASC primitives.

Earlier example :

a “cursor” extension provides the concrete agent (hook or override) implementation, an entry point like “make cursor-analyze” could be a slot (or wrap) of any local implementation of e.g. gpt.

-> possible notation : `log-wrap.thread-wrap.gpt-prompt.ollama-exec`
-> possible asc DSL syntax rules to represent any "controlled" entry point :

- wrappers : '.'
- nesters : '()'
- relations : '--' (key-val) or '--foobar--' (triple)
- same word separator : '_'
- arguments : comma-separated values in '[]' of either :
    - positional arguments like $1 : unprefixed ('$key-$value')
    - boolean option (= boolean argument) : prefix 'b-' ('b-$key')
    - options (= named arguments) : prefix 'o-' ('o-$key-$value')

Ex :

make giw log -- --oneline

could be noted :

`instance-giw[log,b-oneline]]`

Contrived example :

`log-wrap[retention-5m].thread-wrap.gpt-prompt[role-prompt_analyst].hook-ms[o-s-gpt,o-a-exec](ollama-exec[slot])`

Or :

```txt
log-wrap[retention-5m]
  .thread-wrap
  .gpt-prompt[role-prompt_analyst]
  .hook-ms[o-s-gpt, o-a-exec](
    ollama-exec[slot]
  )
```

this tells which wrappers are used, where the hook is declared, where it is implemented, and the wrap + nesting chain of the whole entry point = call.


--


sidecars must be forget.able but for things like status polling / health / heartbeats, any lock TTL must be reset (expire.able ? daemons / crontabs are usable for this)


--

Over-arching general human and agent expected workflow when using ASC implementations (each step able to be run independently, e.g. across different cronjobs or daemons):

1. Idea -> changelog.draft
1. changelog.draft -> repeat(review -> iterate) until (break | exit) -> state : accepted, rejected / abandonned
1. state : accepted -> repeat(iterate -> test) until (break | exit) -> state : failed, success
1. state (failed | success) : update changelog + next steps - human approval - go / no go -> iterate or implement

-> repeat(review -> iterate) until break / exit (accepted, rejected / abandonned) -> update changelog + next steps - human approval - go / no go -> iterate or implement

--

Conceptual representation of ASC “stack” (situation) using the example of a hypothetical “projet complexe” rewrite :

1. Projet complexe **UI (front)**  
2. SolidJS  
3. BrowserView (nestable ?)  
4. Tauri (Rust)  
5. **ASC** instance (nestable bash “seeds” = preprocessed frozen static exports, kind of like controlled / **filterable, breakable** interaction points)  
6. Shell (bash)  
7. Host (OS - ex: debian-13)

--

A **creative visual representation idea** for the UI could be :

Cubic / tree like fractal or auto-moving creatures like sand creatures from eu artist (forgot his name)

But the connections could be “real” ASC level (layer) like a google map layer, webgl ?

**Genericity scale** applicable to links (synonyms: connections, or use “relations” here instead ?) too - color coding, texture, pattern, animation, depth (layers but also tree, nodes / edges, mesh networks, both software and hardware, etc

Applicability could be like receptors conceptually based on the human neurons system analogy (close to : interactivity, reactivity, sensitivity ? compatibility ?)

Diagram.able = kind of view.able or preview.able, where format or style (synonym ? cosmetic, surface …) can be a triple-like relation (rendered, hydrated - ex: slot or template, heredoc.able, etc.)

--

**Taxonomy** (in asc scope) vs **relationships** (not in asc scope)

Complex Fieldable relationships are to be delegated to third-party projects (ex : pattern building, prompts, plans, chain of thoughts -> projet complexe), and / or :

implement **abstract** entry point to “**occupy**” - as in dns / domain names, certain **namespaces** *even when out of asc scope* (**pre-setting contracts** ?)

Bit like a lighter kind of blueprint (vague implementation idea, not a fixed blueprint yet, but expressed like a DSL or seed or “need” synonyms : orientation, intent, next-step.able ? **task-oriented VS knowledge-oriented**)

Only touch point in ASC is not implementation, it is the “naming”.  
That is the precept of level 2 genericity in our scale :

The namespace collision is what turns this into a kind of “game of go”

--

We need a unified - uniformized genericity scale \!

--

Difference between calling and sourcing a shell script (same arguments, same options)  
Wrapper vs slot (vertical vs horizontal structure)

Could be a type of relation :

Relation.able.yml inheritance example :  
is:

- protocol.able  
- field.able

--

Reverse (construct) : imagine installing stock raspberry pi OS.  
Sync user home dir using ASC.  
Manage keys, vpn, etc.  
But : read (synonym : scan, recognize) the local system default state (todo state.able ?) + health (health.able) + TODO metrics.able ? and wrap them in a kind of “frozen” export (yml ?)  
It’s the idea of seed \! (prebuilt template, static export, same idea)

--

(Is) :

- datestamp.able ex: file.path (default : data/<data.store.able>/YYYY/MM/DD-<filename>.txt),  
- timestamp.able (default : data/<data.store.able>/YYYY/MM/DD/HH-MM-SS-UUUU.<filename>.txt)

--

competing / collision namespace analysis (contrib)  
git as inspiration regarding blame, merge conflicts (all boils down to tree (nesting), wrap (make, eval, heredoc, tpl, yml, includes, opt-inc), triple, or key value)

--

emitter vs listener  
caller vs reciever  
etc.

-> all synonyms or mappable to :  
subject vs action

TODO all must have “owner” field ? how to express that kind of contract ? mandatory field in field extension ? entity extension ?

What kind of “situation tracking” / reader / observer do we have ?
Are we the caller, or the implementer ?

Subject = owner, always (when in doubt as to where to implement something worthy of a name in this system)

How to read context ?

Easy when stored in memory somewhere : env , scope , sidecar, data, db (memory types - memory volatility scale ? + forget.ability)

But is it guess.able ?

Even when agent is the generic asc core representation, and for ex. a “cursor” extension provides the concrete agent (hook or override) implementation, an entry point like “make cursor-analyze” could be a slot (or wrap) of any local implementation of e.g. gpt.

In this case, is ollama owned by gpt, or by cursor, the entry point ?

-> Both, nested, e.g. : `log-wrap.thread-wrap.gpt-prompt.ollama-exec`

Back to log level management in ASC core (all wrappers ? some wrappers ? which sidecars ?)


--

a tree is mappable  
a nesting structure is mappable  
any mappable is viewable, preview.able...

any entity field.able etc

--

Attack.able  
Exploit.able  
Securize.able  
offend.able ?  
Obfuscable synonym crypt.able ?  
Ssh important software  
Sshkeygen etc

Yagni - ywnasft wont need software for that  
Generalisable :  
Wont need. Able \!

Builder wont need new x for that \!  
Changelog  
Modification synonym of change ?

Triples \!\!\!\!

Taxonomy is triple able \!

Conceptually, triple synonym of relation ?

--

Selecting the right genericity layer :  
archetypes examples (implementation blueprint \~ reverse engineering ?)

Pentest.able  
Pwn.able  
Pun.able 😂

--

Supervisor manageable, orchestrator... Operable ? Human operable vs agent operable \!

Iterate.able  
Idea.able  
Review.able

Should wrappers and nesters be synonyms ??  
No : call\_wrap[.make.sh](http://.make.sh/) vs log-wrap ?

Coulb be presets of different link or relation types (parent child vs sibling or same plane)

Is-plane ? Has-plane ? Synonym scope \!  
Is-scope for dirs (synonym of folders)

--

TODO make prefixed options uniformization (instead of "-a foobar" or "--a foobar" use "a:foobar" everywhere) // chantier e\_foobar scope var, f\_foobar functions, (local) p\_foobar argument, (local) o\_foobar option)

--

TODO overall args vs options uniformization

--

Owner.able ex : agent vs human wrappers \!

Usable example : dl web using either curl or wget ("important" software entry points in core ?)

Ideal.able : game of go, get there in as few steps and using as few atoms templates etc

Need a field thing for plain string templates vs file templates

Make idea promptable

Git branching alternative models  
Semver.able

Builder soit refactor soit generator - gen only in asc scope \!

TODO expressing need ?

TODO ASC core reserved keywords (DSL idea to express complex, nested chains)

a DSL for ASC control plane ?

--

Important software wrappers for auto log levels uniformize.able ?

--

Same host multi tasking = giw wrapper auto ssh keys \!\!

--

Yodo gitflow  
Git commits temples  
Prompt template 

seed.able = freeze.able = export.able ?

Idea - change - review - next steps \!\!\!

+ post-processed (synonyms : static export, static $subject generated / generator, compile.able ?)

--

logging helpers : "repeat.when" for conditional stdout logging ?

--

slot.able = eval.able filled by heredoc.able ?

-s  
Changeli.reviwabv

TODO aberration.catcher : daemon worker pour détecter genre telle owner a plus de 100 threads, plus de 50% de onso mémoire totale, etc.

crash prevention ?

--

gitflow.able \!  
git commits templates, presets, auto push allowed, gates \!  
[https://github.com/dengmengmian/agentgate-ai](https://github.com/dengmengmian/agentgate-ai) ?  
[https://github.com/agentkitai/agentgate](https://github.com/agentkitai/agentgate) ?

--

nest.able, link.able (relation.able) : implement "accepts" + "rejects" actions in order to compute the compatibility ?

--

ssh switch keyring = make ssk

tree.able \!  
iterate.able (synonym : iteration.able ?)  
synonym : traverse.able = wrap.able

--

semantic collisions principle (how to deal) :  
polysémie, sinon c'est synonymie (MAKE\_TASKS\_SHORTER)

--

Giw -> shw \!  
Multi shell support inc.\*.sh ?  
Shellopt wrap \!  
bash strict mode is back

--

Public ?  
Audience ?

Retry.able  
heredoc.able

--

tunnel  
vpn  
http  
ssl  
...  
-> $protocol.able.yml

--

The seed is the frozen cache with more control (agent only allowed to ... by cache path)

symlinks would solve the git crypt thing more easily...

--

ideal overarching goal : self-explanatory filenames and filepaths  
ideal overarching goal : All (forget.able ?) data must have a lifetime  
ideal overarching goal : csl / cwt / sc = shell-controller ? (whatever name will be decided) organizational precepts must be self-buildable, replicable, nestable (recursive iterations), etc.

--

Stories to describe ideas ?

--

Builder . Extender \!

combine.able \!

--

Skos implement.able -> ontology ? Taxonomy \!

Usb memory store : hardware-addressable ?  
I.e. same disk, different mount / host / etc.

Docker extension use case : inside tiny vms dedicated to agents? Raspberry pi\!

Mailhog for agents inbox but all flux must be materialized

Let's make words matter\!

Users, acl, permission?

--

tailed remote file sync :  
data/remote-$entity (data/remote-instance, data/remote-host, data/remote-aws, data/remote-s3 etc.) tailed logs didecars ex :

data/remote-instance/ = REMOTE\_INSTANCE\_DOCROOT

data/remote-instance/$data\_subdir/\*.tailsync.txt ?

make tail = loop-wrap   
make logged-tail = log-wrap loop-wrap (debunked ?)

remote-tail, remote-logged-tail ?

--

Projet complexe \! Aftermath  
Explain steps yml...  
Polish code = polish prose = polish typography = polish design  
Tutorial for humans  
Tutorial for agents

Naming things : hard problem 

End goal  
Objective ?  
Intent ?  
Chain of thought ?  
Breakable ?  
Exitable ?  
Rule.able ?

--

Is-book-bindable

congestion  
decongestion  
emergency kills switch / circuit breaker

--

Nested cursor

Nested sudo (windows vm remote piloting)

Nested vm  
Wrapped remote (instance, host) calls  
Nested piloting \! Management ?  
Nested entity? Nest.able

Nested condition system à la compta-js \!

Rules = wrap.able + nested.able capabilities   
Emitter reciever differenciator (vs comparator)

Logged-wrapped + rules-wrapped (conditional execution, like hooks)

Specimen is a sidecar (pattern) \!

Builder patterns \! Or blueprints 

Cwt introspection (globals, scoped vars, nested level, wrappers, sidecars, extensions, cwt-upstream-version, inc, opt-inc, hooks, entities, capabilities)

--

Discoverable (through x wrappers x bridges ?)

a pipe is 1 type of bridge  
a stdout redirection too  
stderr too  
all sidecars

Capacity = able ?  
Synonyms ?

Attention specificity submodules

Pattern = \*.able.yml  
Plan.able = (auto) planified  
Is.\*.yml = state (able, auto synonym)  
Prompt.balancer

Git branch = sidecar

Entity contracts yml

Whatever you want as long as x condition is met  
-> projet complexe

--

load balancer - calibrate, stress tests...

compose service \!= instance service \!= stack service \!= host service ?

Chainable entry point

Chainable  
Pipeable  
Observable  
Linkable  
Slotable  
Sortable  
Evaluable  
Viewable (diagrams)  
Protocol argument parser  
Prefer repeatable a: e: etc notation  
Make submodules auto enabled by vsriant

Sidecareable

Protocolable  
Repeatable

Circuit breaker  
Nested extension (ne)  
Hook wrapper

Jackpot

Protocol  
Cryptable  
Wrappable

Cwt subjects ignore is submodule list

Make tail log...

--

thing = actual ([schema.org](http://schema.org) ? ieml ? skos ? owl ?)  
entity = virtual (can be cwt entity, data model entity, type, etc - catergorizable by vocabulary)

--

common-web-tools local work tree : git hook post-push -> upstream commit in hom ?

--

Offloading more ?

Limits (snacks css) - scope - context  
Yml hooks everywhere (context, suitable next steps...)

--

chaining  
next steps  
intent  
chain-of-thought  
rules modules but for cwt  
migrate module but for cwt (transcriptions, insta, etc)  
task-oriented  
knowledge-oriented

Memory + storage

Blueprint + preflight (before after, git diff manual fixes as source of truth, lessons learned ?)  
Agents custom acl + dsl ?  
Link and pattern building from projet complexe  
Recursion ?  
Tree leaf etc visualização   
--

**Shortcut**  
**Target**  
lt  
logged-thread  
lc  
logged-chain  
lb  
logged-batch  
lp  
logged-pipe  
ll  
logged-loop

The addition of new implementations should be done in sync with their own "ideal" representation as cwt presets.

Update the plan to include that in its scope.

--

--

Now, does it make sense to have the default cwt core to have out-of-the-box something implementing its own hooks (like gpu and log storage) serving as an overridable default for debian hosts that :

- by default, monitor all host-level threads (opt-in behaviour from the thread subject) via crontab (overridable default, must be easily switched via a dedicated prefixed env var) so that any CWT instance (nested or not) can know about their respective siblings (if they're running already, etc).  
- offer instance-level loop monitoring (what is running, is stale, finished...)

that default cwt observability / monitoring needs a global off switch.

The plan also needs to include new living documentation files to be created at docs/[observability.md](http://observability.md) and docs/[monitoring.md](http://monitoring.md)
