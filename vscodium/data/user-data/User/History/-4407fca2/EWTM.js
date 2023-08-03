const vscode = require('vscode');

// Macro configuration settings
module.exports.macroCommands = {
  CutPasteTopBottom: {
    no: 1,
    func: cutPasteTopBottomFunc
  }
};

// CutPasteTopBottom macro
function cutPasteTopBottomFunc() {
  const editor = vscode.window.activeTextEditor;
  if (!editor) {
    // Return an error message if necessary.
    return 'Editor is not opening.';
  }
  const document = editor.document;
  const selection = editor.selection;
  const text = document.getText(selection);

    

  // Toggle between top and bottom of file
  let position;
  if (selection.start.line === 0) {
    // Go to bottom of file
    position = new vscode.Position(document.lineCount - 1, document.lineAt(document.lineCount - 1).text.length);
  } else {
    // Go to top of file
    position = new vscode.Position(0, 0);
  }
  

// Cut the current line
editor.edit((editBuilder) => {
  editBuilder.delete(selection);
  editBuilder.insert(position, '\n'+ text + '\n');
});

  // Move cursor to the pasted line
  //editor.selection = new vscode.Selection(position, position);
}
