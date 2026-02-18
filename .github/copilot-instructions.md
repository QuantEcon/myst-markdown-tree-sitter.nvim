# GitHub Copilot Instructions for myst-markdown-tree-sitter.nvim

## Project Overview

This is a Neovim plugin that provides Tree-sitter based syntax highlighting for MyST (Markedly Structured Text) Markdown files. The plugin detects MyST-specific syntax (like `{code-cell}` directives) and applies proper highlighting through Tree-sitter language injection.

**Target Neovim Version:** >= 0.8.0  
**Primary Language:** Lua  
**Dependencies:** nvim-treesitter with markdown parser

## Architecture

### Modular Structure
The plugin uses a modular architecture with clear separation of concerns:

```
lua/myst-markdown/
├── init.lua          # Main entry point, orchestrates modules
├── config.lua        # Configuration management & validation
├── utils.lua         # Shared utilities, logging, caching
├── filetype.lua      # MyST filetype detection
├── highlighting.lua  # Tree-sitter highlighting setup
└── commands.lua      # User commands (:MystDebug, :MystStatus, :MystInfo)
```

**Key Principle:** Each module has a single responsibility. Don't create monolithic files.

### Tree-sitter Query Files
```
queries/markdown/
├── injections.scm    # Language injection for code-cell syntax
└── highlights.scm    # (if needed) Custom highlighting rules
```

**Important:** Tree-sitter loads queries based on **parser name**, not filetype. Since MyST files use the `markdown` parser, queries must be in `queries/markdown/`, NOT `queries/myst/`.

## Code Style Guidelines

### Lua Conventions
- **Indentation:** 2 spaces (enforced by `.stylua.toml`)
- **Line Length:** 100 characters max
- **Naming:** `snake_case` for functions and variables
- **Module Pattern:** Return a table of functions, keep state local

### Error Handling
- **Always use `vim.notify` for user feedback** - NO silent failures with `pcall`
- Use appropriate log levels: `vim.log.levels.ERROR`, `WARN`, `INFO`, `DEBUG`
- Provide context in error messages (what failed, why, how to fix)

```lua
-- ✅ Good
if not success then
  vim.notify(
    "[myst-markdown] Failed to detect filetype: Tree-sitter not available. Install nvim-treesitter.",
    vim.log.levels.ERROR
  )
  return false
end

-- ❌ Bad
if not success then
  return false  -- Silent failure
end
```

### Configuration
- **All magic numbers must be configurable** through `setup()` options
- Provide sensible defaults in `config.lua`
- Validate configuration values before use
- Document all options in README.md

### Performance
- Use caching where appropriate (filetype detection, tree-sitter queries)
- Limit buffer scanning (configurable `scan_lines`)
- Avoid repeated API calls in tight loops

## Testing Requirements

### Test Framework
We use **plenary.nvim** for testing. All tests must pass before committing.

```bash
make test        # Run all tests
make test-unit   # Run unit tests only
make test-integration  # Run integration tests only
```

### Test Structure
```
test/
├── minimal_init.lua           # Test environment setup
├── fixtures/                  # Test data files
│   ├── basic_myst.md
│   ├── edge_cases.md
│   └── regular_markdown.md
├── unit/                      # Unit tests (isolated functions)
│   └── detection_spec.lua
└── integration/               # Integration tests (full workflow)
    └── filetype_spec.lua
```

### Testing Guidelines
- **Write tests for visual features** - don't just document "test manually"
- Test both positive and negative cases
- Use descriptive test names: `"should detect code-cell with ipython"`
- Add fixtures for new MyST syntax patterns
- Integration tests should validate the complete workflow
- Use `assert.are.equal()` for exact matches, `assert.truthy()` for existence checks

### What to Test
1. **Pattern Detection:** Does it correctly identify MyST directives?
2. **Filetype Detection:** Does it set filetype to `myst` for MyST files?
3. **Parser Mapping:** Does it use the `markdown` parser for `myst` filetype?
4. **Edge Cases:** Empty files, large files, malformed syntax
5. **Configuration:** Do config options work as expected?

## Documentation Requirements

### Do NOT Create Summary Files
**Important:** When making changes, do NOT create separate summary Markdown files like `FIX_SUMMARY.md` or `CHANGES.md`.

### Extension Documentation Files

The plugin uses three primary documentation locations:

1. **README.md** - User-facing documentation
   - Installation instructions (multiple plugin managers)
   - Configuration examples with explanations
   - Features overview
   - Usage guide (commands, directives, languages)
   - Troubleshooting section
   - Testing information (concise overview)
   - Development setup instructions
   - Links to examples and help docs

2. **CHANGELOG.md** - Project history (Keep-a-Changelog format)
   - Add entries under `[Unreleased]` section
   - Use categories: Added, Changed, Deprecated, Removed, Fixed, Security
   - Be specific about what changed and why
   - Reference issue/PR numbers when applicable
   - Update when releasing versions

3. **doc/myst-markdown.txt** - Vim help documentation
   - Follows Vim help file format with proper tags
   - Comprehensive reference for `:help myst-markdown`
   - Covers all commands, configuration options, and usage
   - Include code examples in help format
   - Cross-reference related topics
   - Update when adding/changing user-facing features

**Do NOT create a `docs/` directory** - All documentation should live in these three files.

### Documentation Style
- Use clear, concise language
- Include code examples
- Link to related issues/PRs in CHANGELOG
- Keep README focused on getting started quickly
- Put detailed reference material in doc/myst-markdown.txt
- Keep all three files in sync when making changes

