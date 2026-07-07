# _plugins/url_manifest.rb
#
# Emits `.url-manifest.json` into the site output on every build: an
# authoritative map of source-path -> published-URL for every real page on the
# site. This is the URL-resolution oracle consumed by deploy/archive-update.sh,
# which uses it to turn changed source paths (from `git diff --name-status`)
# into the absolute URLs it submits to the Wayback Machine.
#
# See docs/superpowers/specs/2026-07-07-archive-update-pipeline-design.md (§6).
#
# Why let Jekyll do this instead of computing URLs in shell: Jekyll already
# resolves custom `permalink:` front matter, `:output_ext`, `baseurl`, and
# collections. Re-deriving any of that in the script would duplicate config and
# invite drift. Manifest membership also *is* the "is this a page?" test, so the
# script needs no hand-kept ignore-list for layouts/includes/sass/assets.
#
# Keys are the source path **relative to the repo root** — the exact form
# `git diff --name-status` emits (the Jekyll source dir is the repo root here).
# Values are the **absolute** published URL.
#
# Written from a :site :post_write hook rather than a Generator body: at
# post_write the site is fully rendered (URLs are final) and already flushed to
# disk, so Jekyll's cleanup pass — which would delete an untracked file a
# generator wrote early — has already run. If this hook raises, `jekyll build`
# exits non-zero, the deploy never happens, and the archive step is never
# called; there is no path by which a bad build yields a stale manifest.

require "json"

module UrlManifest
  MANIFEST_NAME = ".url-manifest.json"

  module_function

  # Join site url + baseurl + a root-relative page URL into an absolute URL.
  # page_url always begins with "/", so we only trim trailing slashes off the
  # host/baseurl to avoid doubling the separator.
  def absolute_url(site, page_url)
    base = site.config["url"].to_s.sub(%r{/\z}, "")
    baseurl = site.config["baseurl"].to_s.sub(%r{/\z}, "")
    "#{base}#{baseurl}#{page_url}"
  end

  # A page/document is "real" only if a source file backs it. Plugin-synthesized
  # outputs (jekyll-feed's feed.xml, jekyll-sitemap's sitemap.xml/robots.txt)
  # have a relative_path but no file on disk; git can never reference them, and
  # we don't want them in the manifest.
  def real_source?(site, relative_path)
    return false if relative_path.nil? || relative_path.empty?
    File.file?(File.join(site.source, relative_path))
  end

  # A URL is archivable only if it addresses an HTML document a reader visits:
  # a post (".html") or a permalink/pretty page (trailing "/"). Jekyll turns
  # *any* front-matter-bearing file into a "page", so without this filter the
  # manifest would also list assets/main.scss -> /assets/main.css and
  # deploy/setup.yml -> /deploy/setup.yml. Dropping those here is what makes
  # "absent from the manifest" mean "not a page" for the script, honoring the
  # non-goal of never archiving asset/config/tooling changes (spec §4).
  def archivable_url?(url)
    url.to_s.end_with?("/", ".html")
  end

  def build(site)
    pages = {}

    # Collections cover _posts today and any future collection.
    site.collections.each_value do |collection|
      collection.docs.each do |doc|
        rel = doc.relative_path
        next unless real_source?(site, rel)
        next unless archivable_url?(doc.url)
        pages[rel] = absolute_url(site, doc.url)
      end
    end

    # Regular pages (about, audio, index, 404, galleries/index.html, ...).
    site.pages.each do |page|
      rel = page.relative_path
      next unless real_source?(site, rel)
      next unless archivable_url?(page.url)
      pages[rel] = absolute_url(site, page.url)
    end

    {
      "site_url" => site.config["url"],
      "generated_by" => "_plugins/url_manifest.rb",
      # Sorted for deterministic, diff-friendly output.
      "pages" => pages.sort.to_h,
    }
  end

  def write(site)
    manifest = build(site)
    path = File.join(site.dest, MANIFEST_NAME)
    File.write(path, JSON.pretty_generate(manifest) + "\n")
    Jekyll.logger.info "URL manifest:", "wrote #{pages_count(manifest)} pages to #{MANIFEST_NAME}"
  end

  def pages_count(manifest)
    manifest["pages"].size
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  UrlManifest.write(site)
end
