# VS Code Jekyll Filter Extension Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a local VS Code extension and a new Jekyll filter that together make inserting `blog_anchor`, `blog_anchor2`, `blog_anchor_link`, and `blog_cross_link` filter calls into blog posts require zero thought.

**Architecture:** A TypeScript VS Code extension in `vscode-extension/` provides four keybind-able commands (wrap selected text → filter call) and IntelliSense completions triggered by `{{ "`. A post index scans `_posts/` on activation, parses every `blog_anchor`/`blog_anchor2` call across all posts, and powers a three-step Quick Pick for `blog_cross_link` (pick post → pick section → optional display text). Pure logic lives in testable modules (`util.ts`, `postParser.ts`); VS Code API wiring stays in `postIndex.ts`, `commands.ts`, `completions.ts`, and `extension.ts`.

**Tech Stack:** TypeScript 5, VS Code Extension API (^1.85.0), Jest + ts-jest for unit tests, `@vscode/vsce` for packaging. No runtime dependencies beyond Node built-ins and the VS Code API itself.

---

## File Map

**Modified:**
- `_plugins/anchor_filter.rb` — add `blog_cross_link` filter

**Created:**
```
vscode-extension/
  package.json               extension manifest: commands, keybindings, activation
  tsconfig.json              TypeScript compiler config (compiles src/ → out/)
  jest.config.js             Jest config: ts-jest preset, vscode module mock
  .vscodeignore              exclude src/, tests, node_modules from .vsix
  install.sh                 build + install script (-h/--help required)
  src/
    util.ts                  pure functions: normalizeAnchor, derivePostUrl, buildXxxFilter
    postParser.ts            pure functions: parseFrontMatterTitle, parseAnchors
    postIndex.ts             PostIndex class: scans _posts/, file watcher, VS Code APIs
    commands.ts              four registerCommand implementations
    completions.ts           BlogFilterCompletionProvider
    extension.ts             activate/deactivate: wires index, commands, completions
    test/
      __mocks__/vscode.ts    minimal vscode module mock for Jest
      util.test.ts           tests for util.ts
      postParser.test.ts     tests for postParser.ts
```

---

## Task 1: Add blog_cross_link to anchor_filter.rb

**Files:**
- Modify: `_plugins/anchor_filter.rb`

- [ ] **Step 1: Add the filter method**

Open `_plugins/anchor_filter.rb` and add `blog_cross_link` inside the `AnchorFilter` module, after `blog_anchor_link`:

```ruby
def blog_cross_link(input, post_url, display_text=nil)
  # Link to a specific section on another post.
  # post_url comes from the Jekyll permalink: /YYYY/MM/DD/slug.html
  #
  # Usage (default link text):
  #   {{ "Section Title" | blog_cross_link: "/2024/06/27/some-post.html" }}
  #
  # Usage (custom link text):
  #   {{ "Section Title" | blog_cross_link: "/2024/06/27/some-post.html", "click here" }}
  link_text = display_text ? display_text : input
  anchor_id = self.normalize(input)
  "<a href='#{post_url}##{anchor_id}'>#{link_text}</a>"
end
```

- [ ] **Step 2: Verify the build succeeds**

```bash
./build-local.sh
```

Expected: build completes with no errors. The new filter won't be used by any post yet — that's fine.

- [ ] **Step 3: Commit**

```bash
git add _plugins/anchor_filter.rb
git commit -m "feat: add blog_cross_link Liquid filter for cross-post anchor links"
```

---

## Task 2: Extension scaffold

**Files:**
- Create: `vscode-extension/package.json`
- Create: `vscode-extension/tsconfig.json`
- Create: `vscode-extension/jest.config.js`
- Create: `vscode-extension/.vscodeignore`

- [ ] **Step 1: Create package.json**

