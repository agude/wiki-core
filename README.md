# wiki-core

**Wiki-Core** is tooling to run a personal markdown wiki using an LLM for
curation and editing. Scripts, skills, and schemas that operate on a separate
content repo.

## Quick start

```bash
# Clone this repo
git clone https://github.com/agude/wiki-core.git
cd wiki-core

# Initialize a content repo
scripts/init --path ~/my-wiki-content

# Or point at an existing one
export WIKI_CONTENT_DIR=~/my-wiki-content

# Capture something
scripts/observe --title "NAS restart order" --body "Traefik first, then Syncthing, then Plex"

# Search
scripts/search "syncthing"

# List pages
scripts/toc
scripts/toc --tag infrastructure
scripts/toc --depth 2

# Check status
scripts/status
```

## Architecture

Two git repos: this one (infra/tooling) and a content repo (your wiki pages).

```
wiki-core/              # this repo
├── scripts/            # CLI tools
├── skills/             # Claude Code skills
├── tests/              # bats tests
└── .claude/skills      # symlink → skills/

content/                # separate git repo
├── wiki/               # all wiki pages (flat)
├── inbox/              # raw captures, uncurated
└── handled/            # processed inbox items
```

The content repo can live anywhere. Set `WIKI_CONTENT_DIR` to point at it,
or let it default to `./content` within the wiki-core directory.

## Content structure

Wiki pages live in `wiki/`. Subfolders are allowed for grouping, but tags are
the primary organization mechanism.

```yaml
---
title: Sync Topology
tags: [infrastructure, nas, syncthing, backup]
created: 2026-04-12
updated: 2026-04-12
---

# Sync Topology

Standard markdown content. Links use [normal syntax](other-page.md).
```

## Scripts

| Script | Purpose |
|---|---|
| `init [--path DIR]` | Initialize a content repo |
| `observe --title "..." --body "..."` | Capture a note to inbox/ |
| `pending [--full] [--count]` | List uncurated inbox items |
| `archive FILENAME [--all]` | Move inbox items to handled/ |
| `search "<query>"` | Search wiki pages and inbox |
| `toc [--depth N] [--tag TAG] [--flat]` | List pages with titles and tags |
| `status` | Summary stats |
| `context` | Compact summary for session injection |
| `session-start` | SessionStart hook for Claude Code |

All scripts support `--help`.

## Capture → curate pipeline

1. **Capture.** Call `scripts/observe` during a session (or just create a
   markdown file in `inbox/`). Observations are timestamped and auto-committed.

2. **Curate.** Review inbox items and merge them into wiki pages. The
   `write-wiki` Claude skill handles this, or do it manually.

3. **Archive.** Processed items move from `inbox/` to `handled/` for
   provenance. Never delete inbox items.

## Claude Code integration

### Skills

| Skill | Scope | Purpose |
|---|---|---|
| `wiki` | Project | Search, browse, observe |
| `write-wiki` | Project | Create/edit pages, curate inbox |
| `wiki-observe` | Global | Capture observations from any session |

Project skills activate when Claude is working in this repo. The global
`wiki-observe` skill is symlinked to `~/.claude/skills/` by the dotfiles
installer, making it available from any session.

### Session hook

`scripts/session-start` is a [coat-tree][ct] hook that injects `CLAUDE.md`
into Claude's context at session start. Install it by symlinking into the
coat-tree hooks directory (the dotfiles installer handles this).

[ct]: https://github.com/agude/dotfiles/tree/main/llm/coat-tree

## Testing

```bash
bats tests/
```

Tests run in CI via GitHub Actions on push and PR to main.
