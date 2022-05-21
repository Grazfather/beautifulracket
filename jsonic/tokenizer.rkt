#lang br/quicklang
(require brag/support)

(define (make-tokenizer port)
  (define (next-token)
    (define jsonic-lexer
      (lexer
       ; We skip over comments
       [(from/to "//" "\n") (next-token)]
       ; We capture anything between "@$" and "$@" and make it a `SEXP-TOK`
       [(from/to "@$" "$@")
        ; `trim-ends` removes the literal "@$" and "$@" which were captured in
        ; the match
        (token 'SEXP-TOK (trim-ends "@$" lexeme "$@"))]
       ; any-char is like an else branch, matching anything else
       [any-char (token 'CHAR-TOK lexeme)]))
    (jsonic-lexer port))
  next-token)
(provide make-tokenizer)
