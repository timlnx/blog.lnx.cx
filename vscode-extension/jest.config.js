// SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
// SPDX-License-Identifier: MIT

module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/src/test/**/*.test.ts'],
  moduleNameMapper: {
    '^vscode$': '<rootDir>/src/test/__mocks__/vscode.ts'
  }
};
