import { normalizeAnchor } from './util';

export interface PostAnchor {
    title: string;
    anchorId: string;
    level: 'H1' | 'H2';
}

// Matches blog_anchor (H1) and blog_anchor2 (H2) in document order.
// Group 1: title string. Group 2: '2' for H2, '' for H1.
const ANCHOR_RE = /\{\{\s*["']([^"']+)["']\s*\|\s*blog_anchor(2?)\s*\}\}/g;

const FRONT_MATTER_RE = /^---\r?\n([\s\S]*?)\r?\n---/;
const TITLE_LINE_RE = /^title:\s*["']?(.+?)["']?\s*$/m;

export function parseFrontMatterTitle(content: string): string | undefined {
    const fm = content.match(FRONT_MATTER_RE);
    if (!fm) return undefined;
    const t = fm[1].match(TITLE_LINE_RE);
    return t ? t[1].trim() : undefined;
}

export function parseAnchors(content: string): PostAnchor[] {
    const anchors: PostAnchor[] = [];
    for (const match of content.matchAll(ANCHOR_RE)) {
        const title = match[1];
        anchors.push({
            title,
            anchorId: normalizeAnchor(title),
            level: match[2] === '2' ? 'H2' : 'H1'
        });
    }
    return anchors;
}
