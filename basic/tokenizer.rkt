#lang br
(require "lexer.rkt" brag/support)

; The [path #f] part is a]
(define (make-tokenizer ip [path #f])
  (port-count-lines! ip)
  ; This sets the filepath parameter in the lexer
  (lexer-file-path path)
  (define (next-token) (basic-lexer ip))
  next-token)

(provide make-tokenizer)