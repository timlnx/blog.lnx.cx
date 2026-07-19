#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
# SPDX-License-Identifier: MIT

"""
new-post.py - Scaffold a new Jekyll _posts/ entry, old-school TUI style.

Prompts for the basic front-matter (title, date, tags, categories, draft),
auto-stubs today's date into both the metadata and the YYYY-MM-DD filename
prefix, slugifies the title (lowercase, hyphen-merged, ASCII), and shows your
most-used tags & categories by frequency so you can tab-complete them.

Line editing is full GNU readline with emacs bindings: M-f / M-b word motion,
M-DEL backward-kill-word, C-y yank, C-a/C-e, history, the works. Tags and
categories are entered one per line (blank line to finish); each line
tab-completes against your existing vocabulary, multi-word tags included.

macOS note: for M-f / M-b to fire in Terminal.app, enable
  Settings -> Profiles -> Keyboard -> "Use Option as Meta key".
iTerm2: Preferences -> Profiles -> Keys -> Left Option key -> Esc+.
"""

import argparse
import re
import sys
import unicodedata
from collections import Counter
from datetime import date as date_cls, datetime
from pathlib import Path
import shutil

# --- Fully-juiced GNU readline (fall back to the stdlib/libedit shim) --------
try:
    import gnureadline as readline           # the real GNU readline, if installed
except ImportError:                          # pragma: no cover - environment dependent
    import readline

USING_LIBEDIT = "libedit" in (getattr(readline, "__doc__", "") or "")


# --- Colors ------------------------------------------------------------------
def make_colors(enabled):
    codes = {
        "RESET": "0", "BOLD": "1", "DIM": "2", "REV": "7",
        "GREEN": "32", "BGREEN": "92", "AMBER": "33", "BAMBER": "93",
        "CYAN": "36", "RED": "31", "GREY": "90",
    }
    ns = type("Palette", (), {})()
    for name, code in codes.items():
        setattr(ns, name, f"\033[{code}m" if enabled else "")
    return ns


# --- readline helpers --------------------------------------------------------
_RL_ESCAPE = re.compile(r"(\033\[[0-9;]*m)")


def rl(prompt):
    """Wrap ANSI codes so readline computes the prompt width correctly."""
    return _RL_ESCAPE.sub("\001\\1\002", prompt)


def setup_readline():
    if USING_LIBEDIT:
        readline.parse_and_bind("bind ^I rl_complete")   # emacs mode is the default
    else:
        readline.parse_and_bind("set editing-mode emacs")
        readline.parse_and_bind("tab: complete")
    # No completion (and no accidental filename completion) unless a prompt opts in.
    readline.set_completer(lambda text, state: None)


def ask(prompt, default=""):
    """input() with a readline-safe colored prompt; empty reply falls back to `default`.

    We show the default as a visible [hint] rather than pre-filling the line
    buffer: buffer pre-fill relies on readline's startup hook, which libedit
    (macOS's default readline) silently ignores.
    """
    reply = input(rl(prompt)).strip()
    return reply if reply else default


def leader(C, label, hint=None):
    """A retro dotted-leader prompt, e.g. ' ▸ Date ...... [2026-07-09] '."""
    dots = "." * max(3, 12 - len(label) - 1)
    s = f"{C.CYAN} ▸ {C.BOLD}{label}{C.RESET} {C.DIM}{dots}{C.RESET}"
    if hint:
        s += f" {C.GREY}[{hint}]{C.RESET}"
    return s + " "


def make_completer(options):
    def completer(text, state):
        stem = text.strip().lower()
        if not stem:                       # never dump the whole vocabulary
            return None
        matches = [o for o in options if o.lower().startswith(stem)]
        return matches[state] if state < len(matches) else None
    return completer


def ask_lines(C, label, vocab, hint):
    """Collect a list one entry per line; blank line (or Ctrl-D) ends it.

    Tab completes the whole line against `vocab`, so multi-word tags like
    'audio technica' complete as a single unit.
    """
    print(f"{C.DIM}{C.GREEN}   {hint}{C.RESET}")
    old_completer = readline.get_completer()
    old_delims = readline.get_completer_delims()
    readline.set_completer(make_completer(vocab))
    readline.set_completer_delims("")      # whole line is one completion token
    out, seen = [], set()
    try:
        while True:
            entry = input(rl(label)).strip()
            if not entry:
                break
            if entry.lower() not in seen:
                seen.add(entry.lower())
                out.append(entry)
    except EOFError:                       # Ctrl-D also finishes the list
        print()
    finally:
        readline.set_completer(old_completer)
        readline.set_completer_delims(old_delims)
    return out


