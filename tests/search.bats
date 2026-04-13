#!/usr/bin/env bats

load test_helper

setup() { setup_content_dir; }
teardown() { teardown_content_dir; }

@test "search finds match in wiki page" {
    create_test_page "topic.md" "---
title: Test
tags: [networking]
---

# Topic

## Section One

The server uses PostgreSQL for storage."
    run "$SCRIPTS/search" "PostgreSQL"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"wiki/topic.md"* ]]
    [[ "$output" == *"Section One"* ]]
    [[ "$output" == *"PostgreSQL"* ]]
}

@test "search finds match in inbox" {
    create_test_inbox "20260412T000000-aaaa.md" "Test obs" "Found a bug in the deploy script."
    run "$SCRIPTS/search" "deploy script"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"inbox"* ]]
}

@test "search is case-insensitive" {
    create_test_page "topic.md" "# Topic

## Info

PostgreSQL is the database."
    run "$SCRIPTS/search" "postgresql"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"PostgreSQL"* ]]
}

@test "search returns nothing for no match" {
    create_test_page "topic.md" "# Topic

## Info

Some content."
    run "$SCRIPTS/search" "zzzznonexistent"
    [[ "$status" -eq 0 ]]
    [[ -z "$output" ]]
}

@test "search succeeds when only some pages match" {
    create_test_page "alpha.md" "# Alpha

No match here."
    create_test_page "beta.md" "# Beta

## Details

The server uses PostgreSQL."
    create_test_page "gamma.md" "# Gamma

Also no match."
    run "$SCRIPTS/search" "PostgreSQL"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"wiki/beta.md"* ]]
    [[ "$output" != *"wiki/alpha.md"* ]]
    [[ "$output" != *"wiki/gamma.md"* ]]
}

@test "search handles empty content directories" {
    run "$SCRIPTS/search" "anything"
    [[ "$status" -eq 0 ]]
}

@test "search shows 'top' when match is before any H2" {
    create_test_page "topic.md" "---
title: Test
---

# Topic

Preamble with target_word here."
    run "$SCRIPTS/search" "target_word"
    [[ "$output" == *"| top |"* ]]
}
