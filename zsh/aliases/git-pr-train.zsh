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

function _gprtp_assign_if_not_approved() {
    local branch=$1
    shift

    local pr_info
    pr_info=$(ASSIGNEE_LOGIN="$USER" gh pr view "$branch" --json reviewDecision,isDraft,assignees \
        -q '[.reviewDecision // "", (.isDraft | tostring), (([.assignees[].login] | index(env.ASSIGNEE_LOGIN)) != null | tostring)] | @tsv') || return 1

    local review_decision is_draft_str is_assigned_str
    review_decision="${pr_info%%$'\t'*}"
    local rest="${pr_info#*$'\t'}"
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

    ghpra "$branch" "$@"
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

    cecho cyan "🏗️ 🚂 Pushing and creating/updating PRs..."
    printf "%s\ny\n" "$combined_title" | git pr-train --push --create-prs --draft
    local push_exit=$?
    echo

    if (( push_exit != 0 )); then
        return $push_exit
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

    if [[ -z "$train_key" || "$train_key" == "null" ]]; then
        cecho red bold "❌ branch '$branch' not found in ${PR_TRAIN_FILENAME}; aborting." >&2
        return 1
    fi

    TRAIN_KEY="$train_key" yq e -r '
      .trains[strenv(TRAIN_KEY)][]
      | (. | select(type == "!!str")) // (keys | .[0])
    ' "$config_file"
}

# Git PR Train list branches function
function _gprtllfn() {
    local start_branch=""
    local from_branch_requested=false
    local show_progress=false

    while (( $# > 0 )); do
        case "$1" in
            --from-branch|--after-branch|--start-at)
                from_branch_requested=true
                if [[ -n "$2" && "$2" != "--" && "$2" != -* ]]; then
                    start_branch="$2"
                    shift 2
                else
                    start_branch="$(gbn)"
                    shift
                fi
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
        echo "usage: _gprtllfn [--from-branch [branch]] [--show-progress] <function> [extra args...]" >&2
        echo "       _gprtllfn [--from-branch [branch]] [--show-progress] -- <command> [&& more commands...]" >&2
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
    if [[ -n "$start_branch" ]]; then
        all_branches_output="$(gprtll "$start_branch")" || return 1
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
function gprtpp() {
    gprtll | fzf --prompt "🚂 Push PR Train branch(s): " --cycle --multi | xargs git push origin
}

# Git PR Train push all branches without running all git pr-train fluff
function gprtppa() {
    _gprtllfn git push origin
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
