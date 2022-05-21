#lang brag
; Every character is either json or a jsonic sexp.
; Comments have already been removed by the tokenizer
jsonic-program : (jsonic-char | jsonic-sexp)*
jsonic-char    : CHAR-TOK
jsonic-sexp    : SEXP-TOK
