#!/usr/bin/env bash
#
# _lib.sh - Shared functions for wiki scripts.
#
# Source this after setting REPO_ROOT:
#   SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
#   REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
#   source "$SCRIPT_DIR/_lib.sh"
#
# Sets CONTENT_DIR (defaults to $REPO_ROOT/content, overridable via
# WIKI_CONTENT_DIR env var). All content paths go through CONTENT_DIR.

CONTENT_DIR="${WIKI_CONTENT_DIR:-$REPO_ROOT/content}"

# need_arg - Verify that a flag's required value is present.
#
# Call inside argument-parsing loops before accessing $2.
#
# Usage:
#   --flag) need_arg "$1" "$#"; VALUE="$2"; shift 2 ;;
need_arg() {
    if (( $2 < 2 )); then
        echo "Option $1 requires an argument" >&2
        exit 1
    fi
}

# resolve_path - Normalize a path to be relative to the content root.
#
# Handles: absolute paths, content-relative paths, wiki/-relative paths,
# and bare filenames (searched under wiki/ only).
#
# Prints the resolved content-relative path on success.
# Returns 1 if not found; prints error to stderr if ambiguous.
#
# Usage:
#   resolved="$(resolve_path "$path")" && VAR="$CONTENT_DIR/$resolved"
resolve_path() {
    local input="$1"

    # Strip absolute content root prefix
    input="${input#"$CONTENT_DIR/"}"

    # Exists relative to content root
    if [[ -e "$CONTENT_DIR/$input" ]]; then
        echo "$input"
        return 0
    fi

    # Try prepending wiki/
    if [[ "$input" != wiki/* ]] && [[ "$input" != inbox/* ]] \
        && [[ "$input" != handled/* ]]; then
        if [[ -e "$CONTENT_DIR/wiki/$input" ]]; then
            echo "wiki/$input"
            return 0
        fi
    fi

    # Basename search under wiki/, inbox/, handled/
    local base matches count
    base="$(basename "$input")"
    matches="$(find "$CONTENT_DIR/wiki" "$CONTENT_DIR/inbox" \
        "$CONTENT_DIR/handled" \
        -name "$base" 2>/dev/null)"

    if [[ -z "$matches" ]]; then
        return 1
    fi

    count="$(echo "$matches" | wc -l | tr -d ' ')"

    if (( count == 1 )); then
        echo "${matches#"$CONTENT_DIR/"}"
        return 0
    fi

    echo "Ambiguous match for '$base' — $count files found:" >&2
    echo "$matches" | sed "s|^$CONTENT_DIR/|  |" >&2
    return 1
}

# locked_commit - Commit with a filesystem lock to serialize concurrent writes.
#
# Uses a PID file inside the lock dir to detect and break stale locks
# left by killed processes. Registers an EXIT trap as a safety net;
# clears it after the explicit cleanup to avoid stealing another
# process's lock. Git operations run in a subshell to avoid leaking
# a cd into the caller.
#
# Usage:
#   locked_commit "message" path1 [path2 ...]
locked_commit() {
    local message="$1"
    shift

    local lockdir="$CONTENT_DIR/.observe.lock"
    local pidfile="$lockdir/pid"
    local retries=30

    while ! mkdir "$lockdir" 2>/dev/null; do
        # Break stale locks left by dead processes
        if [[ -f "$pidfile" ]]; then
            local owner
            owner="$(cat "$pidfile" 2>/dev/null || echo "")"
            if [[ -n "$owner" ]] && ! kill -0 "$owner" 2>/dev/null; then
                rm -rf "$lockdir"
                continue
            fi
        fi
        retries=$((retries - 1))
        if (( retries <= 0 )); then
            echo "Could not acquire lock" >&2
            return 1
        fi
        sleep 1
    done

    echo $$ > "$pidfile"
    trap 'rm -rf "'"$CONTENT_DIR"'/.observe.lock" 2>/dev/null || true' EXIT

    (
        cd "$CONTENT_DIR"
        for p in "$@"; do
            git add "$p"
        done
        git commit -m "$message" -q 2>/dev/null || echo "locked_commit: git commit failed for: $message" >&2
    )

    rm -rf "$lockdir" 2>/dev/null || true
    trap - EXIT
}

# yaml_escape - Escape a string for safe use in double-quoted YAML values.
#
# Handles backslashes and double quotes. Sufficient for single-line shell
# arguments (--title values); does not handle newlines or other YAML specials.
#
# Usage:
#   safe="$(yaml_escape "$title")"
#   echo "title: \"$safe\""
yaml_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    echo "$s"
}

# frontmatter_field - Extract a field from YAML frontmatter.
#
# Reads a markdown file's frontmatter block (between --- delimiters) and
# returns the value of the named field. Handles double-quoted values and
# reverses yaml_escape escaping.
#
# Usage:
#   title="$(frontmatter_field "title" "$file")"
frontmatter_field() {
    local field="$1" file="$2"
    local in_fm=false

    while IFS= read -r line; do
        if [[ "$line" == "---" ]]; then
            if [[ "$in_fm" == false ]]; then
                in_fm=true
                continue
            else
                return 1
            fi
        fi
        if [[ "$in_fm" == true ]] && [[ "$line" =~ ^${field}:[[:space:]]*(.*) ]]; then
            local value="${BASH_REMATCH[1]}"
            # Strip surrounding double quotes and reverse yaml_escape
            if [[ "$value" =~ ^\"(.*)\"$ ]]; then
                value="${BASH_REMATCH[1]}"
                value="${value//\\\"/\"}"
                value="${value//\\\\/\\}"
            fi
            echo "$value"
            return 0
        fi
    done < "$file"

    return 1
}

# frontmatter_list - Extract a YAML list field from frontmatter.
#
# Returns one item per line, stripping the "- " prefix.
#
# Usage:
#   tags="$(frontmatter_list "tags" "$file")"
frontmatter_list() {
    local field="$1" file="$2"
    local in_fm=false in_list=false

    while IFS= read -r line; do
        if [[ "$line" == "---" ]]; then
            if [[ "$in_fm" == false ]]; then
                in_fm=true
                continue
            else
                break
            fi
        fi
        [[ "$in_fm" == false ]] && continue

        if [[ "$in_list" == true ]]; then
            # Continuation line: must start with "  - "
            if [[ "$line" =~ ^[[:space:]]+-[[:space:]]+(.*) ]]; then
                echo "${BASH_REMATCH[1]}"
                continue
            else
                break
            fi
        fi

        if [[ "$line" =~ ^${field}:[[:space:]]*(.*) ]]; then
            local value="${BASH_REMATCH[1]}"
            # Inline list: [item1, item2, item3]
            if [[ "$value" =~ ^\[(.+)\]$ ]]; then
                local items="${BASH_REMATCH[1]}"
                IFS=',' read -ra parts <<< "$items"
                for part in "${parts[@]}"; do
                    # Trim whitespace
                    part="${part#"${part%%[![:space:]]*}"}"
                    part="${part%"${part##*[![:space:]]}"}"
                    echo "$part"
                done
                return 0
            fi
            # Empty value means block list follows
            if [[ -z "$value" ]]; then
                in_list=true
                continue
            fi
            # Single value
            echo "$value"
            return 0
        fi
    done < "$file"

    [[ "$in_list" == true ]] && return 0
    return 1
}
