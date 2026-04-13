#!/usr/bin/env bats

load test_helper

setup() { setup_content_dir; }
teardown() { teardown_content_dir; }

@test "archive moves file from inbox to handled" {
    create_test_inbox "20260412T000000-aaaa.md" "Test" "Body"
    run "$SCRIPTS/archive" "20260412T000000-aaaa.md" --no-commit
    [[ "$status" -eq 0 ]]
    [[ ! -f "$TEST_CONTENT_DIR/inbox/20260412T000000-aaaa.md" ]]
    [[ -f "$TEST_CONTENT_DIR/handled/20260412T000000-aaaa.md" ]]
}

@test "archive --all moves all files" {
    create_test_inbox "20260412T000000-aaaa.md" "First" "Body one"
    create_test_inbox "20260412T000001-bbbb.md" "Second" "Body two"
    run "$SCRIPTS/archive" --all --no-commit
    [[ "$status" -eq 0 ]]
    count=$(ls "$TEST_CONTENT_DIR/inbox/"*.md 2>/dev/null | wc -l)
    [[ "$count" -eq 0 ]]
    count=$(ls "$TEST_CONTENT_DIR/handled/"*.md 2>/dev/null | wc -l)
    [[ "$count" -eq 2 ]]
}

@test "archive reports missing file" {
    run "$SCRIPTS/archive" "nonexistent.md" --no-commit
    [[ "$output" == *"Not found"* ]]
}

@test "archive --help prints usage" {
    run "$SCRIPTS/archive" --help
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Usage:"* ]]
}

@test "archive with no files does nothing" {
    run "$SCRIPTS/archive" --all --no-commit
    [[ "$output" == *"No files to archive"* ]]
}
