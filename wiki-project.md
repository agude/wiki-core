# Personal Wiki

## Why

JD files *artifacts* (PDFs, records). The KB teaches *Claude*. Neither
stores *what you know about how things work and why* — sync topology,
NAS setup, decision history, runbooks. That knowledge lives in your head
or in one-off brainstorm docs that you won't find in six months.

Rule of thumb for what goes where:

| Question | System |
|----------|--------|
| Is it a *thing* (document, file, record)? | JD |
| Does Claude need to *know* it? | KB |
| Do *you* need to *find* it in six months? | Wiki |

## Architecture: Three Independent Layers

Same decomposition the KB needs, plus a render layer:

```
[infra repo]     scripts, curation tools, schemas
     |
[content repo]   the actual pages, inbox
     |
[render layer]   Jekyll, GitHub, whatever
```

Each layer is replaceable without touching the others.

### Content Layer

- Pure standard markdown. No `[[wikilinks]]`, no renderer-specific syntax.
- YAML frontmatter for metadata.
- Standard `[text](path.md)` links.
- Compatible with GitHub's markdown renderer, any SSG, any editor.
- Git repo on the NAS. Accessible from every machine via existing
  CIFS/SMB mounts. Edit from anywhere.

### Infra Layer

- Observe → inbox → curate pipeline (same shape as the KB).
- `wiki-observe` command for capturing knowledge from Claude sessions.
- Curation: hybrid model — Claude drafts merges, you review.
- Separate repo from content so the tooling can be shared or cloned
  independently.

### Render Layer

Requirement: off-the-shelf SSG, no custom rendering code to maintain.

**Rejected:**
- **Quartz** — Fork-and-modify model. Content lives inside Quartz's repo.
  Upstream updates require merging main. Violates the layer separation.
- **MkDocs** — Governance crisis (Apr 2026). Three-way schism between
  original author (non-open 2.0), Material theme fork (pre-1.0), and
  previous maintainer's fork (~30 stars). Don't bet on any of them now.

**Chosen: Jekyll.**
- Clean separation: content + config in your repo, Jekyll as a library.
- You already know it from alexgude.com.
- Stable, boring, maintained.
- Not branded as a "wiki" but a wiki is just interlinked pages with
  navigation.

**Render layer progression:**
1. **Day one: GitHub.** Push to GitHub, it's already browsable. Zero
   build step, zero hosting.
2. **Soon: Jekyll on the NAS.** Container (nginx) serving the built
   site. LAN-only, private. Another service in the NAS docker-compose.
   Accessible at something like `nas-ip:8081`.
3. **Both.** GitHub as the public/shareable subset (or just the git
   remote). NAS as the full private wiki.

## Filesystem Structure

Two git repos: infra (the tooling) and content (the pages).

```
wiki/                               # infra repo (git repo #1)
├── .gitignore                      # ignores content/
├── CLAUDE.md                       # how the wiki works, for Claude
├── scripts/
│   ├── observe                     # capture a note → content/inbox/
│   ├── curate                      # process inbox → content/wiki/
│   ├── search                      # search across content/wiki/
│   ├── pending                     # list uncurated observations
│   └── ...
├── .claude/
│   └── skills/
│       └── wiki/
│           └── SKILL.md            # project-level skill (rich)
└── content/                        # content repo (git repo #2)
    ├── inbox/                      # raw captures, uncurated
    ├── handled/                    # processed items (provenance)
    └── wiki/                       # the wiki. all pages live here.
        └── index.md                # top-level map
```

**Inbox is content.** Observations are your notes about your stuff.
They travel with the content repo, not the tooling. Different machine,
different content repo, different inbox.

**`wiki/` is the wiki.** A flat folder of markdown files. No
subfolders. Every `.md` file in `wiki/` is a wiki page. Unique
filenames required (slug-style: `sync-topology.md`,
`nas-container-inventory.md`).

Organization is via frontmatter, not folders:

