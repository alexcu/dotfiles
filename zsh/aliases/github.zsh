#! /usr/bin/env zsh

#
# GitHub aliases
#

# GitHub PR
alias ghpr="gh pr"

# GitHub PR Checkout
alias ghprco="gh pr checkout"

# GitHub Short Hash
alias ghs="git rev-parse --short HEAD"

# GitHub Short Hash copy with "Resolved in <hash>" for PR reviews
alias ghsr="(ghs | xargs echo 'Resolved in') | pbcopy"

# GitHub PR View web
alias ghprv="gh pr view --web"

# GitHub Repo View web
alias gweb="gh repo view -w"

# GitHub PR Create
function ghprc() {
    # If only one argument and it doesn't start with --, treat as title
    if [[ $# -eq 1 && "$1" != --* ]]; then
        branch_name=$(gbn)
        title="$1"
    else
        branch_name=${1:-$(gbn)}
        title=${2:-}
    fi
    # Parse command line arguments
    local draft="--draft"  # default to draft
    local open_web="yes"   # default to open web

    for arg in "$@"; do
        case "$arg" in
            --draft)
                draft="--draft"
                ;;
            --no-draft)
                draft=""
                ;;
            --web)
                open_web="yes"
                ;;
            --no-web)
                open_web="no"
                ;;
        esac
    done

    echo "🫸 📝 Pushing branch $branch_name..."
    git push origin $branch_name
    echo "🫸 ✅ Pushed branch $branch_name!"
    if [ -z "$title" ]; then
        echo -n "🔄 📝 Enter PR title [$branch_name]: "
        read title
        title=${title:-$branch_name}
    fi

    # Add Jira ID prefix if gbnj function exists and returns a value
    if command -v gbnj >/dev/null 2>&1; then
        jira_id=$(gbnj "$branch_name")
        if [[ -n "$jira_id" && ! "$title" =~ ^\[[A-Z]+-[0-9]+\] ]]; then
            title="[$jira_id] $title"
        fi
    fi

    echo "🔄 ⌛ Creating PR..."
    gh pr create --assignee @me --body "" --head "$branch_name" --title "$title" $draft
    sleep 5 # wait for PR to have its bot comments added
    echo "🔄 ✅ PR created!"
    if [[ "$open_web" == "yes" ]]; then
        echo "🌐 ⌛ Opening PR in web browser..."
        gh pr view --web
        echo "🌐 ✅ PR ready to review"
    fi
    if [ -z "$draft" ]; then
        ghprt
    fi
    notify 'PR Created' 'GitHub PR' '🔗 ✅' 'Glass' || notify 'PR Creation Failed' 'GitHub PR' '🔗 ❌' 'Basso'
}

# GitHub PR Test Function
function _ghprtfn() {
    # Override this function to add your own logic for specific test commands
    # Exanple:
    #
    #   undef _ghprtfn
    #   ghprt() {
    #       # GitHub test logic here
    #   }
}

# GitHub PR Test
function ghprt() {
    branch=${1:-$(gbn)}
    echo "🧪➕ Initiating tests on CI for $branch..."
    _ghprtfn
    echo "🧪⌛ Tests initiated... let's hope they pass 🤞"
}

# GitHub PR URL
function ghpru() {
    gh pr view --json url $1 | jq -r '.url'
}

# GitHub PR Assignee Check
function ghprac() {
    pr=$1
    assignees=$(gh pr view --json assignees $pr | jq -r '.assignees[].login')
    if echo "$assignees" | grep -q "alexcu"; then
        echo "➡️ 🏓 Ping-Pong: It's your turn..."
        return 1
    else
        echo "⬅️ 🏓 Ping-Pong: It's their turn..."
        return 0
    fi
}

# GitHub PR Assign
function ghpra() {
    pr=$1
    force_flag=""

    # Check if --force is passed as second argument
    if [[ "$2" == "--force" ]]; then
        force_flag="true"
    fi

    if [[ "$force_flag" == "true" ]] || ghprac $pr; then
        echo "👤➕ Assigning you to $pr..."
        gh pr edit --add-assignee @me $pr > /dev/null
        echo "👤📌 You are now assigned to $pr"
        return 0
    else
        echo "👤❌ $pr is already assigned to you!"
        return 1
    fi
}

