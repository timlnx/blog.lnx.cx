# PRD: Wayback Archive Update Pipeline

**Status:** Draft for review
**Date:** 2026-07-07
**Supersedes:** `archive-update.txt` (original notes, kept as the source of intent)

## 1. Summary

After `blog-poll.sh` detects new commits and rebuilds/deploys the site, submit
**only the pages whose source content actually changed** to the Internet Archive
Wayback Machine, so recent posts and edits get re-captured promptly instead of
waiting for the Archive's own crawler.

Submissions use the **anonymous** Save Page Now endpoint (no account credentials
on the server), select **at most 3 URLs per run** in a defined priority order,
and are strictly best-effort: the archive step can never fail or delay the deploy
in a way that matters.

## 2. Context and environment

- **Host:** `blog.lnx.cx`, Fedora Linux server.
- **Trigger:** existing `blog-builder` systemd timer runs `blog-poll.sh` every 5
  minutes as the blog user (rootless podman).
- **Pipeline today:** `blog-poll.sh` fetches `origin/main`; if `HEAD` moved (or
  `-f`), it pulls, rebuilds the site in a container, and rsyncs `_site` to the
  Apache docroot. It already computes `LOCAL` (pre-pull `HEAD`) and `HEAD`
  (post-pull) — i.e. the exact commit range that landed this round.
- **Permalinks:** `_config.yml` sets `permalink: /:year/:month/:day/:title:output_ext`
  for posts; sub-pages (`audio.markdown`, `pgp.md`, `about.markdown`,
  `socials.md`, `projects.md`, `carl.markdown`, `galleries/index.html`) each
  declare an explicit `permalink:` in front matter; `index.markdown` is the site
  root (`/`). Rather than re-derive any of this in the script, we have Jekyll emit
  the authoritative source→URL mapping at build time (see §6).
- **Custom plugins:** the build already loads custom Ruby plugins from `_plugins/`
  (e.g. `anchor_filter.rb`) with no safe mode, so adding a generator plugin is a
  second file in an existing directory, not new infrastructure.

## 3. Key insight: diff the source, never the rendered HTML

The blog footer prints a "last built on" date, so **every** rendered page in
`_site` changes on every build even when its body did not. Diffing built HTML
would therefore flag everything, every time.

The fix: determine what changed by **git-diffing the Markdown/HTML source** over
the `LOCAL..HEAD` range. A post or page source file only appears in that diff
when it was actually edited. This single decision makes the footer caveat
disappear and makes the priority tiers fall directly out of
`git diff --name-status`.

A corollary: changes to **layouts, includes, `_sass`, `_config.yml`, assets, and
tooling are ignored** — they rebuild many pages but publish to no single page
URL. We get this filtering for free: such paths are absent from the build
manifest (§6), so "not in the manifest" simply means "not a page, ignore it" — no
hand-kept ignore-list to maintain. This is the "last built on" scenario
generalized, and the correct response is to submit nothing.

## 4. Non-goals

- No authenticated Save Page Now / no Archive.org S3 keys on the server.
- No "come back later" queue. URLs beyond the top 3 in a run are dropped and
  forgotten (per the original spec).
- No cross-run memory of what was submitted; each run considers only its own
  `LOCAL..HEAD` range.
- No polling of Save Page Now job status.
- No submissions for layout/include/config/asset/tooling changes.
- No body-vs-front-matter distinction (see §11, Decision 1).

## 5. Architecture (Approach A)

Two components:

1. **`_plugins/url_manifest.rb`** — a Jekyll generator that, at build time, writes
   `.url-manifest.json` (an authoritative source-path → published-URL map) into
   the site output. This is the URL-resolution oracle (§6).
2. **`archive-update.sh`** — a standalone script that owns all archive logic and
   consumes the manifest.

**Two inputs, two questions.** The script needs both a git range *and* the
manifest because they answer different questions — neither can do the other's job.
The manifest is a full snapshot of every page on the site, not a diff, so it has
no notion of what changed this round; git knows what changed but not where it
publishes.

