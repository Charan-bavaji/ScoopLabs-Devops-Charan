# Git and GitHub Interview Prep: 2 to 5 Years Experience

Questions with interview answers and the commands to say (and show) while answering.

**How to use this file:** For each question, read the **Say** part (your spoken answer, in simple words), then practice the **Commands**. In the interview, say the answer first, then type or explain the commands.

**Practice folder (WSL):**

```bash
mkdir -p ~/linuxCMD/git-lab && cd ~/linuxCMD/git-lab
git init
git config user.name "Your Name"
git config user.email "you@example.com"
```

## Sections

1. Basics and concepts (Q1 to Q11)
2. Branching and workflow (Q12 to Q16)
3. Scenarios: fix mistakes (Q17 to Q26)
4. Merge conflicts (Q27 to Q30)
5. Debugging with Git (Q31 to Q35)
6. GitHub collaboration and security (Q36 to Q40)
7. GitHub Actions and CI/CD (Q41 to Q51)
8. Advanced Git (Q52 to Q57)

---

# 1. Basics and concepts

## Q1. What is the difference between Git and GitHub?

**Say:** Git is a version control tool. It runs on my computer, tracks changes in code, and lets me work with branches. GitHub is a website that hosts Git repositories. It adds team features like pull requests, code review, issues, permissions, and GitHub Actions for CI/CD. GitLab and Bitbucket are similar to GitHub.

**Commands:**

```bash
git --version
git init                                   # start a Git repo on my machine
git remote add origin <repo-url>           # connect it to GitHub
git push -u origin main                    # send my code to GitHub
```

---

## Q2. What are the three areas of Git?

**Say:** The **working directory** is where I edit files. The **staging area** (also called the index) is where I choose which changes go into the next commit. The **repository** (the `.git` folder) stores the saved commits. The **remote** (GitHub) is the shared copy.

**Commands:**

```bash
git status                     # see the state of all areas
git add file.txt               # working directory -> staging
git commit -m "message"        # staging -> local repository
git push origin main           # local repository -> remote
git diff                       # working directory vs staging
git diff --staged              # staging vs last commit
```

---

## Q3. What is the difference between `git fetch` and `git pull`?

**Say:** `git fetch` downloads new commits from the remote, but it does **not** change my files or my branch. `git pull` is fetch plus merge (or rebase), so it changes my branch. I like to fetch first, look at what changed, and then merge.

**Commands:**

```bash
git fetch origin
git log HEAD..origin/main --oneline        # see what is new on the remote
git merge origin/main                      # bring it into my branch
git pull --rebase origin main              # fetch + rebase (straight history)
```

---

## Q4. What is the difference between merge and rebase?

**Say:** **Merge** joins two branches with a merge commit. It keeps the full history as it happened. **Rebase** takes my commits and replays them on top of the latest target branch, so the history is a straight line. The golden rule: **never rebase a branch that other people are using**, because rebase rewrites history. I rebase my own feature branch before the PR, and I merge into main.

**Commands:**

```bash
git switch feature
git merge main                             # merge main into my branch
git rebase main                            # or: replay my commits on top of main
git push --force-with-lease                # needed after a rebase (my own branch only)
git log --oneline --graph --all            # see the difference in history
```

---

## Q5. What is the difference between `reset`, `revert`, and `restore`?

**Say:** `git reset` moves the branch back and **rewrites history**. I use it only for local commits that are not pushed. `git revert` creates a **new commit that undoes** an old commit, so it is safe for pushed and shared branches. `git restore` throws away changes in files (or removes them from staging).

**Commands:**

```bash
git reset --soft HEAD~1        # undo commit, keep changes staged
git reset --mixed HEAD~1       # undo commit, keep changes unstaged (default)
git reset --hard HEAD~1        # undo commit and DELETE the changes
git revert <commit-sha>        # new commit that undoes that commit
git restore file.txt           # discard changes in the file
git restore --staged file.txt  # remove the file from staging
```

---

## Q6. What is `git stash`?

**Say:** Stash saves my uncommitted work on a shelf, so my working directory is clean. Then I can switch branches, do something urgent, and bring my work back later.

**Commands:**

```bash
git stash push -m "wip login page"
git stash push -u                 # also include new (untracked) files
git stash list
git stash pop                     # bring back the latest and remove it from the list
git stash apply stash@{1}         # bring back a specific one and keep it in the list
git stash drop stash@{0}          # delete one
```

