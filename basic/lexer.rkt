#lang br
(require brag/support)

(define-lex-abbrev digits (:+ (char-set "0123456789")))

(define basic-lexer
  (lexer-srcloc
  ["\n" (token 'NEWLINE lexeme)]
  ; Ignore whitespace
  [whitespace (token lexeme #:skip? #t)]
  ; We stop BEFORE the newline since we still need it to break up statements
  [(from/stop-before "rem" "\n") (token 'REM lexeme)]
  ; All basic keywords/symbols
  [(:or "print" "goto" "end"
	"+" ":" ";") (token lexeme lexeme)]
  [digits (token 'INTEGER (string->number lexeme))]
  ; `:?` behaves like the regex `?`, meaning the leading digits part is optional
  [(:or (:seq (:? digits) "." digits)
	(:seq digits "."))
   (token 'DECIMAL (string->number lexeme))]
  [(:or (from/to "\"" "\"") (from/to "'" "'"))
   (token 'STRING
          (substring lexeme
                     1 (sub1 (string-length lexeme))))]))

(provide basic-lexer)
