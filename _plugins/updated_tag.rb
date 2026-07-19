# SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
# SPDX-License-Identifier: MIT

# _plugins/updated_tag.rb
#
# Derives the "updated" tag from a post's `updated` front-matter list instead of
# having it hand-maintained alongside it. The revision list, the [Updated] title
# prefix, and this tag then all read from one source and cannot drift apart --
# they already had, before this: a 2026 link-fix sweep stamped the tag and the
# title prefix onto six posts that had no revision to show for it.
#
# Registered on :site/:post_read, which fires once every post's front matter is
# parsed but before any generator runs. A per-document :post_init hook is too
# early to work here: Document#initialize has not read the file yet, so
# post.data is still empty and every post looks un-updated.
#
# Ordering matters downstream: _plugins/tag_pages.rb reads post.tags from a
# generator, and would otherwise emit a /tags/updated.html missing every post.

Jekyll::Hooks.register :site, :post_read do |site|
  site.posts.docs.each do |post|
    updated = post.data["updated"]
    next unless updated.is_a?(Array) && !updated.empty?

    tags = (post.data["tags"] ||= [])
    tags << "updated" unless tags.include?("updated")
  end
end
