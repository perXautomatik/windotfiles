No, it is not possible to set `git config --global core.editor "code --wait"` to have different editors for different file formats. The `core.editor` setting applies to all files that Git opens in an editor, regardless of their format. If you want to use different editors for different file formats, you need to use a different approach.

One possible way is to use a wrapper script that can detect the file format and launch the appropriate editor accordingly. For example, you can create a script called `git-editor.sh` with the following content:

```bash
#!/bin/bash
# Get the file name from the first argument
FILE=$1
# Get the file extension
EXT=${FILE##*.}
# Choose the editor based on the extension
case $EXT in
  md) # For Markdown files, use VSCode
    code --wait "$FILE"
    ;;
  txt) # For plain text files, use Notepad++
    "C:/Program Files/Notepad++/notepad++.exe" -multiInst -notabbar -nosession -noPlugin "$FILE"
    ;;
  *) # For other files, use the default editor
    "$GIT_EDITOR" "$FILE"
    ;;
esac
```

Then, you need to make the script executable and set it as your `core.editor`:

```bash
chmod +x git-editor.sh
git config --global core.editor "/path/to/git-editor.sh"
```

This way, when Git opens a file in an editor, it will invoke the script and pass the file name as an argument. The script will then check the file extension and launch the corresponding editor. You can modify the script to suit your preferences and add more cases for different file formats.

You can find more information about how to use different editors for Git in this article². You can also find more tips and tricks for using Git in this article³. I hope this helps you with your task. 😊

Källa: Konversation med Bing, 2023-09-13
(1) Multiple git editors - Stack Overflow. https://stackoverflow.com/questions/18571741/multiple-git-editors.
(2) git config | Atlassian Git Tutorial. https://www.atlassian.com/git/tutorials/setting-up-a-repository/git-config.
(3) git - Setting different config for different repositories - Stack Overflow. https://stackoverflow.com/questions/18181439/setting-different-config-for-different-repositories.
(4) Git - pretty-formats Documentation. https://git-scm.com/docs/pretty-formats.