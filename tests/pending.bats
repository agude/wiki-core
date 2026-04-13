#!/usr/bin/env bats

load test_helper

setup() { setup_content_dir; }
teardown() { teardown_content_dir; }

@test "pending shows count of items" {
    create_test_inbox "20260412T000000-aaaa.md" "First" "Body one"
    create_test_inbox "20260412T000001-bbbb.md" "Second" "Body two"
    run "$SCRIPTS/pending" --count
    [[ "$output" == "2" ]]
}

@test "pending shows zero when empty" {
    run "$SCRIPTS/pending" --count
    [[ "$output" == "0" ]]
}

@test "pending lists titles" {
    create_test_inbox "20260412T000000-aaaa.md" "My Title" "Body"
    run "$SCRIPTS/pending"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"My Title"* ]]
    [[ "$output" == *"1 pending"* ]]
}

@test "pending --full shows body content" {
    create_test_inbox "20260412T000000-aaaa.md" "Full Test" "Detailed body here"
    run "$SCRIPTS/pending" --full
    [[ "$output" == *"Detailed body here"* ]]
}

@test "pending --help prints usage" {
    run "$SCRIPTS/pending" --help
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Usage:"* ]]
}

@test "pending shows 'No pending items' when empty" {
    run "$SCRIPTS/pending"
    [[ "$output" == "No pending items." ]]
}
