# OpenCode Rules for Dotfiles Repository

## Permission Configuration

The OpenCode configuration in this repository is set up with specific permissions:

### Allowed Bash Commands
- `uv sync` - Sync Python dependencies
- `uv run pytest *` - Run pytest with any arguments
- `uv run pytest` - Run pytest without arguments
- `go mod tidy` - Clean up Go dependencies
- `go test *` - Run Go tests with any arguments
- `go test` - Run Go tests without arguments
- `git status` - View git status
- `git log *` - View git logs
- `git diff *` - View git diffs
- `ls` - List directory contents
- `find *` - Find files
- `grep *` - Search file contents
- `head` - View beginning of files

### Shell Tool Configuration Notes

#### cat → bat Replacement
In this dotfiles repository, the `cat` command is replaced with `bat` via zsh-abbr:
- `bat` provides syntax highlighting, line numbers, and Git integration
- It's interactive with scrollable output and search (press `/`)
- When AI agents use `cat`, they will invoke `bat` instead
- For raw output (no coloring), use `bat --plain` or `bat -p`
- Configuration: See `zsh/.zshrc` line 116

#### eza → ls Replacement
The `ls` command is replaced with `eza` for better icons and Git status

### Web Access
- `websearch` - Allowed for searching the web
- `codesearch` - Allowed for code searches

### File Operations
- `read` - Set to "allow" (always allow reading files)
- `glob` - Set to "allow" (always allow file pattern matching)
- `edit` - Set to "ask" (requires approval for file edits)
- All other operations - Set to "ask" by default

## Usage Guidelines

When working with this dotfiles repository, OpenCode will:

1. **Automatically allow** reading files and basic navigation
2. **Prompt for approval** before making file edits (edit operations)
3. **Automatically allow** running the specific bash commands listed above
4. **Prompt for approval** for any other bash commands

## Recommendations

- Since this is a dotfiles repository, file edits should be made carefully
- Always review changes before approving edit operations
- Use `uv sync` and `go mod tidy` to keep dependencies clean
- Run tests with `uv run pytest` or `go test` as needed
- Use websearch to research tools and best practices when needed

## Customization

To modify permissions, edit `.opencode/opencode.json`. See the [OpenCode Permissions Documentation](https://opencode.ai/docs/permissions/) for details.
