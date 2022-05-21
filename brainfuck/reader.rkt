#lang br/quicklang
(require "parser.rkt")

(define (read-syntax path port)
  ; We path the port to make-tokenizer, which returns something that spits out
  ; tokens as needed (like a generator))
  ; We then parse the tokens
  (define parse-tree (parse path (make-tokenizer port)))
  (define module-datum `(module bf-mod "expander.rkt"
                          ,parse-tree))
  (datum->syntax #f module-datum))
(provide read-syntax)

(require brag/support)
(define (make-tokenizer port)
  (define (next-token)
    (define bf-lexer
      ; provided by brag/support
      (lexer
       ; `lexeme` is a special variable representing whatever was just matched
       [(char-set "><-.,+[]") lexeme]
       ; Anything else just moves to the next token (so it's ignored))
       [any-char (next-token)]))
    (bf-lexer port))
  next-token)
