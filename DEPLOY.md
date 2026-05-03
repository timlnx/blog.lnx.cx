# Deploy Notes

This doc exists because I got tired of waking up to a site randomly serving 403s and
being unable to publish a post from anywhere that wasn't my Mac.

The old workflow was: run `build.sh` locally, then run `sync.sh` to rsync the output up
to the server. This worked fine until it didn't. The rsync had no permission enforcement,
so every few syncs the file ownership or mode would drift and Apache would start refusing
to serve things. I had a literal `umask 0002` hack baked into `build.sh`. That is not a
solution, that is a ritual.

The images situation was also pretty goofy: roughly 60 image files lived only on my Mac,
untracked by git. Building from anywhere else meant building a site with holes in it. I
left WordPress two years ago to make this whole thing simpler — and somehow ended up with
a publishing workflow that chained me to one machine and a fragile rsync command.

So. The new setup builds the site inside a rootless podman container on the server,
triggered whenever I push to GitHub (or commit via the web UI). Images live on the server
in `/srv/blog-images/`. Permissions are enforced by the deploy rsync on every single run,
so they can't drift. The git repo stays light — just posts, CSS, fonts, and a
`Containerfile`.

## What Runs Where

```
GitHub repo (timlnx/blog.lnx.cx)
  ↓  git push (local or web UI)
GitHub Actions CI — validates the Jekyll build on Fedora 41 (no images, just structure)
  ↓
lnx.cx — systemd.timer fires blog-poll.sh every 5 minutes
  ↓  new commits detected → git pull
podman run localhost/blog-builder
  mounts: /srv/blog.lnx.cx (source, ro)
          /srv/blog-images (images, ro)
          /tmp/blog-output (build target, rw)
  ↓  jekyll build
rsync /tmp/blog-output/ → /var/www/blog.lnx.cx/
  --chmod=D755,F644 --exclude=/scratch/
Apache serves /var/www/blog.lnx.cx/
```

The `--chmod` flags on that final rsync are doing the work that the old umask hack tried
and failed to do reliably. Ask me how I know.

## Repo Layout

| Path | What it is |
|------|-----------|
| `_posts/` | Blog post markdown |
| `assets/{css,woff,woff2,opengraph,gpx}/` | Static assets — in git |
| `assets/images/` | **Gitignored.** Populated at build time from `/srv/blog-images/` |
| `Containerfile` | Fedora 41 multi-arch build image |
| `container-build.sh` | Entrypoint script that runs inside the container |
| `build-local.sh` | Mac podman build helper (ARM-native) |
| `upload-image.sh` | scp wrapper — uploads to server and prints the markdown ref |
| `deploy/blog-poll.sh` | The poll + build + deploy script that systemd runs |
| `deploy/setup.yml` | Ansible playbook for first-time server setup |
| `.github/workflows/ci.yml` | GitHub Actions CI |

## First-Time Server Setup

This only needs to happen once. The playbook is idempotent so re-running it is safe
if something goes sideways partway through.

### Prerequisites

```bash
sudo dnf -y install ansible git podman rsync
```

### Bootstrap the checkout

The playbook can't clone the repo before the repo exists, so this part is manual:

```bash
sudo mkdir -p /srv/blog.lnx.cx
sudo chown tc:tc /srv/blog.lnx.cx
git clone https://github.com/timlnx/blog.lnx.cx.git /srv/blog.lnx.cx
```

### Run the playbook

```bash
cd /srv/blog.lnx.cx
ansible-playbook -i localhost, -c local deploy/setup.yml --ask-become-pass
```

What it does, in order:

1. Creates `/srv/blog-images/` (owned `tc:tc`, mode 750)
2. Sets SELinux `container_file_t` on `/srv/blog-images/` and `/srv/blog.lnx.cx/`
   so rootless podman can actually read them (this burned me during the POC)
3. Creates `/var/www/blog.lnx.cx/scratch/` — the pipeline never touches this directory,
   so files dropped here by hand persist across deploys
