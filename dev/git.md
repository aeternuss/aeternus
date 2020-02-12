# GIT

types：

* local
* centralized
* distributed

difference:

* Snapshots, Not Differences
* Nearly Every Operation Is Local
* Git Has Integrity
* Git Generally Only Adds Data

## The Three States

Git has three main states that your files can reside in: modified, staged, and committed

## Configuration

Git comes with a tool called git config that lets you get and set configuration variables
that control all aspects of how Git looks and operates.

* /etc/gitconfig file: Contains values applied to every user on the system and all their repositories. --system
* ~/.gitconfig or ~/.config/git/config file: Values specific personally to you, the user. --global
* .git/config of whatever repository you’re currently using: Specific to that single repository. --local

## Basics

undoing things: `git commit --amend`

unstaging an staged file: `git reset HEAD <file>`

unmodifying a modified file: `git checkout -- <file>`

adding remote repository: `git remote add <shortname> <url>`

pushing to your remotes: `git push <remote> <branch>`

tow type of tags: lightweight and annotated: `git tag -a <tag> -m "msg"` and `git tag <tag>`

sharing tags: `git push <remote> <tag>` or `git push <remote> --tags`

deleting tags: `git tag -d <tag>` and `git push <remote> --delete <tag>`

aliases: `git config --global alias.<alias> <command>`

## Branching

new branch: `git branch <branch>`

switch branch: `git checkout <branch>`

merge: `git merge <commit>`

delete branch: `git branch -d <branch>`

tracking branch: `git checkout -b <branch> <remote>/<branch>` or `git checkout --track <remote>/<branch>`

delete remote branch: `git push <remote> --delete <branch>`

Generally it's better to simply use the `fetch` and `merge` commands explicitly
as the magic of `git pull` can often be confusing.

In Git,there are two main ways to integrate changes from one branch into another:the `merge` and the `rebase`.

rebase: `git rebase <newbase>` or `git rebase --onto <newbase> <upstream> <branch>` or `git rebase <newbase> <topicbranch>`

> rebase local changes you’ve made but haven’t shared yet before you push them in order to cleanup your story,
> but never rebase any thing you’ve pushed some where.** 

## Git Tools

Ancestry References:

* the first parent: `git show HEAD^`
* the second parent: `git show HEAD^2` (for merge commit)
* parent of parent: `git show HEAD~n`

Commit range: `git log <upstream>..<upstream>`

Reachable by either of two references but not by both of them: `git log <upstream>...<upstream>`

If you want to see all commits that are reachable from refA or refB but not from refC:

```bash
git log refA refB ^refC
git log refA refB --not refC
```

Interactive Staging: `git add -i`

Stashing and Cleaning:

Often, when you’ve been working on part of your project,things are in amessy state and
you want to switch branches for a bit to work on something else.
The problem is, you don’t want to do a commit of half-done work just so
you can get back to this point later.
The answer to this issue is the `git stash` command.

```bash
git stash
git stash list
git stash apply
```

Signing Your Work:

```bash
gpg --gen-key
git config --global user.signingkey <keyid>
```

## Git Internals

This leaves four important entries:

* the HEAD
* the index files
* the objects
* refs directories

These are the core parts of Git.

The `objects` directory stores all the content for your database

the `refs` directory stores pointers into commit objects in that data (branches, tags, remotes and more)

the `HEAD` file points to the branch you currently have checked out,

and the `index` file is where Git stores your staging area information.

### Objects

Git is a content-addressable filesystem.

blob, tree, commit, tag

### References

branches, tags, remotes

### The HEAD
