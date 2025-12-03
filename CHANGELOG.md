# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.2] - 2025-12-04

### Changed
- **Improved `:MystDebug` and `:MystStatus` output** - Fixed misleading "Tree-sitter highlighter: not active" message
  - Now uses more reliable parser detection methods
  - Shows clear status indicators (✓, ✗, ⚠) for highlighting state
  - Explains that nvim-treesitter internal state can show false negatives
  - Primary success indicator is now parser + injection queries loaded

## [0.4.1] - 2025-12-04

### Added
- **`python3` language support** - Added `python3` as a recognized language alias for `{code-cell}` directives
  - Now supports: `python`, `python3`, `ipython`, `ipython3`

## [0.4.0] - 2025-12-03

### Added
- **Single source of truth for version management** - Version now defined in `lua/myst-markdown/version.lua`
  - Prevents version drift between modules
  - Both `init.lua` and `commands.lua` now reference this single source
- **Comprehensive integration tests** - Added 4 new integration test files (33 new tests):
  - `test/integration/version_spec.lua` - Version consistency tests
  - `test/integration/commands_spec.lua` - User command tests
  - `test/integration/highlighting_spec.lua` - Tree-sitter highlighting tests
  - `test/integration/setup_spec.lua` - Plugin setup and module loading tests
- Total test count increased from 77 to 110 tests

### Changed
- **Simplified filetype detection** - Consolidated to use `vim.filetype.add()` API in ftdetect
- **Reduced logging verbosity** - Changed startup logging from INFO to DEBUG level
- **Cleaned up test directory** - Moved 47 legacy test files to `test/legacy/` with explanatory README
- Moved `VISUAL_TEST.md` back to root level for easy manual testing access

### Removed
- **Dead code cleanup**:
  - Removed unused `refresh_highlighting()` call from ftdetect/myst.lua
  - Removed unused functions from utils.lua: `cache_*`, `defer`, `wait`, `get_parser`
  - Removed duplicate filetype detection autocmd (now uses single `vim.filetype.add()`)
- Deleted `REFACTORING_SUMMARY.md` (per project guidelines)
- Removed `test_latex_highlighting.tex` from root (moved to legacy)

### Fixed
- **Version consistency** - commands.lua now references `version.lua` instead of hardcoded value
- **CHANGELOG links** - Updated version comparison links to be accurate

## [0.3.2] - 2025-11-07

### Fixed
- **Correct LaTeX highlighting for `{math}` directives**: Now uses `latex` parser to match `$$` block behavior
  - v0.3.1 incorrectly used `markdown_inline` parser which didn't provide LaTeX highlighting
  - `$$` blocks in markdown automatically get `latex` parser injection from nvim-treesitter
  - `{math}` directives now use the same `latex` parser for consistent green highlighting
  - Both formats now show identical LaTeX command highlighting (e.g., `\mathbf`, `\begin`, `\end` in green)

### Technical Details
- Investigation revealed `$$` blocks use `language: latex` with `@function.latex` → Green
- `{math}` with `markdown_inline` was using `language: markdown` with `@markup.raw.block` → String
- Solution: Changed `{math}` injection from `markdown_inline` back to `latex` parser
- This matches the automatic behavior of `$$` blocks in standard markdown

## [0.3.1] - 2025-11-07 [YANKED - Incorrect Fix]

### Note
This version attempted to use `markdown_inline` parser but investigation showed this was incorrect.
Use v0.3.2 instead which properly uses the `latex` parser.

## [0.3.0] - 2025-11-07

### Added
- **LaTeX syntax highlighting for `{math}` directives** - Major new feature
- Support for `{math}` directives with YAML configuration (`:label:`, `:nowrap:`, etc.)
- Test suite for math directive support (6 new tests, total: 82 tests)
- Test fixture `test/fixtures/math_directive.md` demonstrating various math formats
- Test fixture `test/fixtures/yaml_syntax_formats.md` showing both MyST config formats
- Documentation for both concise and YAML block configuration formats
- Comprehensive examples in `VISUAL_TEST.md` for both config formats

### Changed
- Reorganized `VISUAL_TEST.md` to clearly demonstrate both MyST configuration syntaxes
  - Concise format: `:tags: [value]`, `:linenos:` (with colons)
  - YAML block format: `tags: [value]`, `linenos: true` (without leading colons, in `---` blocks)
- Updated README.md with math directive documentation and examples
- Improved documentation clarity around MyST YAML syntax formats

### Fixed
- Corrected YAML block syntax examples to use proper MyST format
- Fixed inconsistencies between test titles and actual syntax used

