#lang br/quicklang
(require json)

(define-macro (jsonic-mb PARSE-TREE)
  #'(#%module-begin
     (define result-string PARSE-TREE)
     (define validated-jsexpr (string->jsexpr result-string))
     (display result-string)))
(provide (rename-out [jsonic-mb #%module-begin]))

; json characters are passed through unmodified
(define-macro (jsonic-char CHAR-TOK-VALUE)
  #'CHAR-TOK-VALUE)
(provide jsonic-char)

; This macro simply passes the inner tokens to their own macro, combining their
; result into a string, plus trim white space off the ends
(define-macro (jsonic-program SEXP-OR-JSON-STR ...)
  #'(string-trim (string-append SEXP-OR-JSON-STR ...)))
(provide jsonic-program)

; This macro simply 'unwraps' jsonic-sexp into 'raw' racket so it can be
; evaluated.
(define-macro (jsonic-sexp SEXP-STR)
  ; We convert the expression into a syntax object
  (with-pattern ([SEXP-DATUM (format-datum '~a #'SEXP-STR)])
    ; We then evaluate it and interpret its result as json, converting that to
    ; a string
    #'(jsexpr->string SEXP-DATUM)))
(provide jsonic-sexp)
