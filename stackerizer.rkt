#lang br/quicklang
(provide + *)

(define-macro (stackerizer-mb EXPR)
  #'(#%module-begin
     (for-each displayln (reverse (flatten EXPR)))))
(provide (rename-out [stackerizer-mb #%module-begin]))

; Defining a macro that creates a macro for the specified OP
(define-macro (define-ops OP ...)
  ; We need `begin` to allow more than one form in the macro.
  #'(begin
     ; Matching syntax patterns (like cond but for a macro)
     (define-macro-cases OP
       [(OP FIRST) #'FIRST]
       ; The (... ...) form is so that the ellipsis is not interpreted as one
       ; from the macro maker, but rather from the inner macro)
       [(OP FIRST NEXT (... ...))
        ; Recursive macro call
        #'(list 'OP FIRST (OP NEXT (... ...)))])
     ; Repeat the define macro for each extra op
     ...))

; Invoking the macro maker for our 2 ops
(define-ops + *)
