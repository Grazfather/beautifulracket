#lang br/quicklang


(define-macro (bf-module-begin PARSE-TREE)
  #'(#%module-begin
     PARSE-TREE))
(provide (rename-out [bf-module-begin #%module-begin]))

(define (fold-funcs apl bf-funcs)
  ; We fold (reduce) each func, passing the new state to the next func
  ; apl is '(arr ptr))
  (for/fold ([current-apl apl])
            ([bf-func (in-list bf-funcs)])
    ; We use apply to break up the apl into separate args to the next func
    (apply bf-func current-apl)))

; This macro defines the initial state and then calls fold-funcs on all of its
; ops
(define-macro (bf-program OP-OR-LOOP-ARG ...)
  #'(begin
      (define first-apl (list (make-vector 30000 0) 0))
      (void (fold-funcs first-apl (list OP-OR-LOOP-ARG ...)))))
(provide bf-program)

; bf-loop creates and return a function that can be passed to fold-funcs, that
; itself calls fold-funcs for all of its inner ops
(define-macro (bf-loop "[" OP-OR-LOOP-ARG ... "]")
  #'(lambda (arr ptr)
      (for/fold ([current-apl (list arr ptr)])
		; We create an infinite list since we don't know when we are done
                ([i (in-naturals)]
                ; We break out when the counter byte hits zero
                 #:break (zero? (apply current-byte
                                       current-apl)))
        (fold-funcs current-apl (list OP-OR-LOOP-ARG ...)))))
(provide bf-loop)

; Here we simply replace the operation with a function, which fold-funcs will
; call with the current state.
(define-macro-cases bf-op
  [(bf-op ">") #'gt]
  [(bf-op "<") #'lt]
  [(bf-op "+") #'plus]
  [(bf-op "-") #'minus]
  [(bf-op ".") #'period]
  [(bf-op ",") #'comma])
(provide bf-op)

(define (current-byte arr ptr) (vector-ref arr ptr))
; This version doesn't mutate state, it returns the new version, so no '!'
(define (set-current-byte arr ptr val)
  (define new-arr (vector-copy arr))
  (vector-set! new-arr ptr val)
  new-arr)

; These return the old array, but a new ptr value
(define (gt arr ptr) (list arr (add1 ptr)))
(define (lt arr ptr) (list arr (sub1 ptr)))
; These return a new modified array and the old ptr value
(define (plus arr ptr)
  (list
    (set-current-byte arr ptr (add1 (current-byte arr ptr)))
    ptr))
(define (minus arr ptr)
  (list
    (set-current-byte arr ptr (sub1 (current-byte arr ptr)))
    ptr))
; This changes nothing so we return the old values
(define (period arr ptr)
  (write-byte (current-byte arr ptr))
  (list arr ptr))
; This returns a new modified array and the old ptr value
(define (comma arr ptr)
  (list (set-current-byte arr ptr (read-byte)) ptr))
