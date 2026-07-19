# SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
# SPDX-License-Identifier: MIT

# _plugins/last_modified.rb
#
# Derives `last_modified_at` from a post's `updated` front-matter list so the
# Atom feed's per-entry <updated> reflects real revisions. jekyll-feed renders
# `post.last_modified_at | default: post.date`, and nothing else in this repo
# sets that key, so without this every entry's <updated> was a copy of its
# <published> -- including the seven posts that do record revisions.
#
# Registered on :site/:post_read for the same reason as _plugins/updated_tag.rb:
# a per-document :post_init hook fires before the file is read, so post.data is
# still empty.

Jekyll::Hooks.register :site, :post_read do |site|
  site.posts.docs.each do |post|
    next if post.data["last_modified_at"]

    updated = post.data["updated"]
    next unless updated.is_a?(Array)

    revisions = updated.filter_map do |entry|
      next unless entry.is_a?(Hash) && entry["date"]

      Jekyll::Utils.parse_date(
        entry["date"].to_s,
        "Post #{post.relative_path} has an invalid date in its `updated` list"
      )
    end
    next if revisions.empty?

    # The list is chronological by convention, but take the max so an
    # out-of-order entry cannot move the timestamp backwards.
    latest = revisions.max
    post.data["last_modified_at"] = latest if latest > post.date
  end
end
