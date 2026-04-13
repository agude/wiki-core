---
name: write-wiki
description: Write or edit wiki pages directly. Use when the user asks to create a new page, update an existing page, or convert notes/brainstorms into wiki content.
user-invocable: true
---

# Wiki Writer

You are writing content for a personal wiki. The audience is the user —
write clearly, directly, and for future reference.

## Workflow

1. Run `scripts/toc` to see existing pages and tags.
2. If editing, read the existing page first.
3. If the user provided source material (brainstorm doc, notes, CLAUDE.md
   sections), read it and extract the durable knowledge.
4. Write or edit the page in `content/wiki/`.
5. Commit when done.

## Creating a new page

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

Set `created` and `updated` to today's date.

## Page structure

- **H1** — Page title. One per file. Matches the `title` frontmatter.
- **H2** — Primary content sections. Each should stand alone as a
  reference unit.
- **H3+** — Supporting detail within a section.

## Voice

- Clear, direct, reference-style. No filler.
- Include commands, config, code, or examples where they make content
  actionable.
- Strip session-specific framing ("We discovered that...", "I learned...").
  Keep the durable fact.
- Preserve *why* and *context* — not just what, but the reasoning behind
  decisions.
- Use present tense for current state ("The NAS runs Syncthing"), past
  tense for history ("Switched from rsync in 2024 after...").

## Links

Standard markdown only. No `[[wikilinks]]`.

- Between wiki pages: `[Sync Topology](sync-topology.md)`
- External: `[Syncthing docs](https://docs.syncthing.net/)`

Check `scripts/toc` for existing page filenames when linking.

## Tags

Tags are the primary discovery mechanism. Lowercase, hyphenated where
needed. A page can have multiple tags.

Common dimensions:

- Domain: `infrastructure`, `networking`, `backup`, `media`
- System: `nas`, `syncthing`, `docker`, `plex`
- Type: `runbook`, `reference`, `decision-log`

Reuse existing tags where possible — check `scripts/toc` output.

## Granularity

- One topic per page. If a page covers two distinct systems, split it.
- Keep H2 sections short enough to scan. If one grows past ~50 lines,
  consider splitting into multiple H2s or promoting to its own page.
- Prefer many small pages over few large ones.

## Converting source material

When the user provides brainstorm docs, notes, or CLAUDE.md sections:

- Extract the durable knowledge. Drop ephemeral discussion, open
  questions that have been resolved, and planning artifacts.
- Reorganize for reference use. A brainstorm flows as a conversation;
  a wiki page is structured for lookup.
- Preserve decision rationale. "We chose X because Y" is high-value
  wiki content.
- Split into multiple pages if the source covers distinct topics.

## Committing

After writing, commit in the content repo:

```bash
cd content/
git add wiki/
git commit -m "Add: <page title>"
```

For edits to existing pages:

```bash
git commit -m "Update: <page title> — <what changed>"
```
