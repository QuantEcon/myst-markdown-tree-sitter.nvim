; extends

;; MyST {math} directive: apply math styling to content
;; This gives {math} blocks the same base @markup.math highlight that
;; $$ blocks receive from the markdown_inline parser, producing
;; consistent visual styling between the two math syntaxes.
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @markup.math)
  (#match? @_lang "^\\{math\\}")
  (#set! priority 95))

;; Standard ```latex code blocks: apply math styling for consistency
;; Without this, ```latex blocks only get @markup.raw.block while
;; $$ and {math} blocks get @markup.math, causing visual differences.
((fenced_code_block
  (info_string
    (language) @_lang)
  (code_fence_content) @markup.math)
  (#eq? @_lang "latex")
  (#set! priority 95))
