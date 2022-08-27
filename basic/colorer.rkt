#lang br
(require "lexer.rkt" brag/support)
(provide basic-colorer)

(define (basic-colorer port)
  ; Define a handler for lexer errors of type exn:fail:read
  (define (handle-lexer-error excn)
    ; Extract the srclocs from it using read-srclocs
    (define excn-srclocs (exn:fail:read-srclocs excn))
    ; Return an ERROR token for it
    (srcloc-token (token 'ERROR) (car excn-srclocs)))
  (define srcloc-tok
    ; Setup a handler for exn:fail:read type exceptions
    (with-handlers ([exn:fail:read? handle-lexer-error])
      (basic-lexer port)))
  (match srcloc-tok
    [(? eof-object?) (values srcloc-tok 'eof #f #f #f)]
    [else
      ; Define type, val, srcloc, posn, & span by pattern matching on srcloc-tok
      (match-define
        (srcloc-token
          (token-struct type val _ _ _ _ _)
          (srcloc _ _ _ posn span)) srcloc-tok)
      (define start posn)
      (define end (+ start span))
      ; From these define cat & paren by using match to create a tuple and
      ; match define to assign to the vars
      (match-define (list cat paren)
                    (match type
                           ['STRING '(string #f)]
                           ['REM '(comment #f)]
                           ['ERROR '(error #f)]
                           [else (match val
                                        [(? number?) '(constant #f)]
                                        [(? symbol?) '(symbol #f)]
                                        ["(" '(parenthesis |(|)]
                                        [")" '(parenthesis |)|)]
                                        [else '(no-color #f)])]))
      ; Return the colour annotation
      (values val cat paren start end)]))