---

## Q7. What is `cherry-pick` and when do you use it?

**Say:** Cherry-pick copies **one specific commit** from another branch onto my current branch. A common use is a hotfix: the fix is on `develop`, and I need only that fix on the `release` branch.

**Commands:**

```bash
git log --oneline develop          # find the commit id
git switch release
git cherry-pick <commit-sha>
git cherry-pick --continue         # after fixing a conflict
git cherry-pick --abort            # cancel
```

---

## Q8. What is HEAD? What is a detached HEAD?

**Say:** HEAD points to where I am now, usually the latest commit of my current branch. **Detached HEAD** means HEAD points straight to a commit and not to a branch (for example, after `git checkout <sha>` or a tag). If I commit there, those commits can get lost when I switch away. The fix: create a branch at that point.

**Commands:**

```bash
cat .git/HEAD                      # shows "ref: refs/heads/main" normally
git checkout <commit-sha>          # this makes a detached HEAD
git switch -c rescue-branch        # keep my work by making a branch
git switch main                    # go back to normal
```

---

## Q9. A file is in `.gitignore`, but Git still tracks it. Why?

**Say:** `.gitignore` only works for files Git is **not tracking yet**. If a file was already committed, ignoring it does nothing. I need to remove it from tracking (not from disk) and commit.

**Commands:**

```bash
echo ".env" >> .gitignore
git rm --cached .env                       # stop tracking, keep the file on disk
git rm -r --cached node_modules            # same for a folder
git commit -m "Stop tracking .env"
git check-ignore -v .env                   # shows which rule ignores a file
```

---

## Q10. What is the difference between fork, clone, and branch?

**Say:** **Clone** copies a repository to my machine. **Fork** makes my own copy of someone else's repository on GitHub (used in open source, when I have no write access). **Branch** is a separate line of work inside the same repo. With a fork I add an `upstream` remote to keep my copy up to date.

**Commands:**

```bash
git clone <url>
git remote -v
git remote add upstream <original-repo-url>
git fetch upstream
git switch main
git merge upstream/main                    # sync my fork with the original
git push origin main
```

---

## Q11. What is a pull request and how does the flow work?

**Say:** A pull request (PR) asks to merge my branch into another branch, usually `main`. The team reviews the code, comments, CI runs the tests, someone approves, and then we merge. Flow: create branch, commit, push, open PR, review, merge, delete branch.

**Commands:**

```bash
git switch -c feature/login
git add . && git commit -m "Add login page"
git push -u origin feature/login
gh pr create --title "Add login page" --body "What and why"
gh pr list
gh pr checkout 12                          # test someone else's PR locally
gh pr merge 12 --squash --delete-branch
```

---

# 2. Branching and workflow

## Q12. Explain branching strategies: GitFlow, GitHub Flow, and trunk-based.

**Say:** **GitFlow** has `main`, `develop`, `feature`, `release`, and `hotfix` branches. It is good for planned releases, but it is heavy. **GitHub Flow** is simple: `main` is always deployable, I make a short feature branch, open a PR, merge, and deploy. **Trunk-based** means everyone merges to `main` in small, quick changes, often with feature flags. For CI/CD and DevOps I prefer GitHub Flow or trunk-based, because they deploy faster with less merge pain.

**Commands:**

```bash
git switch -c feature/payment main         # feature branch
git switch -c hotfix/1.0.1 main            # hotfix branch (GitFlow)
git switch -c release/1.1.0 develop        # release branch (GitFlow)
git tag -a v1.0.1 -m "Hotfix release"
```

---

## Q13. What are the merge options on GitHub: merge commit, squash, and rebase merge?

**Say:** **Merge commit** keeps all commits and adds one merge commit. **Squash and merge** turns all PR commits into one commit, so `main` stays clean. **Rebase and merge** replays each commit on `main` with no merge commit, so the history is linear. Many teams choose squash for small feature PRs.

**Commands:**

```bash
gh pr merge 12 --merge
gh pr merge 12 --squash
gh pr merge 12 --rebase
```

---

## Q14. What is a fast-forward merge?

