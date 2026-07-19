// SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
// SPDX-License-Identifier: MIT

import { parseFrontMatterTitle, parseAnchors } from '../postParser';

describe('parseFrontMatterTitle', () => {
    it('extracts a quoted title from front matter', () => {
        const content = `---\ntitle: "GPS Mapping Chicago Trails"\ndate: 2024-06-27\n---\nContent.`;
        expect(parseFrontMatterTitle(content)).toBe('GPS Mapping Chicago Trails');
    });

    it('extracts an unquoted title', () => {
        expect(parseFrontMatterTitle('---\ntitle: GPS Mapping Chicago Trails\n---'))
            .toBe('GPS Mapping Chicago Trails');
    });

    it('returns undefined when no title field is present', () => {
        expect(parseFrontMatterTitle('---\ndate: 2024-06-27\n---')).toBeUndefined();
    });

    it('ignores title: lines in the post body', () => {
        const content = `---\ndate: 2024-06-27\n---\nSome text with title: Not The Title`;
        expect(parseFrontMatterTitle(content)).toBeUndefined();
    });
});

describe('parseAnchors', () => {
    it('extracts H1 anchors from blog_anchor calls', () => {
        const content = '{{ "The Problem" | blog_anchor }}\ntext\n{{ "Solution" | blog_anchor }}';
        const anchors = parseAnchors(content);
        expect(anchors).toHaveLength(2);
        expect(anchors[0]).toEqual({ title: 'The Problem', anchorId: 'the-problem', level: 'H1' });
        expect(anchors[1]).toEqual({ title: 'Solution', anchorId: 'solution', level: 'H1' });
    });

    it('extracts H2 anchors from blog_anchor2 calls', () => {
        const anchors = parseAnchors('{{ "Sub Section" | blog_anchor2 }}');
        expect(anchors).toHaveLength(1);
        expect(anchors[0]).toEqual({ title: 'Sub Section', anchorId: 'sub-section', level: 'H2' });
    });

    it('preserves document order for mixed H1 and H2', () => {
        const content = [
            '{{ "Intro" | blog_anchor }}',
            '{{ "Overview" | blog_anchor2 }}',
            '{{ "Details" | blog_anchor }}'
        ].join('\n');
        expect(parseAnchors(content).map(a => a.title)).toEqual(['Intro', 'Overview', 'Details']);
    });

    it('normalizes anchor IDs — matches what the Ruby filter produces', () => {
        const anchors = parseAnchors('{{ "But what about...?" | blog_anchor }}');
        expect(anchors[0].anchorId).toBe('but-what-about');
    });

    it('returns an empty array when no anchors are present', () => {
        expect(parseAnchors('Just some markdown content.')).toEqual([]);
    });
});
