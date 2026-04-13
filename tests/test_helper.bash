# test_helper.bash - Shared setup/teardown for bats tests.
#
# Creates a temporary content directory with the expected structure.
# Sets WIKI_CONTENT_DIR so scripts find it. Cleans up on teardown.

setup_content_dir() {
    export TEST_CONTENT_DIR="$(mktemp -d)"
    mkdir -p "$TEST_CONTENT_DIR"/{wiki,inbox,handled}
    export WIKI_CONTENT_DIR="$TEST_CONTENT_DIR"
    export SCRIPTS="$BATS_TEST_DIRNAME/../scripts"

    # Init a git repo in content dir (needed for locked_commit, status)
    git -C "$TEST_CONTENT_DIR" init -q
    git -C "$TEST_CONTENT_DIR" config user.email "test@test.com"
    git -C "$TEST_CONTENT_DIR" config user.name "Test"
    # Need an initial commit for git log to work
    touch "$TEST_CONTENT_DIR/.gitkeep"
    git -C "$TEST_CONTENT_DIR" add .gitkeep
    git -C "$TEST_CONTENT_DIR" commit -q -m "init"
}

teardown_content_dir() {
    if [[ -n "${TEST_CONTENT_DIR:-}" ]] && [[ -d "$TEST_CONTENT_DIR" ]]; then
        rm -rf "$TEST_CONTENT_DIR"
    fi
}

# create_test_page - Write a markdown file into content/wiki/.
#
# Usage: create_test_page "filename.md" "content"
create_test_page() {
    local name="$1"
    local content="$2"
    printf '%s\n' "$content" > "$TEST_CONTENT_DIR/wiki/$name"
}

# create_test_inbox - Write an item into content/inbox/.
#
# Usage: create_test_inbox "filename.md" "title" "body"
create_test_inbox() {
    local name="$1"
    local title="$2"
    local body="$3"
    cat > "$TEST_CONTENT_DIR/inbox/$name" <<EOF
---
title: "$title"
source: session
created: 2026-04-12T00:00:00Z
---

$body
EOF
}
