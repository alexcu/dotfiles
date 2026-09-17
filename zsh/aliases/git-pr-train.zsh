#! /usr/bin/env zsh

#
# Git PR Train aliases
#


typeset -gr PR_TRAIN_FILENAME=".pr-train.yml"

function _find_pr_train_config_file() {
    local dir="${1:-$PWD}"
    while true; do
        local candidate="${dir}/${PR_TRAIN_FILENAME}"
        if [[ -f "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi

        if [[ "$dir" == "/" ]]; then
            return 1
        fi
        dir="${dir:h}"
    done
}

# Git PR Train Config editor
function gprtc() {
    local cfg_file
    cfg_file="$(_find_pr_train_config_file)" || {
        echo "gprtc: no $PR_TRAIN_FILENAME found in this directory tree" >&2
        return 1
    }
    local editor="${EDITOR:-vi}"
    $=editor "$cfg_file"
}

# Git PR Train (main function)
# - `gprt [args]`            → standard `git pr-train` passthrough
# - `gprt -- <cmd> [&& ...]` → run <cmd> on every branch in the train (quote the chain),
#                             showing the progress board by default (pass --no-progress to opt out)
#   Extra options (before `--`):
#     --on <id>              → target the whole train containing <id> (PR#, branch, URL, or DLE-123)
#     --from-branch [branch] → start from a branch; omit branch to fzf-pick (resume)
#     --merge-forward        → after each success, merge the branch into the next (gmbn)
function gprt() {
    local arg
    local has_sep=false
    for arg in "$@"; do
        if [[ "$arg" == "--" ]]; then
            has_sep=true
            break
        fi
    done

    if [[ "$has_sep" == true ]]; then
        local show_progress=true
        local -a passthru
        passthru=()
        for arg in "$@"; do
            case "$arg" in
                --no-progress)
                    show_progress=false
                    ;;
                *)
                    passthru+=("$arg")
                    ;;
            esac
        done

        if [[ "$show_progress" == true ]]; then
            _gprtllfn --show-progress "${passthru[@]}"
        else
            _gprtllfn "${passthru[@]}"
        fi
        return $?
    fi

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
function gprT() {
    _gprtllfn "$@" ghprt
    notify 'Tests Submitted for PRs' 'Git PR Train' '🚂 ✅' 'Glass' || notify 'PR Testing Failed' 'Git PR Train' '🚂 ❌' 'Basso'
}
alias gprtt=gprT

# Git PR Train Test selected branches
function gprTT() {
    local selected_branches
    selected_branches=$(gprtll | fzf --prompt "🚂 Select branches to test: " --cycle --multi)

    if [[ -z "$selected_branches" ]]; then
        echo "No branches selected"
        return 0
    fi

    echo "$selected_branches" | while read -r branch; do
        if [[ -n "$branch" ]]; then
            cecho cyan "🧪 Testing branch: $branch"
            ghprt "$branch"
        fi
    done

    notify 'Tests Submitted for Selected PRs' 'Git PR Train' '🚂 ✅' 'Glass' || notify 'PR Testing Failed' 'Git PR Train' '🚂 ❌' 'Basso'
}

# Git PR Train update approval titles
function _gprtp_update_approval_title() {
    local branch="${1:-$(gbn)}"
    local update_title="${2:-yes}"

    if [[ -z "$branch" ]]; then
        echo "usage: _gprtp_update_approval_title [branch] [yes|no]" >&2
        return 1
    fi

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

    if [[ "$should_tick" == true ]]; then
        cecho green "  -> $branch${tick_suffix}"
    else
        cecho white "  -> $branch${tick_suffix}"
    fi
}

function _gprtp_test_if_not_approved() {
    local branch="$1"

    local pr_info
    pr_info="$(
        gh pr view "$branch" --json reviewDecision,isDraft \
            -q '[((.reviewDecision // "")), (.isDraft | tostring)] | @tsv'
    )" || return 1

    local review_decision is_draft_str
    review_decision="${pr_info%%$'\t'*}"
    is_draft_str="${pr_info#*$'\t'}"

    if [[ "$is_draft_str" != "true" && "$review_decision" == "APPROVED" ]]; then
        cecho green "  -> already approved; skipping tests"
        return 0
    fi

    ghprt "$branch"
}