# GitHub PR Assign Remove
function ghprarm() {
    pr=$1
    force_flag=""

    # Check if --force is passed as second argument
    if [[ "$2" == "--force" ]]; then
        force_flag="true"
    fi

    if [[ "$force_flag" == "true" ]] || ! ghprac $pr; then
        echo "👤➖ Unassigning you from the PR..."
        gh pr edit --remove-assignee @me $pr
        echo "👤✅ Unassigned you from the PR."
        ghprac $pr
        return 0
    else
        echo "👤❌ You are not assigned to this PR!"
        return 1
    fi
}

# GitHub PR Draft Check
function ghprdc() {
    pr=$1
    is_draft=$(gh pr view --json isDraft $1 | jq -r '.isDraft')
    if [ "$is_draft" = "true" ]; then
        return 0
    else
        return 1
    fi
}

# GitHub PR Draft
function ghprd() {
    pr=$1
    if ghprdc $pr; then
        echo "📑➕ Marking the PR as a draft..."
        gh pr ready $pr
        echo "📑✅ Marked PR as a draft."
        return 0
    else
        echo "📑❌ PR is already a draft."
        return 1
    fi
}

# GitHub PR Draft Remove
function ghprdrm() {
    pr=$1
    if ghprdc $pr; then
        echo "📑➖ Marking PR as ready for review..."
        gh pr ready --undo $pr
        echo "📑✅ Marked PR ready for review."
        return 0
    else
        echo "📑❌ PR is already ready for review."
        return 1
    fi
    return 1
}

# GitHub PR Close (optionally posting a closing comment)
#   ghprcl [pr] [-c|--comment <text>] [-F|--comment-file <file>]
function ghprcl() {
    local pr=""
    local body=""
    local body_file=""

    while (( $# > 0 )); do
        case "$1" in
            -c|--comment)
                body="$2"
                shift 2
                ;;
            -F|--comment-file)
                body_file="$2"
                shift 2
                ;;
            *)
                pr="$1"
                shift
                ;;
        esac
    done

    # gh pr close needs an explicit target (it does not default to current branch)
    pr="${pr:-$(gbn)}"
    if [[ -z "$pr" ]]; then
        echo "ghprcl: not on a git branch and no PR given" >&2
        return 1
    fi

    local pr_json
    pr_json="$(gh pr view "$pr" --json state,assignees 2>/dev/null)"
    if [[ -z "$pr_json" ]]; then
        echo "🚫⏭️  No PR found for ${pr}; skipping"
        return 0
    fi

    local state
    state="$(echo "$pr_json" | jq -r '.state')"
    if [[ "$state" == "MERGED" || "$state" == "CLOSED" ]]; then
        echo "🚫⏭️  PR ${pr} is already ${state:l}; skipping"
        return 0
    fi

    if [[ -n "$body_file" ]]; then
        body="$(cat "$body_file")"
    fi

    local -a comment_args
    comment_args=()
    if [[ -n "$body" ]]; then
        comment_args=(--comment "$body")
    fi

    if echo "$pr_json" | jq -e --arg me "$USER" 'any(.assignees[]?; .login == $me)' >/dev/null 2>&1; then
        echo "👤➖ Unassigning you from ${pr}..."
        gh pr edit --remove-assignee @me "$pr" >/dev/null
    fi

    echo "🚫 Closing PR ${pr}..."
    if gh pr close "$pr" "${comment_args[@]}"; then
        echo "🚫✅ Closed PR ${pr}"
    else
        echo "🚫❌ Failed to close PR ${pr}" >&2
        return 1
    fi
}

# GitHub PR Reviewers
function ghprr() {
    pr=$1
    echo "👀➕ Adding reviewers to the PR. Enter reviewer names (comma-separated, or press Enter to open web): "
    read reviewers
    if [ -z "$reviewers" ]; then
        echo "🌐 Opening PR in web browser..."
        gh pr view --web $pr
        return
    fi

    # Convert comma-separated list to space-separated for gh pr edit
    local reviewer_args=""
    local reviewer_array
    IFS=',' read -rA reviewer_array <<< "$reviewers"
    for reviewer in "${reviewer_array[@]}"; do
        reviewer=$(echo "$reviewer" | xargs)  # trim whitespace
        reviewer_args="$reviewer_args --add-reviewer $reviewer"
    done

    echo "👀➕ Adding reviewers ($reviewers) to PR..."
    eval "gh pr edit $pr $reviewer_args"
    echo "👀✅ Added reviewers: $reviewers"
}
