# Claude Docker

## Overview

The idea of this project is to allow Claude Code to run in a Sandboxed environment. It will mount the current directory in `/project`, which is the area where Claude Code will run. As such, it will be able to many any changes to the project, but it won't be able to directly change the host system autonomously.

Claude will be run using `--dangerously-skip-permissions`, which will allow it to be more autonomous.

## Setup

Ensure that Docker or equivelant is currently running on your system.

Ensure that the `claude-build.sh` and `claude-run.sh` scripts are set to executable:

```
chmod +x claude-build.sh
chmod +x claude-run.sh
```

Then run the build script:

```
./claude-build.sh
```

After that, you can create an alias to execute the run script. With ZSH, you could add this to your `.zshrc` file:

```
alias claude='/path/to/claude-run.sh'
```

After reloading the configuration (e.g. running `source ~/.zshrc` or restarting your terminal), you should be able to run `claude` from within any directory.

The script will mount the current directory in the image at `/project` and run Claude Code within that directory.

## Authentication

On first run, if no authentication is found, you will be prompted to log in. Claude will print a URL — open it in your browser, complete the sign-in, and paste the resulting code back into the terminal.

Authentication is persisted in `claude/config/` so subsequent runs will not require re-authentication.

## Reference Directories

You can give Claude read-only access to directories outside the current project using `--add-dir`:

```
claude --add-dir /home/josh/projects/other-repo
```

This mounts the directory at `/refs/other-repo` inside the container (using the directory's basename by default). You can specify a custom name with a colon:

```
claude --add-dir /home/josh/projects/other-repo:other
```

This mounts it at `/refs/other` instead. If two `--add-dir` arguments resolve to the same name, the script will exit with an error.

## Configuration

Default settings are stored in `claude/claude.defaults.json` and `claude/settings.defaults.json`. These are baked into the Docker image and copied to `claude/claude.json` and `claude/config/settings.json` on first run. The `claude/claude.json` and `claude/config/` files are gitignored so personal configuration and credentials are never committed.

## Warnings

This isn't 100% foolproof. For it to function, some internet requests must be allowed, so it's not completely isolated from the internet. In addition, whilst the isolation should prevent Claude Code from being able to execute commands on the host, it won't stop Claude from inserting something malcious into the project which may, in turn, get executed on the host machine or another environment.

