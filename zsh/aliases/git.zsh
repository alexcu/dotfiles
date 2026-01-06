#! /usr/bin/env zsh

#
# Git aliases
#

# Git Add all and commit with Dot message '.'
alias gad="git add --all && git commit --message '.'"

# Git Add patch in current directory
alias gapa.='git add --patch .'

# Git Add untracked files
alias gar="git ls-files -u | awk '{print \$4}' | sort -u | xargs git add"

# Git Add assumed unchanged files
alias gaau="git update-index --assume-unchanged"

# Git Branch list and fuzzy find
alias gB="git branch | grep -v '^\s*z/' | fzf"

# Git Branch switch and fuzzy find
alias gb="git branch --format='%(refname:short)' | grep -v '^\s*z/' | fzf | xargs git switch"

# Git Branch copy
alias gbc="git branch --copy"

# Git Commit with message (single quote start)
alias gc="git commit --message \""

# Git Commit in editor
alias gC="git commit"

# Git Checkout new Branch with user and date prefix (alexcu-20260105-foo)
alias gcb="git checkout -b $USER-$(dsc)-"

# Git Checkout new Branch from ORigin branch (e.g., master or main)
alias gcbor="(gco master || gco main) && gpor && gcb $1"

# Git Checkout new Branch from UPstream branch (e.g., master or main)
alias gcbup="(gco master || gco main) && gpup && gcb $1"

# Git Commit with Dot message '.'
alias gcd="git commit --message '.'"

# Git CLEAN untracked FIles
alias gcleanfi="git clean -fi"

# Git CheckOut file
alias gco\!="git checkout -- "

# Git CheckOut All files
alias gcoa\!="git checkout -- ."

# Git CheckOut previous Branch
alias gcob="git checkout @{-1}"

# Git CheckOut Branch by fuzzy find
alias gcobr="gb | xargs git checkout"

# Git CheckOut Master branch and fetch origin master
alias gcom="gfm && git checkout master"

# Git CheckOut Master branch
alias gcom="git checkout master"

# Git Cherry Pick No commit
alias gcpn="git cherry-pick --no-commit"

# Git Commit with WIP message
alias gcwip="git commit -m 'WIP'"

# Git Diff (with --)
alias gd="git diff --"

# Git Diff (without --)
alias gD="git diff"

# Git Fetch Origin Master
alias gfm="git fetch origin master:master"

# Git Pull Origin No edit
alias ggpulln="git pull origin --no-edit"

# Git Push Personal
alias ggpushper="ssh-add ~/.ssh/id_rsa_personal && ggpush &&  ssh-add -d  ~/.ssh/id_rsa_personal"

# Git Push SSH
alias ggpushs="ggpush && (ghs | pbcopy)"

# Git Push SSH Repo
alias ggpushsr="ghsr && ggpushs"

# Git Merge Origin Master No edit
alias gmm="git merge origin master --no-edit"

# Git Merge No edit
alias gmn="git merge --no-edit"

# Git Merge No commit
alias gmnc="git merge --no-commit"

# Git Push with Personal Email
alias gper="git -c user.email=alexcu@me.com $1"

# Git Pull Rebase Origin Master
alias gpor="git pull --rebase origin master || git pull --rebase origin main"

# Git Revert No edit
alias grevn="git revert --no-edit”"

# Git Pull Rebase Upstream Master or Main
alias gpup="git pull --rebase upstream master || git pull --rebase upstream main"

# Git Rebase Master
alias grbm="git rebase master"

# Git Reset Hard HEAD
alias grhH="git reset --hard HEAD"

# Git Restore Staged
alias grsta="git restore --staged :/"

# Git Stash
alias gs="git stash"

# Git Status of all modified files
alias gsts='git status -s | awk '\''{print $2}'\'' | paste -sd " " -'

# Git Status of current directory
alias gst.="git status ."

# Git Tag
alias gt="git tag"

# Git Branch Name (HEAD or at index)
function gbn() {
  local idx=${1:-0}
  if (( idx == 0 )); then
    git rev-parse --abbrev-ref HEAD 2>/dev/null || return 0
  else
    git rev-parse --abbrev-ref "@{-${idx}}" 2>/dev/null || return 0
  fi
}

