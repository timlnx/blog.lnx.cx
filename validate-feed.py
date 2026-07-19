#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
# SPDX-License-Identifier: MIT

"""Validate the generated Atom feed against RFC 4287.

Checks well-formedness, the elements RFC 4287 marks as required, RFC 3339 date
syntax, identifier uniqueness, and the invariant that the feed's own <updated>
is the newest timestamp among the entries it carries -- not the build time.

With --baseline, also diffs entry identity against a previously captured feed,
which is what catches a regression in the generator: if an <id> or <published>
shifts by a byte, every reader marks every entry unread again.

Requires lxml (installed in blogenv/).
"""

import argparse
import sys
from datetime import datetime
from pathlib import Path

try:
    from lxml import etree
except ImportError:
    sys.exit("lxml is not installed. Try: blogenv/bin/pip install lxml")

ATOM = "http://www.w3.org/2005/Atom"
NS = {"atom": ATOM}

# RFC 4287 4.1.1 (feed) and 4.1.2 (entry): elements a conforming document MUST
# contain exactly one of.
REQUIRED_FEED = ("id", "title", "updated")
REQUIRED_ENTRY = ("id", "title", "updated")


class Report:
    """Collects failures so one run reports every problem, not just the first."""

    def __init__(self):
        self.errors = []
        self.checks = 0

    def check(self, ok, message):
        self.checks += 1
        if not ok:
            self.errors.append(message)
        return ok

    @property
    def ok(self):
        return not self.errors


def parse_rfc3339(value):
    """Return a datetime, or None if the value is not an RFC 3339 timestamp."""
    try:
        parsed = datetime.fromisoformat(value)
    except (ValueError, TypeError):
        return None
    # RFC 4287 requires a timezone offset; a naive datetime means none was given.
    return parsed if parsed.tzinfo is not None else None


def text_of(element, name):
    found = element.find(f"atom:{name}", NS)
    return None if found is None else (found.text or "")


def validate(path, report):
    try:
        tree = etree.parse(str(path))
    except etree.XMLSyntaxError as exc:
        report.check(False, f"not well-formed XML: {exc}")
        return None

    root = tree.getroot()
    if not report.check(
        root.tag == f"{{{ATOM}}}feed",
        f"root element is {root.tag}, expected an Atom <feed>",
    ):
        return None

    for name in REQUIRED_FEED:
        report.check(
            len(root.findall(f"atom:{name}", NS)) == 1,
            f"feed must contain exactly one <{name}> (RFC 4287 4.1.1)",
        )

    entries = root.findall("atom:entry", NS)
    report.check(len(entries) > 0, "feed contains no entries")

    seen_ids = set()
    entry_stamps = []

    for index, entry in enumerate(entries, start=1):
        label = text_of(entry, "id") or f"entry #{index}"

        for name in REQUIRED_ENTRY:
            report.check(
                len(entry.findall(f"atom:{name}", NS)) == 1,
                f"{label}: must contain exactly one <{name}> (RFC 4287 4.1.2)",
            )

        entry_id = text_of(entry, "id")
        if entry_id is not None:
            report.check(
                "://" in entry_id,
                f"{label}: <id> must be an absolute IRI (RFC 4287 4.2.6)",
            )
            report.check(entry_id not in seen_ids, f"{label}: duplicate <id>")
            seen_ids.add(entry_id)

        for name in ("updated", "published"):
            raw = text_of(entry, name)
            if raw is None:
                continue
            stamp = parse_rfc3339(raw)
            report.check(stamp is not None, f"{label}: <{name}> is not RFC 3339: {raw!r}")
            if stamp and name == "updated":
                entry_stamps.append(stamp)

        published = parse_rfc3339(text_of(entry, "published") or "")
        updated = parse_rfc3339(text_of(entry, "updated") or "")
        if published and updated:
            report.check(
                updated >= published,
                f"{label}: <updated> precedes <published>",
            )

    feed_updated = parse_rfc3339(text_of(root, "updated") or "")
    report.check(feed_updated is not None, "feed <updated> is not RFC 3339")

    if feed_updated and entry_stamps:
        newest = max(entry_stamps)
        report.check(
            feed_updated == newest,
            f"feed <updated> is {feed_updated.isoformat()} but the newest entry "
            f"is {newest.isoformat()} -- the feed claims a change it did not make",
        )

    return tree


def compare(tree, baseline_path, report):
    """Entry identity must survive a generator change, or readers re-notify."""
    try:
        baseline = etree.parse(str(baseline_path))
    except (OSError, etree.XMLSyntaxError) as exc:
        report.check(False, f"cannot read baseline {baseline_path}: {exc}")
        return

    def identity(doc):
        return {
            (entry.findtext("atom:id", None, NS)): entry.findtext("atom:published", None, NS)
            for entry in doc.getroot().findall("atom:entry", NS)
        }

    now, before = identity(tree), identity(baseline)

    for missing in sorted(set(before) - set(now)):
        report.check(False, f"entry dropped since baseline: {missing}")
    for added in sorted(set(now) - set(before)):
        report.check(False, f"entry appeared since baseline: {added}")
    for entry_id in sorted(set(now) & set(before)):
        report.check(
            now[entry_id] == before[entry_id],
            f"<published> changed for {entry_id}: {before[entry_id]} -> {now[entry_id]}",
        )


def main():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "feed",
        nargs="?",
        default="_site/feed.xml",
        type=Path,
        help="path to the Atom feed (default: _site/feed.xml)",
    )
    parser.add_argument(
        "--baseline",
        type=Path,
        metavar="FEED",
        help="compare entry ids and publish dates against this previously captured feed",
    )
    parser.add_argument(
        "-q",
        "--quiet",
        action="store_true",
        help="only report failures",
    )
    args = parser.parse_args()

    if not args.feed.is_file():
        sys.exit(f"no such feed: {args.feed}")

    report = Report()
    tree = validate(args.feed, report)
    if tree is not None and args.baseline:
        compare(tree, args.baseline, report)

    if report.ok:
        if not args.quiet:
            print(f"{args.feed}: OK ({report.checks} checks)")
        return 0

    print(f"{args.feed}: FAILED ({len(report.errors)} of {report.checks} checks)")
    for error in report.errors:
        print(f"  - {error}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