## [0.2.1] - 2025-11-07

### Fixed
- Tree-sitter injection queries now support code-cell directives with YAML configuration blocks
- Code cells with `:tags:`, `:linenos:`, or other MyST options now correctly receive syntax highlighting
- Changed from exact string matching (`#eq?`) to regex matching (`#match?`) to handle config blocks

### Added
- Test suite for code-cell directives with configuration (21 new tests)
- Test fixture `test/fixtures/code_cell_with_config.md` demonstrating various config formats
- `VISUAL_TEST.md` for manual verification of the fix

## [0.2.0] - 2025-11-07

### Major Refactoring Release

This release represents a complete overhaul of the plugin architecture, testing infrastructure, and documentation.

### Added
- LICENSE file (MIT)
- .gitignore for Neovim projects
- .stylua.toml for consistent code formatting
- .editorconfig for editor consistency
- .luacheckrc for Lua linting configuration
- CHANGELOG.md for version tracking
- Comprehensive testing framework with plenary.nvim
- Test fixtures for unit and integration testing
- Edge case tests for malformed syntax, unicode, and boundary conditions
- Performance tests for large files and memory efficiency
- Makefile for easy test running, code formatting, and linting
- `make install-dev-tools` target for installing development dependencies
- GitHub Actions CI/CD for automated testing and linting
- `:MystInfo` command to show plugin information
- Modular architecture with separate files for config, filetype, highlighting, commands, and utils
- Configuration options for scan_lines, timeouts, and caching
- Detection caching for improved performance
- LuaDoc annotations for better documentation
- Comprehensive error handling with vim.notify
- Guard clauses for safety and robustness
- **doc/myst-markdown.txt** - Vim help documentation for `:help myst-markdown`
- **examples/** directory with sample configurations:
  - basic.lua - Minimal setup
  - advanced.lua - Full configuration with all options
  - performance.lua - Optimized for large files
  - jupyter.lua - Jupyter notebook integration
  - lazy-nvim.lua - Complete lazy.nvim plugin spec
  - with-lsp.lua - Integration with LSP and development tools
- **test/fixtures/** - Comprehensive edge case test files
  - edge_cases_comprehensive.md - Various edge cases
  - large_file.md - Performance testing with 100+ code cells
- **50 unit tests** covering pattern detection, edge cases, and performance
- **5 integration tests** for complete workflow validation

### Changed
- Refactored monolithic init.lua into modular structure:
  - `config.lua` - Configuration management
  - `filetype.lua` - Filetype detection logic
  - `highlighting.lua` - Highlighting setup
  - `commands.lua` - User commands
  - `utils.lua` - Shared utilities
- Improved error handling with consistent vim.notify usage
- Made configuration values configurable (no more magic numbers)
- Enhanced code readability and maintainability
- Updated README with configuration examples and better documentation
- Improved CONTRIBUTING.md with clearer architecture explanation
- Consolidated testing documentation into README (removed separate docs/ directory)

### Removed
- Duplicate `queries/myst/` directory (was not being used, only `queries/markdown/` is loaded)
- Empty `setup_injection_queries()` function that did nothing
- Redundant code and silent failures
- **docs/** directory - documentation consolidated into README.md, CHANGELOG.md, and doc/ (for Vim help)

### Fixed
- Consistent error handling throughout codebase
- Buffer validation checks to prevent crashes
- Cache invalidation on buffer changes

## [0.1.0] - 2025-08-20

### Added
- Initial release
- MyST Markdown filetype detection
- Tree-sitter integration for syntax highlighting
- Code-cell directive support for multiple languages (Python, JavaScript, Bash, R, Julia, etc.)
- Manual commands: `:MystDebug` and `:MystStatus`
- Support for lazy.nvim and packer.nvim

### Fixed
- Priority parameter compatibility issues (Issue #44)
- MystRefresh activation enhancement (Issue #54)
- Various highlighting and injection query fixes

[Unreleased]: https://github.com/QuantEcon/myst-markdown-tree-sitter.nvim/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/QuantEcon/myst-markdown-tree-sitter.nvim/compare/v0.3.2...v0.4.0
[0.3.2]: https://github.com/QuantEcon/myst-markdown-tree-sitter.nvim/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/QuantEcon/myst-markdown-tree-sitter.nvim/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/QuantEcon/myst-markdown-tree-sitter.nvim/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/QuantEcon/myst-markdown-tree-sitter.nvim/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/QuantEcon/myst-markdown-tree-sitter.nvim/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/QuantEcon/myst-markdown-tree-sitter.nvim/releases/tag/v0.1.0