```json
{
  "name": "blog-lnx-cx-filters",
  "displayName": "blog.lnx.cx Jekyll Filters",
  "description": "Insert Jekyll Liquid filter calls in blog posts without thinking about syntax.",
  "version": "1.0.0",
  "engines": { "vscode": "^1.85.0" },
  "categories": ["Other"],
  "activationEvents": ["onLanguage:markdown"],
  "main": "./out/extension.js",
  "contributes": {
    "commands": [
      { "command": "blog-filters.wrapAnchor",     "title": "Blog: Wrap as H1 anchor" },
      { "command": "blog-filters.wrapAnchor2",    "title": "Blog: Wrap as H2 anchor" },
      { "command": "blog-filters.wrapAnchorLink", "title": "Blog: Wrap as anchor link" },
      { "command": "blog-filters.insertCrossLink","title": "Blog: Insert cross-post link" }
    ],
    "keybindings": [
      {
        "command": "blog-filters.wrapAnchor",
        "key": "ctrl+shift+1", "mac": "cmd+shift+1",
        "when": "editorTextFocus && (resourceExtname == '.md' || resourceExtname == '.markdown')"
      },
      {
        "command": "blog-filters.wrapAnchor2",
        "key": "ctrl+shift+2", "mac": "cmd+shift+2",
        "when": "editorTextFocus && (resourceExtname == '.md' || resourceExtname == '.markdown')"
      },
      {
        "command": "blog-filters.wrapAnchorLink",
        "key": "ctrl+shift+l", "mac": "cmd+shift+l",
        "when": "editorTextFocus && (resourceExtname == '.md' || resourceExtname == '.markdown')"
      },
      {
        "command": "blog-filters.insertCrossLink",
        "key": "ctrl+shift+x", "mac": "cmd+shift+x",
        "when": "editorTextFocus && (resourceExtname == '.md' || resourceExtname == '.markdown')"
      }
    ]
  },
  "scripts": {
    "compile": "tsc -p ./",
    "watch": "tsc -watch -p ./",
    "test": "jest"
  },
  "devDependencies": {
    "@types/jest": "^29.0.0",
    "@types/node": "^20.0.0",
    "@types/vscode": "^1.85.0",
    "@vscode/vsce": "^2.22.0",
    "jest": "^29.0.0",
    "ts-jest": "^29.0.0",
    "typescript": "^5.3.0"
  }
}
```

- [ ] **Step 2: Create tsconfig.json**

```json
{
  "compilerOptions": {
    "module": "commonjs",
    "target": "ES2020",
    "outDir": "out",
    "lib": ["ES2020"],
    "sourceMap": true,
    "strict": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules", "src/test", "out"]
}
```

- [ ] **Step 3: Create jest.config.js**

```js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/src/test/**/*.test.ts'],
  moduleNameMapper: {
    '^vscode$': '<rootDir>/src/test/__mocks__/vscode.ts'
  }
};
```

- [ ] **Step 4: Create .vscodeignore**

```
.vscode-test/**
src/**
node_modules/**
jest.config.js
tsconfig.json
*.vsix
```

- [ ] **Step 5: Create src/ directories**

```bash
mkdir -p vscode-extension/src/test/__mocks__
```

- [ ] **Step 6: Install dependencies**

```bash
cd vscode-extension && npm install
```

Expected: `node_modules/` populated, no errors.

- [ ] **Step 7: Commit**

```bash
cd ..
git add vscode-extension/
git commit -m "feat: scaffold VS Code extension with package.json, tsconfig, jest config"
```

---

## Task 3: util.ts

**Files:**
- Create: `vscode-extension/src/test/__mocks__/vscode.ts`
- Create: `vscode-extension/src/test/util.test.ts`
- Create: `vscode-extension/src/util.ts`

