#!/usr/bin/env bats

load test_helper

setup() { setup_content_dir; }
teardown() { teardown_content_dir; }

@test "observe creates file with correct frontmatter" {
    export WIKI_OBSERVE=1
    run "$SCRIPTS/observe" --title "Test title" --body "Test body" --no-commit
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Wrote: inbox/"* ]]

    # Check the file exists and has correct content
    file=$(ls "$TEST_CONTENT_DIR/inbox/"*.md | head -1)
    [[ -f "$file" ]]
    grep -q 'title: "Test title"' "$file"
    grep -q 'source: session' "$file"
    grep -q 'Test body' "$file"
}

@test "observe respects custom --source" {
    export WIKI_OBSERVE=1
    run "$SCRIPTS/observe" --title "Test" --body "Body" --source "slack" --no-commit
    [[ "$status" -eq 0 ]]
    file=$(ls "$TEST_CONTENT_DIR/inbox/"*.md | head -1)
    grep -q 'source: slack' "$file"
}

@test "observe refuses without WIKI_OBSERVE=1" {
    unset WIKI_OBSERVE
    run "$SCRIPTS/observe" --title "Test" --body "Body" --no-commit
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Observation disabled"* ]]
    count=$(ls "$TEST_CONTENT_DIR/inbox/"*.md 2>/dev/null | wc -l)
    [[ "$count" -eq 0 ]]
}

@test "observe refuses with WIKI_OBSERVE=0" {
    export WIKI_OBSERVE=0
    run "$SCRIPTS/observe" --title "Test" --body "Body" --no-commit
    [[ "$output" == *"Observation disabled"* ]]
    count=$(ls "$TEST_CONTENT_DIR/inbox/"*.md 2>/dev/null | wc -l)
    [[ "$count" -eq 0 ]]
}

@test "observe requires --title" {
    export WIKI_OBSERVE=1
    run "$SCRIPTS/observe" --body "Body" --no-commit
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"--title is required"* ]]
}

@test "observe reads body from stdin" {
    export WIKI_OBSERVE=1
    echo "Piped body content" | WIKI_OBSERVE=1 "$SCRIPTS/observe" --title "Stdin test" --no-commit
    file=$(ls "$TEST_CONTENT_DIR/inbox/"*.md | head -1)
    grep -q 'Piped body content' "$file"
}

@test "observe escapes quotes in title" {
    export WIKI_OBSERVE=1
    run "$SCRIPTS/observe" --title 'Say "hello"' --body "Body" --no-commit
    [[ "$status" -eq 0 ]]
    file=$(ls "$TEST_CONTENT_DIR/inbox/"*.md | head -1)
    grep -q 'Say \\"hello\\"' "$file"
}