| Input | Answers |
|-------|---------|
| `git diff <old-ref> <new-ref>` | **Which** source paths changed, and how (`A`/`M`/`D`) |
| `.url-manifest.json` | Given a path, **what URL** it publishes to — and whether it is a page at all |

(Manifest-diffing can't substitute for git: an *edited* post keeps the same URL,
so comparing two builds' manifests would miss the most common case — a body edit
to an existing post. Only git sees content edits.)

`blog-poll.sh` gains exactly one line, at the very end, after a successful deploy:

```sh
/usr/local/bin/archive-update.sh "$LOCAL" "$HEAD" "$OUTPUT_DIR/.url-manifest.json" || true
```

The `|| true` guarantees the archive step can never change the outcome of a
deploy. `archive-update.sh` is installed to `/usr/local/bin/` by the Ansible
playbook, exactly like `blog-poll.sh` already is.

**Data flow:**

```
blog-poll.sh (deploy succeeds)
   └─> archive-update.sh LOCAL HEAD MANIFEST
         1. git diff --name-status LOCAL HEAD   (in the repo checkout)
         2. classify changed source files into priority tiers
         3. resolve each via the build manifest (§6);
            paths absent from the manifest are not pages -> dropped
         4. order by tier, take first 3
         5. rate-limit guard (state-file mtime)
         6. submit via anonymous Save Page Now (best-effort)
```

**Separation of concerns:** the script is testable in isolation — hand it any two
git refs and (with `--dry-run`) it prints the URLs it *would* submit without
touching the network or the state file.

## 6. URL resolution via the build manifest

URL resolution is delegated to Jekyll, which already computes every page's final
URL, rather than re-derived in shell. The `_plugins/url_manifest.rb` generator
writes a JSON manifest into the site output on every build:

```json
{
  "site_url": "https://blog.lnx.cx",
  "generated_by": "_plugins/url_manifest.rb",
  "pages": {
    "_posts/2026-06-26-archive.org-THC-collection.markdown": "https://blog.lnx.cx/2026/06/26/archive.org-THC-collection.html",
    "audio.markdown": "https://blog.lnx.cx/audio/",
    "index.markdown": "https://blog.lnx.cx/"
  }
}
```

The generator walks `site.collections` (covers `_posts` today and any future
collection) and `site.pages`, keying each entry by its **source path relative to
the repo root** — the exact form `git diff --name-status` emits — and storing the
**absolute** published URL. Paths with no real source (e.g. plugin-synthesized
feeds) are skipped.

`archive-update.sh` then resolves each changed path with a single lookup:

- **Path present in `pages`** → use its URL.
- **Path absent** → it is not a page (layout, include, `_sass`, config, asset,
  tooling) → ignore it.

Why this over shell-side filename math:

- Custom `permalink:` front matter, `:output_ext`, `baseurl`, and collections are
  all handled correctly because Jekyll computed them; nothing is duplicated from
  `_config.yml`, so the two cannot drift.
- Manifest membership *is* the "is this a page?" test, eliminating any
  hand-maintained ignore-list.
- The worst failure of filename math — silently submitting a *wrong* URL — cannot
  occur; a path either resolves to Jekyll's own URL or is ignored.

**Manifest transport.** The generator writes to the site destination, so the file
lands in `OUTPUT_DIR` (`/tmp/blog-output/.url-manifest.json`) on the server after
the container build. `blog-poll.sh` passes that path to `archive-update.sh`. The
docroot rsync excludes it (`--exclude=/.url-manifest.json`) so it is not served
publicly — it is build metadata, not site content.

**Failure mode.** If the generator errors, the Jekyll build fails, so
`blog-poll.sh` never deploys and never calls the archive step — there is no path
by which a missing manifest yields wrong submissions. If the manifest is
unreadable at archive time, `archive-update.sh` treats it as "no resolvable pages"
and exits cleanly (best-effort).

## 7. Change classification (priority tiers)

