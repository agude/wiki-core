#!/usr/bin/env bats

load test_helper

setup() {
    setup_content_dir
    export REPO_ROOT="$BATS_TEST_DIRNAME/.."
    export CLAUDE_ENV_FILE="$(mktemp)"
}

teardown() {
    teardown_content_dir
    rm -f "${CLAUDE_ENV_FILE:-}"
}

@test "session-start sets WIKI_OBSERVE=1 in env file" {
    echo '{"session_id": "test-123"}' | "$SCRIPTS/session-start"
    grep -q 'WIKI_OBSERVE=1' "$CLAUDE_ENV_FILE"
}

@test "session-start outputs CLAUDE.md content" {
    result="$(echo '{"session_id": "test-123"}' | "$SCRIPTS/session-start")"
    [[ "$result" == *"Wiki"* ]]
}

@test "session-start respects WIKI_OBSERVE=0 suppression" {
    export WIKI_OBSERVE=0
    echo '{"session_id": "test-123"}' | "$SCRIPTS/session-start"
    grep -q 'WIKI_OBSERVE=0' "$CLAUDE_ENV_FILE"
    ! grep -q 'WIKI_OBSERVE=1' "$CLAUDE_ENV_FILE"
}

@test "session-start still outputs CLAUDE.md when observation suppressed" {
    export WIKI_OBSERVE=0
    result="$(echo '{"session_id": "test-123"}' | "$SCRIPTS/session-start")"
    [[ "$result" == *"Wiki"* ]]
}

@test "session-start handles missing CLAUDE_ENV_FILE" {
    unset CLAUDE_ENV_FILE
    run bash -c 'echo "{\"session_id\": \"test-123\"}" | '"$SCRIPTS/session-start"
    [[ "$status" -eq 0 ]]
}
