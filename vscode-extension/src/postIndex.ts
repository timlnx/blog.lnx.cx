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
        try {
            await fs.promises.access(postsDir);
        } catch {
            return;
        }

        const filenames = (await fs.promises.readdir(postsDir))
            .filter(f => f.endsWith('.markdown') || f.endsWith('.md'))
            .sort()
            .reverse();

        const results = await Promise.all(
            filenames.map(async filename => {
                const url = derivePostUrl(filename);
                if (!url) return null;
                try {
                    const content = await fs.promises.readFile(
                        path.join(postsDir, filename), 'utf8'
                    );
                    return {
                        filename,
                        displayTitle: parseFrontMatterTitle(content) ?? slugToTitle(filename),
                        url,
                        anchors: parseAnchors(content)
                    } as PostEntry;
                } catch {
                    return null;
                }
            })
        );

        this.entries = results.filter((e): e is PostEntry => e !== null);
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
        return [...this.entries];
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