4. Builds the `localhost/blog-builder` podman image (this takes a few minutes the first time)
5. Installs `deploy/blog-poll.sh` → `/usr/local/bin/blog-poll.sh`
6. Installs the systemd user service and timer units under `~/.config/systemd/user/`
7. Runs `loginctl enable-linger tc` so the timer survives logout
8. Enables and starts `blog-builder.timer`

### Verify it took

```bash
systemctl --user status blog-builder.timer
# Should show: active (waiting), next trigger in ≤5 min

journalctl --user -u blog-builder.service -f
# Watch for: "No new commits" or a build run
```

## Day-to-Day

### Publishing a post

Write it, push it. The server picks it up within 5 minutes. That's the whole thing.

From the GitHub web UI: navigate to `_posts/`, create a new file named
`YYYY-MM-DD-your-title.markdown`, commit to `main`. Done.

### Adding an image to a post

From your Mac:

```bash
./upload-image.sh ~/Desktop/photo.jpg
```

Output looks like:

```
photo.jpg                    100%  842KB   1.2MB/s
Uploaded. Reference in posts as:
  ![alt text](/assets/images/photo.jpg)
```

The image lands in `/srv/blog-images/` on the server immediately. Reference it in the
post markdown and push — the next build will include it.

If you're not on your Mac, `scp` directly:

```bash
scp photo.jpg tc@lnx.cx:/srv/blog-images/
```

### Dropping files for direct download

Files placed in `/scratch/` by hand are never touched by the pipeline:

```bash
scp thing.zip tc@lnx.cx:/var/www/blog.lnx.cx/scratch/
# Serves at https://blog.lnx.cx/scratch/thing.zip
```

### Local Mac build

```bash
./build-local.sh
# Builds inside a native ARM64 Fedora container
# Uses ~/blog-images/ for images (or set BLOG_IMAGES=/path/to/yours)
# Output: _site/
```

If you've changed `Containerfile` or `Gemfile`, you need to rebuild the local image first:

```bash
podman rmi localhost/blog-builder
./build-local.sh   # rebuilds automatically on first run
```

There's also `./build.sh` for when you just want a fast `bundle exec jekyll build`
without any container overhead. Images won't be present, but post structure and templates
validate fine.

## Re-running the Playbook

If `deploy/blog-poll.sh` or the systemd unit content changes after the initial setup,
re-run the playbook to push the updates:

```bash
cd /srv/blog.lnx.cx
git pull
ansible-playbook -i localhost, -c local deploy/setup.yml --ask-become-pass
```

## Troubleshooting

### Check what the last build did

```bash
journalctl --user -u blog-builder.service --since "2 hours ago"
```

### Force a build right now without waiting for the timer

```bash
/usr/local/bin/blog-poll.sh
```

### 403s are back

The rsync enforces permissions on every run, so running the poll script manually will
fix it:

```bash
/usr/local/bin/blog-poll.sh
```

If it's happening consistently, check that `tc` owns `/var/www/blog.lnx.cx/` and that
Apache is configured to serve files owned by `tc`. The old umask problem shouldn't come
back, but if something changed ownership out from under us, that's where to look.

### SELinux is blocking podman from reading the mounts

```bash
sudo restorecon -Rv /srv/blog-images /srv/blog.lnx.cx
```

Re-applies the `container_file_t` labels. This can happen after certain package updates
or if files were added to `/srv/blog-images/` by a process that didn't inherit the
right context (rsyncing from your Mac, for example).

### Gemfile or Containerfile changed and the build is failing

The poll script detects changes to `Gemfile`, `Gemfile.lock`, and `Containerfile` and
rebuilds the container image automatically. If the automatic rebuild failed for some
reason, do it manually:

```bash
cd /srv/blog.lnx.cx
podman build -t localhost/blog-builder .
```

---

Good luck. The site should more or less take care of itself from here.
