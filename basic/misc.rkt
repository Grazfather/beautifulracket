#lang br
(require "struct.rkt" "expr.rkt")
(provide b-rem b-print b-let b-input b-import b-export b-repl)

(define (b-rem val) (void))

(define (b-print . vals)
  (displayln (string-append* (map ~a vals))))

(define-macro (b-let ID VAL) #'(set! ID VAL))

(define-macro (b-input ID)
  ; We read the line and try to parse it as an int, but if we can't, we bind
  ; the original string
  #'(b-let ID (let* ([str (read-line)]
                     [num (string->number (string-trim str))])
                (or num str))))

; IMPORT and EXPORT are handled by our expander, so we can replace their
; occurrences in the outputted racket with void
(define-macro (b-import NAME) #'(void))

(define-macro (b-export NAME) #'(void))

(define-macro (b-repl . ALL-INPUTS)
  (with-pattern
      ([INPUTS (pattern-case-filter #'ALL-INPUTS
                 [(b-print . PRINT-ARGS)
                  #'(b-print . PRINT-ARGS)]
                 ; We want to print the result of expressions
                 [(b-expr . EXPR-ARGS)
                  #'(b-print (b-expr . EXPR-ARGS))]
                 ; Unlike when running basic scripts, we can't pre-define all
                 ; variables and set! them later, so we just use define
                 [(b-let ID VAL)
                  #'(define ID VAL)]
                 [(b-def FUNC-ID VAR-ID ... EXPR)
                  #'(define (FUNC-ID VAR-ID ...) EXPR)]
                 ; anything else, like goto doesn't make sense in a repl
                 [ANYTHING-ELSE
                  #'(error 'invalid-repl-input)])])
    #'(begin . INPUTS)))