**Say:** If `main` has no new commits since I created my branch, Git just moves the `main` pointer forward. There is no merge commit. If I want a merge commit anyway, I use `--no-ff`.

**Commands:**

```bash
git merge --ff-only feature/x              # fails if a fast-forward is not possible
git merge --no-ff feature/x                # always create a merge commit
```

---

## Q15. How do you delete a branch locally and on the remote?

**Say:** `-d` deletes a branch only if it is merged. `-D` forces the delete. To delete on GitHub I use `push --delete`. I also clean old remote references with `fetch --prune`.

**Commands:**

```bash
git branch -d feature/x                    # safe delete (merged only)
git branch -D feature/x                    # force delete
git push origin --delete feature/x         # delete on remote
git fetch --prune                          # remove stale remote branches locally
git branch --merged main                   # list branches that are already merged
```

---

## Q16. What are tags and releases?

**Say:** A **tag** marks a specific commit, usually a version like `v1.0.0`. An **annotated tag** also stores the author, date, and message. A **GitHub Release** is built on a tag and can have notes and files. In CI/CD, pushing a tag can trigger a production deployment.

**Commands:**

```bash
git tag -a v1.0.0 -m "First release"
git push origin v1.0.0                     # push one tag
git push origin --tags                     # push all tags
git tag -d v1.0.0                          # delete local tag
git push origin --delete v1.0.0            # delete remote tag
gh release create v1.0.0 --generate-notes
```

---

# 3. Scenarios: fix mistakes

## Q17. You made a commit on `main` by mistake. It should be on a feature branch. Nothing is pushed. What do you do?

**Say:** I do not lose the commit. First I create a new branch at my current commit, so the commit is safe there. Then I move `main` back to match the remote. Then I switch to the new branch.

**Commands:**

```bash
git status                                 # make sure the working tree is clean
git branch feature/login                   # new branch keeps the commit
git reset --hard origin/main               # move main back to the remote state
git switch feature/login
git log --oneline -3
```

---

## Q18. How do you undo the last commit?

**Say:** It depends on whether it is pushed. If it is **not pushed**, I use `reset`. If it is **already pushed**, I use `revert`, because I must not rewrite shared history.

**Commands:**

```bash
# not pushed:
git reset --soft HEAD~1                    # keep my changes staged
# already pushed:
git revert HEAD
git push origin main
```

---

## Q19. How do you fix the last commit message, or add a file you forgot?

**Say:** I use `--amend`. This rewrites the last commit, so I do it only if I have not pushed it (or it is my own branch and I use `--force-with-lease`).

**Commands:**

```bash
git commit --amend -m "Better message"
git add forgotten-file.txt
git commit --amend --no-edit               # add the file, keep the same message
git push --force-with-lease                # only if it was already pushed on my own branch
```

---

## Q20. You pushed a bug to `main` and production is broken. What do you do?

**Say:** The first goal is to bring production back fast and safely. I do not rewrite shared history. I **revert** the bad commit, push, and let CI/CD redeploy. After the site is stable, I fix the bug properly in a new branch with a PR and tests.

**Commands:**

```bash
git log --oneline -5                       # find the bad commit
git revert <bad-commit-sha>                # normal commit
git revert -m 1 <merge-commit-sha>         # if the bad commit is a merge commit
git push origin main                       # pipeline redeploys
git switch -c fix/login-bug                # proper fix afterwards
```

---

## Q21. You committed a password (or API key) and pushed it to GitHub. What do you do?

**Say:** First, I treat the secret as **leaked**. The most important step is to **rotate or revoke it at once** (change the password, delete the key). Deleting it in a new commit is not enough, because the old commit still has it in history. Next I remove it from the whole history with `git filter-repo` or BFG, and force push. I tell the team to re-clone. To prevent it in future, I add the file to `.gitignore`, use GitHub Secrets or a secrets manager, and add secret scanning and a pre-commit hook like gitleaks.

**Commands:**

```bash
pip install git-filter-repo
git filter-repo --path .env --invert-paths         # remove the file from all history
git remote add origin <repo-url>                   # filter-repo removes the remote, add it again
git push --force --all origin
git push --force --tags origin
echo ".env" >> .gitignore
gitleaks detect                                    # scan the repo for secrets
```

---

## Q22. How do you recover a deleted branch or a lost commit?