# Git Branch Name (previous branch)
alias gbnb="gbn 1"

# Git Merge previous Branch
function gmb() {
    git merge $(gbnb)
}

# Git Merge previous Branch No edit
function gmbn() {
    git merge --no-edit $(gbnb)
}

# Git Branch Name (JIRA ID)
function gbnj () {
    local branch="${1:-$(git symbolic-ref --short HEAD 2>/dev/null)}"
    echo "$branch" | sed -nE 's/.*-([A-Z]{3,}-[[:digit:]]+)(-|$).*/\1/p'
}

# Check for git repo
function gig() {
    local repo_path=${1:-$(pwd)}
    git -C "$repo_path" rev-parse --is-inside-work-tree > /dev/null 2>&1
}

# Must unalias `git` plugin gwip
gunalias gwip 2>/dev/null
function gwip() {
    local force=0
    local base_branch="master"

    # Parse options
    while getopts "f" opt; do
      case ${opt} in
        f )
          force=1
          ;;
        \? )
          echo "Usage: gwip [-f] [base-branch]"
          return 1
          ;;
      esac
    done
    shift $((OPTIND -1))

    # Set the base branch if provided
    if [ -n "$1" ]; then
        base_branch="$1"
    fi

    # Check for changes unless -f is provided
    if [ "$force" -eq 0 ]; then
        if git diff-index --quiet HEAD; then
            echo "No changes to push a WIP commit. Aborting."
            return 1
        fi
    fi

    echo "Start git WIP push..."

    # Adding changes, exit on failure
    echo "Adding changes..."
    git add -A || { echo "Failed to add changes"; return 1; }

    # Determine the current branch and WIP branch
    local current_branch=$(git rev-parse --abbrev-ref HEAD) || { echo "Failed to get current branch"; return 1; }
    local wip_branch="wip/$current_branch"
    local remote_branch="$current_branch"

    # Check if current branch is already a WIP branch, avoid nesting
    if [[ $current_branch == wip/* ]]; then
        wip_branch="$current_branch"
        remote_branch="${current_branch#*/}"
    else
        # Create WIP branch, exit on failure
        echo "Creating WIP branch: $wip_branch..."
        git checkout -b $wip_branch || { echo "Failed to create WIP branch"; return 1; }
    fi

    # Find the base WIP commit, exit on failure
    echo "Finding base WIP commit..."
    local base_wip_commit=$(git log --author=$(git config user.email) --grep="^wip$" -n 1 --pretty=format:"%H")

    if [ -n "$base_wip_commit"  ]; then
        echo "Found base WIP commit: $base_wip_commit"
        git commit --allow-empty --no-verify --no-gpg-sign --fixup=$base_wip_commit || { echo "Failed to create fixup commit"; return 1; }
    else
        echo "No WIP commit found, creating new one"
        git commit --allow-empty --no-verify --no-gpg-sign --message="wip" || { echo "Failed to create new WIP commit"; return 1; }
    fi

    # Fetch base branch, exit on failure
    echo "Fetching $base_branch..."
    git fetch origin $base_branch:$base_branch || { echo "Failed to fetch base branch $base_branch"; return 1; }

    # Rebase base branch, exit on failure
    echo "Rebasing $base_branch..."
    git rebase $base_branch || { echo "Rebase failed"; return 1; }

    # Push the WIP commit, exit on failure
    local remote_wip_branch="${remote_branch}-wip"
    echo "Pushing WIP commit to remote branch: $remote_wip_branch"
    git push --force origin $wip_branch:$remote_wip_branch || { echo "Failed to push WIP branch"; return 1; }

    echo "Squash all WIPs using: gwips $base_branch"
}
function gwips() {
    git rebase --interactive --autosquash ${1-master}
}

# fzf-git aliases
alias G="_fzf_git_files"
alias Gb="_fzf_git_branches"
alias Gh="_fzf_git_hashes"
alias Gr="_fzf_git_remotes"
alias Grf="_fzf_git_lreflogs"
alias Gs="_fzf_git_stashes"
alias Gt="_fzf_git_tags"
alias Gwt="_fzf_git_worktrees"

