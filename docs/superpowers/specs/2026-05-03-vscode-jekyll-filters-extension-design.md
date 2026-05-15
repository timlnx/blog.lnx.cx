# VS Code Jekyll Filter Extension — Design Spec

**Date:** 2026-05-03
**Status:** Approved

## Overview

A local VS Code extension that makes inserting Jekyll Liquid filter calls into blog posts nearly effortless. Targets the four custom filters in `_plugins/anchor_filter.rb` — three existing, one new. The goal is zero thought during writing: keybinds for anchor insertion, a guided Quick Pick for cross-post references.

## New Ruby Filter

Add `blog_cross_link` to `_plugins/anchor_filter.rb`:

```ruby
def blog_cross_link(input, post_url, display_text=nil)
  link_text = display_text ? display_text : input
  anchor_id = self.normalize(input)
  "<a href='#{post_url}##{anchor_id}'>#{link_text}</a>"
end
```

Usage in posts:
```liquid
{{ "New Fences" | blog_cross_link: "/2025/07/04/hiking-the-chicago-outer-belt-map-27-correction/" }}
{{ "New Fences" | blog_cross_link: "/2025/07/04/hiking-the-chicago-outer-belt-map-27-correction/", "the fence situation" }}
```

## Extension

### Location & Distribution

Lives at `vscode-extension/` in the repo. Local-only — never published to the marketplace. Build and install via `vscode-extension/install.sh`. No CI, no versioning ceremony.

### Source Files

| File | Responsibility |
|---|---|
| `src/extension.ts` | Activate/deactivate — wires post index, commands, and completions together |
| `src/postIndex.ts` | Scans `_posts/`, parses anchors, builds in-memory index, watches for changes |
| `src/commands.ts` | Implements all four insert/wrap commands |
| `src/completions.ts` | IntelliSense completion provider |

### Commands & Keybindings

All commands are scoped to `.markdown` and `.md` files.

| Command ID | Behavior | Keybind |
|---|---|---|
| `blog-filters.wrapAnchor` | Wraps selection → `{{ "text" \| blog_anchor }}` | `Cmd+Shift+1` |
| `blog-filters.wrapAnchor2` | Wraps selection → `{{ "text" \| blog_anchor2 }}` | `Cmd+Shift+2` |
| `blog-filters.wrapAnchorLink` | Wraps selection, optional display text prompt → `blog_anchor_link` | `Cmd+Shift+L` |
| `blog-filters.insertCrossLink` | 3-step Quick Pick → `blog_cross_link` | `Cmd+Shift+X` |

If nothing is selected when running `wrapAnchor` or `wrapAnchor2`, the cursor lands inside the quotes ready to type.

For `wrapAnchorLink`: if text is selected, it uses that as the anchor title and then prompts for optional display text. If nothing is selected, it prompts for the anchor title first, then display text. Pressing Enter with nothing on the display text prompt uses the anchor title as the link text.

For `insertCrossLink`, the 3-step Quick Pick (post → header → optional display text) handles all input — no selection needed.

### Post Index (`src/postIndex.ts`)

- Builds asynchronously on extension activation — never blocks VS Code startup
- Scans `_posts/` for `.markdown` and `.md` files
- Derives post URL from filename: `YYYY-MM-DD-slug.markdown` → `/YYYY/MM/DD/slug/`
- Extracts anchor titles via regex on `blog_anchor` and `blog_anchor2` filter calls
- Derives anchor IDs using the same normalization as the Ruby filter: lowercase, spaces → hyphens, strip non-alphanumeric
- Quick Pick list sorted newest-first, date shown as secondary label, H1/H2 level shown per section
- File watcher on `_posts/` rebuilds index automatically on any add/edit/delete — no window reload needed

### IntelliSense Completions (`src/completions.ts`)

Trigger character: `"` after `{{ `. Activates in `.markdown` and `.md` files.

| Completion label | Behavior |
|---|---|
| `blog_anchor` | Inserts snippet, cursor on title placeholder |
| `blog_anchor2` | Inserts snippet, cursor on title placeholder |
| `blog_anchor_link` | Inserts snippet, cursor on title placeholder |
| `blog_anchor_link (custom text)` | Inserts snippet with two tab stops: title, then link text |
| `blog_cross_link` | Fires the 3-step Quick Pick flow (needs post index — no raw snippet) |

### install.sh

`vscode-extension/install.sh` handles the full build-and-install sequence:
- Runs `npm install`
- Runs `vsce package`
- Installs the resulting `.vsix` via `code --install-extension`
- Includes `-h/--help` and rejects unexpected args per project convention

## Files Changed

- `_plugins/anchor_filter.rb` — add `blog_cross_link` filter
- `vscode-extension/` — new directory, full extension source
- `vscode-extension/install.sh` — build and install script
- `.gitignore` — already updated with `.superpowers/`
