#lang br
(require "parser.rkt" "tokenizer.rkt")
(provide basic-output-port do-setup!)

(define basic-output-port
  (make-parameter (open-output-nowhere)))

(define repl-parse (make-rule-parser b-repl))

(define (read-one-line origin port)
  (define one-line (read-line port))
  (if (eof-object? one-line)
    eof
    (repl-parse
      (make-tokenizer (open-input-string one-line)))))

(define (do-setup!)
  (basic-output-port (current-output-port))
  ; current-read-interaction is used by the repl to determine how to read
  ; entered lines
  (current-read-interaction read-one-line))
