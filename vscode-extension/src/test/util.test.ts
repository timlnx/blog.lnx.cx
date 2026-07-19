// SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
// SPDX-License-Identifier: MIT

import {
    normalizeAnchor,
    derivePostUrl,
    buildAnchorFilter,
    buildAnchor2Filter,
    buildAnchorLinkFilter,
    buildCrossLinkFilter
} from '../util';

describe('normalizeAnchor', () => {
    it('lowercases and replaces spaces with hyphens', () => {
        expect(normalizeAnchor('Hello World')).toBe('hello-world');
    });

    it('drops non-alphanumeric non-hyphen characters', () => {
        expect(normalizeAnchor('But what about...?')).toBe('but-what-about');
    });

    it('preserves numbers', () => {
        expect(normalizeAnchor('Part 3')).toBe('part-3');
    });

    it('matches Ruby filter behavior for real anchor names from the blog', () => {
        expect(normalizeAnchor('Sorting out the Mess')).toBe('sorting-out-the-mess');
        expect(normalizeAnchor('Symbol Name To Code Value (Linux)')).toBe('symbol-name-to-code-value-linux');
    });
});

describe('derivePostUrl', () => {
    it('converts a .markdown filename to the correct Jekyll URL', () => {
        expect(derivePostUrl('2024-06-27-gps-mapping-chicago-trails-part-1.markdown'))
            .toBe('/2024/06/27/gps-mapping-chicago-trails-part-1.html');
    });

    it('handles .md extension', () => {
        expect(derivePostUrl('2025-07-04-some-post.md'))
            .toBe('/2025/07/04/some-post.html');
    });

    it('returns empty string for filenames that do not match the YYYY-MM-DD-slug pattern', () => {
        expect(derivePostUrl('not-a-post.md')).toBe('');
        expect(derivePostUrl('README.md')).toBe('');
    });
});

describe('buildAnchorFilter', () => {
    it('wraps a title in a blog_anchor filter call', () => {
        expect(buildAnchorFilter('The Problem')).toBe('{{ "The Problem" | blog_anchor }}');
    });

    it('strips double quotes from title to prevent broken Liquid syntax', () => {
        expect(buildAnchorFilter('He said "hello"')).toBe('{{ "He said hello" | blog_anchor }}');
    });
});

describe('buildAnchor2Filter', () => {
    it('wraps a title in a blog_anchor2 filter call', () => {
        expect(buildAnchor2Filter('Overview')).toBe('{{ "Overview" | blog_anchor2 }}');
    });
});

describe('buildAnchorLinkFilter', () => {
    it('builds a basic anchor link with no display text', () => {
        expect(buildAnchorLinkFilter('The Problem'))
            .toBe('{{ "The Problem" | blog_anchor_link }}');
    });

    it('includes display text when it differs from the title', () => {
        expect(buildAnchorLinkFilter('The Problem', 'see the problem'))
            .toBe('{{ "The Problem" | blog_anchor_link: "see the problem" }}');
    });

    it('omits display text when it matches the title', () => {
        expect(buildAnchorLinkFilter('The Problem', 'The Problem'))
            .toBe('{{ "The Problem" | blog_anchor_link }}');
    });
});

describe('buildCrossLinkFilter', () => {
    const url = '/2025/07/04/hiking-the-chicago-outer-belt-map-27-correction.html';

    it('builds a basic cross-post link', () => {
        expect(buildCrossLinkFilter('New Fences', url))
            .toBe(`{{ "New Fences" | blog_cross_link: "${url}" }}`);
    });

    it('includes display text when it differs from the title', () => {
        expect(buildCrossLinkFilter('New Fences', url, 'the fence situation'))
            .toBe(`{{ "New Fences" | blog_cross_link: "${url}", "the fence situation" }}`);
    });

    it('omits display text when it matches the title', () => {
        expect(buildCrossLinkFilter('New Fences', url, 'New Fences'))
            .toBe(`{{ "New Fences" | blog_cross_link: "${url}" }}`);
    });
});
