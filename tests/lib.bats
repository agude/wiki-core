#!/usr/bin/env bats

load test_helper

setup() { setup_content_dir; }
teardown() { teardown_content_dir; }

@test "frontmatter_field extracts unquoted value" {
    create_test_page "test.md" "---
title: My Page
---

Content."
    source "$SCRIPTS/_lib.sh"
    result="$(frontmatter_field "title" "$TEST_CONTENT_DIR/wiki/test.md")"
    [[ "$result" == "My Page" ]]
}

@test "frontmatter_field extracts quoted value" {
    create_test_page "test.md" '---
title: "My Page"
---

Content.'
    source "$SCRIPTS/_lib.sh"
    result="$(frontmatter_field "title" "$TEST_CONTENT_DIR/wiki/test.md")"
    [[ "$result" == "My Page" ]]
}

@test "frontmatter_field reverses yaml_escape" {
    create_test_page "test.md" '---
title: "Say \"hello\""
---

Content.'
    source "$SCRIPTS/_lib.sh"
    result="$(frontmatter_field "title" "$TEST_CONTENT_DIR/wiki/test.md")"
    [[ "$result" == 'Say "hello"' ]]
}

@test "frontmatter_field returns 1 for missing field" {
    create_test_page "test.md" "---
title: My Page
---

Content."
    source "$SCRIPTS/_lib.sh"
    run frontmatter_field "missing" "$TEST_CONTENT_DIR/wiki/test.md"
    [[ "$status" -ne 0 ]]
}

@test "frontmatter_list parses inline list" {
    create_test_page "test.md" "---
title: Test
tags: [one, two, three]
---

Content."
    source "$SCRIPTS/_lib.sh"
    result="$(frontmatter_list "tags" "$TEST_CONTENT_DIR/wiki/test.md")"
    [[ "$(echo "$result" | wc -l | tr -d ' ')" -eq 3 ]]
    [[ "$(echo "$result" | head -1)" == "one" ]]
    [[ "$(echo "$result" | tail -1)" == "three" ]]
}

@test "frontmatter_list parses block list" {
    create_test_page "test.md" "---
title: Test
tags:
  - alpha
  - beta
---

Content."
    source "$SCRIPTS/_lib.sh"
    result="$(frontmatter_list "tags" "$TEST_CONTENT_DIR/wiki/test.md")"
    [[ "$(echo "$result" | wc -l | tr -d ' ')" -eq 2 ]]
    [[ "$(echo "$result" | head -1)" == "alpha" ]]
}

@test "yaml_escape escapes quotes and backslashes" {
    source "$SCRIPTS/_lib.sh"
    result="$(yaml_escape 'Say "hello" with \')"
    [[ "$result" == 'Say \"hello\" with \\' ]]
}

@test "resolve_path finds file in wiki/" {
    create_test_page "mypage.md" "content"
    source "$SCRIPTS/_lib.sh"
    result="$(resolve_path "mypage.md")"
    [[ "$result" == "wiki/mypage.md" ]]
}

@test "resolve_path finds file with full path" {
    create_test_page "mypage.md" "content"
    source "$SCRIPTS/_lib.sh"
    result="$(resolve_path "wiki/mypage.md")"
    [[ "$result" == "wiki/mypage.md" ]]
}
