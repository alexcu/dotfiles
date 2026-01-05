#! /usr/bin/env zsh

#
# Git PR Train aliases
#

# Git PR Train Config editor
alias gprtc="$EDITOR ./.pr-train.yml"

# Git PR Train List
alias gprtl="git pr-train --list"

# Git PR Train (main function)
function gprt() {
    local tmpfile=$(mktemp)
    script -q "$tmpfile" git pr-train "$@"
    local ret=$?
    if [[ $ret -ne 0 ]] || grep -q "Aborting\|❌.*error" "$tmpfile"; then
        rm -f "$tmpfile"
        return 1
    fi
    rm -f "$tmpfile"
    return 0
}

# Git PR Train Test all branches
function gprtt() {
    _gprtllfn "$@" ghprt
    notify 'Tests Submitted for PRs' 'Git PR Train' '🚂 ✅' 'Glass' || notify 'PR Testing Failed' 'Git PR Train' '🚂 ❌' 'Basso'
}

# Git PR Train update approval titles
function _gprtp_update_approval_title() {
    local branch=$1
    local update_title=$2

    local pr_info
    pr_info=$(gh pr view "$branch" --json title,reviewDecision,isDraft \
        -q '[.title, (.reviewDecision // ""), (.isDraft | tostring)] | @tsv') || return 1

    local title review_decision is_draft_str
    title="${pr_info%%$'\t'*}"
    local rest="${pr_info#*$'\t'}"
    review_decision="${rest%%$'\t'*}"
    is_draft_str="${rest#*$'\t'}"

    local should_tick=false
    if [[ "$is_draft_str" != "true" && "$review_decision" == "APPROVED" ]]; then
        should_tick=true
    fi

    local normalized_title
    normalized_title=$(printf "%s" "$title" \
        | sed -E 's/[[:space:]]*✅+[[:space:]]*$//; s/[[:space:]]*$//')

    local expected_title="$normalized_title"
    local tick_suffix=""
    if [[ "$should_tick" == true ]]; then
        expected_title="${normalized_title} ✅"
        tick_suffix=" ✅"
    fi

    if [[ "$update_title" != "no" && "$expected_title" != "$title" ]]; then
        gh pr edit "$branch" --title "$expected_title" > /dev/null || return 1
    fi

    cecho white dim "  -> $branch${tick_suffix}"
}

