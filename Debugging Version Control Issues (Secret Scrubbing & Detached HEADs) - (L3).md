# Debugging Version Control Issues (Secret Scrubbing & Detached HEADs) - (L3)

## Problem Statement

A junior developer accidentally hardcoded a plaintext AWS API key into a config file (`aws_config.json`) and committed it to the repository. Three more commits were made on top before the mistake was noticed, burying the secret deeper in history. While trying to inspect the old code, the developer also checked out a commit directly by hash and ended up in a **detached HEAD** state, disconnected from any branch.

This scenario is dangerous for two separate reasons:

1. **A leaked secret in Git history is a leaked secret, period.** Simply deleting the key in a new commit (e.g. `git commit -m "remove key"`) does **not** remove it from the repository. Git stores every commit as a full snapshot, so the old commit containing the plaintext key still exists in the object database and remains fully retrievable with `git log -p`, `git show <hash>`, or by checking out that commit directly — even after the file is "fixed" later. Anyone with access to the repo (or its clone history, forks, or CI logs) can dig it out. The only real fix is to **rewrite history** at the exact commit where the secret was introduced.
2. **A detached HEAD is not an error, but it is a trap if misunderstood.** It simply means `HEAD` is pointing directly at a commit instead of at a branch reference. Any new commits made in this state would not belong to any branch and could be lost permanently (eligible for garbage collection) once you switch away, unless explicitly saved to a new branch.

The fix required two things: safely return to the main timeline, then perform a surgical interactive rebase to edit the bad commit and permanently scrub the secret from history.

## Repository Used

A dedicated repo, `git-recovery-lab`, was created for this exercise to keep the secret-scrubbing history isolated and easy to verify.

## Steps Followed

### Step 1: Recreate the disaster

```bash
mkdir git-recovery-lab && cd git-recovery-lab
git init

echo "<html><body><h1>Hello</h1></body></html>" > index.html
git add index.html
git commit -m "Initial commit"

echo '{"API_KEY": "AKIAIOSFODNN7EXAMPLE"}' > aws_config.json
git add aws_config.json
git commit -m "Add AWS config"

echo "body { background: #fff; }" > styles.css
git add styles.css
git commit -m "Add styles"

echo "console.log('app loaded');" > app.js
git add app.js
git commit -m "Add javascript"

git log --oneline
```

### Step 2: Trigger the detached HEAD state

```bash
git checkout <hash-of-initial-commit>
git branch
```

Git printed the standard warning:

```
Note: switching to '<hash>'.
You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by switching back to a branch.
```

`git branch` confirmed `HEAD` was floating, not attached to `main`:

```
* (HEAD detached at <hash>)
  main
```

**[Insert Screenshot 1 here — detached HEAD warning + `git branch` output]**
`![Detached HEAD State](screenshot-detached-head.png)`

### Step 3: Reattach HEAD to main

Since no new commits were made while detached, reattaching was a simple branch switch:

```bash
git checkout main
git log --oneline
```

This works because `git checkout main` moves `HEAD` to point at the `main` branch reference again instead of a raw commit — no merge or recovery needed since nothing was changed in the detached state.

### Step 4: Start the interactive rebase

```bash
git rebase -i HEAD~3
```

This opened the rebase todo list with the last 3 commits:

```
pick <hash> Add AWS config
pick <hash> Add styles
pick <hash> Add javascript
```

The `pick` on the **"Add AWS config"** line was changed to `edit`, then saved. Git paused exactly at that commit:

```
Stopped at <hash>... Add AWS config
You can amend the commit now, with

  git commit --amend

Once you are satisfied with your changes, run

  git rebase --continue
```

### Step 5: Scrub the secret and resume

```bash
nano aws_config.json
```

Changed the file content from:
```json
{"API_KEY": "AKIAIOSFODNN7EXAMPLE"}
```
to:
```json
{"API_KEY": "REDACTED"}
```

Then staged and amended the paused commit, and resumed the rebase:

```bash
git add aws_config.json
git commit --amend --no-edit
git rebase --continue
```

Output:
```
[detached HEAD <hash>] Add AWS config
 1 file changed, 1 insertion(+)
 create mode 100644 aws_config.json

Successfully rebased and updated refs/heads/main.
```

### Step 6: Verify and document

```bash
git log -p
```

The full history was reviewed end to end. The original plaintext key (`AKIAIOSFODNN7EXAMPLE`) does **not** appear anywhere in the output — only the redacted version shows up in the rewritten commit:

```
commit <hash>
Author: ...
Date:   ...

    Add AWS config

diff --git a/aws_config.json b/aws_config.json
new file mode 100644
index 0000000..1d1cf08
--- /dev/null
+++ b/aws_config.json
@@ -0,0 +1 @@
+{"API_KEY": "REDACTED"}
```

All commit hashes after and including "Add AWS config" changed as a result of the rebase, confirming that history was genuinely rewritten rather than patched with a new commit on top.

**[Insert Screenshot 2 here — full `git log -p` output proving plaintext key is gone]**
`![Clean History Verification](screenshot-clean-history.png)`

## Output / Logs Summary

| Stage | Evidence |
|---|---|
| Detached HEAD triggered | Screenshot 1 — `git branch` shows `(HEAD detached at <hash>)` |
| HEAD reattached | `git checkout main` → `Switched to branch 'main'` |
| Rebase paused at bad commit | `Stopped at <hash>... Add AWS config` |
| Secret scrubbed | `git commit --amend --no-edit` succeeded |
| Rebase completed | `Successfully rebased and updated refs/heads/main.` |
| History verified clean | Screenshot 2 — `git log -p` shows only `REDACTED`, no plaintext key anywhere |

<img width="937" height="981" alt="image" src="https://github.com/user-attachments/assets/5ad9a8b7-8483-41e2-b2a6-7b9c2653daa3" />
<img width="937" height="953" alt="image" src="https://github.com/user-attachments/assets/a4d67510-2986-403c-8ccd-bbf29a78d37c" />
<img width="938" height="981" alt="image" src="https://github.com/user-attachments/assets/82f98c92-987f-462e-ba11-a2dcf66e8d37" />
<img width="937" height="793" alt="image" src="https://github.com/user-attachments/assets/dba320f0-49c8-49c7-a7a3-3a38bbb11e74" />
