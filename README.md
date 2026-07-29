# Dotforge

Automation engine driven by declarative YAML modules.

## Requirements

- `bash` - Main language
- `git` - Used to clone repositories
- `sudo` - Installing packages and manage systemd services
- `yq` - Parsing YAML modules

### Installation

#### Arch Linux

```bash
sudo pacman -Syu bash git sudo go-yq
```

#### Ubuntu

```bash
sudo apt install bash git sudo
sudo snap install yq
```

#### Alpine

```bash
sudo apk add bash git sudo yq-go
```

## How to use

1. Add this repository as [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

   ```txt
   [submodule ".dotforge"]
       path = .dotforge
       url = https://github.com/Konsyliarz42/dotforge.git
       branch = 1.0.0
   ```

2. Create **executable** `dotforge.sh`

   ```bash
    #!/bin/bash

    git submodule update --init --recursive

    ./.dotforge/validate.sh
    ./.dotforge/run.sh "$*"
   ```

3. _[OPTIONAL]_ Add configuration file
4. Create YAML modules
5. Run `dotforge.sh`

## Configuration

Dotforge has their default configuration, but you can change them by creating their own `config.yaml`

| Key             | Value                 | Description                           |
| --------------- | --------------------- | ------------------------------------- |
| sudo_interval   | 60                    | Time to keep sudo active              |
| backup.enabled  | true                  | Before any copy or link create backup |
| backup.suffix   | ".bak"                | Suffix for backup files               |
| package.manager | apk, apt, dnf, pacman | Manager used to install packages      |

## Modules

Each module must have three properties:

- `name` - Name of module
- `strict` - Boolean to stop executing when step failed
- `steps` - Array of steps to execute

### Steps

#### `clone`

_Clone git repository._

- `description` - [Optional] Text displayed in terminal during executing
- `url` - URL to git repository
- `target` - Path to directory

#### `command`

_Execute any command._

- `description` - [Optional] Text displayed in terminal during executing
- `cmd` - Command to execute

#### `copy`

_Copy file from dotfiles to the machine._

- `description` - [Optional] Text displayed in terminal during executing
- `source` - Path to file in your dotfiles
- `target` - Path to file on the machine

#### `install`

_Install packages via defined manager._

- `description` - [Optional] Text displayed in terminal during executing
- `manager` - Manager used to install packages. If you want to use custom managers you have to defined them in your config file.
- `packages` - Array of packages to install

#### `link`

_Create a symlink file from dotfiles to the machine._

- `description` - [Optional] Text displayed in terminal during executing
- `source` - Path to file in your dotfiles
- `target` - Path to file on the machine

#### `module`

_Execute other module._

- `path` - Path to module

#### `service`

_Manage systemd service._

- `description` - [Optional] Text displayed in terminal during executing
- `scope` - `user` | `system`
- `action` - `disable` | `enable` | `restart` | `start` | `stop`
- `name` - Name of the service
