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
        (find-property 'b-export-name #'(LINE ...))])
    #'(#%module-begin
       ; This is not run when 'require'd, leaving basic-output-port to nothing,
       ; making it so that prints aren't written to stdout
       (module configure-runtime br
          (require basic/setup)
          (do-setup!))
       ; requires have to be top level
       (require IMPORT-NAME ...)
       (provide EXPORT-NAME ...)
       ; Undefined variables have a value of 0
       (define VAR-ID 0) ...
       LINE ...
       (define line-table
         (apply hasheqv (append (list NUM LINE-FUNC) ...)))
       ; We parameterize the output port while running the lines so that we
       ; respect the basic-output-port set by setup
       (parameterize
           ([current-output-port (basic-output-port)])
         (void (run line-table))))))

; begin-for-syntax is used to run this at compile time
(begin-for-syntax
  (require racket/list)
  ; This helper used above iterates the flattened parse tree and removes
  ; duplicates (keying on the datum only, otherwise the same one at a different
  ; location won't match) and looks for the specified syntax property.
  (define (find-property which line-stxs)
    (remove-duplicates
      (for/list ([stx (in-list (stx-flatten line-stxs))]
                 #:when (syntax-property stx which))
                stx)
      #:key syntax->datum)))