# Git Add and Commit with Push SSH Repo
function gA() {
    gapa && git commit --message "$1" && ggpushsr
}

# Git Pull Origin with notification
function ggpull() {
    git pull origin $(gbn) && notify 'Pull Success' 'Git Pull' '📥 ✅' 'Glass' || notify 'Pull Failed' 'Git Pull' '📥 ❌' 'Basso'
}

# Git Push Origin with notification
function ggpush() {
    git push origin $(gbn) && notify 'Push Success' 'Git Push' '📤 ✅' 'Glass' || notify 'Push Failed' 'Git Push' '📤 ❌' 'Basso'
}

# Set up a new worktree
function Gwta() {
    # Ensure the current directory is a Git repository
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Error: Not in a Git repository" >&2
        return 1
    fi

    local repo=$(basename "$(git rev-parse --show-toplevel)")
    local base_branch="${2:-master}"
    local sparse_checkout_glob="${3:-/*\n!/exclude/}"
    local worktree="$1"
    local worktree_path="$HOME_GIT_WORKTREES/$repo/$worktree"
    local worktree_base_branch="$base_branch-$worktree"

    # Create a Git worktree
    echo "Fetching origin $base_branch first..."
    git fetch origin "$base_branch:$base_branch" || { echo "Error fetching base branch $base_branch!" >&2; return 1 }

    echo "Initialising new worktree $worktree based on branch $base_branch at $worktree_path..."
    git worktree add --no-checkout -b "$worktree_base_branch" "$worktree_path" || { echo "Error creating worktree!" >&2; return 1 }
    cd "$worktree_path" || { echo "Error, $worktree_path doesn't exist..." >&2; return 1 }
    git config core.sparseCheckout true
    echo $sparse_checkout_glob > $(git rev-parse --git-path info/sparse-checkout)
    $EDITOR $(git rev-parse --git-path info/sparse-checkout)

    echo "Reapplying sparse checkout..."
    git sparse-checkout reapply || { echo "Error reapplying sparse checkout!" >&2; return 1 }

    echo "Checking out worktree branch $worktree_base_branch..."
    git checkout $worktree_base_branch || { echo "Error checking out $worktree_base_branch!" >&2; return 1 }

    echo "Rebasing against $base_branch..."
    git rebase "origin/$base_branch" || { echo "Error rebasing against origin/$base_branch!" >&2; return 1 }

    echo "Running git status..."
    git status

    echo "Done! Please ensure that you regularly:"
    echo "  1. Fetch changes from remote (git fetch origin $base_branch)"
    echo "  2. Rebase the worktree's base branch against the fetched remote (git rebase origin/$base_branch)"
    echo "  3. Reapply sparse checkout to sync correctly (git sparse-checkout reapply)"
}

# # Precmd hook to refresh aliases based on the current branch every time the prompt is shown
# # FIXME: This seems to slow stuff down a lot
# function precmd() {
#     local branch_name="$(gbn)"

#     if [[ -n $branch_name ]]; then
#         # Set up new aliases
#         alias gbcn="git branch --copy $branch_name"
#         alias gbct="git branch --copy $branch_name _tmp_$branch_name"
#         alias gbcz="git branch --copy $branch_name z/$branch_name"
#         alias gbmn="git branch --move $branch_name"
#         alias gbmt="git branch --move $branch_name _tmp/$branch_name"
# 	    alias gwtA="git worktree add $HOME_GIT_WORKTREES/$(basename $(git rev-parse --show-toplevel))/$branch_name $branch_name"

#         function gbmz() {uo pipefail
#             local b
#             if [[ $# -gt 0 ]]; then
#                 b="$1"
#             else
#                 b="$(git rev-parse --abbrev-ref HEAD)"
#                 if [[ "$b" == "HEAD" ]]; then
#                 echo "Detached HEAD; please specify a branch name." >&2
#                 return 1
#                 fi
#             fi

#             # Protect common primary branches
#             if [[ "$b" == "main" || "$b" == "master" || "$b" == "develop" ]]; then
#                 echo "Refusing to archive protected branch: $b" >&2
#                 return 1
#             fi

