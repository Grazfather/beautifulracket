#lang br/quicklang
(require "parser.rkt" "tokenizer.rkt")

; We define a simple language (a reader and expander) that quotes the parse
; tree instead of running it
(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port path)))
  (strip-bindings
    #`(module basic-parser-mod basic/parse-only
        #,parse-tree)))
(module+ reader (provide read-syntax))

(define-macro (parser-only-mb PARSE-TREE)
  #'(#%module-begin
     'PARSE-TREE))
(provide (rename-out [parser-only-mb #%module-begin]))
