#!/usr/bin/env bats

load test_helper

setup() {
    setup_content_dir
    export REPO_ROOT="$BATS_TEST_DIRNAME/.."
}

teardown() {
    teardown_content_dir
}

@test "session-start outputs CLAUDE.md content" {
    result="$(echo '{"session_id": "test-123"}' | "$SCRIPTS/session-start")"
    [[ "$result" == *"Wiki"* ]]
}

@test "session-start handles missing CLAUDE_ENV_FILE" {
    unset CLAUDE_ENV_FILE
    run bash -c 'echo "{\"session_id\": \"test-123\"}" | '"$SCRIPTS/session-start"
    [[ "$status" -eq 0 ]]
}
