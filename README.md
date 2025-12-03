# myst-markdown-tree-sitter.nvim

A MyST Markdown plugin for neovim with tree-sitter backend support.

This plugin provides syntax highlighting and filetype detection for [MyST (Markedly Structured Text)](https://mystmd.org/) markdown files in Neovim. It extends the standard markdown highlighting with MyST-specific features like directives and roles.

## Features

- **Automatic filetype detection** for MyST markdown files
- **Code-cell directive highlighting** with language-specific syntax highlighting for `{code-cell}` directives
- **Math directive highlighting** with LaTeX syntax highlighting for `{math}` directives
- **Tree-sitter integration** for robust parsing
- **Markdown compatibility** - works alongside existing markdown features
- **Modular architecture** with clean separation of concerns
- **Comprehensive testing** with 110 tests covering directives, edge cases, and performance
- **Vim help documentation** - Access via `:help myst-markdown`
- **Configuration examples** - See `examples/` directory for common use cases

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'QuantEcon/myst-markdown-tree-sitter.nvim',
  dependencies = {'nvim-treesitter/nvim-treesitter'},
  ft = {"markdown", "myst"},
  config = function()
    -- Your MyST setup here
    -- Ensure this runs after treesitter is loaded
    require('myst-markdown').setup()
  end,
  priority = 1000, -- Load after other markdown plugins
}
```

**Configuration Options Explained:**
- `ft = {"markdown", "myst"}` - Lazy loads the plugin only when opening markdown or MyST files, improving startup performance
- `priority = 1000` - Ensures this plugin loads after other markdown plugins to prevent highlighting conflicts
- `config` function - Runs the setup after treesitter is properly loaded

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'QuantEcon/myst-markdown-tree-sitter.nvim',
  requires = {'nvim-treesitter/nvim-treesitter'},
  config = function()
    require('myst-markdown').setup()
  end
}
```

### Testing from a Specific Branch