**Say:** I use **`git reflog`**. It is a log of every place HEAD has been, even after `reset --hard` or after deleting a branch. Git keeps these commits for some weeks (at least 30 days by default), so I can find the commit id and get it back.

**Commands:**

```bash
git reflog
git branch restored-branch <commit-sha>            # bring back a deleted branch
git reset --hard HEAD@{2}                          # go back to where HEAD was 2 moves ago
git switch -c recovered <commit-sha>
```

---

## Q23. `git push` is rejected with "non-fast-forward". What does it mean?

**Say:** The remote has commits that I do not have. Git does not want me to overwrite them. I fetch, bring in the remote changes (with rebase or merge), and push again. I do **not** force push on a shared branch. On my own branch, if I really need to force, I use `--force-with-lease`, because it fails if someone else pushed after my last fetch. Plain `--force` would overwrite their work.

**Commands:**

```bash
git pull --rebase origin main
git push origin main
git push --force-with-lease                # my own branch only
```

---

## Q24. You ran `git reset --hard` and lost work. Can you get it back?

**Say:** If the work was **committed**, yes. The commits are still in the reflog. If the changes were **never committed** (only in the working directory), they cannot be recovered. This is why I commit small and often.

**Commands:**

```bash
git reflog
git reset --hard HEAD@{1}                  # go back to the state before the reset
```

---

## Q25. A big file was committed by mistake and the repo is very big. What do you do?

**Say:** First I find the big files in history. If the file is not pushed, I fix it with amend or reset. If it is pushed and in old history, I remove it with `git filter-repo`. For big files that really belong in the repo (zip, images, models), I use **Git LFS**.

**Commands:**

```bash
git rev-list --objects --all \
  | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
  | awk '$1=="blob"' | sort -k3 -n -r | head           # biggest files in history

git filter-repo --path big-file.zip --invert-paths      # remove from history

git lfs install
git lfs track "*.zip"
git add .gitattributes
```

---

## Q26. You are working on a feature and get an urgent production hotfix. What do you do?

**Say:** I do not mix work. I stash my unfinished work, create a hotfix branch from `main`, fix, push, and open a PR. After it is merged and tagged, I go back to my feature branch and restore my work from the stash.

**Commands:**

```bash
git stash push -u -m "wip feature"
git switch main && git pull
git switch -c hotfix/login-bug
git commit -am "Fix login bug"
git push -u origin hotfix/login-bug
gh pr create --title "Hotfix: login bug" --body "Urgent fix"
# after the PR is merged:
git switch feature/payment
git stash pop
```

---
# 4. Merge conflicts

## Q27. What is a merge conflict and how do you resolve it?

**Say:** A conflict happens when two branches change the **same lines** of a file. Git stops and marks the file with `<<<<<<<`, `=======`, and `>>>>>>>`. I open the file, decide the correct final code (I talk to the other developer if I am not sure), remove the markers, add the file, and commit. Then I run the tests. If I am confused, I can cancel with `--abort` and start again.

**Commands:**

```bash
git merge main                              # conflict appears
git status                                  # files marked "both modified"
git diff --name-only --diff-filter=U        # list only conflicted files
# edit the file, remove <<<<<<<, =======, >>>>>>>
git add file.txt
git commit                                  # finish the merge
git merge --abort                           # or cancel the merge
git checkout --ours file.txt                # take my version
git checkout --theirs file.txt              # take the other version
git mergetool
```

---

## Q28. What is different about conflicts during a rebase?

**Say:** The fix is the same, but I continue with `rebase --continue`, not `commit`. Also, "ours" and "theirs" are **reversed** in a rebase: "ours" is the branch I am rebasing onto (for example `main`), and "theirs" is my own commit being replayed. I can also skip a commit or cancel the whole rebase.

**Commands:**

```bash
git rebase main
# fix the conflict in the file
git add file.txt
git rebase --continue
git rebase --skip                           # skip this commit
git rebase --abort                          # cancel and go back
```

---

## Q29. Your PR shows conflicts on GitHub. How do you fix it?

**Say:** For a small conflict, I can use the GitHub web editor. For anything bigger, I fix it on my machine: I bring the latest `main` into my branch, resolve the conflicts, test, and push. The PR updates by itself.

**Commands:**

