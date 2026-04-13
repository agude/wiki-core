#!/usr/bin/env bats

load test_helper

setup() { setup_content_dir; }
teardown() { teardown_content_dir; }

@test "status shows wiki page count" {
    create_test_page "page1.md" "---
title: Page One
---

Content."
    run "$SCRIPTS/status"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Wiki pages:"* ]]
    [[ "$output" == *"1"* ]]
}

@test "status shows inbox count" {
    create_test_inbox "20260412T000000-aaaa.md" "Test" "Body"
    run "$SCRIPTS/status"
    [[ "$output" == *"Inbox items:"* ]]
    [[ "$output" == *"1"* ]]
}

@test "status shows zeros when empty" {
    run "$SCRIPTS/status"
    [[ "$output" == *"Wiki pages:      0"* ]]
    [[ "$output" == *"Inbox items:     0"* ]]
}

@test "context lists wiki pages" {
    create_test_page "sync.md" "---
title: Sync Topology
tags: [infra]
---

# Sync Topology"
    run "$SCRIPTS/context"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Pages (1)"* ]]
    [[ "$output" == *"Sync Topology"* ]]
}

@test "context shows none when empty" {
    run "$SCRIPTS/context"
    [[ "$output" == *"Pages: (none yet)"* ]]
}
