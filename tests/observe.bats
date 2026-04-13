#!/usr/bin/env bats

load test_helper

setup() { setup_content_dir; }
teardown() { teardown_content_dir; }

@test "observe creates file with correct frontmatter" {
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
    run "$SCRIPTS/observe" --title "Test" --body "Body" --source "slack" --no-commit
    [[ "$status" -eq 0 ]]
    file=$(ls "$TEST_CONTENT_DIR/inbox/"*.md | head -1)
    grep -q 'source: slack' "$file"
}

@test "observe requires --title" {
    run "$SCRIPTS/observe" --body "Body" --no-commit
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"--title is required"* ]]
}

@test "observe reads body from stdin" {
    echo "Piped body content" | "$SCRIPTS/observe" --title "Stdin test" --no-commit
    file=$(ls "$TEST_CONTENT_DIR/inbox/"*.md | head -1)
    grep -q 'Piped body content' "$file"
}

@test "observe escapes quotes in title" {
    run "$SCRIPTS/observe" --title 'Say "hello"' --body "Body" --no-commit
    [[ "$status" -eq 0 ]]
    file=$(ls "$TEST_CONTENT_DIR/inbox/"*.md | head -1)
    grep -q 'Say \\"hello\\"' "$file"
}