```bash
git fetch origin
git switch feature/x
git merge origin/main                       # or: git rebase origin/main
# resolve conflicts
git add .
git commit                                  # (for merge)
git push                                    # use --force-with-lease if you rebased
```

---

## Q30. How do you avoid merge conflicts in a team?

**Say:** I keep branches **short-lived** and PRs **small**. I pull from `main` often. I talk with the team about who works on which files. I use CODEOWNERS and a clear file structure. I also turn on `rerere`, so Git remembers how I solved the same conflict before.

**Commands:**

```bash
git pull --rebase origin main               # update often
git config --global rerere.enabled true     # remember conflict fixes
git log --oneline main..feature             # see what my branch has
```

---

# 5. Debugging with Git

## Q31. A bug appeared in the last 50 commits. How do you find the commit that caused it?

**Say:** I use `git bisect`. It does a binary search: I tell Git one good commit and one bad commit, and it checks out the middle. I test and say good or bad. In about 6 steps it finds the first bad commit among 50. I can also automate it with a test script.

**Commands:**

```bash
git bisect start
git bisect bad                              # current commit is bad
git bisect good v1.0.0                      # this old commit was good
# test the app, then tell Git:
git bisect good      # or: git bisect bad
git bisect reset                            # finish and go back
git bisect run ./test.sh                    # automatic (script returns 0 = good)
```

---

## Q32. Who changed this line, and why?

**Say:** I use `git blame` to see who last changed each line and in which commit. Then I use `git show` to read the commit and its message. To find when some code was added or removed, I search history with `-S`.

**Commands:**

```bash
git blame -L 10,20 app.js                   # who changed lines 10 to 20
git show <commit-sha>                       # what and why
git log -p -- app.js                        # full history of one file
git log -S"calculateTax" --oneline          # commits that added or removed this text
git log --follow -- app.js                  # follow the file even after rename
```

---

## Q33. What `git log` commands do you use daily?

**Say:** I use the graph view to understand branches, and filters for author, date, and message.

**Commands:**

```bash
git log --oneline --graph --all --decorate
git log --author="Charan"
git log --since="2 weeks ago"
git log --grep="fix"                        # search commit messages
git log --stat                              # files changed in each commit
git log -p -3                               # last 3 commits with the changes
git shortlog -sn                            # commits per person
```

---

## Q34. How do you compare two branches or two commits?

**Commands:**

```bash
git diff main..feature                      # all changes between two branches
git diff --stat main..feature               # short summary
git diff --name-only main                   # only file names
git diff HEAD~1 HEAD                        # last commit
git log main..feature --oneline             # commits in feature but not in main
git show HEAD                               # details of the last commit
```

**Say:** `diff` shows the code changes. `log a..b` shows the commits that are in `b` but not in `a`.

---

## Q35. A file was deleted a few commits ago. How do you get it back?

**Say:** I find the commit that deleted it, then restore the file from the commit **before** that one.

**Commands:**

```bash
git log --diff-filter=D --summary -- path/to/file      # find the deleting commit
git restore --source=<delete-commit-sha>^ -- path/to/file
git commit -m "Restore deleted file"
```

---

# 6. GitHub collaboration and security

## Q36. What are branch protection rules?

**Say:** They are rules on important branches like `main`, so nobody can push broken code directly. Common rules: require a pull request, require approvals, require status checks (CI must pass), require the branch to be up to date, block force pushes and branch deletion, and require signed commits or linear history. In newer GitHub settings these are also called **rulesets**.

**Commands:**

```bash
# Setup path: Repo -> Settings -> Branches -> Add branch protection rule
gh api repos/OWNER/REPO/branches/main/protection        # view the rules
gh pr checks 12                                         # see CI status on a PR
```

---

## Q37. What is CODEOWNERS?

**Say:** It is a file that says who **must review** changes to certain files or folders. GitHub adds those people as reviewers automatically. With branch protection, the PR cannot merge until the code owner approves.

**Commands:**

```bash
mkdir -p .github
cat > .github/CODEOWNERS << 'EOF'
/terraform/            @devops-team
*.js                   @frontend-team
/.github/workflows/    @your-username
EOF
git add .github/CODEOWNERS && git commit -m "Add CODEOWNERS"
```

---

## Q38. SSH key or HTTPS with a token: which do you use with GitHub?

