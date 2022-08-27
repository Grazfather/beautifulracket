#lang br
(require "struct.rkt")
(provide b-rem b-print b-let b-input b-import b-export)

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
