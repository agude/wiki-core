---
name: wiki-observe
description: >-
  Capture wiki-worthy knowledge from any session. Use when institutional
  knowledge surfaces — how systems work, setup procedures, decision rationale,
  troubleshooting discoveries. Calls the wiki observe script at ~/Wiki.
allowed-tools:
  - "Bash(${CLAUDE_SKILL_DIR}/../scripts/*)"
---

# Wiki Observe

Capture knowledge into the personal wiki's inbox from any Claude session.
The wiki lives at `~/Wiki`. Observations land in `~/Wiki/content/inbox/`
for later curation into wiki pages.

## Usage

```bash
${CLAUDE_SKILL_DIR}/../scripts/observe --title "<one-line summary>" --body "<details>"
```

## What to capture

- How systems work and why they're configured that way
- Setup procedures, runbooks, troubleshooting steps
- Infrastructure topology and dependencies
- Configuration details and decision rationale
- Anything you'd want to find in six months

## Rules

- **One observation per concept.** Three things learned = three calls.
- **Be specific.** Include exact commands, paths, config values, reasoning.
- **Don't capture** ephemeral state, things already in the wiki, or
  debugging noise with no extractable lesson.

## Searching the wiki

To check if something is already captured:

```bash
${CLAUDE_SKILL_DIR}/../scripts/search "<query>"
${CLAUDE_SKILL_DIR}/../scripts/toc
```