**Say:** For daily work I use **SSH**. It uses a key pair, so I do not type a password or token each time. **HTTPS** needs a personal access token (GitHub no longer accepts account passwords), but it works when SSH port 22 is blocked. For CI/CD I do not use my personal key. I use the built-in `GITHUB_TOKEN`, a **deploy key** (one repo), or a GitHub App.

**Commands:**

```bash
ssh-keygen -t ed25519 -C "you@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub                  # copy this to GitHub -> Settings -> SSH keys
ssh -T git@github.com                      # test the connection
git remote set-url origin git@github.com:USER/REPO.git
gh auth login                              # easy login with GitHub CLI
```

---

## Q39. What are signed commits and why use them?

**Say:** A signed commit proves the commit really came from me, and GitHub shows a **Verified** badge. Anyone can set any name and email in Git, so without signing, someone could pretend to be me. Some companies require signed commits on `main`. I can sign with GPG or with my SSH key.

**Commands:**

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true      # sign every commit
git commit -S -m "Signed commit"
git log --show-signature -1
```

---

## Q40. What are Git hooks? How do you use them in a team?

**Say:** Hooks are scripts that run at Git events, like before a commit or before a push. A `pre-commit` hook can run the linter, the tests, or a secret scan, so bad code is stopped early. Hooks in `.git/hooks` are not shared through the repo, so teams use a shared folder, or tools like husky or pre-commit. Hooks can be skipped on a developer's machine, so the real check must also run in CI.

**Commands:**

```bash
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
npm run lint || exit 1
EOF
chmod +x .git/hooks/pre-commit

git config core.hooksPath .githooks        # use a shared folder that is in the repo
git commit --no-verify -m "skip hooks"     # skip hooks (only when really needed)
```

---

# 7. GitHub Actions and CI/CD

## Q41. What is GitHub Actions? Explain workflow, event, job, step, and runner.

**Say:** GitHub Actions is the built-in CI/CD tool of GitHub. A **workflow** is a YAML file in `.github/workflows/`. An **event** starts it (push, pull request, schedule, manual). A workflow has one or more **jobs**. Each job runs on a **runner** (a virtual machine). A job has **steps**, and each step is either a shell command (`run`) or a ready-made **action** (`uses`). Jobs run in parallel by default, unless I use `needs`.

**Example:** `.github/workflows/ci.yml`

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm test
```

**Commands:**

```bash
mkdir -p .github/workflows
git add .github/workflows/ci.yml && git commit -m "Add CI" && git push
gh workflow list
gh run list
gh run watch
```

---

## Q42. How do you build a Docker image and push it to Docker Hub with Actions?

**Say:** I check out the code, log in to Docker Hub using **secrets**, then build and push with the Docker actions. I tag the image with the commit SHA (so every build is unique and can be traced) and also with `latest`.

```yaml
name: Docker build and push
on:
  push:
    branches: [main]

jobs:
  docker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: |
            ${{ secrets.DOCKERHUB_USERNAME }}/myapp:${{ github.sha }}
            ${{ secrets.DOCKERHUB_USERNAME }}/myapp:latest
```

**Commands:**

```bash
gh secret set DOCKERHUB_USERNAME
gh secret set DOCKERHUB_TOKEN              # use a Docker Hub access token, not the password
gh secret list
```

---

## Q43. How do you manage secrets in GitHub Actions?

**Say:** I store them in **GitHub Secrets**, never in code. There are repository secrets, environment secrets (for example, only for `production`), and organization secrets. In the workflow I read them with `${{ secrets.NAME }}`. GitHub hides them in logs, but I must never `echo` them. Secrets are not given to workflows from forked PRs. For non-secret settings I use **variables**.

**Commands:**

```bash
gh secret set API_KEY                      # repo secret (it asks for the value)
gh secret set DB_PASSWORD --env production # environment secret
gh secret list
gh variable set APP_ENV --body "staging"   # normal variable, not secret
```

```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}
```

---

## Q44. How do you deploy to an EC2 server from GitHub Actions?

**Say:** After the build job passes, a deploy job connects to the server over SSH and pulls and starts the new version. The SSH private key and host are stored in GitHub Secrets. `needs: build` makes deploy wait for build. I also use `environment: production`, so I can add a manual approval.

```yaml
jobs:
  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ubuntu
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            cd /opt/myapp
            docker compose pull
            docker compose up -d
```

