# frozen_string_literal: true
# SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
# SPDX-License-Identifier: MIT

# _plugins/atom_feed.rb
#
# Builds /feed.xml as an XML document tree instead of by string templating.
# This replaces jekyll-feed, which renders a Liquid template and then squeezes
# the whitespace back out with a regex -- an approach that cannot escape its
# own output, cannot pretty-print, and left a stray space in every `<link ... />`
# because the minifier only matches whitespace *following* a '>'.
#
# Escaping here is REXML's problem, not ours: text goes in through add_text and
# comes out escaped, so there is no xml_escape to forget.
#
# Scope is this blog, not feature parity with jekyll-feed. Deliberately absent:
# per-tag and per-category feeds, non-post collections, xsl stylesheets,
# post.lang, excerpt_only, and media:thumbnail images -- none of which this site
# uses. Present because this site does use them: the draft filter, per-post
# authors (5 distinct across the archive, not just Tim), categories and tags,
# and description-or-excerpt summaries.
#
# Ordering: the document is assembled in a :site/:post_render hook rather than
# in the generator, because generators run before rendering and post.content is
# still raw Markdown at that point. The generator only reserves the page.

require "rexml/document"
require "time"

module AtomFeed
  ATOM_NS     = "http://www.w3.org/2005/Atom"
  PATH        = "feed.xml"
  DECLARATION = %(<?xml version="1.0" encoding="utf-8"?>\n)
  INDENT      = 2

  # REXML's pretty printer hard-wraps text at :width columns, which silently
  # folds newlines into any title longer than the default 80 -- the bitmath post
  # is 103. Nothing here should ever be wrapped.
  NO_WRAP = 1 << 30

  # A page jekyll-feed would have generated. Subclassed so the render hook can
  # find it again without matching on a path string.
  class Page < Jekyll::PageWithoutAFile
    def initialize(site)
      super(site, site.source, "", PATH)
      # render_with_liquid is honored via Convertible#render_with_liquid? and is
      # essential: a dozen posts contain {{ }} or {% %} inside code samples that
      # Liquid would otherwise try to evaluate when they land in the feed.
      data.merge!("layout" => nil, "sitemap" => false, "render_with_liquid" => false)
    end
  end

  class Builder
    def initialize(site)
      @site = site
    end

    def to_xml
      doc = REXML::Document.new
      doc.context[:attribute_quote] = :quote # double-quoted attributes
      build_feed(doc.add_element("feed", "xmlns" => ATOM_NS))

      body = +""
      formatter = REXML::Formatters::Pretty.new(INDENT)
      formatter.compact = true
      formatter.width = NO_WRAP
      formatter.write(doc, body)
      DECLARATION + body + "\n"
    end

    private

    def config
      @config ||= @site.config["feed"] || {}
    end

    def posts
      @posts ||= begin
        limit = config["posts_limit"] || 10
        # site.posts.docs already excludes `published: false`; `draft: true` is
        # this repo's own convention and has to be filtered here.
        @site.posts.docs
             .reject { |post| post.data["draft"] }
             .sort_by(&:date)
             .reverse
             .first(limit)
      end
    end

    def absolute(path)
      "#{@site.config["url"]}#{@site.config["baseurl"]}#{path}"
    end

    def stamp(time)
      time.to_time.xmlschema
    end

    # The feed's own <updated> is the newest entry it actually carries -- not
    # site.time, and not the newest post on the site. RFC 4287 4.2.15 reserves
    # this for changes "the publisher considers significant"; a rebuild is not
    # one, and revising a post too old to appear here does not change this
    # document either.
    def feed_updated
      posts.map { |post| updated_at(post) }.max || Time.now
    end

    def updated_at(post)
      (post.data["last_modified_at"] || post.date).to_time
    end

    def text(parent, name, value, attrs = {})
      element = parent.add_element(name, attrs)
      element.add_text(value.to_s)
      element
    end

    # CDATA cannot contain "]]>" and there is no way to escape it inside one, so
    # fall back to an ordinary escaped text node when a post trips over it.
    def markup(parent, name, html, attrs = {})
      element = parent.add_element(name, attrs)
      element.add(html.include?("]]>") ? REXML::Text.new(html) : REXML::CData.new(html))
      element
    end

    def plain(html)
      html.to_s.gsub(%r{<[^>]*>}, "").gsub(/\s+/, " ").strip
    end

    def build_feed(feed)
      text feed, "id", absolute("/#{PATH}")
      text feed, "title", @site.config["title"], "type" => "html"

      subtitle = @site.config["description"]
      text feed, "subtitle", subtitle.strip if subtitle

      text feed, "updated", stamp(feed_updated)
      feed.add_element("link", "href" => absolute("/#{PATH}"),
                               "rel" => "self", "type" => "application/atom+xml")
      feed.add_element("link", "href" => absolute("/"),
                               "rel" => "alternate", "type" => "text/html")
      author(feed, @site.config["author"])
      # RFC 4287 4.2.4: the uri identifies the generating agent, so it is left
      # off until this plugin lives somewhere it can point at.
      text feed, "generator", "atom_feed.rb", "version" => Jekyll::VERSION

      posts.each { |post| build_entry(feed.add_element("entry"), post) }
    end

    def build_entry(entry, post)
      title = plain(post.data["title"])

      text entry, "id", absolute(post.id)
      text entry, "title", title, "type" => "html"
      text entry, "published", stamp(post.date)
      text entry, "updated", stamp(updated_at(post))
      entry.add_element("link", "href" => absolute(post.url), "rel" => "alternate",
                                "type" => "text/html", "title" => title)
      author(entry, post.data["author"] || @site.config["author"])

      terms = Array(post.data["categories"]) + Array(post.data["tags"])
      terms.each { |term| entry.add_element("category", "term" => term.to_s) }

      summary = post.data["description"] || post.data["excerpt"]
      summary = plain(summary)
      markup entry, "summary", summary, "type" => "html" unless summary.empty?

      markup entry, "content", post.content.to_s.strip,
             "type" => "html", "xml:base" => absolute(post.url)
    end

    def author(parent, name)
      return if name.nil? || name.to_s.empty?

      # site.author may be a scalar or a hash of name/email/uri.
      name = name["name"] if name.is_a?(Hash)
      text parent.add_element("author"), "name", name
    end
  end

  class Generator < Jekyll::Generator
    safe true
    priority :lowest

    def generate(site)
      return if File.exist?(site.in_source_dir(PATH))

      site.pages << Page.new(site)
    end
  end
end

Jekyll::Hooks.register :site, :post_render do |site|
  page = site.pages.find { |candidate| candidate.is_a?(AtomFeed::Page) }
  next if page.nil?

  page.output = AtomFeed::Builder.new(site).to_xml
  Jekyll.logger.info "Atom feed:", "built #{AtomFeed::PATH} from the document tree"
end