function _gprtp_assign_if_not_approved() {
    local branch="$1"
    shift

    local pr_info
    pr_info="$(
        ASSIGNEE_LOGIN="$USER" gh pr list --head "$branch" --state open \
            --json number,reviewDecision,isDraft,assignees \
            -q 'if length == 0 then "" else [ (.[0].number | tostring), (.[0].reviewDecision // ""), (.[0].isDraft | tostring), (([.[0].assignees[].login] | index(env.ASSIGNEE_LOGIN)) != null | tostring) ] | @tsv end'
    )" || return 1

    if [[ -z "$pr_info" ]]; then
        cecho yellow "  -> no open PR found; skipping"
        return 0
    fi

    local pr_number review_decision is_draft_str is_assigned_str
    pr_number="${pr_info%%$'\t'*}"
    local rest="${pr_info#*$'\t'}"
    review_decision="${rest%%$'\t'*}"
    rest="${rest#*$'\t'}"
    is_draft_str="${rest%%$'\t'*}"
    is_assigned_str="${rest#*$'\t'}"

    if [[ "$is_draft_str" != "true" && "$review_decision" == "APPROVED" ]]; then
        cecho green "  -> already approved"
        return 0
    fi

    if [[ "$is_assigned_str" == "true" ]]; then
        cecho blue "  -> already assigned"
        return 0
    fi

    ghpra "$pr_number" "$@"
}

# Git PR Train push and create/update PRs
function gprtp() {
    local send_notify="yes"
    local update_title="yes"
    local run_tests="no"
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
            --run-tests)
                run_tests="yes"
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
        echo "usage: gprtp [--notify|--no-notify] [--no-update-title] [--run-tests] [combined_pr_title]" >&2
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
            combined_title="[$(git symbolic-ref --short HEAD 2>/dev/null)] Combined branch"
        fi
    fi

    cecho cyan "🏗️ 🚂 Pushing and creating/updating PRs..."
    cecho cyan dim "Combined PR title: $combined_title"
    COMBINED_TITLE="$combined_title" expect -c '
        set timeout -1
        spawn git pr-train --create-prs --draft
        expect "Combined branch PR title:"
        send "$env(COMBINED_TITLE)\r"
        expect "Shall we do this?"
        send "y\r"
        expect eof
        lassign [wait] pid spawnid os_error exit_code
        exit $exit_code
    '
    local create_pr_exit=$?
    echo

    if (( create_pr_exit != 0 )); then
        return $create_pr_exit
    fi

    echo
    cecho cyan "📌 🚂 Assigning unapproved PRs to you..."
    creset
    _gprtllfn _gprtp_assign_if_not_approved --force
    local assign_exit=$?

    local overall_exit=$assign_exit
    if (( overall_exit == 0 )); then
        overall_exit=$approval_exit
    fi

    if [[ "$run_tests" == "yes" ]]; then
        echo
        cecho cyan "🧪 🚂 Running tests on unapproved PRs..."
        creset
        _gprtllfn _gprtp_test_if_not_approved
        local test_exit=$?
        if (( overall_exit == 0 )); then
            overall_exit=$test_exit
        fi
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

