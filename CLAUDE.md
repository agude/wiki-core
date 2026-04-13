# Wiki

A personal wiki engine. Infra repo (scripts, skills, schemas) that operates
on a separate content repo.

## Architecture

```
wiki-core/              # this repo (infra)
├── scripts/            # CLI tools
├── tests/              # bats tests
├── skills/             # Claude skills (symlinked from .claude/skills)
└── .claude/skills/     # symlink to skills/

content/                # separate git repo (or WIKI_CONTENT_DIR)
├── wiki/               # all wiki pages (flat, one .md per page)
├── inbox/              # raw captures, uncurated
└── handled/            # processed inbox items (provenance)
```

## Content structure

Wiki pages live in `wiki/`. Flat folder, no subfolders. Organization is via
frontmatter tags, not directory hierarchy.

```yaml
---
title: Sync Topology
tags: [infrastructure, nas, syncthing, backup]
created: 2026-04-12
updated: 2026-04-12
---
```

Standard markdown. No `[[wikilinks]]`. Use `[text](page.md)` links.

## Scripts

All paths are `scripts/<name>`.

| Script | Purpose |
|---|---|
| `search "<query>"` | Search wiki pages and inbox |
| `toc [--depth N] [--tag TAG] [--flat]` | List wiki pages with titles and tags |
| `observe --title "..." --body "..."` | Capture a note to inbox/ |
| `pending [--full] [--count]` | List uncurated inbox items |
| `archive FILENAME [--all]` | Move inbox items to handled/ |
| `init [--path DIR]` | Initialize a content repo |
| `status` | Summary stats |
| `context` | Compact summary for session injection |

## Environment variables

| Variable | Purpose |
|---|---|
| `WIKI_CONTENT_DIR` | Override content directory (default: `./content`) |
| `WIKI_OBSERVE` | Set to `1` to enable observation capture |

## Observations

When wiki-worthy knowledge surfaces during a session, capture it:

```
scripts/observe --title "<summary>" --body "<details>"
```

Only writes if `WIKI_OBSERVE=1`. Capture immediately, curate later.

## Rules

- **Use scripts, not direct file I/O**, for inbox operations.
- Wiki pages under `wiki/` can be read and edited directly.
- The write-wiki skill drafts changes; the user reviews and approves.

## Testing

Tests use [bats](https://github.com/bats-core/bats-core). Run:

```bash
bats tests/
```
