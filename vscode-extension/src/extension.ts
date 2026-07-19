// SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
// SPDX-License-Identifier: MIT

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

    await index.build(postsDir);
    index.watch(postsDir, () => { void index.build(postsDir).catch(() => {}); });
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
