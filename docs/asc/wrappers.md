# ASC core concept : Wrappers

Table of contents :

1. batch (synonym : parallel)
1. chain (synonym : sequence)
1. cronjob (TODO or just use "raw" thread wrapper instead ?)
1. loop (TODO synonyms : deamon ? background task ? background job ? always-on ?)
1. nested
1. pipe
1. remote
1. rule (conditional and/or nested combinations)
1. sequence
1. stream ?
1. thread
1. tunnel

## nested (synonym ~ recursivity)

TODO [wip]

- nested-asc : deals with child ASC project instances (any host-related things must automatically climb up the chain to avoid duplicating crontabs, logs, etc)
- nested-git : deals with child git clones / work trees
- nested-extension = sub-modules = sub-folder(s) in any ASC extension place via .asc_subjects_ignore
- nested-blueprint ? (see builder + possibility of sub-modules)