- [ ] **Step 1: Create the vscode mock** (needed by Jest so imports of 'vscode' don't blow up)

`vscode-extension/src/test/__mocks__/vscode.ts`:

```typescript
export const CompletionItemKind = { Function: 2, Method: 1 };

export class CompletionItem {
    insertText: any;
    detail: string = '';
    command: any;
    range: any;
    constructor(public label: string, public kind?: number) {}
}

export class SnippetString {
    constructor(public value: string) {}
}

export class Range {
    constructor(public start: any, public end: any) {}
}

export class Position {
    constructor(public line: number, public character: number) {}
    translate(_lineDelta: number, charDelta: number): Position {
        return new Position(this.line, this.character + charDelta);
    }
}

export const window = {
    showInputBox: jest.fn(),
    showQuickPick: jest.fn(),
    showWarningMessage: jest.fn(),
    activeTextEditor: undefined as any
};

export const workspace = {
    workspaceFolders: undefined as any,
    createFileSystemWatcher: jest.fn()
};

export const commands = { registerCommand: jest.fn() };
export const languages = { registerCompletionItemProvider: jest.fn() };
```

- [ ] **Step 2: Write the failing tests**

`vscode-extension/src/test/util.test.ts`:

```typescript
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
```

- [ ] **Step 3: Run tests and confirm they fail**

```bash
cd vscode-extension && npm test
```

Expected: Jest reports failures like `Cannot find module '../util'`.

- [ ] **Step 4: Implement util.ts**

`vscode-extension/src/util.ts`:

```typescript
// Mirrors Jekyll::AnchorFilter#normalize — keep in sync with anchor_filter.rb.
export function normalizeAnchor(input: string): string {
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
    return `{{ "${title}" | blog_anchor }}`;
}

export function buildAnchor2Filter(title: string): string {
    return `{{ "${title}" | blog_anchor2 }}`;
}

export function buildAnchorLinkFilter(title: string, displayText?: string): string {
    if (displayText && displayText !== title) {
        return `{{ "${title}" | blog_anchor_link: "${displayText}" }}`;
    }
    return `{{ "${title}" | blog_anchor_link }}`;
}

export function buildCrossLinkFilter(title: string, postUrl: string, displayText?: string): string {
    if (displayText && displayText !== title) {
        return `{{ "${title}" | blog_cross_link: "${postUrl}", "${displayText}" }}`;
    }
    return `{{ "${title}" | blog_cross_link: "${postUrl}" }}`;
}
```

- [ ] **Step 5: Run tests and confirm they pass**

```bash
npm test
```

Expected: all tests pass, no failures.

- [ ] **Step 6: Commit**

```bash
cd ..
git add vscode-extension/src/
git commit -m "feat: add util.ts with filter string builders and anchor normalization"
```

---

## Task 4: postParser.ts

**Files:**
- Create: `vscode-extension/src/test/postParser.test.ts`
- Create: `vscode-extension/src/postParser.ts`

- [ ] **Step 1: Write the failing tests**

`vscode-extension/src/test/postParser.test.ts`:

```typescript
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
```

- [ ] **Step 2: Run tests and confirm they fail**

```bash
cd vscode-extension && npm test
```

Expected: failures like `Cannot find module '../postParser'`.

- [ ] **Step 3: Implement postParser.ts**

`vscode-extension/src/postParser.ts`:

```typescript
import { normalizeAnchor } from './util';

export interface PostAnchor {
    title: string;
    anchorId: string;
    level: 'H1' | 'H2';
}

// Matches blog_anchor (H1) and blog_anchor2 (H2) in document order.
// Group 1: title string. Group 2: '2' for H2, '' for H1.
const ANCHOR_RE = /\{\{\s*["']([^"']+)["']\s*\|\s*blog_anchor(2?)\s*\}\}/g;

const FRONT_MATTER_TITLE_RE = /^title:\s*["']?(.+?)["']?\s*$/m;

export function parseFrontMatterTitle(content: string): string | undefined {
    const match = content.match(FRONT_MATTER_TITLE_RE);
    return match ? match[1].trim() : undefined;
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
```

- [ ] **Step 4: Run tests and confirm they pass**

```bash
npm test
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
cd ..
git add vscode-extension/src/postParser.ts vscode-extension/src/test/postParser.test.ts
git commit -m "feat: add postParser.ts — extract front matter title and blog_anchor calls from post content"
```

---

## Task 5: postIndex.ts

**Files:**
- Create: `vscode-extension/src/postIndex.ts`

No unit tests here — this module orchestrates VS Code file system APIs. Its behavior is validated end-to-end in Task 10.

- [ ] **Step 1: Implement postIndex.ts**

`vscode-extension/src/postIndex.ts`:

```typescript
import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import { parseFrontMatterTitle, parseAnchors, PostAnchor } from './postParser';
import { derivePostUrl } from './util';

export interface PostEntry {
    filename: string;
    displayTitle: string;
    url: string;
    anchors: PostAnchor[];
}

export class PostIndex {
    private entries: PostEntry[] = [];
    private watcher: vscode.FileSystemWatcher | undefined;

    async build(postsDir: string): Promise<void> {
        if (!fs.existsSync(postsDir)) return;

        const files = fs.readdirSync(postsDir)
            .filter(f => f.endsWith('.markdown') || f.endsWith('.md'))
            .sort()
            .reverse(); // newest first in Quick Pick

        this.entries = files.flatMap(filename => {
            const url = derivePostUrl(filename);
            if (!url) return [];
            const content = fs.readFileSync(path.join(postsDir, filename), 'utf8');
            return [{
                filename,
                displayTitle: parseFrontMatterTitle(content) ?? slugToTitle(filename),
                url,
                anchors: parseAnchors(content)
            }];
        });
    }

    watch(postsDir: string, onChange: () => void): void {
        this.watcher?.dispose();
        this.watcher = vscode.workspace.createFileSystemWatcher(
            new vscode.RelativePattern(postsDir, '*.{markdown,md}')
        );
        this.watcher.onDidCreate(() => onChange());
        this.watcher.onDidChange(() => onChange());
        this.watcher.onDidDelete(() => onChange());
    }

    getEntries(): PostEntry[] {
        return this.entries;
    }

    dispose(): void {
        this.watcher?.dispose();
    }
}

function slugToTitle(filename: string): string {
    const match = filename.match(/^\d{4}-\d{2}-\d{2}-(.+)\.(markdown|md)$/);
    if (!match) return filename;
    return match[1]
        .split('-')
        .map(w => w.charAt(0).toUpperCase() + w.slice(1))
        .join(' ');
}
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd vscode-extension && npx tsc --noEmit
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
cd ..
git add vscode-extension/src/postIndex.ts
git commit -m "feat: add PostIndex — scans _posts/ for anchor headers with file watcher"
```

---

## Task 6: commands.ts

**Files:**
- Create: `vscode-extension/src/commands.ts`

- [ ] **Step 1: Implement commands.ts**

`vscode-extension/src/commands.ts`:

```typescript
import * as vscode from 'vscode';
import { PostIndex } from './postIndex';
import {
    buildAnchorFilter,
    buildAnchor2Filter,
    buildAnchorLinkFilter,
    buildCrossLinkFilter
} from './util';

export function registerCommands(context: vscode.ExtensionContext, index: PostIndex): void {
    context.subscriptions.push(
        vscode.commands.registerCommand('blog-filters.wrapAnchor', wrapAnchor),
        vscode.commands.registerCommand('blog-filters.wrapAnchor2', wrapAnchor2),
        vscode.commands.registerCommand('blog-filters.wrapAnchorLink', wrapAnchorLink),
        vscode.commands.registerCommand('blog-filters.insertCrossLink', () => insertCrossLink(index))
    );
}

async function getTitle(prompt: string): Promise<string | undefined> {
    const editor = vscode.window.activeTextEditor;
    if (!editor) return undefined;
    const selected = editor.document.getText(editor.selection);
    return selected || vscode.window.showInputBox({ prompt });
}

async function insert(text: string): Promise<void> {
    const editor = vscode.window.activeTextEditor;
    if (!editor) return;
    await editor.edit(eb => eb.replace(editor.selection, text));
}

async function wrapAnchor(): Promise<void> {
    const title = await getTitle('Section title');
    if (title) await insert(buildAnchorFilter(title));
}

async function wrapAnchor2(): Promise<void> {
    const title = await getTitle('Sub-section title');
    if (title) await insert(buildAnchor2Filter(title));
}

async function wrapAnchorLink(): Promise<void> {
    const title = await getTitle('Anchor title — must match the blog_anchor header exactly');
    if (!title) return;
    const displayText = await vscode.window.showInputBox({
        prompt: 'Display text (leave blank to use the anchor title)',
        placeHolder: title
    });
    if (displayText === undefined) return; // user pressed Escape
    await insert(buildAnchorLinkFilter(title, displayText || undefined));
}

export async function insertCrossLink(index: PostIndex): Promise<void> {
    const entries = index.getEntries();
    if (entries.length === 0) {
        vscode.window.showWarningMessage('No posts found — is this workspace the blog repo?');
        return;
    }

    const postPick = await vscode.window.showQuickPick(
        entries.map(e => ({ label: e.displayTitle, description: e.url, entry: e })),
        { placeHolder: 'Select a post' }
    );
    if (!postPick) return;

    if (postPick.entry.anchors.length === 0) {
        vscode.window.showWarningMessage('No blog_anchor calls found in that post.');
        return;
    }

    const anchorPick = await vscode.window.showQuickPick(
        postPick.entry.anchors.map(a => ({
            label: `${a.level === 'H1' ? '$(symbol-method)' : '$(symbol-field)'} ${a.title}`,
            description: `${postPick.entry.url}#${a.anchorId}`,
            anchor: a
        })),
        { placeHolder: 'Select a section' }
    );
    if (!anchorPick) return;

    const displayText = await vscode.window.showInputBox({
        prompt: 'Display text (leave blank to use the section title)',
        placeHolder: anchorPick.anchor.title
    });
    if (displayText === undefined) return;

    await insert(buildCrossLinkFilter(
        anchorPick.anchor.title,
        postPick.entry.url,
        displayText || undefined
    ));
}
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd vscode-extension && npx tsc --noEmit
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
cd ..
git add vscode-extension/src/commands.ts
git commit -m "feat: add commands.ts — wrapAnchor, wrapAnchor2, wrapAnchorLink, insertCrossLink"
```

---

## Task 7: completions.ts

**Files:**
- Create: `vscode-extension/src/completions.ts`

- [ ] **Step 1: Implement completions.ts**

`vscode-extension/src/completions.ts`:

```typescript
import * as vscode from 'vscode';
import { PostIndex } from './postIndex';

