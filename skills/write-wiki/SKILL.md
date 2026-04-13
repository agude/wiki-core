---
name: write-wiki
description: >-
  Write, edit, and curate wiki pages. Use when the user asks to create a
  page, update an existing page, convert notes into wiki content, or
  process pending inbox items into the wiki.
user-invocable: true
allowed-tools:
  - "Bash(${CLAUDE_SKILL_DIR}/../scripts/*)"
---

# Wiki Writer

You are writing content for a personal wiki. The audience is the user —
write clearly, directly, and for future reference.

## Choosing a workflow

**Direct writing** — the user asks you to create or edit a page, or hands
you source material (brainstorm doc, notes, CLAUDE.md sections) to convert.
Go to the Direct Writing section.

**Inbox curation** — the user asks you to process the inbox, or you are
invoked with no specific topic. Go to the Inbox Curation section.

Both workflows produce the same output: wiki pages in `content/wiki/`
following the conventions below.

## Direct writing

1. Run `${CLAUDE_SKILL_DIR}/../scripts/toc` to see existing pages and tags.
2. If editing, read the existing page first.
3. If the user provided source material, read it and extract the durable
   knowledge.
4. Write or edit the page in `content/wiki/`.
5. Commit when done.

### Converting source material

When the user provides brainstorm docs, notes, or CLAUDE.md sections:

- Extract the durable knowledge. Drop ephemeral discussion, resolved
  questions, and planning artifacts.
- Reorganize for reference use. A brainstorm flows as a conversation;
  a wiki page is structured for lookup.
- Preserve decision rationale. "We chose X because Y" is high-value
  wiki content.
- Split into multiple pages if the source covers distinct topics.

## Inbox curation

1. Run `${CLAUDE_SKILL_DIR}/../scripts/pending --full` to read all inbox items.
2. Run `${CLAUDE_SKILL_DIR}/../scripts/toc` to see the current wiki pages and tags.
3. For each inbox item, decide:
   - **Add to existing page** — fits an existing topic. Add as a new H2
     or extend an existing section. Read the page first.
   - **Create new page** — no existing home. Create a new file.
   - **Merge items** — multiple items on the same topic. Synthesize into
     one coherent addition.
   - **Discard** (rare) — purely ephemeral or exact duplicate.
4. Edit wiki pages directly under `content/wiki/`.
5. Archive each processed item: `${CLAUDE_SKILL_DIR}/../scripts/archive FILENAME`. Archive
   discarded items too — never delete inbox items.
6. Commit all changes as a single batch.

If there are no pending items, stop.

## Page conventions

### Creating a new page

File goes in `content/wiki/`. Slug-style filename: `sync-topology.md`,
`nas-container-inventory.md`.

Every page needs frontmatter:

```yaml
---
title: Sync Topology
tags: [infrastructure, nas, syncthing, backup]
created: 2026-04-12
updated: 2026-04-12
---
```

Set `created` and `updated` to today's date. When editing an existing
page, update `updated` only.

### Structure

- **H1** — Page title. One per file. Matches the `title` frontmatter.
- **H2** — Primary content sections. Each should stand alone as a
  reference unit.
- **H3+** — Supporting detail within a section.

### Voice

- Clear, direct, reference-style. No filler.
- Include commands, config, code, or examples where they make content
  actionable.
- Strip session-specific framing ("We discovered that...", "I learned...").
  Keep the durable fact.
- Preserve *why* and *context* — not just what, but the reasoning behind
  decisions.
- Use present tense for current state ("The NAS runs Syncthing"), past
  tense for history ("Switched from rsync in 2024 after...").

### Links

Standard markdown only. No `[[wikilinks]]`.

- Between wiki pages: `[Sync Topology](sync-topology.md)`
- External: `[Syncthing docs](https://docs.syncthing.net/)`

Check `${CLAUDE_SKILL_DIR}/../scripts/toc` for existing page filenames when linking.

### Tags

Tags are the primary discovery mechanism. Lowercase, hyphenated where
needed. A page can have multiple tags.

Common dimensions:

- Domain: `infrastructure`, `networking`, `backup`, `media`
- System: `nas`, `syncthing`, `docker`, `plex`
- Type: `runbook`, `reference`, `decision-log`

Reuse existing tags where possible — check `${CLAUDE_SKILL_DIR}/../scripts/toc` output.

### Granularity

- One topic per page. If a page covers two distinct systems, split it.
- Keep H2 sections short enough to scan. If one grows past ~50 lines,
  consider splitting into multiple H2s or promoting to its own page.
- Prefer many small pages over few large ones.

## Committing

For direct writing:

```bash
cd content/
git add wiki/
git commit -m "Add: <page title>"
```

For edits: `git commit -m "Update: <page title> — <what changed>"`

For inbox curation (single batch after all edits and archives):

```bash
cd content/
git add wiki/ inbox/ handled/
git commit -m "Curate: <brief summary of what changed>"
```
