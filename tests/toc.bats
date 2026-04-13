#!/usr/bin/env bats

load test_helper

setup() { setup_content_dir; }
teardown() { teardown_content_dir; }

@test "toc lists wiki pages with titles" {
    create_test_page "sync.md" "---
title: Sync Topology
tags: [infrastructure, nas]
---

# Sync Topology

## Machines

Content."
    run "$SCRIPTS/toc"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Sync Topology"* ]]
    [[ "$output" == *"wiki/sync.md"* ]]
}

@test "toc shows tags" {
    create_test_page "sync.md" "---
title: Sync Topology
tags: [infrastructure, nas]
---

# Sync Topology"
    run "$SCRIPTS/toc"
    [[ "$output" == *"infrastructure"* ]]
    [[ "$output" == *"nas"* ]]
}

@test "toc --depth 2 shows H2 sections" {
    create_test_page "sync.md" "---
title: Sync Topology
tags: [infra]
---

# Sync Topology

## Machines

Content.

## Data Flow

More content."
    run "$SCRIPTS/toc" --depth 2
    [[ "$output" == *"1. Machines"* ]]
    [[ "$output" == *"2. Data Flow"* ]]
}

@test "toc --flat omits file paths" {
    create_test_page "sync.md" "---
title: Sync Topology
tags: [infra]
---

# Sync Topology"
    run "$SCRIPTS/toc" --flat
    [[ "$output" != *"wiki/sync.md"* ]]
    [[ "$output" == *"Sync Topology"* ]]
}

@test "toc --tag filters by tag" {
    create_test_page "sync.md" "---
title: Sync Topology
tags: [infrastructure, nas]
---

# Sync Topology"
    create_test_page "recipe.md" "---
title: Cookie Recipe
tags: [cooking]
---

# Cookie Recipe"
    run "$SCRIPTS/toc" --tag infrastructure
    [[ "$output" == *"Sync Topology"* ]]
    [[ "$output" != *"Cookie Recipe"* ]]
}

@test "toc shows message when no pages" {
    run "$SCRIPTS/toc"
    [[ "$output" == *"No wiki pages"* ]]
}

@test "toc --help prints usage" {
    run "$SCRIPTS/toc" --help
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Usage:"* ]]
}

@test "toc falls back to filename when no title" {
    create_test_page "no-title.md" "Just some content, no frontmatter."
    run "$SCRIPTS/toc"
    [[ "$output" == *"no-title"* ]]
}