export class BlogFilterCompletionProvider implements vscode.CompletionItemProvider {
    constructor(private index: PostIndex) {}

    provideCompletionItems(
        document: vscode.TextDocument,
        position: vscode.Position
    ): vscode.CompletionItem[] {
        const linePrefix = document.lineAt(position).text.slice(0, position.character);
        // Only fire after the user has typed the opening of a filter call.
        if (!linePrefix.endsWith('{{ "') && !linePrefix.endsWith("{{ '")) {
            return [];
        }

        return [
            this.snippet('blog_anchor',
                '${1:Title}" | blog_anchor }}',
                'H1 section header with permalink anchor'),
            this.snippet('blog_anchor2',
                '${1:Title}" | blog_anchor2 }}',
                'H2 section header with permalink anchor'),
            this.snippet('blog_anchor_link',
                '${1:Title}" | blog_anchor_link }}',
                'Same-page anchor link'),
            this.snippet('blog_anchor_link (custom text)',
                '${1:Title}" | blog_anchor_link: "${2:link text}" }}',
                'Same-page anchor link with custom display text'),
            this.crossLinkItem(position)
        ];
    }

    private snippet(label: string, body: string, detail: string): vscode.CompletionItem {
        const item = new vscode.CompletionItem(label, vscode.CompletionItemKind.Function);
        item.insertText = new vscode.SnippetString(body);
        item.detail = detail;
        return item;
    }