# --- Front-matter scanning ---------------------------------------------------
def scan_frontmatter(posts_dir):
    """Return (tag_counter, category_counter) across every post's front-matter."""
    tags, cats = Counter(), Counter()
    for path in sorted(posts_dir.glob("*.markdown")) + sorted(posts_dir.glob("*.md")):
        try:
            lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
        except OSError:
            continue
        if not lines or lines[0].strip() != "---":
            continue
        key = None
        for line in lines[1:]:
            stripped = line.strip()
            if stripped == "---":
                break
            if stripped.startswith("-"):
                item = stripped[1:].strip().strip("\"'")
                if item and key in ("tags", "categories"):
                    (tags if key == "tags" else cats)[item] += 1
            elif ":" in line and not line[:1].isspace():
                head, _, val = line.partition(":")
                key = head.strip().lower()
                val = val.strip()
                if val.startswith("[") and val.endswith("]") and key in ("tags", "categories"):
                    for item in (x.strip().strip("\"'") for x in val[1:-1].split(",")):
                        if item:
                            (tags if key == "tags" else cats)[item] += 1
                    key = None
            else:
                key = None
    return tags, cats


def freq_panel(C, heading, counter, limit, width):
    print(f"{C.DIM}{C.GREEN}   {heading} by frequency:{C.RESET}")
    items = counter.most_common(limit)
    if not items:
        print(f"{C.DIM}     (none on file yet){C.RESET}")
        return
    cells = [f"{C.BAMBER}{count:>3}{C.DIM}x{C.RESET} {C.GREEN}{name}{C.RESET}" for name, count in items]
    raw_w = max(len(f"{count:>3}x {name}") for name, count in items) + 3
    ncols = max(1, min(3, max(1, width) // raw_w))
    for i in range(0, len(cells), ncols):
        row = cells[i:i + ncols]
        raw_row = [f"{count:>3}x {name}" for name, count in items[i:i + ncols]]
        line = "     "
        for cell, raw_cell in zip(row, raw_row):
            line += cell + " " * (raw_w - len(raw_cell))
        print(line.rstrip())


# --- Rendering ---------------------------------------------------------------
def slugify(text):
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode("ascii")
    return re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")


def yaml_scalar(value):
    """Quote a YAML scalar only when it would otherwise be ambiguous."""
    if value == "" or value[:1] in "-?:,[]{}#&*!|>%@`\"' " or re.search(r":(\s|$)|\s#", value):
        return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'
    return value


def render(post_date, title, tags, cats, draft):
    def block(key, items):
        if not items:
            return f"{key}: []"
        return key + ":\n" + "\n".join(f"- {i}" for i in items)

    return "\n".join([
        "---",
        f"date: {post_date}",
        f"title: {yaml_scalar(title)}",
        block("tags", tags),
        block("categories", cats),
        f"draft: {'true' if draft else 'false'}",
        "author: Tim Case",
        "layout: post",
        "---",
        "",
    ]) + "\n"


# --- UI chrome ---------------------------------------------------------------
def banner(C, post_count):
    inner = 52
    today = date_cls.today().isoformat()
    top = "╔" + "═" * inner + "╗"
    bot = "╚" + "═" * inner + "╝"
    left, right = "  N E W   P O S T", "blog.lnx.cx  "
    mid = "║" + C.BAMBER + left + C.GREEN + " " * (inner - len(left) - len(right)) + right + "║"
    sub = f"  {today}   ·   {post_count} posts on file"
    print(C.BOLD + C.GREEN + top)
    print(mid)
    print(bot + C.RESET)
    print(f"{C.DIM}{C.GREEN}{sub}{C.RESET}\n")


# --- Main --------------------------------------------------------------------
def main():
    here = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(
        prog="new-post",
        description="Scaffold a new Jekyll _posts/ entry with an old-school TUI.",
        epilog=(
            "macOS: enable 'Use Option as Meta key' in your terminal so M-f / M-b "
            "word motion works. Enter tags & categories one per line (blank line to "
            "finish); each line tab-completes against your existing vocabulary."
        ),
    )
    parser.add_argument("title", nargs="*", help="post title (otherwise you'll be prompted)")
    parser.add_argument("--posts-dir", type=Path, default=here / "_posts",
                        help="directory to scan and write into (default: ./_posts next to this script)")
    parser.add_argument("--date", metavar="YYYY-MM-DD", default=None,
                        help="override the post date (default: today)")
    parser.add_argument("--draft", action="store_true", help="mark the post draft: true")
    parser.add_argument("-n", "--dry-run", action="store_true",
                        help="print the rendered post instead of writing it")
    parser.add_argument("--no-color", action="store_true", help="disable ANSI colors")
    parser.add_argument("--top", type=int, default=15, metavar="N",
                        help="how many tags/categories to show by frequency (default: 15)")
    args = parser.parse_args()

    use_color = sys.stdout.isatty() and not args.no_color
    C = make_colors(use_color)
    width = shutil.get_terminal_size((80, 24)).columns

    posts_dir = args.posts_dir
    if not posts_dir.is_dir():
        parser.error(f"posts dir not found: {posts_dir}")

    setup_readline()
    tag_counts, cat_counts = scan_frontmatter(posts_dir)
    post_count = len(list(posts_dir.glob("*.markdown")) + list(posts_dir.glob("*.md")))

    banner(C, post_count)

    try:
        # Title -> slug
        title = " ".join(args.title).strip()
        while not title:
            title = ask(leader(C, "Title")).strip()
        slug = slugify(ask(leader(C, "Slug", slugify(title)), default=slugify(title))) or slugify(title)

        # Date (metadata + filename prefix), today by default
        default_date = args.date or date_cls.today().isoformat()
        while True:
            entered = ask(leader(C, "Date", default_date), default=default_date)
            try:
                datetime.strptime(entered, "%Y-%m-%d")
                post_date = entered
                break
            except ValueError:
                print(f"{C.RED}     not YYYY-MM-DD, try again{C.RESET}")

        # Tags (one per line, blank line ends)
        print(f"\n{C.CYAN} ▸ {C.BOLD}Tags{C.RESET}")
        freq_panel(C, "Tags", tag_counts, args.top, width)
        tags = ask_lines(C, f"{C.CYAN}   tag {C.DIM}▸{C.RESET} ",
                         [t for t, _ in tag_counts.most_common()],
                         "one per line · Tab completes · blank line to finish")

        # Categories (one per line, blank line ends)
        print(f"\n{C.CYAN} ▸ {C.BOLD}Categories{C.RESET}")
        freq_panel(C, "Categories", cat_counts, args.top, width)
        cats = ask_lines(C, f"{C.CYAN}   cat {C.DIM}▸{C.RESET} ",
                         [c for c, _ in cat_counts.most_common()],
                         "one per line · Tab completes · blank line to finish")

        # Draft
        default_draft = "y" if args.draft else "n"
        answer = ask(leader(C, "Draft?", "y/N"), default=default_draft).lower()
        draft = answer.startswith("y")
    except (EOFError, KeyboardInterrupt):
        print(f"\n{C.RED}aborted.{C.RESET}")
        return 130

    content = render(post_date, title, tags, cats, draft)
    filename = f"{post_date}-{slug}.markdown"
    target = posts_dir / filename

    if args.dry_run:
        print(f"\n{C.DIM}{C.GREEN}── would write {target} ──{C.RESET}")
        print(content, end="")
        return 0

    if target.exists():
        overwrite = ask(f"{C.RED} ! {filename} exists. Overwrite? [y/N] {C.RESET}").strip().lower()
        if not overwrite.startswith("y"):
            print(f"{C.RED}aborted.{C.RESET}")
            return 1

    target.write_text(content, encoding="utf-8")

    line = "─" * min(52, max(20, width - 2))
    print(f"\n{C.GREEN}{line}{C.RESET}")
    print(f"{C.BGREEN} ✓ wrote{C.RESET} {C.BAMBER}{target}{C.RESET}")
    print(f"{C.GREEN}{line}{C.RESET}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
