---
name: wiki-observe
description: >-
  Capture wiki-worthy knowledge from any session. Use when institutional
  knowledge surfaces — how systems work, setup procedures, decision rationale,
  troubleshooting discoveries. Calls the wiki observe script at ~/Wiki.
allowed-tools: "Bash(~/Wiki/scripts/:*)"
---

# Wiki Observe

Capture knowledge into the personal wiki's inbox from any Claude session.
The wiki lives at `~/Wiki`. Observations land in `~/Wiki/content/inbox/`
for later curation into wiki pages.

## Usage

```bash
~/Wiki/scripts/observe --title "<one-line summary>" --body "<details>"
```

Only works when `WIKI_OBSERVE=1` is set (the wiki's SessionStart hook
sets this automatically).

## What to capture

- How systems work and why they're configured that way
- Setup procedures, runbooks, troubleshooting steps
- Infrastructure topology and dependencies
- Configuration details and decision rationale
- Anything you'd want to find in six months

## Rules

- **Check `WIKI_OBSERVE=1`** before calling. If it's not set, tell the
  user what you would have captured so they can note it manually.
- **One observation per concept.** Three things learned = three calls.
- **Be specific.** Include exact commands, paths, config values, reasoning.
- **Don't capture** ephemeral state, things already in the wiki, or
  debugging noise with no extractable lesson.

## Searching the wiki

To check if something is already captured:

```bash
~/Wiki/scripts/search "<query>"
~/Wiki/scripts/toc
```
