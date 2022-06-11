#lang br
(module our-submod br
  (require racket/contract)
  (define (our-div num denom)
    (/ num denom))
  (provide (contract-out
            [our-div (number? (not/c zero?) . -> . number?)])))

(require (submod "." our-submod))
