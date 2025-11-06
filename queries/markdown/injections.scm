;; MyST Markdown Language Injection Queries (Enhanced)
;; These queries extend standard markdown with MyST code-cell support
;; Support code-cells with optional YAML configuration blocks

;; MyST code-cell injection patterns (processed first)
;; Inject Python parser into code-cell python blocks
;; Matches: {code-cell} python, {code-cell} ipython, {code-cell} ipython3
;; With or without YAML config (---, :tags:, etc.)
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#match? @_lang "^\\{code-cell\\}\\s+(python|ipython|ipython3)")
  (#set! injection.language "python"))

;; Inject JavaScript parser into code-cell javascript blocks  
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#match? @_lang "^\\{code-cell\\}\\s+(javascript|js)")
  (#set! injection.language "javascript"))

;; Inject Bash parser into code-cell bash blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#match? @_lang "^\\{code-cell\\}\\s+(bash|sh)")
  (#set! injection.language "bash"))

;; Inject R parser into code-cell r blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#match? @_lang "^\\{code-cell\\}\\s+r\\b")
  (#set! injection.language "r"))

;; Inject Julia parser into code-cell julia blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#match? @_lang "^\\{code-cell\\}\\s+julia")
  (#set! injection.language "julia"))

;; Inject C++ parser into code-cell cpp blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#match? @_lang "^\\{code-cell\\}\\s+cpp")
  (#set! injection.language "cpp"))

;; Inject C parser into code-cell c blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#match? @_lang "^\\{code-cell\\}\\s+c\\b")
  (#set! injection.language "c"))

;; Inject Rust parser into code-cell rust blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#match? @_lang "^\\{code-cell\\}\\s+rust")
  (#set! injection.language "rust"))

;; Inject Go parser into code-cell go blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#match? @_lang "^\\{code-cell\\}\\s+go\\b")
  (#set! injection.language "go"))

;; Inject TypeScript parser into code-cell typescript blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#match? @_lang "^\\{code-cell\\}\\s+(typescript|ts)")
  (#set! injection.language "typescript"))

;; MyST math directive injection
;; Inject LaTeX parser into {math} blocks for proper math syntax highlighting
;; Supports both simple and YAML-configured math directives
;; Example: ```{math} or ```{math}\n:label: eq_name
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#match? @_lang "^\\{math\\}")
  (#set! injection.language "latex"))





;; Standard markdown language injection (preserve existing behavior)
;; This handles regular markdown code blocks like ```python
;; Must match the official tree-sitter-markdown pattern
((fenced_code_block
  (info_string
    (language) @injection.language)
  (code_fence_content) @injection.content)
  (#not-eq? @injection.language "")
  (#not-match? @injection.language "^\\{"))

;; LaTeX math support: Enable $$...$$ and $...$ highlighting via markdown_inline parser
;; Only apply to content that's NOT inside fenced_code_blocks to avoid conflicts
((paragraph
  (inline) @injection.content)
  (#set! injection.language "markdown_inline"))

((pipe_table_cell) @injection.content
  (#set! injection.language "markdown_inline"))