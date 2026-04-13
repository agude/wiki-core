#!/usr/bin/env bats

load test_helper

teardown() {
    if [[ -n "${INIT_DIR:-}" ]] && [[ -d "$INIT_DIR" ]]; then
        rm -rf "$INIT_DIR"
    fi
}

@test "init creates directory structure" {
    INIT_DIR="$(mktemp -d)"
    rm -rf "$INIT_DIR"
    run "$BATS_TEST_DIRNAME/../scripts/init" --path "$INIT_DIR"
    [[ "$status" -eq 0 ]]
    [[ -d "$INIT_DIR/wiki" ]]
    [[ -d "$INIT_DIR/inbox" ]]
    [[ -d "$INIT_DIR/handled" ]]
    [[ -d "$INIT_DIR/.git" ]]
}

@test "init --help prints usage" {
    run "$BATS_TEST_DIRNAME/../scripts/init" --help
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Usage:"* ]]
}

@test "init is idempotent" {
    INIT_DIR="$(mktemp -d)"
    rm -rf "$INIT_DIR"
    "$BATS_TEST_DIRNAME/../scripts/init" --path "$INIT_DIR"
    run "$BATS_TEST_DIRNAME/../scripts/init" --path "$INIT_DIR"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"already initialized"* ]]
}