```yaml
---
title: Sync Topology
tags: [infrastructure, nas, syncthing, backup]
created: 2026-04-12
updated: 2026-04-12
---
```

The infra scripts find pages by recursively searching for `*.md` in
`wiki/` and reading frontmatter. Tags are the primary discovery
mechanism — `search` matches against title, tags, and body text.

This means:
- No folder hierarchy to maintain or debate.
- Tags are flexible and multi-dimensional (a page can be both
  "infrastructure" and "backup").
- Adding a page is: create a file, add frontmatter, write.
- The render layer (Jekyll, GitHub) gets tags for free from frontmatter.

**OPEN QUESTION: Subfolders and link resolution.**

For now: flat structure, standard markdown links (`[text](page.md)`).
Simple, works everywhere including GitHub.

If the folder grows unwieldy later, options include:
- Allow subfolders, links stay filename-only, tooling resolves paths
  (relink script and/or Jekyll plugin).
- This is effectively wikilink semantics in standard markdown syntax.

Decide when there's enough content to feel the pain.

`inbox/` and `handled/` are siblings of `wiki/`, not inside it.
They're operational (pipeline state), not wiki pages. The curation
step moves things *from* inbox *into* wiki.

**Skills — two levels:**
- **Project-level** (`.claude/skills/wiki/` in the repo): Rich skill
  for working inside the wiki — search, curate, manage structure.
  Activates when Claude is in the wiki directory.
- **Global** (`~/.claude/skills/wiki-observe/` or similar): Thin skill
  that just calls `wiki/scripts/observe`. Lets you capture observations
  from *any* session — you're working in ~/Projects/foo and something
  wiki-worthy comes up.

Content structure is flat-ish. Don't over-categorize up front. Folders
are a rough first sort, not a rigid taxonomy.

## Capture and Ingestion

### From Claude sessions

The big one. A `wiki-observe` command (analogous to KB's `observe`) that
captures notes into inbox/. Claude calls it during conversations when
institutional knowledge surfaces. Same discipline as KB observations:
capture immediately, curate later.

### Manual

Open a markdown file and write. Any editor. The "I just figured something
out" path.

### From existing sources

One-time imports to seed the wiki: this brainstorm doc, the
pi-cron-automation CLAUDE.md, the sync topology we worked out.

## Curation

**Hybrid model.** Claude drafts merges into wiki pages (combines inbox
items with existing pages, adds links, creates new pages). You review
and approve. Claude does the tedious merging, you keep editorial control.

The KB can be fully automated because the audience is an LLM. Wiki
content is *yours* — you control the voice and structure.

## Relationship to the KB

Separate repos, cross-referenced. The KB can reference wiki pages. The
wiki can reference KB articles. But they serve different audiences.

The KB could ingest wiki pages as a source (like it ingests external
docs into sources/). You write the wiki for yourself; the KB curation
agent pulls relevant facts for Claude.

Shared infra is a "notice the similarity, keep the door open"
observation. Start with two independent repos that follow the same
conventions. Merge shared tooling later only if duplication hurts.

## Implementation Path

1. Create the content repo on the NAS. Minimal structure (inbox/, a few
   topic folders, index.md).
2. Seed it: convert brainstorm sync topology and NAS sections into wiki
   pages.
3. Push to GitHub — immediate free rendering.
4. Build `wiki-observe` script (or Claude skill) for session capture.
5. Jekyll container on the NAS for LAN-accessible rendering.
6. Curation tooling once there's enough content to curate.

Steps 1-3 are an afternoon. Step 4 is a small project. Steps 5-6 come
later.

## Example Wiki Content

Things that would go in the wiki today based on this brainstorm session:

- Sync topology: which machines, which methods, which data
- NAS container inventory: what's running, how it's managed
- Syncthing share inventory: what each share contains, its backup status
- ScanSnap pipeline: how scans flow from scanner to inbox to filed
- Kids' PC setup: Orange/Blue, Synology Drive config, account structure
- Backup strategy: NAS → Backblaze (real), NAS → Google Drive (access)