To test unreleased changes from a specific branch (useful for testing fixes before they're merged):

#### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'QuantEcon/myst-markdown-tree-sitter.nvim',
  branch = 'branch-name',  -- Replace with the actual branch name
  dependencies = {'nvim-treesitter/nvim-treesitter'},
  ft = {"markdown", "myst"},
  config = function()
    -- Your MyST setup here
    -- Ensure this runs after treesitter is loaded
    require('myst-markdown').setup()
  end,
  priority = 1000, -- Load after other markdown plugins
}
```

**Note:** After changing branches or updating the plugin, you may need to:
1. Restart Neovim
2. Run `:PackerSync` (for packer) or `:Lazy sync` (for lazy.nvim)
3. Run `:TSUpdate` to ensure tree-sitter parsers are up to date

## Requirements

- Neovim >= 0.8.0
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- Tree-sitter markdown parser: `:TSInstall markdown markdown_inline`
- **Recommended:** `:TSInstall python latex` (for code-cell and math directive highlighting)

## Usage

The plugin automatically detects MyST markdown files based on content patterns and applies appropriate syntax highlighting.

### Configuration

The plugin provides sensible defaults, but you can customize behavior:

```lua
require('myst-markdown').setup({
  -- Enable debug logging (shows verbose initialization messages)
  debug = false,

  -- Filetype detection settings
  detection = {
    scan_lines = 50,  -- Number of lines to scan for MyST patterns
  },
  
  -- Performance settings
  performance = {
    defer_timeout = 50,     -- ms to defer highlighting setup
    refresh_wait = 100,     -- ms to wait during refresh
    cache_enabled = true,   -- Enable detection caching
  },
  
  -- Highlighting settings
  highlighting = {
    enabled = true,
  },
})
```

### Manual Commands

For debugging and information, the plugin provides these commands:

- `:MystDebug` - Show comprehensive debugging information about MyST state and tree-sitter queries
- `:MystStatus` - Quick health check of MyST highlighting status
- `:MystInfo` - Show plugin version and configuration information

These commands are useful for debugging highlighting issues and verifying MyST functionality.

### Code Cells

MyST code-cell directives like this:

````markdown
```{code-cell} python
import pandas as pd
df = pd.DataFrame()
print(df)
```
````

Will be highlighted with language-specific syntax highlighting, similar to standard markdown code blocks.

### Supported Languages

The plugin provides injection queries for the following languages in `{code-cell}` directives:

**Commonly Available:**
- Python (`python`, `python3`, `ipython`, `ipython3`) - Usually pre-installed ✅
- LaTeX (for `{math}` directives) - Install with `:TSInstall latex`

**Additional Languages** (require manual installation):
- JavaScript (`javascript`, `js`) - `:TSInstall javascript`
- TypeScript (`typescript`, `ts`) - `:TSInstall typescript`
- Bash (`bash`, `sh`) - `:TSInstall bash`
- R (`r`) - `:TSInstall r`
- Julia (`julia`) - `:TSInstall julia`
- C (`c`) - `:TSInstall c`
- C++ (`cpp`) - `:TSInstall cpp`
- Rust (`rust`) - `:TSInstall rust`
- Go (`go`) - `:TSInstall go`

**Important:** Syntax highlighting only works if you've installed the corresponding tree-sitter parser. If a code-cell isn't highlighted, install the parser with `:TSInstall <language>`.

**To install multiple parsers at once:**
```vim
:TSInstall python latex javascript bash rust
```

### MyST Code-Cell Directives

The plugin provides syntax highlighting for MyST `{code-cell}` directives with language-specific syntax highlighting support.

### MyST Math Directives

The plugin provides LaTeX syntax highlighting for MyST `{math}` directives:

```markdown
```{math}
:label: eq_name

\begin{aligned}
    y_1 &= a_{11} x_1 + a_{12} x_2 \\
    y_2 &= a_{21} x_1 + a_{22} x_2
\end{aligned}
` ``
```

Math directives support YAML configuration options like `:label:`, `:nowrap:`, etc., just like code-cell directives.

## Configuration

The plugin works automatically without configuration:

```lua
require('myst-markdown').setup()
```

### Manual Commands

The plugin provides several commands for troubleshooting and manual control:

- `:MystStatus` - Quick health check of MyST highlighting status
- `:MystDebug` - Detailed debugging information with diagnostic suggestions

### Troubleshooting

If MyST highlighting is not working:

1. **Run `:MystStatus`** for a quick health check
2. **For detailed diagnosis, run `:MystDebug`**
3. Ensure the file contains MyST directives like `{code-cell}` or `{math}`
4. Verify nvim-treesitter is installed and markdown parser is available

**Code-cell highlighting not working?**
- Check if the language parser is installed: `:TSInstall <language>`
- Example: For Python highlighting, run `:TSInstall python`
- Verify parser is loaded: `:lua print(vim.inspect(require('nvim-treesitter.parsers').get_parser()))`

**Math directive highlighting not working?**
- Install the LaTeX parser: `:TSInstall latex`
- Verify it's installed: `:TSInstall` (check the list)

**To see which parsers you have installed:**
```vim
:TSInstallInfo
```

### Known Limitations

- **Inline roles** (e.g., `{math}\`a^2 + b^2\``) are not currently supported. Only block directives like ` ```{math} ` have syntax highlighting.

## Documentation

### Vim Help

Comprehensive documentation is available via Vim's built-in help system:

```vim
:help myst-markdown
:help myst-markdown-commands
:help myst-markdown-configuration
:help myst-markdown-troubleshooting
```

### Configuration Examples

The `examples/` directory contains ready-to-use configurations for common scenarios:

- **[basic.lua](examples/basic.lua)** - Minimal setup (recommended starting point)
- **[advanced.lua](examples/advanced.lua)** - Full configuration with all options and custom keymaps
- **[performance.lua](examples/performance.lua)** - Optimized settings for large files
- **[jupyter.lua](examples/jupyter.lua)** - Jupyter notebook integration with code execution
- **[lazy-nvim.lua](examples/lazy-nvim.lua)** - Complete lazy.nvim plugin specification
- **[with-lsp.lua](examples/with-lsp.lua)** - Integration with LSP, linters, and formatters

Copy any example to your config and adjust as needed.

## Testing

The plugin includes comprehensive test coverage with **110 tests** (77 unit + 33 integration):

**Test Categories:**
- **Unit tests** - Pattern detection, configuration, edge cases, performance
- **Integration tests** - Filetype detection, tree-sitter integration, commands, version management

**Run tests locally:**

```bash
make test              # Run all tests
make test-unit         # Unit tests only
make test-integration  # Integration tests only
```

**Test fixtures** are available in `test/fixtures/` for manual verification.

**Testing philosophy:** We focus on state verification and API testing rather than visual verification. Tests validate that:
- MyST patterns are correctly detected
- Filetype is properly set based on content
- Tree-sitter queries load and inject languages correctly
- Configuration options work as expected
- Edge cases are handled gracefully

See individual test files in `test/unit/` and `test/integration/` for examples.

## Development

### Setting Up Development Environment

Install development tools:

```bash
make install-dev-tools  # Installs StyLua and Luacheck
```

### Code Quality Tools

- **Format code:** `make format` (uses StyLua)
- **Lint code:** `make lint` (uses Luacheck)
- **Check formatting:** `make check-format`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.
