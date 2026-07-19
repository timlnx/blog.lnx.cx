# SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
# SPDX-License-Identifier: MIT

# _plugins/tag_pages.rb
#
# Emits /tags/<slug>.html for every tag in use: a date-descending index of the
# posts carrying that tag, laid out like the landing page. Without these the
# tag buttons on the landing page link nowhere.
#
# Every tag gets a page, including the many that carry a single post. Thresholding
# by post count would leave those buttons pointing at 404s, which is the state
# this is meant to fix.
#
# Tags are grouped by their *slug*, so `Python` and `python` (and `Music`/`music`)
# collapse onto one page rather than two pages differing only in case. The label
# shown is the most-used spelling, ties broken alphabetically so the output is
# stable across builds.
#
# Slugs come from Jekyll::Utils.slugify, the same implementation backing the
# Liquid `slugify` filter that _includes/post-list-item.html uses to build the
# hrefs -- so the links and the pages agree by construction, including on the
# awkward ones (`OS X` -> os-x, `scribe's guides` -> scribe-s-guides).

module TagPages
  # `draft` is a local front-matter convention the post list honors; posts with
  # `published: false` never reach site.posts at all, so they need no check.
  def self.listed?(post)
    !post.data["draft"]
  end

  class TagPage < Jekyll::Page
    def initialize(site, base, slug, label, posts)
      @site = site
      @base = base
      @dir  = "tags"
      @name = "#{slug}.html"

      process(@name)

      self.data = {
        "layout" => "tag",
        "tag" => label,
        "posts" => posts,
        "title" => %(Posts tagged "#{label}"),
        "description" => "Every post on Technitribe tagged \"#{label}\", newest first.",
      }
    end
  end

  class Generator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      groups = Hash.new { |h, k| h[k] = { labels: Hash.new(0), posts: [] } }

      site.posts.docs.each do |post|
        next unless TagPages.listed?(post)

        Array(post.data["tags"]).each do |tag|
          slug = Jekyll::Utils.slugify(tag.to_s)
          next if slug.nil? || slug.empty?

          group = groups[slug]
          group[:labels][tag.to_s] += 1
          group[:posts] << post unless group[:posts].include?(post)
        end
      end

      groups.each do |slug, group|
        label = group[:labels].sort_by { |spelling, count| [-count, spelling] }.first.first
        posts = group[:posts].sort_by { |post| post.date }.reverse
        site.pages << TagPage.new(site, site.source, slug, label, posts)
      end

      Jekyll.logger.info "Tag pages:", "generated #{groups.size} tag indexes"
    end
  end
end
