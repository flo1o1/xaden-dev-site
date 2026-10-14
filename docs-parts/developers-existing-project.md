> **Planned, not released yet.** `xaden adopt` is approved but not built; Xaden @VERSION@ has no such
> command. This section shows what the release will do. The method that works today follows below it.

### The planned way: `xaden adopt`

Your repository keeps its build, its tests and its CI. Xaden is added beneath it in one pull request
that your team reviews.

```bash
cd ~/code/shop
xaden adopt --scan
xaden adopt --plan
xaden adopt
```

- `cd ~/code/shop`: goes to your repository.
- `xaden adopt --scan`: reads the repository and reports its language, test and lint commands, CI, git hooks and existing `AGENTS.md`. It changes no file.
- `xaden adopt --plan`: prints exactly which files would be created or touched. It writes nothing.
- `xaden adopt`: applies the plan on its own branch, ready for a pull request. It asks before it downloads anything.

What it adds:

- A visible folder `xaden/` with your requirements, personas and security reviews as plain Markdown, plus one settings file that pins the Xaden version.
- A short marked block in `AGENTS.md` that points to the rules. Text you wrote there stays untouched. `CLAUDE.md` is created only if you use Claude Code.
- Your own test and lint commands are reused, and hooks are added next to the ones you already have. If a tool is missing, Xaden offers a preset as a separate step and adds nothing unless you accept.

Existing code never blocks you. Findings that are already there are recorded in a baseline that can
only shrink, and you choose how strict the checks are: warn only, hold changed files to the rules, or
hold everything.

### Today: merge into a fresh Xaden project

Xaden has no one-step import for an existing project yet. The reliable way is to create a fresh Xaden
project and merge your project's git history into it. Your files and history stay, and Xaden adds its
rules, checks and documents around them. The example assumes your project is `~/code/shop`.

### 1. Create the Xaden project next to it

```bash
cd ~/code
xaden new shop-xaden
cd shop-xaden
```

- `cd ~/code`: goes to the folder that holds your project.
- `xaden new shop-xaden`: creates the new project `shop-xaden` there, with its own git repository and hooks.
- `cd shop-xaden`: moves your terminal into it.

### 2. Merge your project into it

```bash
git remote add old ../shop
git fetch old
git merge old/main --allow-unrelated-histories
```

- `git remote add old ../shop`: registers your project's repository under the name `old`.
- `git fetch old`: copies its history over without touching any file.
- `git merge old/main --allow-unrelated-histories`: joins the two histories. The flag is needed because they have no common start. Replace `main` with your branch name; `git -C ../shop branch --show-current` prints it.

### 3. Resolve the conflicts

Git stops at files that exist in both projects, usually `README.md` and `.gitignore`. Open each one and
keep what you need: your own text for the README, the lines of both for `.gitignore`. Then finish the
merge:

```bash
git add README.md .gitignore
git commit --no-edit
git remote remove old
```

- `git add README.md .gitignore`: marks the two files as resolved. Add every other file Git listed as conflicting in the same way.
- `git commit --no-edit`: completes the merge with Git's default message.
- `git remote remove old`: removes the link to your old project.

### 4. Check and teach the assistant

```bash
xaden check
```

- `xaden check`: runs all checks on the merged project. Existing code may trigger findings. Fix them, or record the current violations in the tool's baseline file so that only new code is held to the rule.

Then start your assistant and run `/kickoff`. Describe what the project already does instead of a new
idea. It asks questions and writes the requirements, the threat model and the architecture notes, and
you approve them. Review what it writes, because it describes code you know better than it does.
