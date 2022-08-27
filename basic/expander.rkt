#lang br/quicklang
(require "struct.rkt" "run.rkt" "elements.rkt" "setup.rkt")
(provide (rename-out [b-module-begin #%module-begin])
         (all-from-out "elements.rkt"))

(define-macro (b-module-begin (b-program LINE ...))
  (with-pattern
      ([((b-line NUM STMT ...) ...) #'(LINE ...)]
       [(LINE-FUNC ...) (prefix-id "line-" #'(NUM ...))]
       [(VAR-ID ...) (find-property 'b-id #'(LINE ...))]
       [(IMPORT-NAME ...)
        (find-property 'b-import-name #'(LINE ...))]
       [(EXPORT-NAME ...)
        (find-property 'b-export-name #'(LINE ...))]
       [((SHELL-ID SHELL-IDX) ...)
        (make-shell-ids-and-idxs caller-stx)]
       [(UNIQUE-ID ...)
        (unique-ids
          (syntax->list #'(VAR-ID ... SHELL-ID ...)))])
    #'(#%module-begin
       ; This is not run when 'require'd, leaving basic-output-port to nothing,
       ; making it so that prints aren't written to stdout
       (module configure-runtime br
          (require basic/setup)
          (do-setup!))
       ; requires have to be top level
       (require IMPORT-NAME ...)
       (provide EXPORT-NAME ...)
       (define UNIQUE-ID 0) ...
       ; Set a variable for each command line argument
       (let ([clargs (current-command-line-arguments)])
         (set! SHELL-ID (get-clarg clargs SHELL-IDX)) ...)
       LINE ...
       (define line-table
         (apply hasheqv (append (list NUM LINE-FUNC) ...)))
       ; We parameterize the output port while running the lines so that we
       ; respect the basic-output-port set by setup
       (parameterize
           ([current-output-port (basic-output-port)])
         (void (run line-table))))))

; This function just gets the command line argument at the specified index. We
; try to parse it as an int, but if we can't we return the string.
(define (get-clarg clargs idx)
  (if (<= (vector-length clargs) idx)
    0
    (let ([val (vector-ref clargs idx)])
      (or (string->number val) val))))

; begin-for-syntax is used to run this at compile time
(begin-for-syntax
  (require racket/list)

  (define (unique-ids stxs)
    (remove-duplicates stxs #:key syntax->datum))

  ; This helper used above iterates the flattened parse tree and removes
  ; duplicates (keying on the datum only, otherwise the same one at a different
  ; location won't match) and looks for the specified syntax property.
  (define (find-property which line-stxs)
    (unique-ids
      (for/list ([stx (in-list (stx-flatten line-stxs))]
                 #:when (syntax-property stx which))
        stx)))

  ; This function makes a list of syntax objects, each with an identifier and
  ; the index of the command line argument it corresponds to, with the context
  ; where we want to place the identifier
  (define (make-shell-ids-and-idxs ctxt)
    (define arg-count 10)
    (for/list ([idx (in-range arg-count)])
      (list (suffix-id #'arg idx #:context ctxt) idx))))