    private crossLinkItem(position: vscode.Position): vscode.CompletionItem {
        const item = new vscode.CompletionItem('blog_cross_link', vscode.CompletionItemKind.Function);
        item.detail = 'Cross-post anchor link (opens Quick Pick)';
        // Delete the `{{ "` the user typed, then fire the command.
        // The command inserts the complete filter call at the cursor.
        item.range = new vscode.Range(position.translate(0, -4), position);
        item.insertText = '';
        item.command = { command: 'blog-filters.insertCrossLink', title: 'Insert cross-post link' };
        return item;
    }
}
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd vscode-extension && npx tsc --noEmit
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
cd ..
git add vscode-extension/src/completions.ts
git commit -m "feat: add BlogFilterCompletionProvider — IntelliSense after {{ \""
```

---

## Task 8: extension.ts (wire everything together)

**Files:**
- Create: `vscode-extension/src/extension.ts`

- [ ] **Step 1: Implement extension.ts**

`vscode-extension/src/extension.ts`:

```typescript
import * as vscode from 'vscode';
import * as path from 'path';
import { PostIndex } from './postIndex';
import { registerCommands } from './commands';
import { BlogFilterCompletionProvider } from './completions';

export async function activate(context: vscode.ExtensionContext): Promise<void> {
    const workspaceRoot = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
    if (!workspaceRoot) return;

    const postsDir = path.join(workspaceRoot, '_posts');
    const index = new PostIndex();

    const rebuild = (): void => { index.build(postsDir); };
    await index.build(postsDir);
    index.watch(postsDir, rebuild);
    context.subscriptions.push({ dispose: () => index.dispose() });

    registerCommands(context, index);

    context.subscriptions.push(
        vscode.languages.registerCompletionItemProvider(
            [{ language: 'markdown' }],
            new BlogFilterCompletionProvider(index),
            '"', "'"
        )
    );
}

