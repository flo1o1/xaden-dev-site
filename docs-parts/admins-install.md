Xaden runs from one folder on your machine and gives you one command, `xaden`. Install it once; every
other command in these docs uses it. First get the files (clone or zip), then run the installer.

### Get the files

Clone with git (recommended, because `git pull` updates Xaden later):

```bash
git clone https://github.com/flo1o1/xaden.git ~/.xaden
```

- `git clone ...`: downloads Xaden into the hidden folder `.xaden` in your home directory.

Or download the release as a zip (no git history; you update by downloading a newer release):

```bash
curl -fsSL -o xaden.zip https://github.com/flo1o1/xaden/archive/refs/tags/@TAG@.zip
unzip -q xaden.zip -d ~/tools
```

- `curl ...`: downloads the archive of release @TAG@ into the current folder and stops with an error if the download fails.
- `unzip ...`: extracts it into `~/tools/xaden-@VERSION@`. If `unzip` is missing, install it with your package manager.

Xaden publishes no checksums or signatures. Download only from the address above over HTTPS and read
the scripts you are about to run: they are plain shell.

### Install the command

```bash
~/.xaden/scripts/install.sh
```

- `~/.xaden/scripts/install.sh`: creates one link, `~/.local/bin/xaden`, that points into the Xaden folder. It changes nothing else and never replaces a different file of that name. Keep the folder where it is, because the link points into it.

If you downloaded the zip, run the installer from that folder instead: `~/tools/xaden-@VERSION@/scripts/install.sh`.

If `~/.local/bin` is not on your `PATH`, the installer says so. Add this line to your shell profile
(`~/.bashrc` for bash, `~/.zshrc` for zsh) and open a new terminal:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

- `export PATH=...`: puts `~/.local/bin` in front of the folders your shell searches for commands, so it finds `xaden`.

Check the result:

```bash
xaden version
```

- `xaden version`: prints the installed Xaden version, @VERSION@ for this release.

### Update Xaden

If you cloned it:

```bash
git -C ~/.xaden pull
```

- `git -C ~/.xaden pull`: fetches the newest Xaden into the folder. The `xaden` command keeps working. To stay on a fixed release instead of the newest code, run `git -C ~/.xaden tag -l` to list the releases and `git -C ~/.xaden checkout @TAG@` (use the release you want) to switch; switch back with `git -C ~/.xaden checkout main` before the next pull.

If you downloaded the zip, get the new release and extract it next to the old one. Then move the command over:

```bash
~/tools/xaden-OLD/scripts/install.sh --uninstall
~/tools/xaden-NEW/scripts/install.sh
rm -r ~/tools/xaden-OLD
```

- `~/tools/xaden-OLD/scripts/install.sh --uninstall`: removes the `xaden` link, but only if it points into the old folder. Replace `OLD` with the old version, for example `0.2.2`.
- `~/tools/xaden-NEW/scripts/install.sh`: links `xaden` to the new folder. Replace `NEW` with the new version.
- `rm -r ~/tools/xaden-OLD`: deletes the old folder once the new link works.

### Planned: one Xaden version per project

> **Planned, not released yet.** The commands in this section are approved but not built.

A team project will pin the Xaden version it uses, together with a checksum, in its `xaden/` folder.
Installing a newer Xaden on your machine changes nothing in a project.

```bash
xaden doctor
xaden fetch 0.3.0
xaden upgrade
```

- `xaden doctor`: compares the installed version with the one the project pins. It does not use the network.
- `xaden fetch 0.3.0`: downloads that version after you confirm, and installs it only if the checksum matches. Replace `0.3.0` with the pinned version.
- `xaden upgrade`: moves the project to a newer version on a branch. It updates the rules file and shows what changed, so your team reviews it in a pull request.

### Linux

git, bash, awk, sed, tar, grep and cksum are normally preinstalled. Install a missing one with your
distribution's package manager.

### macOS

bash 3.2, the version macOS ships, is supported. If `git` is missing, running it once offers to install
Apple's command line tools. The default shell is zsh, so the `PATH` line goes into `~/.zshrc`.

### Windows

Untested: nobody has run these steps on Windows yet, so expect to adapt them. WSL is recommended: open a
WSL shell and follow the Linux steps, keeping Xaden and your projects in the Linux file system (your
WSL home directory) rather than under `/mnt/c`. Git Bash is also possible but untested. Native
PowerShell is not supported, because the scripts are bash.
