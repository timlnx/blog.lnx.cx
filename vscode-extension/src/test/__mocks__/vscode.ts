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