# Git PR Train list branches from .pr-train.yml
function gprtll() {
    local branch="${1:-$(gbn)}"
    if [[ -z "$branch" ]]; then
        echo "gprtll: not on a git branch" >&2
        return 1
    fi

    local config_file
    config_file="$(_find_pr_train_config_file)" || {
        echo "gprtll: could not find ${PR_TRAIN_FILENAME} in parent directories" >&2
        return 1
    }

    local train_key
    if ARG="$branch" yq e -e '.trains | has(strenv(ARG))' "$config_file" >/dev/null 2>&1; then
        # The argument names a train directly.
        train_key="$branch"
    else
        train_key="$(
            BRANCH="$branch" yq e -r '
              .trains
              | to_entries[]
              | select(
                  .value[]
                  | (
                      (type == "!!str" and . == strenv(BRANCH))
                      or (type == "!!map" and has(strenv(BRANCH)))
                    )
                )
              | .key
            ' "$config_file" \
            | head -n 1
        )"
    fi

    if [[ -z "$train_key" || "$train_key" == "null" ]]; then
        cecho red bold "❌ '$branch' not found in ${PR_TRAIN_FILENAME} (as a branch or train); aborting." >&2
        return 1
    fi

    TRAIN_KEY="$train_key" yq e -r '
      .trains[strenv(TRAIN_KEY)][]
      | (. | select(type == "!!str")) // (keys | .[0])
    ' "$config_file"
}

