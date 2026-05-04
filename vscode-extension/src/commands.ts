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
    return selected.trim() || vscode.window.showInputBox({ prompt });
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

async function insertCrossLink(index: PostIndex): Promise<void> {
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
