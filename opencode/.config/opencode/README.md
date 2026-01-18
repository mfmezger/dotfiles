# OpenCode Configuration

This directory contains OpenCode AI coding agent configuration for this dotfiles repository.

## Structure

- `opencode.json` - Main OpenCode configuration file
- `rules/` - Additional rule files (optional)

## Usage

OpenCode automatically reads the `AGENTS.md` file in the project root. This `.opencode` directory allows for additional configuration:

1. Reference external instruction files in `opencode.json`
2. Store modular rule files in `rules/` subdirectory

## Example Configuration

To add external instruction files to opencode.json:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "docs/contributing.md",
    "rules/*.md"
  ]
}
```

See [OpenCode Rules Documentation](https://opencode.ai/docs/rules/) for more details.