Only paths that resolve via the manifest (§6) are considered — every tier below
implicitly requires manifest membership. A useful consequence: a future-dated or
otherwise unpublished post is absent from the manifest and therefore skipped, so
the script never submits a URL that is not actually live.

From `git diff --name-status LOCAL HEAD`, for each such changed file:

| Tier | Meaning                       | Condition                                    |
|------|-------------------------------|----------------------------------------------|
| 0    | New blog post                 | status `A`, path under `_posts/`             |
| 1    | New sub-page                  | status `A`, not under `_posts/`              |
| 2    | Body-updated blog post        | status `M`, path under `_posts/`             |
| 3    | Body-updated sub-page         | status `M`, not under `_posts/`              |
| 4    | Index page (`/`)              | see below                                     |

**Tier 4 (index `/`)** is a candidate when **either**:
- this run has ≥1 tier-0 (new) post — the homepage genuinely changed to list it
  (confirmed decision), **or**
- `index.markdown` itself was directly modified.

`/` appears at most once in the candidate pool regardless.

**Deleted files** (status `D`) are skipped — nothing to archive (and a deleted
page is absent from the manifest anyway). **Renames** (status `R`) treat the new
path as new content (see §11, Decision 3).

## 8. Selection algorithm

1. Build the candidate list, grouped by tier 0 → 4.
2. Within a tier, order deterministically: posts by date **newest-first**;
   pages by path, alphabetical (see §11, Decision 2). This only matters when a
   single tier has more candidates than remaining slots.
3. Concatenate tiers in priority order and take the **first 3** URLs.
4. Discard everything after the third. Do not persist it anywhere.

## 9. Rate limiting and state file

- **State file:** `${XDG_STATE_HOME:-$HOME/.local/state}/blog-archive/last-submit`
  — a persistent, empty marker file in the blog user's XDG state directory. The
  script creates the directory with `mkdir -p` on first run; no Ansible task is
  needed. It lives in the user's home, well **outside** the git checkout, so it
  cannot interfere with `git pull` (see §11, Decision 4).
- **Guard logic:**
  1. If the candidate list is empty → exit 0. (No submission, no touch.)
  2. Else if the state file exists and `now - mtime(state file) <= 60s` →
     exit 0. (Rate-limited; take no action this run.)
  3. Else, enter the submission phase (§10), then `touch` the state file.

Because `blog-poll.sh` runs at most every 5 minutes, the 60-second guard is
effectively always satisfied on automated runs — its real purpose is to prevent
rapid **manual** `-f` re-runs from bursting the anonymous rate limit.

## 10. Submission and error handling

- **Endpoint:** anonymous Save Page Now via HTTP GET:
  `https://web.archive.org/save/<full-url>`.
- **Command shape:** `curl` with a short-ish timeout and a descriptive
  `User-Agent` (`blog.lnx.cx archive-update`). Submit up to 3 URLs sequentially,
  **spaced 7 seconds apart** (`sleep 7` between submissions, not after the last),
  to stay comfortably under the 3/minute anonymous ceiling.
- **On error:** if a submission fails (curl error or non-success HTTP status),
  stop submitting the remaining URLs for this run — no retries (per the original
  spec: "the script passes and does not make any subsequent attempts for this
  round"). Then `touch` the state file and exit 0.
- **Never fails the caller:** the script exits 0 on all normal and error paths;
  `blog-poll.sh` also guards the call with `|| true`.
- Worst-case added latency to a poll cycle is roughly `3 × curl-timeout + 14s`
  of spacing — acceptable for a background systemd service, and the deploy has
  already completed before any of it runs.

## 11. Design decisions and defaults

1. **Front-matter-only edits count as content updates.** Any modification to a
   post/page source file is treated as a tier-2/3 update. Distinguishing a body
   edit from a metadata-only edit (e.g. adding a tag) would require parsing past
   the `---` front-matter fence and diffing only below it — added complexity for
   marginal gain, and re-archiving after a metadata tweak is harmless. The
   footer caveat is already fully handled by diffing source (§3), so this does
   **not** reintroduce spurious submissions.

2. **Within-tier tiebreak:** posts newest-first, pages alphabetical by path.
   Only relevant when a single tier overflows the remaining slots.

3. **Deletes skipped, renames treated as new.** A deleted page has nothing to
   archive. A renamed page's new path is treated as new content (its old URL now
   404s; that is out of scope to fix here).

