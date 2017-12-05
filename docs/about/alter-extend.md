# Alter / Extend ASC

There a different ways to alter or extend ASC. They usually consist in providing your own bash files in `ASC_CUSTOM_DIR` following the conventions listed below.

It relies on [a minimalist "autoload" pattern](https://paulmicha.github.io/asc/about/patterns.html) (see **caveats** and **ways to mitigate** in documentation).

Notable alteration/extension entry points :

- `asc/bash_utils.sh`
- `asc/stack/init.sh`

## Complements

Given any bash include (sourced script include), the **complement** pattern simply attempts to include another corresponding file. The correspondance matches the relative path from `$PROJECT_DOCROOT/asc` in `$ASC_CUSTOM_DIR` : if the complementary file exists, it is included (sourced) right where `u_autoload_get_complement()` is called.

Simple example from `asc/bash_utils.sh` :

```sh
for file in $(find asc/utilities/* -type f -print0 | xargs -0); do
  . "$file"
  u_autoload_get_complement "$file"
done
```

## Hooks

TODO

## Overrides

Same as the **complement** pattern, but this only includes the corresponding file :

Given any bash include (sourced script include), the **override** pattern attempts to include another corresponding file. The correspondance matches the relative path from `$PROJECT_DOCROOT/asc` in `$ASC_CUSTOM_DIR` : if the overriding file exists, it is included (sourced) instead.

Example in `asc/git/apply_config.sh` :

```sh
# When called in current shell scope, this will prevent the rest of the script
# to run - return early - if an override for the current file (calling this) was
# found and sourced.
eval $(u_autoload_override "$BASH_SOURCE")
```

Example in `u_hook()` :

```sh
for hook_script in "${lookup_paths[@]}"; do
  if [[ -f "$hook_script" ]]; then
    eval $(u_autoload_override "$hook_script" 'continue')
    . "$hook_script"
  fi
  u_autoload_get_complement "$hook_script"
done
```

## Presets

TODO