# Git PR Train push and create/update PRs
function gprtp() {
    local send_notify="yes"
    local update_title="yes"
    local combined_title=""

    local -a positional_args
    positional_args=()

    while (( $# > 0 )); do
        case "$1" in
            --notify)
                send_notify="yes"
                shift
                ;;
            --no-notify)
                send_notify="no"
                shift
                ;;
            --no-update-title)
                update_title="no"
                shift
                ;;
            --check-approved)
                shift
                ;;
            --)
                shift
                positional_args+=("$@")
                break
                ;;
            -*)
                echo "Unknown option: $1" >&2
                return 1
                ;;
            *)
                positional_args+=("$1")
                shift
                ;;
        esac
    done

    if (( ${#positional_args[@]} > 1 )); then
        echo "usage: gprtp [--notify|--no-notify] [--no-update-title] [combined_pr_title]" >&2
        return 1
    fi

    if (( ${#positional_args[@]} == 1 )); then
        combined_title="${positional_args[1]}"
    else
        local jira_id
        jira_id=$(gbnj)
        if [[ -n "$jira_id" ]]; then
            combined_title="[$jira_id] Combined branch"
        else
            combined_title="$(git pr-train --list | awk '{print $1}' | paste -sd " " -)"
        fi
    fi

    cecho blue dim "🏗️ 🚂 Pushing and creating/updating PRs..."
    printf "%s\ny\n" "$combined_title" | git pr-train --push --create-prs --draft
    local push_exit=$?
    echo

    if (( push_exit != 0 )); then
        return $push_exit
    fi

    cecho blue dim "📌 🚂 Assigning these PRs to you..."
    _gprtllfn ghpra --force
    local assign_exit=$?

    cecho blue dim "👀 🚂 Checking approvals..."
    _gprtllfn _gprtp_update_approval_title "$update_title"
    local approval_exit=$?

    local overall_exit=$assign_exit
    if (( overall_exit == 0 )); then
        overall_exit=$approval_exit
    fi

    if [[ "$send_notify" == "yes" ]]; then
        if (( overall_exit == 0 )); then
            notify 'PRs Created' 'Git PR Train' '🚂 ✅' 'Glass'
        else
            notify 'PR Creation Failed' 'Git PR Train' '🚂 ❌' 'Basso'
        fi
    fi

    return $overall_exit
}

# Git PR Train list branches
function gprtll() {
    script -q /dev/stdout timeout -s KILL 3s git pr-train 2>/dev/null \
    | perl -pe 's/\x1b\[[0-9;]*[mK]//g' \
    | tr -d '\r' \
    | awk '
        / -> \[[0-9]+\] / {
        sub(/^.* -> \[[0-9]+\] /, "", $0)              # drop " -> [N] "
        sub(/ \(combined\)[[:space:]]*$/, "", $0)      # drop trailing " (combined)"
        if (!seen[$0] && length($0) > 0) {
            seen[$0] = 1
            print
        }
        }
    '
}

# Git PR Train list branches function
function _gprtllfn() {
    local start_branch=""

    while (( $# > 0 )); do
        case "$1" in
            --from-branch|--after-branch|--start-at)
                if [[ -n "$2" && "$2" != "--" && "$2" != -* ]]; then
                    start_branch="$2"
                    shift 2
                else
                    start_branch="$(gbn)"
                    shift
                fi
                ;;
            *)
                break
                ;;
        esac
    done

    if (( $# < 1 )); then
        echo "usage: _gprtllfn [--from-branch [branch]] <function> [extra args...]" >&2
        echo "       _gprtllfn [--from-branch [branch]] -- <command> [&& more commands...]" >&2
        return 1
    fi

    local checkout=false
    if [[ "$1" == "--" ]]; then
        checkout=true
        shift
    fi

    local fn=$1
    shift

    local -a branches
    branches=("${(@f)$(gprtll)}")
    branches=(${branches[@]:#})  # filter empty elements

    if [[ -n "$start_branch" ]]; then
        local start_index=0
        local idx=1
        local candidate_branch
        for candidate_branch in "${branches[@]}"; do
            if [[ "$candidate_branch" == "$start_branch" ]]; then
                start_index=$idx
                break
            fi
            (( idx++ ))
        done

        if (( start_index == 0 )); then
            cecho red bold "❌ start branch '$start_branch' not found in PR train; aborting." >&2
            return 1
        fi

        branches=("${branches[@]:$((start_index-1))}")
    fi

    local total=${#branches[@]}
    local i=1 branch

    for branch in "${branches[@]}"; do

        cecho white dim "🚂 [$i/$total]: $branch"

        if [[ "$checkout" == true ]]; then
            git checkout "$branch"
            if [[ $? -ne 0 ]]; then
                cecho red bold "❌ git checkout failed for '$branch'; aborting." >&2
                return 1
            fi
            eval "$fn $@"
            if [[ $? -ne 0 ]]; then
                cecho red bold "❌ command failed for '$branch'; aborting." >&2
                return 1
            fi
        else
            "$fn" "$branch" "$@"
            if [[ $? -ne 0 ]]; then
                cecho red bold "❌ $fn failed for '$branch'; aborting." >&2
                return 1
            fi
        fi

        (( i++ ))
    done
}

# Git PR Train checkout branch
function gprtco() {
    gprtll | fzf | xargs git checkout
}

# Git PR Train push branch
function gprtpp() {
    gprtll | fzf | xargs git push origin
}

# Git PR Train push all branches
function gprtppa() {
    _gprtllfn git push origin
}
