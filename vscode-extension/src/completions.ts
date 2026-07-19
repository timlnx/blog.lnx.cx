// SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
// SPDX-License-Identifier: MIT

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
        // Delete the 4 chars the user typed (`{`, `{`, ` `, `"` or `'`), then fire the command.
        // The command inserts a complete filter call — no doubled opening braces.
        item.range = new vscode.Range(position.translate(0, -4), position);
        item.insertText = '';
        item.command = { command: 'blog-filters.insertCrossLink', title: 'Insert cross-post link' };
        return item;
    }
}
