# Environment settings

The variables written and loaded using the scripts in `asc/env` directory are used in all ASC tasks. Some are common to any type of stack, while others are specific to certain variants.

The very first step required to use ASC is writing current instance's env settings, a task referred to as **stack init** :

```sh
# This is the starting point.
# It provides options and/or terminal prompts to obtain all mandatory values,
# then calls asc/env/write.sh.
. asc/stack/init.sh

# Optional arguments examples.
# Details : see asc/stack/init/get_args.sh
. asc/stack/init.sh -p ansible # Specify provisioning tool.
. asc/stack/init.sh -s nodejs-8 -y # Specify project stack + bypass prompts (will use defaults).
. asc/stack/init.sh -s drupal-7--redis,varnish-4,solr -y # Add services to the stack using '--' separator.
```

This process generates a single file (`asc/env/current/vars.sh`) by assembling 2 types of files :

1. dependency files - purpose : aggregate host-level *services* (or softwares) dependencies;
1. env files called config or env *models* - purpose : aggregate env settings (global variables) necessary for configuring the local project instance and its services.

## Software dependencies (required host services)

Dependencies specify all services (or softwares) required to run the current project instance(s). They are used to list what will be provisioned on hosts.

The list of dependencies is stored in the `$STACK_SERVICES` global variable. The syntax used to declare these dependencies allows to specify mutually exclusive alternative (uses either this OR that).

```sh
# Dependency declaration syntax examples - see asc/app/drupal/dependencies.sh

# Separate each item with a comma.
# Use the '..' prefix to specify a list of mutually exclusive alternatives.
softwares='php,..db,..webserver'

# Each list of alternatives is a simple comma-separated string.
alternatives['..db']='mariadb,mysql,postgresql'
alternatives['..webserver']='apache,nginx'
```

## Configuration aggregation (env settings)

```sh
# Env models syntax examples - see asc/env/vars.sh

# 1. No default value provided.
define PROJECT_STACK

# 2. Immediate variable substitution (uses current shell scope variables).
define PROJECT_DOCROOT "[default]=$PWD"

# 3. Subshell demo (callback must echo result).
define HOST_OS "[default]=$(u_host_get_os)"

# 4. Variable substitution during env vars aggregation - see :
# asc/stack/init/aggregate_env_vars.sh
define APP_DOCROOT "[default]=\$PROJECT_DOCROOT/web"
```

The aggregation rules consist of a correspondance between a basic syntax used in the `$PROJECT_STACK` value (+ `$PROVISION_USING` value) and optional directories + filenames matching it.

The way this process works is :

- get `$PROJECT_STACK` value (see examples below) and `$PROVISION_USING` value - if not provided in `asc/stack/init.sh` arguments
- add the common, generic `asc/env/vars.sh` model
- check if additional, optional rules-matching models exist
- assemble all models found
- assign values to the variables they contain by using terminal prompts - if not provided (or instructed to use default values) in `asc/stack/init.sh` arguments
- write the result to `asc/env/current/vars.sh`

Every time `asc/stack/init.sh` is called, current instance's env file is (over)written.

`$PROJECT_STACK` and `$PROVISION_USING` values are used to derive the rest of conditional settings and custom overrides/complements lookup paths. Aggregation will include generic models first, then more specific ones, and finally their corresponding customization (overrides or complements)

ASC provides a few models but its purpose remains to be useful for your specific project(s), so the reason this process is detailed here is to better understand how to provide your own custom env settings declarations.

To illustrate how lookups work, we use the following examples for possible `$PROJECT_STACK` values :

1. `contenta` (nothing else specified = use latest version of the corresponding "barebone" stack + project settings)
1. `drupal-7--php-5.4,redis,solr-3` (request additional services after the *variant* or *modifier* separator `--` and then separate multiple services by `,` if needed)
1. `phenomic--libp2p,p-preact` (predefined combos or custom namespaces may be provided as *presets*, freely named - uses `p-` prefix to avoid potential collisions with services)

The config models paths looked up for each example are listed below, in order. Each "candidate" may be overridden or complemented using the normal customization pattern (see `asc/custom/README.md`).

### Example 1 : `PROJECT_STACK=contenta`

- `asc/provision/${PROVISION_USING}.vars.sh`
- corresponding `provision` customizations
- `asc/app/contenta/env.vars.sh`
- `asc/app/contenta/env.${PROVISION_USING}.vars.sh`
- corresponding `app` customizations (same order)

### Example 2 : `PROJECT_STACK=drupal-7--php-5.4,redis,solr-3`

- `asc/provision/${PROVISION_USING}.vars.sh`
- `asc/provision/php/${PROVISION_USING}.vars.sh`
- `asc/provision/php/5.4/${PROVISION_USING}.vars.sh`
- `asc/provision/redis/${PROVISION_USING}.vars.sh`
- `asc/provision/solr/${PROVISION_USING}.vars.sh`
- `asc/provision/solr/3/${PROVISION_USING}.vars.sh`
- corresponding `provision` customizations (same order)
- `asc/app/drupal/env.vars.sh`
- `asc/app/drupal/env.${PROVISION_USING}.vars.sh`
- `asc/app/drupal/7/env.vars.sh`
- `asc/app/drupal/7/env.${PROVISION_USING}.vars.sh`
- corresponding `app` customizations (same order)

### Example 3 : `PROJECT_STACK=phenomic--libp2p,p-preact`

- `asc/provision/${PROVISION_USING}.vars.sh`
- `asc/provision/libp2p/${PROVISION_USING}.vars.sh`
- `asc/provision/presets/phenomic/preact.vars.sh`
- `asc/provision/presets/phenomic/preact.${PROVISION_USING}.vars.sh`
- corresponding `provision` customizations (same order)
- `asc/app/phenomic/env.vars.sh`
- `asc/app/phenomic/env.${PROVISION_USING}.vars.sh`
- corresponding `app` customizations (same order)

## Roadmap

```sh
# Differenciate secrets store from registry, which would then only store things
# like non-secret host-level flags. Ex:
SECRETS_BACKEND=ansible_vault
SECRETS_BACKEND=hashicorp_vault

# Implement automated tests / Visual Regression Testing (as presets ?) - ex:
APP_TESTS_PRESET=behat
APP_TESTS_PRESET=gatling

APP_VRT_PRESET=gemini
APP_VRT_PRESET=puppeteer
```