**Commands:**

```bash
gh secret set EC2_HOST
gh secret set EC2_SSH_KEY < ~/.ssh/deploy_key        # read the key from a file
gh run view --log                                    # check the deploy logs
```

For better security, use **OIDC** (Q50) or a separate deploy key with limited access, not your personal key.

---

## Q45. How do you make a slow pipeline faster?

**Say:** I use **caching** for dependencies (npm, pip, Docker layers). I split work into **parallel jobs** and use a **matrix** to test many versions at once. I use **path filters**, so the pipeline runs only when related files change. I use **concurrency** to cancel old runs on the same branch. And I make the Docker build use layer cache.

```yaml
on:
  push:
    paths:
      - "src/**"
      - "package*.json"

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node: [18, 20, 22]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
          cache: npm
      - run: npm ci && npm test
```

---

## Q46. What are environments and manual approvals in GitHub Actions?

**Say:** An **environment** (like `staging` or `production`) is a named target for deployment. For `production` I can add **required reviewers**. The job then waits until a person approves. I can also add wait timers and limit which branches can deploy, and each environment has its own secrets.

```yaml
jobs:
  deploy-prod:
    runs-on: ubuntu-latest
    environment: production        # waits for approval if reviewers are set
    steps:
      - run: echo "Deploying to production"
```

**Setup path:** Repo → Settings → Environments → New environment → Required reviewers.

---

## Q47. What are reusable workflows and composite actions?

**Say:** They stop me from copying the same YAML in many repos. A **reusable workflow** is a full workflow that other workflows call with `workflow_call`. A **composite action** groups several steps into one action. I use them for standard build, test, and deploy steps across the team.

**Reusable workflow** (`.github/workflows/build.yml` in a shared repo):

```yaml
on:
  workflow_call:
    inputs:
      node-version:
        required: true
        type: string

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
      - run: npm ci && npm test
```

**Calling it:**

```yaml
jobs:
  call-build:
    uses: my-org/shared-workflows/.github/workflows/build.yml@main
    with:
      node-version: "20"
```

---

## Q48. GitHub-hosted runner or self-hosted runner: when do you use each?

**Say:** **GitHub-hosted** runners are easy: GitHub gives a clean VM for each job and looks after updates. I use them by default. I use a **self-hosted** runner when I need access to a private network (for example, a private server or database), special hardware, more power, or lower cost for heavy use. The risk: I must patch and secure it myself, and I should **not** use self-hosted runners on public repos, because a stranger's PR could run code on my machine.

**Commands:**

```bash
# on the runner machine (token from Repo -> Settings -> Actions -> Runners -> New)
./config.sh --url https://github.com/OWNER/REPO --token <TOKEN>
./run.sh                                   # run once in the terminal
sudo ./svc.sh install && sudo ./svc.sh start     # run as a service
```

```yaml
runs-on: [self-hosted, linux]
```

---

## Q49. A workflow is failing. How do you debug it?

**Say:** I read the failed step's log first. Then I re-run only the failed jobs. If the log is not enough, I turn on debug logging. I check common causes: wrong secret name, missing permissions, wrong file path, and YAML indentation errors. I can also check the YAML with `actionlint`, or run the workflow on my machine with `act`.

**Commands:**

```bash
gh run list
gh run view <run-id> --log-failed          # only the failed step logs
gh run rerun <run-id> --failed             # re-run only failed jobs
gh workflow run deploy.yml                 # manual start (needs workflow_dispatch)
actionlint                                 # check the YAML
act -j build                               # run a job locally (needs Docker)
gh secret set ACTIONS_STEP_DEBUG --body true     # more detailed logs
```

```yaml
on:
  workflow_dispatch:          # allows manual runs from the Actions tab
```

---

## Q50. How do you keep GitHub Actions secure? (`GITHUB_TOKEN`, OIDC, pinning)

**Say:** I follow least privilege. I set the `GITHUB_TOKEN` permissions to read-only by default and add write only where needed. To use AWS, I use **OIDC** so the workflow gets short-lived credentials, and I do not store long-lived AWS keys in secrets. I pin third-party actions to a **full commit SHA** (a tag can be changed). I never print secrets. I am careful with `pull_request_target`, because it runs with secrets on code from forks.

