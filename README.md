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

## Warnings

This isn't 100% foolproof. For it to function, some internet requests must be allowed, so it's not completely isolated from the internet. In addition, whilst the isolation should prevent Claude Code from being able to execute commands on the host, it won't stop Claude from inserting something malcious into the project which may, in turn, get executed on the host machine or another environment.

