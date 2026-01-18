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