export function deactivate(): void {}
```

- [ ] **Step 2: Compile the full extension**

```bash
cd vscode-extension && npm run compile
```

Expected: `out/` directory populated with `.js` files, no TypeScript errors.

- [ ] **Step 3: Run all tests one final time**

```bash
npm test
```

Expected: all tests pass.

- [ ] **Step 4: Commit**

```bash
cd ..
git add vscode-extension/src/extension.ts
git commit -m "feat: add extension.ts — wires PostIndex, commands, and completion provider"
```

---

## Task 9: install.sh

**Files:**
- Create: `vscode-extension/install.sh`

- [ ] **Step 1: Create install.sh**

`vscode-extension/install.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    cat <<EOF
Usage: $(basename "$0") [-h|--help]

Build and install the blog.lnx.cx VS Code extension locally.

Runs npm install, packages with vsce, and installs the .vsix into VS Code.
After it finishes, reload VS Code (Cmd+Shift+P → Reload Window) to activate.

Options:
  -h, --help    Show this message and exit
EOF
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        -h|--help) usage ;;
        *) echo "Unknown argument: $arg" >&2; usage ;;
    esac
done

cd "$SCRIPT_DIR"

echo "Installing dependencies..."
npm install

echo "Packaging extension..."
npx vsce package --no-dependencies

VSIX=$(ls -t ./*.vsix | head -1)
echo "Installing ${VSIX}..."
code --install-extension "${VSIX}"

echo ""
echo "Done. Reload VS Code (Cmd+Shift+P → Reload Window) to activate the extension."
```

- [ ] **Step 2: Make executable**

```bash
chmod +x vscode-extension/install.sh
```

- [ ] **Step 3: Run it**

```bash
./vscode-extension/install.sh
```

Expected: `node_modules/` refreshed, a `.vsix` file created in `vscode-extension/`, extension installed. Final line: `Done. Reload VS Code...`

- [ ] **Step 4: Commit**

```bash
git add vscode-extension/install.sh vscode-extension/*.vsix
git commit -m "feat: add install.sh — builds and installs the extension locally"
```

---

## Task 10: End-to-end verification

No code changes. Manual smoke test in VS Code after reloading the window.

- [ ] **Step 1: Reload VS Code**

`Cmd+Shift+P` → `Reload Window`

- [ ] **Step 2: Open a post**

Open any file in `_posts/` — e.g., `_posts/2024-06-27-gps-mapping-chicago-trails-part-1.markdown`.

- [ ] **Step 3: Test wrapAnchor (H1)**

Type a section title like `Overview`, select it, press `Cmd+Shift+1`.
Expected: selection replaced with `{{ "Overview" | blog_anchor }}`.

- [ ] **Step 4: Test wrapAnchor2 (H2)**

Type a sub-section title, select it, press `Cmd+Shift+2`.
Expected: `{{ "Sub-section title" | blog_anchor2 }}`.

- [ ] **Step 5: Test wrapAnchorLink (same-page link)**

Type an anchor title, select it, press `Cmd+Shift+L`.
- Press Enter with no display text → `{{ "Title" | blog_anchor_link }}`
- Type custom text → `{{ "Title" | blog_anchor_link: "custom text" }}`

- [ ] **Step 6: Test insertCrossLink (cross-post Quick Pick)**

Press `Cmd+Shift+X`. Confirm:
1. Quick Pick shows posts sorted newest-first with dates
2. Selecting a post shows its sections with H1/H2 labels and the resolved URL
3. Pressing Enter without display text inserts `{{ "Section" | blog_cross_link: "/url.html" }}`
4. Typing display text inserts `{{ "Section" | blog_cross_link: "/url.html", "custom" }}`

- [ ] **Step 7: Test IntelliSense**

Type `{{ "` in the post. Confirm the completion list appears with all five options. Select `blog_anchor` — confirm cursor lands on the title placeholder. Select `blog_cross_link` — confirm the Quick Pick opens.

- [ ] **Step 8: Commit any fixes found during smoke test, then done**

```bash
git add -p
git commit -m "fix: <describe what broke>"
```
