// SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
// SPDX-License-Identifier: MIT

// Strips " so user-typed titles can't break Liquid string delimiters.
function sanitize(s: string): string {
    return s.replace(/"/g, '');
}

// Mirrors Jekyll::AnchorFilter#normalize — keep in sync with anchor_filter.rb.
export function normalizeAnchor(input: string): string {
    // [^0-9a-z-] is safe here because toLowerCase() already ran; mirrors Ruby's [^0-9a-zA-Z-]
    return input.toLowerCase().replace(/ /g, '-').replace(/[^0-9a-z-]/g, '');
}

// Derives the Jekyll permalink from a _posts filename.
// Assumes permalink: /:year/:month/:day/:title:output_ext (see _config.yml).
export function derivePostUrl(filename: string): string {
    const match = filename.match(/^(\d{4})-(\d{2})-(\d{2})-(.+)\.(markdown|md)$/);
    if (!match) return '';
    const [, year, month, day, slug] = match;
    return `/${year}/${month}/${day}/${slug}.html`;
}

export function buildAnchorFilter(title: string): string {
    return `{{ "${sanitize(title)}" | blog_anchor }}`;
}

export function buildAnchor2Filter(title: string): string {
    return `{{ "${sanitize(title)}" | blog_anchor2 }}`;
}

export function buildAnchorLinkFilter(title: string, displayText?: string): string {
    if (displayText && displayText !== title) {
        return `{{ "${sanitize(title)}" | blog_anchor_link: "${sanitize(displayText)}" }}`;
    }
    return `{{ "${sanitize(title)}" | blog_anchor_link }}`;
}

export function buildCrossLinkFilter(title: string, postUrl: string, displayText?: string): string {
    if (displayText && displayText !== title) {
        return `{{ "${sanitize(title)}" | blog_cross_link: "${sanitize(postUrl)}", "${sanitize(displayText)}" }}`;
    }
    return `{{ "${sanitize(title)}" | blog_cross_link: "${sanitize(postUrl)}" }}`;
}