```yaml
permissions:
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write            # needed for OIDC
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions-role
          aws-region: ap-south-1
```

---

## Q51. What are Dependabot, secret scanning, and code scanning?

**Say:** **Dependabot** opens PRs to update old or vulnerable dependencies. **Secret scanning** finds passwords and keys in the code, and push protection can block a push that contains a secret. **Code scanning** (CodeQL) looks for security bugs in the code. Together they make a basic DevSecOps setup on GitHub.

`.github/dependabot.yml`

```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

**Setup path:** Repo → Settings → Code security → turn on Dependabot alerts, secret scanning with push protection, and code scanning.

---

# 8. Advanced Git

## Q52. How do you squash many commits into one before a PR?

**Say:** I use **interactive rebase**. I choose how many commits to edit, keep the first as `pick`, change the others to `squash` or `fixup`, and write one clean message. This rewrites history, so I do it only on my own branch, and I push with `--force-with-lease`.

**Commands:**

```bash
git rebase -i HEAD~4              # edit the last 4 commits
# in the editor: pick / squash (s) / fixup (f) / reword (r) / drop (d)
git push --force-with-lease
```

---

## Q53. What is `git worktree`?

**Say:** It lets me check out **two branches at the same time** in two folders, using the same repo. So for a hotfix I do not need to stash my work. I just open the hotfix in a second folder.

**Commands:**

```bash
git worktree add ../hotfix hotfix/1.0.1
git worktree list
cd ../hotfix                       # work here, commit, push
git worktree remove ../hotfix
```

---

## Q54. What are submodules?

**Say:** A submodule is a Git repo inside another Git repo, locked to one specific commit. I use it to share code between projects. The catch: after cloning, the submodule folders are empty until I initialize them, and the team must remember to update them. Many teams prefer package managers when possible.

**Commands:**

```bash
git submodule add <repo-url> libs/shared
git clone --recurse-submodules <url>
git submodule update --init --recursive        # if you forgot --recurse-submodules
git submodule update --remote                  # move to the latest commit of the submodule
```

---

## Q55. How do you work with a very large repo?

**Say:** I do not need the whole history. I use a **shallow clone** (only the last commit), or **sparse checkout** (only some folders). In CI, `actions/checkout` does a shallow clone by default. For big files, I use Git LFS.

**Commands:**

```bash
git clone --depth 1 <url>                      # latest commit only
git clone --filter=blob:none <url>             # download file contents only when needed
git sparse-checkout init --cone
git sparse-checkout set services/api           # only this folder
git fetch --unshallow                          # get the full history later
```

---

## Q56. How do you use `git config`? Global vs local settings?

**Say:** Git has three levels: **system**, **global** (my user), and **local** (this repo). Local wins over global. I set my name, email, default branch, and helpful aliases. I use a local email for a work repo if it is different from my personal one.

**Commands:**

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global alias.st status
git config --global alias.lg "log --oneline --graph --all"
git config user.email "work@company.com"       # local, for this repo only
git config --list --show-origin                # see where each setting comes from
```

---

## Q57. How do you stage only part of a file?

**Say:** With `git add -p` I go through my changes piece by piece (hunk by hunk) and choose which ones go in the commit. It helps me make small, clean commits when I changed many things in one file.

**Commands:**

```bash
git add -p file.txt         # y = stage, n = skip, s = split, q = quit
git diff --staged           # check what will be committed
git commit -m "Fix validation only"
```

---

# Quick practice ideas for `~/linuxCMD/git-lab`

Do these once, so the commands feel natural:

1. Make a repo, create 3 commits, then try `reset --soft`, `reset --hard`, and `revert`. Use `git reflog` to get back a lost commit.
2. Make two branches that change the same line. Merge them, get a conflict, and fix it.
3. Do the same conflict again with `rebase`. Notice `--continue`.
4. Create a bug in commit 5 of 10, then find it with `git bisect run`.
5. Push a repo to GitHub with an SSH key. Add a simple CI workflow (Q41) and watch it run with `gh run watch`.
6. Add a fake `.env` file, commit it, and practice removing it with `git rm --cached` and then `git filter-repo`.

**Final tip:** when you answer a scenario question, say the order: **check first (`git status`, `git log`, `git reflog`), then fix, then explain how you stop it from happening again.**