#             echo "Archiving $b -> refs/archive/z/$b ..."
#             git update-ref "refs/archive/z/$b" "$b"
#             git branch -D "$b"
#             echo "Archived. To restore: git branch \"$b\" \"refs/archive/z/$b\""
#         }

#         # # Worktree check
#         # if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
#         #     local worktree=$(basename "$(git rev-parse --show-toplevel)")
#         #     local worktree_target_branch="${branch_name}-${worktree}"
#         #     if [[ $(git branch --list "$worktree_target_branch") && "$branch_name" != "$worktree_target_branch" ]]; then
#         #         echo "Assuming $worktree_target instead of $branch_name"
#         #         echo "Press ^C now to abort fetch and rebase..."

#         #         echo "(1/5) Checking out $worktree_target_branch..."
#         #         git checkout $worktree_target_branch || { echo "Error checking out $worktree_target_branch!" >&2; return 1 }

#         #         echo "(2/5) Fetching origin $branch_name..."
#         #         git fetch origin $branch_name || { echo "Error fetching origin $branch_name!" >&2; return 1 }

#         #         echo "(3/5) Rebasing origin/$branch_name..."
#         #         git rebase origin/$branch_name || { echo "Error rebasing origin/$branch_name!" >&2; return 1 }

#         #         echo "(4/5) Reapplying sparse checkout..."
#         #         git sparse-checkout reapply || { echo "Error reapplying sparse checkout!" >&2; return 1 }

#         #         echo "(5/5) Checking out $worktree_target_branch..."
#         #         git checkout $worktree_target_branch || { echo "Error checking out $worktree_target_branch!" >&2; return 1 }
#         #     fi
#         # fi
#     else
#         unalias gbcn gbct gbcz gbmn gbmt gbmz gwta 2>/dev/null
#     fi
# }

# Cleanup all z/ branches -> refs/archive/z/*
function gbmzcleanup() {uo pipefail
    local branches
    branches=("${(@f)$(git for-each-ref --format='%(refname:short)' refs/heads/z/)}")
    if [[ ${#branches} -eq 0 ]]; then
        echo "No z/ branches to archive."
        return 0
    fi
    for branch in "${branches[@]}"; do
        echo "Archiving $branch ..."
        git update-ref "refs/archive/$branch" "$branch"
        git branch -D "$branch"
    done
    echo "Done. Archived under refs/archive/z/*"
}

# List archived z/ branches
function gbz() {
  git for-each-ref \
    --sort=-committerdate \
    --format='%(refname:short) | %(objectname:short) | %(committerdate:short) | %(subject)' \
    refs/archive/z/ \
  | sed 's#^refs/archive/##'
}

# Git Branch Move to archived z/ branch restore
function gbmzr() {
    uo pipefail
    local b
    if [[ $# -gt 0 ]]; then
        b="$1"
    else
        echo "Available archived branches:"
        git for-each-ref --format='%(refname:short)' refs/archive/z/ \
        | sed 's#^refs/archive/##' \
        | nl -w2 -s'. '
        return 1
    fi

    # Confirm it exists
    if ! git show-ref --verify --quiet "refs/archive/$b"; then
        echo "No archived ref found for: $b" >&2
        return 1
    fi

    # Restore into a normal branch again
    local target="${b#z/}"   # drop leading z/ if present, optional
    echo "Restoring refs/archive/$b -> branch $b ..."
    git branch "$b" "refs/archive/$b"
    echo "Restored. Switch with: git checkout $b"
}

# Prefix _tmp/ and wip/ and branches with 'z/'
function gbmzc() {
  echo "Prefixing _tmp/ and wip/ and branches with 'z/'..."
  git branch --list '_tmp/*' 'wip/*' | sed 's/^..//' | while IFS= read -r branch; do
      new_branch="z/$branch"

      if git branch -m "$branch" "$new_branch"; then
        cgreen "Renamed $branch -> z/$branch"
      else
        cred "Failed to rename $branch -> z/$branch"
      fi
  done
  creset
  echo "Open branches:"
  git branch | grep -v '^\s*z/' | grep $USER
}