4. **State file at `${XDG_STATE_HOME:-$HOME/.local/state}/blog-archive/last-submit`**
   — in the blog user's XDG state directory, created by the script (`mkdir -p`)
   on first run. No Ansible task and no `/srv` directory needed.

5. **Touch-after-submission-phase.** The state file is touched once the run gets
   past the guard with ≥1 candidate, even if a submission errored mid-batch, so a
   partial/failed batch still holds the 60-second lock. This matches the intent
   of the original spec's "touch after submitting."

## 12. File placement and Ansible changes

- **New:** `_plugins/url_manifest.rb` — the generator that emits
  `.url-manifest.json` at build time. Loaded automatically from `_plugins/`; no
  config change needed.
- **New:** `deploy/archive-update.sh` (source in repo) → installed to
  `/usr/local/bin/archive-update.sh` by the playbook.
- **Changed:** `deploy/blog-poll.sh` — (a) add `--exclude=/.url-manifest.json` to
  the docroot rsync so the manifest is not served publicly, and (b) add the
  one-line best-effort invocation of `archive-update.sh` (passing `$LOCAL`,
  `$HEAD`, and the manifest path under `$OUTPUT_DIR`) at the end of a successful
  deploy.
- **Changed:** `deploy/setup.yml` gains one task: copy `archive-update.sh` into
  `/usr/local/bin/`. (No state-directory task — the script self-creates its XDG
  state dir under the blog user's home on first run.)

## 13. CLI and argument handling

`archive-update.sh` is well over 20 lines, so it parses arguments and rejects
unexpected input:

- `<old-ref> <new-ref> <manifest-path>` — required positionals: the two git refs
  defining the diff range, and the path to the build manifest (§6).
- `--dry-run` — compute and print the selected URLs and their tiers; make no
  network calls and do not touch the state file. This is the primary test hook.
- `-h`, `--help` — usage and exit.
- Any unknown flag or wrong argument count → error to stderr, print usage,
  exit non-zero.

## 14. Testing and verification

- **Dry-run against real history:** pick two commits that bracket a known change
  and run `archive-update.sh --dry-run <old> <new> <manifest>`; confirm the printed URLs and
  tiers match expectation (new post, edited post, layout-only change → nothing,
  etc.).
- **Manifest correctness:** after a build, assert `.url-manifest.json` contains
  the expected source→URL pairs (post with dotted slug, sub-page with explicit
  permalink, `index.markdown` → `/`) and omits non-page sources (a layout, an
  include). This is what the script trusts, so it is the key unit check.
- **Resolution + ignore:** feed the script a diff containing a page change and a
  layout change; confirm the page resolves and the layout is silently dropped.
- **Rate-limit guard:** touch the state file, run, confirm it exits without
  submitting; set mtime older than 60s, confirm it proceeds.
- **Best-effort contract:** simulate a curl failure and confirm the script exits
  0 and `blog-poll.sh` still reports a successful deploy.
- **Live smoke test:** one real `--force` deploy of a trivial post edit; confirm
  the single expected URL is submitted and appears in the Wayback Machine.

## 15. Resolved decisions

All open questions are settled (2026-07-07):

- **§11 defaults** — accepted as written (all five).
- **State-file location** — the blog user's XDG state dir
  (`${XDG_STATE_HOME:-$HOME/.local/state}/blog-archive/last-submit`),
  script-created, not `/srv`. Reflected in §9, §11.4, and §12.
- **Submission pacing** — the ≤3 submissions are spaced **7 seconds apart**, not
  bursted. Reflected in §10.
