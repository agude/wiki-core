---
name: wiki
description: Look up, record, and manage wiki content. Use when the user asks to find information, record something, or work with the wiki.
user-invocable: true
---

# Wiki

You have access to a personal wiki at `$WIKI`. It contains wiki pages,
and pending inbox items. All interaction goes through scripts in
`$WIKI/scripts/`.

## Looking things up

1. **Search first.** `scripts/search "<query>"` returns matches across
   wiki pages and inbox items. Output format:
   `<file> | <section> | <matched line>`.

2. **Browse with toc.** `scripts/toc` lists all wiki pages with titles
   and tags.
   - `toc` — page titles and tags (default)
   - `toc --depth 2` — titles + H2 section names
   - `toc --tag infrastructure` — filter by tag
   - `toc --flat` — just titles, no file paths

3. **Read pages directly.** Wiki pages are standard markdown in
   `content/wiki/`. Read them with the Read tool.

## Recording observations

When wiki-worthy knowledge surfaces during a task — how something works,
why a decision was made, a setup procedure, a troubleshooting discovery —
capture it immediately:

```bash
scripts/observe --title "<one-line summary>" --body "<details>"
```

### Rules

- **Capture immediately.** Do not wait until the task is done.
- **One observation per concept.** Three things learned = three calls.
- **Be specific.** "NAS containers restart order matters: Traefik first,
  then Syncthing, then Plex" is good. "NAS setup notes" is bad.
- **Include concrete details:** exact commands, config paths, version
  numbers, reasoning.

### What to observe

- How systems work and why they're set up that way
- Troubleshooting procedures and gotchas
- Configuration details and decision rationale
- Setup procedures and runbooks
- Infrastructure topology and dependencies

Don't observe ephemeral state ("the NAS is down right now") or things
already captured in the wiki.

## Script reference

| Script | Purpose |
|---|---|
| `search "<query>"` | Search wiki pages and inbox |
| `toc [--depth N] [--tag TAG] [--flat]` | List wiki pages |
| `observe --title "..." --body "..."` | Capture a note to inbox/ |
| `pending [--full] [--count]` | List uncurated inbox items |
| `archive FILENAME [--all]` | Move inbox items to handled/ |
| `init [--path DIR]` | Initialize a content repo |
| `status` | Summary stats |
| `context` | Compact summary |
