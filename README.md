# Dotforge

Automation engine driven by declarative YAML modules.

## Requirements

- `bash` - Main language
- `git` - Used to clone repositories
- `sudo` - Used to install packages and manage systemd services
- `yq` - Used to parse YAML modules

### Alpine

```bash
sudo apk add bash git sudo yq-go
```

### Arch Linux

```bash
sudo pacman -Syu bash git sudo go-yq
```

### Fedora

```bash
sudo dnf install bash git sudo yq
```

### Ubuntu

```bash
sudo apt install bash git sudo
sudo snap install yq
```

## How to use

1. Add this repository as a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules) to your dotfiles

   ```txt
   [submodule "dotforge"]
       path = .dotforge
       url = https://github.com/Konsyliarz42/dotforge.git
       branch = <branch_or_tag>
   ```

2. Create an **executable** `dotforge.sh` in the root of your dotfiles

   ```bash
    #!/bin/bash
    set -euo pipefail

    git submodule update --init --recursive

    profile_path="$1"

    ./.dotforge/validate.sh -p "$profile_path"
    ./.dotforge/run.sh "$profile_path"
   ```

3. _[Optional]_ Add a configuration file

   After that, you have to update your `dotforge.sh`

   ```bash
       #!/bin/bash
       set -euo pipefail

       git submodule update --init --recursive

       profile_path="$1"
       config_path="<path_to_config>"

       ./.dotforge/validate.sh -c "$config_path" -p "$profile_path"
       ./.dotforge/run.sh -c "$config_path" "$profile_path"
   ```

4. Create a profile and modules
5. Run your script

   ```bash
   ./dotforge.sh <profile_path>
   ```

## Configuration

By default, dotforge uses its own config file, `default_config.yaml`.

You can create your own config file in YAML format. Dotforge will then search your config first, and if a property doesn't exist there, it will fall back to the default value.

## Logs

All stdout and stderr are saved in the `logs` directory, grouped by module.

## Validation

It's highly recommended to validate a profile before executing it on a new machine.
If you're developing new modules, you can always check a single module using:

```bash
validate.sh <module_path>
```

or check the whole profile:

```bash
validate.sh -p <profile_path>
```

## Basic concepts

Dotforge defines two types of YAML files:

### Profile

This file defines the order in which modules will be executed.

The file requires this structure:

```yaml
name: <name_of_the_profile>

modules:
    - <module_path>
    - <module_path>
    ...
```

### Module

This file should define what needs to be executed to fully set up a program (install packages, clone/link configuration, enable a daemon, etc.).

The file requires this structure:

```yaml
name: <name_of_the_module>
strict: <enable_disable_strict_mode>

steps:
    - type: <type_of_step>
      <step_options>
    ...
```

> Strict mode requires that all steps finish with an exit code of 0.

#### Steps

Steps define commands to execute. Each step has its own type and options:

##### `clone`

Clones a git repository.

| Option        | Type   | Description           |
| ------------- | ------ | --------------------- |
| `description` | string | Text to display       |
| `target`\*    | string | Path to clone into    |
| `url`\*       | string | URL of the repository |

> _\* - Option is required_

##### `command`

Executes a custom command.

| Option        | Type    | Description                                                          |
| ------------- | ------- | -------------------------------------------------------------------- |
| `cmd`\*       | string  | Command to execute                                                   |
| `description` | string  | Text to display                                                      |
| `optional`    | boolean | Allow the step to exit with a code other than 0, even in strict mode |

> _\* - Option is required_

##### `copy`

Copies a file to a specific path and creates its parent directories.

| Option        | Type   | Description                                        |
| ------------- | ------ | -------------------------------------------------- |
| `description` | string | Text to display                                    |
| `source`\*    | string | Path to the file (relative to the repository root) |
| `target`\*    | string | Path to the file (relative to the user's home)     |

> _\* - Option is required_

##### `install`

Installs packages via a manager.

> You can define your own managers in the config file, but remember to install them before you want to use them.

| Option        | Type   | Description                                    |
| ------------- | ------ | ---------------------------------------------- |
| `description` | string | Text to display                                |
| `manager`\*   | string | Name of the manager defined in the config file |
| `packages`\*  | array  | List of the packages to install                |

> _\* - Option is required_

##### `link`

Creates a link to a specific path and creates its parent directories.

| Option        | Type   | Description                                        |
| ------------- | ------ | -------------------------------------------------- |
| `description` | string | Text to display                                    |
| `source`\*    | string | Path to the file (relative to the repository root) |
| `target`\*    | string | Path to the file (relative to the user's home)     |

> _\* - Option is required_

##### `service`

Manages a systemd service.

| Option        | Type   | Description                                     |
| ------------- | ------ | ----------------------------------------------- |
| `action`\*    | string | `disable`, `enable`, `restart`, `start`, `stop` |
| `description` | string | Text to display                                 |
| `name`\*      | string | Name of the service                             |
| `scope`\*     | string | `system`, `user`                                |

> _\* - Option is required_