# Resolve a PR identifier to a branch name.
# Accepts: PR number (123 / #123), PR URL (.../pull/123), Jira ID (DLE-123 → local
# branch matching *DLE-123*), or a plain branch name (passed through).
function _gprt_resolve_branch() {
    local id="$1"
    [[ -z "$id" ]] && return 1

    if [[ "$id" == *"/pull/"* ]]; then
        id="${id##*/pull/}"
        id="${id%%/*}"
        id="${id%%\?*}"
    fi

    local pr_num="${id#\#}"
    if [[ "$pr_num" =~ ^[0-9]+$ ]]; then
        gh pr view "$pr_num" --json headRefName -q '.headRefName' 2>/dev/null
        return $?
    fi

    # An exact train key wins over branch matching; gprtll resolves it directly.
    local cfg
    cfg="$(_find_pr_train_config_file 2>/dev/null)"
    if [[ -n "$cfg" ]] && ID="$id" yq e -e '.trains | has(strenv(ID))' "$cfg" >/dev/null 2>&1; then
        echo "$id"
        return 0
    fi

    if [[ "$id" =~ ^[A-Z]+-[0-9]+$ ]]; then
        local -a matches
        matches=("${(@f)$(git branch --list "*${id}*" --format '%(refname:short)')}")
        matches=(${matches[@]:#})       # drop empty elements
        matches=(${matches[@]:#z/*})    # drop archived (z/-prefixed) branches
        if (( ${#matches[@]} == 0 )); then
            echo "_gprt_resolve_branch: no local branch matches '$id'" >&2
            return 1
        fi
        if (( ${#matches[@]} == 1 )); then
            echo "${matches[1]}"
            return 0
        fi

        # Multiple matches: if they all belong to the same train, any one identifies
        # it, so skip the picker. Only prompt when matches span different trains.
        local first_train other_train
        local all_same=true
        first_train="$(gprtll "${matches[1]}" 2>/dev/null)"
        local candidate
        for candidate in "${matches[@]:1}"; do
            other_train="$(gprtll "$candidate" 2>/dev/null)"
            if [[ "$other_train" != "$first_train" ]]; then
                all_same=false
                break
            fi
        done
        if [[ "$all_same" == true ]]; then
            echo "${matches[1]}"
            return 0
        fi

        printf '%s\n' "${matches[@]}" | fzf --prompt "🚂 Branch for ${id}: " --cycle
        return $?
    fi

    echo "$id"
}

# Git PR Train list branches function
function _gprtllfn() {
    local start_branch=""
    local train_branch=""
    local from_branch_requested=false
    local show_progress=false
    local merge_forward=false

    while (( $# > 0 )); do
        case "$1" in
            --on)
                if [[ -z "$2" || "$2" == "--" || "$2" == -* ]]; then
                    echo "_gprtllfn: --on requires an identifier (PR#, branch, URL, or Jira ID)" >&2
                    return 1
                fi
                train_branch="$(_gprt_resolve_branch "$2")" || return 1
                if [[ -z "$train_branch" ]]; then
                    echo "_gprtllfn: could not resolve '$2' to a branch" >&2
                    return 1
                fi
                shift 2
                ;;
            --from-branch|--after-branch|--start-at)
                from_branch_requested=true
                if [[ -n "$2" && "$2" != "--" && "$2" != -* ]]; then
                    start_branch="$2"
                    shift 2
                else
                    start_branch="$(gprtll | fzf --prompt '🚂 Run from branch: ' --cycle)"
                    if [[ -z "$start_branch" ]]; then
                        echo "_gprtllfn: no start branch selected; aborting" >&2
                        return 1
                    fi
                    shift
                fi
                ;;
            --merge-forward|--cascade)
                merge_forward=true
                shift
                ;;
            --show-progress)
                show_progress=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    if (( $# < 1 )); then
        echo "usage: _gprtllfn [--on <id>] [--from-branch [branch]] [--merge-forward] [--show-progress] <function> [extra args...]" >&2
        echo "       _gprtllfn [--on <id>] [--from-branch [branch]] [--merge-forward] [--show-progress] -- <command> [&& more commands...]" >&2
        return 1
    fi

    local checkout=false
    if [[ "$1" == "--" ]]; then
        checkout=true
        shift
    fi

    local fn=$1
    shift

    local all_branches_output
    local lookup_branch="${start_branch:-$train_branch}"
    if [[ -n "$lookup_branch" ]]; then
        all_branches_output="$(gprtll "$lookup_branch")" || return 1
    else
        all_branches_output="$(gprtll)" || return 1
    fi

    local -a all_branches
    all_branches=("${(@f)${all_branches_output}}")
    all_branches=(${all_branches[@]:#})  # filter empty elements

    local total_all=${#all_branches[@]}
    if (( total_all == 0 )); then
        cecho red bold "❌ no branches found in PR train; aborting." >&2
        return 1
    fi

    local max_index=$((total_all - 1))
    local start_offset=0

    if [[ -n "$start_branch" ]]; then
        local start_index=0
        local idx=1
        local candidate_branch
        for candidate_branch in "${all_branches[@]}"; do
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

        start_offset=$((start_index - 1))
        if [[ "$from_branch_requested" == true ]]; then
            cecho magenta dim "🚂💨 Running from branch: $start_branch (branch $start_offset of $max_index)"
        fi
    fi

    local -a status_by_index
    status_by_index=()
    local status_idx
    for (( status_idx = 0; status_idx <= max_index; status_idx++ )); do
        status_by_index+=("pending")
    done
    for (( status_idx = 0; status_idx < start_offset; status_idx++ )); do
        status_by_index[$((status_idx + 1))]="skipped"
    done

    local -a branches
    branches=("${all_branches[@]:$start_offset}")

    local branch_index=$start_offset
    local branch
    local prev_branch=""

    _gprtllfn_print_progress() {
        local current_index=$1

        local idx
        for (( idx = 0; idx <= max_index; idx++ )); do
            local b="${all_branches[$((idx + 1))]}"
            local branch_state="${status_by_index[$((idx + 1))]}"
            local indicator=" "
            if [[ "$branch_state" == "skipped" ]]; then
                indicator="…"
            elif [[ "$branch_state" == "ok" ]]; then
                indicator="✔︎"
            elif [[ "$branch_state" == "fail" ]]; then
                indicator="✘"
            elif (( idx == current_index )); then
                indicator="❯"
            fi
            local line="${indicator} [$idx] $b"

            if [[ "$branch_state" == "ok" ]]; then
                cecho green "$line"
                continue
            fi
            if [[ "$branch_state" == "fail" ]]; then
                cecho red bold "$line"
                continue
            fi
            if [[ "$branch_state" == "skipped" ]]; then
                cecho cyan dim "$line"
                continue
            fi

            if (( idx == current_index )); then
                cecho blue bold "$line"
            else
                cecho white dim "$line"
            fi
        done
    }

    if [[ "$checkout" == true ]]; then
        local dirty_status
        dirty_status="$(git status --porcelain 2>/dev/null)"
        if [[ -n "$dirty_status" ]]; then
            cyellow
            echo "⚠️ Working tree has staged/unstaged changes. These will carry across checkouts."
            echo "$dirty_status" | sed -n '1,20p'
            if (( $(echo "$dirty_status" | sed '/^$/d' | wc -l | tr -d ' ') > 20 )); then
                echo "… (truncated; run 'git status --porcelain' for full list)"
            fi
            creset
        fi
    fi

    for branch in "${branches[@]}"; do

        if [[ "$show_progress" == true ]]; then
            _gprtllfn_print_progress "$branch_index"
        else
            cecho white bold "🚂 [$branch_index/$max_index]: $branch"
        fi

        if [[ "$checkout" == true ]]; then
            if ! git checkout -q "$branch" >/dev/null 2>&1; then
                cecho red bold "❌ git checkout failed for '$branch'; aborting." >&2
                git checkout "$branch" 2>&1 | sed -n '1,50p' >&2
                return 1
            fi

            if [[ "$merge_forward" == true && -n "$prev_branch" ]]; then
                cecho cyan "🔀 Merging $prev_branch → $branch"
                if ! git merge --no-edit "$prev_branch"; then
                    status_by_index[$((branch_index + 1))]="fail"
                    if [[ "$show_progress" == true ]]; then
                        _gprtllfn_print_progress "$branch_index"
                    fi
                    cecho red bold "❌ merge of '$prev_branch' into '$branch' failed; resolve conflicts then resume with --from-branch; aborting." >&2
                    return 1
                fi
            fi

            setopt local_options pipefail
            eval "$fn $@"
            local cmd_exit=$?
            if (( cmd_exit != 0 )); then
                status_by_index[$((branch_index + 1))]="fail"
                if [[ "$show_progress" == true ]]; then
                    _gprtllfn_print_progress "$branch_index"
                fi
                cecho red bold "❌ command failed for '$branch'; aborting." >&2
                return 1
            fi

            status_by_index[$((branch_index + 1))]="ok"
        else
            "$fn" "$branch" "$@"
            if [[ $? -ne 0 ]]; then
                status_by_index[$((branch_index + 1))]="fail"
                if [[ "$show_progress" == true ]]; then
                    _gprtllfn_print_progress "$branch_index"
                fi
                cecho red bold "❌ $fn failed for '$branch'; aborting." >&2
                return 1
            fi

            status_by_index[$((branch_index + 1))]="ok"
        fi

        prev_branch="$branch"
        (( branch_index++ ))
    done

    if [[ "$show_progress" == true ]]; then
        _gprtllfn_print_progress $((max_index + 1))
    fi
}
# Select and cycle through branches in PR train
function gprtls() {
    gprtll | fzf --prompt "🚂 Select PR Train branch: " --cycle | xargs echo | tr '\n' ' '
}

# Git PR Train List (git pr-train --list is too slow, so use fzf)
function gprtl() {
    gprtll | fzf --prompt "🚂 Checkout PR Train branch: " --cycle | xargs git checkout
}

# Git PR Train push branch
function gprtP() {
    gprtll | fzf --prompt "🚂 Push PR Train branch(s): " --cycle --multi | xargs git push origin
}
alias gprtpp=gprtP

# Git PR Train push all branches without running all git pr-train fluff
function gprtPP() {
    cecho "🚂 Pushing all PR train branches..."
    gprtll | xargs git push origin
}
alias gprtppa=gprtPP

# Git PR Train Close: author a closing comment once, then comment + close every open
# PR in the train. Forwards options to gprt (e.g. gprtclose --on DLE-174).
function gprtcl() {
    local f
    f=$(mktemp)
    ${EDITOR:-emacs} "$f"
    if [[ ! -s "$f" ]]; then
        echo "gprtclose: empty comment; aborting" >&2
        rm -f "$f"
        return 1
    fi

    gprt "$@" -- "ghprcl -F '$f' || true"
    local ret=$?
    rm -f "$f"
    return $ret
}

# Git PR Train (whole workflow)
function gprt\!() {
  local custom_cmd=""
  local no_confirm=false
  local no_merge=false
  local from_branch_requested=false
  local start_branch=""

  local invocation_branch
  invocation_branch="$(gbn)"
  if [[ -z "$invocation_branch" ]]; then
    echo "gprt!: not on a git branch" >&2
    return 1
  fi
  start_branch="$invocation_branch"

  local -a opt_args
  local -a cmd_args
  opt_args=()
  cmd_args=()

  local in_cmd=false
  local arg
  for arg in "$@"; do
    if [[ "$arg" == "--" && "$in_cmd" == false ]]; then
      in_cmd=true
      continue
    fi
    if [[ "$in_cmd" == true ]]; then
      cmd_args+=("$arg")
    else
      opt_args+=("$arg")
    fi
  done

  if (( ${#cmd_args[@]} > 0 )); then
    custom_cmd="${(j: :)cmd_args}"
  fi

  set -- "${opt_args[@]}"

  local OPTIND=1
  local opt
  while getopts ":yMb:h-:" opt; do
    case "$opt" in
      y)
        no_confirm=true
        ;;
      M)
        no_merge=true
        ;;
      b)
        from_branch_requested=true
        start_branch="$OPTARG"
        ;;
      h)
        echo "usage: gprt! [-y] [-M] [-b <branch>] [--no-confirm] [--no-merge] [--from-branch [branch]] [-- <custom cmd>]" >&2
        return 0
        ;;
      -)
        local long_opt="$OPTARG"
        local long_arg=""
        if [[ "$long_opt" == *=* ]]; then
          long_arg="${long_opt#*=}"
          long_opt="${long_opt%%=*}"
        fi

        case "$long_opt" in
          no-confirm|no-confim|skip-confirm)
            no_confirm=true
            ;;
          no-merge|skip-merge)
            no_merge=true
            ;;
          from-branch|after-branch|start-at)
            from_branch_requested=true
            if [[ -n "$long_arg" ]]; then
              start_branch="$long_arg"
            elif [[ -n "${@[OPTIND]}" && "${@[OPTIND]}" != -* ]]; then
              start_branch="${@[OPTIND]}"
              OPTIND=$((OPTIND + 1))
            else
              start_branch="$invocation_branch"
            fi
            ;;
          help)
            echo "usage: gprt! [-y] [-M] [-b <branch>] [--no-confirm] [--no-merge] [--from-branch [branch]] [-- <custom cmd>]" >&2
            return 0
            ;;
          *)
            echo "Unknown option: --$long_opt" >&2
            return 1
            ;;
        esac
        ;;
      :)
        echo "Option -$OPTARG requires an argument." >&2
        return 1
        ;;
      \?)
        echo "Unknown option: -$OPTARG" >&2
        return 1
        ;;
    esac
  done

  shift $((OPTIND - 1))
  if (( $# > 0 )); then
    echo "Unexpected argument(s): $*" >&2
    echo "usage: gprt! [-y] [-M] [-b <branch>] [--no-confirm] [--no-merge] [--from-branch [branch]] [-- <custom cmd>]" >&2
    return 1
  fi

  local total_steps=4
  local step=1
  [[ -n "$custom_cmd" ]] && total_steps=5
  [[ "$no_merge" == true ]] && (( total_steps -= 1 ))

  cecho magenta bold "🚂💨 PR Train, stopping all stations..."
  if [[ "$from_branch_requested" == true ]]; then
    local train_branches_output
    train_branches_output="$(gprtll "$start_branch")" || return 1
    local -a train_branches
    train_branches=("${(@f)${train_branches_output}}")
    train_branches=(${train_branches[@]:#})

    local max_index=$(( ${#train_branches[@]} - 1 ))
    local idx=0
    local found_index=""
    local b
    for b in "${train_branches[@]}"; do
      if [[ "$b" == "$start_branch" ]]; then
        found_index=$idx
        break
      fi
      (( idx++ ))
    done

    if [[ -n "$found_index" && $max_index -ge 0 ]]; then
      cecho magenta dim "🚂💨 Running from branch: $start_branch (branch $found_index of $max_index)"
    else
      cecho magenta dim "🚂💨 Running from branch: $start_branch"
    fi
  fi

  if [[ "$no_confirm" != true ]]; then
    cyellow
    if ! confirm "⚠️ Have you run build checks on all PRs?" --yn; then
      creset
      echo "Oops!"
      return 1
    fi
    creset
  fi

  if [[ "$(gbn)" != "$start_branch" ]]; then
    if ! git checkout "$start_branch"; then
      cecho red "🚫🚂 Unable to switch to start branch"
      return 1
    fi
  fi

  if [[ "$no_merge" != true ]]; then
    echo
    cecho magenta "🔀 🏫 🚂 [$step/$total_steps] Now arriving at: Merging..."
    if ! gprt; then
      notify 'Merge Failed' 'Git PR Train' '💥🚂' 'Basso'
      cecho red "💥🚂 The train crashed on $(gbn)"
      return 1
    fi
    echo
    cecho magenta dim "🚂💨 Left Merging, moving on..."
    (( step++ ))
  fi

  if [[ -n "$custom_cmd" ]]; then
    echo
    cecho magenta "🔧 🏫 🚂 [$step/$total_steps] Now arriving at: $custom_cmd"
    if ! _gprtllfn --from-branch "$start_branch" --show-progress -- "$custom_cmd"; then
      notify 'Custom Command Failed' 'Git PR Train' '💥🚂' 'Basso'
      cecho red "💥🚂 The train crashed on $(gbn)"
      return 1
    fi
    cecho magenta dim "🚂💨 Left Custom command, moving on..."
    (( step++ ))
  fi

  echo
  cecho magenta "🫸 🏫 🚂 [$step/$total_steps] Now arriving at: Pushing..."
  if ! gprtp --no-notify; then
    notify 'Pushing PRs Failed' 'Git PR Train' '💥🚂' 'Basso'
    cecho red "💥🚂 The train crashed on $(gbn)"
    return 1
  fi
  cecho magenta dim "🚂💨 Left Pushing, moving on..."
  (( step++ ))

  echo
  if [[ "$(gbn)" != "$start_branch" ]]; then
    cecho magenta dim "🚂💨 Switching to start branch: $start_branch"
    if ! git checkout "$start_branch"; then
      notify 'Switching to Start Branch Failed' 'Git PR Train' '💥🚂' 'Basso'
      cecho red "💥🚂 The train crashed on $(gbn)"
      return 1
    fi
  fi

  echo
  cecho magenta "🧪 🏫 🚂 [$step/$total_steps] Now arriving at: Testing..."
  if ! gprtt --from-branch "$start_branch"; then
    notify 'Testing PRs Failed' 'Git PR Train' '💥🚂' 'Basso'
    cecho red "💥🚂 The train crashed switching to start branch"
    return 1
  fi
  cecho magenta dim "🚂💨 Left Testing, moving on..."
  (( step++ ))

  echo
  cecho magenta "🏁 🚂 [$step/$total_steps] Done!"
  notify 'The PR train has reached its destination!' 'Git PR Train' '🚂 ✅' 'Glass'
}

# GitHub PR Train (whole workflow) no confirm and no merge
alias gprtn!="gprt\! -yM"