## Git & GitHub Workflow

### Branch Strategy
- `main` branch is protected
- Create feature branches for changes: `feature/description` or `fix/issue-number`
- Squash commits before merging to main

### Commit Messages
Follow Conventional Commits:
```
feat: add support for Jupyter output directives
fix: correct filetype detection for nested directives
docs: update configuration examples in README
test: add edge cases for code-cell detection
refactor: split highlighting logic into separate module
```

### GitHub CLI (`gh`) Usage
**Important:** The `gh` CLI provides interactive results which can hang the terminal.

**Always pipe output through `cat` or `head` when using `gh` commands:**

```bash
# ✅ Good - Pipe to avoid interactive pager
gh pr view 123 2>&1 | cat
gh issue list --limit 10 2>&1 | cat
```

**When creating PRs or releases that need multi-line descriptions:**

Use the `create_file` tool to write the body/notes to a file first, then reference it with `--body-file` or `--notes-file`. **Never** use heredocs, shell escaping, or inline multi-line strings in terminal commands — they are unreliable and error-prone.

```bash
# ✅ Good - Use create_file tool to write /tmp/pr_body.md, then:
gh pr create --title "feat: description" --body-file /tmp/pr_body.md --base main

# ✅ Good - Use create_file tool to write /tmp/release_notes.md, then:
gh release create v0.2.1 --title "v0.2.1" --notes-file /tmp/release_notes.md

# ❌ Bad - Heredocs and shell escaping break in terminal
gh pr create --title "feat: thing" --body "## Summary
Multi-line content here"

# ❌ Bad - Don't duplicate description in release title
gh release create v0.2.1 --title "v0.2.1 - Bug Fix: Description" --notes-file /tmp/release_notes.md
```

**Rationale:** The `create_file` tool reliably writes exact content without escaping issues. Heredocs and multi-line shell strings frequently get mangled by the terminal. The title/description is already in the notes file — keep GitHub release titles clean with just the version number.

### Pull Request Guidelines
- Write clear PR descriptions (what, why, how)
- Link related issues
- Ensure all tests pass (CI will verify)
- Update CHANGELOG.md
- Request review if significant changes

## Common Tasks

### Adding Support for New Language in Code Cells
1. Update `queries/markdown/injections.scm`:
   ```scheme
   ((fenced_code_block
     (info_string) @_lang
     (code_fence_content) @injection.content)
    (#match? @_lang "^(python|newlang)$")
    (#set! injection.language "python"))  ; or "newlang"
   ```
2. Add test case in `test/fixtures/`
3. Update README.md with new language support
4. Add to CHANGELOG.md under `[Unreleased] - Added`

### Adding New Configuration Option
1. Add default in `lua/myst-markdown/config.lua`
2. Document in README.md Configuration section
3. Add validation logic
4. Write test case
5. Update CHANGELOG.md

### Releasing a New Version
1. Update version in `lua/myst-markdown/version.lua` (single source of truth)
2. Update `website/index.html` — version appears in the hero badge and installation example
3. Move `[Unreleased]` entries in CHANGELOG.md to the new version heading
4. Tag and create GitHub release

### Fixing Bugs
1. Create test that reproduces the bug
2. Fix the code
3. Verify test passes
4. Update CHANGELOG.md under `[Unreleased] - Fixed`
5. Consider if README needs troubleshooting entry

### Performance Improvements
1. Measure before optimizing (use `:MystDebug` for diagnostics)
2. Document performance characteristics
3. Add benchmark if significant change
4. Update CHANGELOG.md under `[Unreleased] - Changed`

## Tree-sitter Specific

### Query File Patterns
MyST uses extended Markdown syntax. Key patterns to match:

```scheme
; Code cell directive
{code-cell} python
{code-cell} ipython
{code-cell} javascript

; Other directives
{note}
{warning}
{admonition}
```

### Parser Relationship
- **Filetype:** `myst` (custom filetype we detect)
- **Parser:** `markdown` (existing tree-sitter parser)
- **Queries:** `queries/markdown/` (loaded by parser, not filetype)

This mapping is critical: changes to query files go in `queries/markdown/`, not a hypothetical `queries/myst/` directory.

## CI/CD

GitHub Actions runs automatically on push/PR:
- Linting with Stylua
- All tests (unit + integration)
- Multiple Neovim versions (nightly, stable)

Ensure `.github/workflows/ci.yml` is up-to-date with test commands.

## Plugin Manager Support

The plugin supports all major Neovim plugin managers:
- lazy.nvim (recommended)
- packer.nvim
- vim-plug
- paq-nvim

Test installation instructions with lazy.nvim (most common) before documenting.

## Debug Commands

Users can diagnose issues with:
- `:MystInfo` - Plugin information
- `:MystStatus` - Current buffer status
- `:MystDebug` - Comprehensive diagnostics

These commands should provide actionable information for troubleshooting.

## Version Support

- **Minimum Neovim:** 0.8.0 (for stable Tree-sitter API)
- **Recommended:** Latest stable release
- Test on both stable and nightly when possible

## Questions?

Refer to:
- `README.md` - User documentation, testing overview, development setup
- `CHANGELOG.md` - Project history and version tracking
- `doc/myst-markdown.txt` - Vim help documentation (`:help myst-markdown`)
- `CONTRIBUTING.md` - Contribution workflow and guidelines
- `examples/` - Sample configurations for common use cases
- Existing code for patterns and style

When in doubt, maintain consistency with the existing codebase.
