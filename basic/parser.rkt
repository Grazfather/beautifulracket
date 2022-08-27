#lang brag
# We can cut elements from the resulting tree by prefixing with a "/"
b-program : [b-line] (/NEWLINE [b-line])*
b-line : b-line-num [b-statement] (/":" [b-statement])* [b-rem]
# We can splice in elements from the tree by prefixing with a "@". This makes
# whatever includes them 'absorb' them, so in this case the INTEGER is show as
# part of the b-line, without mention of b-line-num.
# We could splice this b-line-num only when it appears in b-line by putting the
# "@" before its inclusion in the b-line line, but by putting it in the rule
# name it will be spliced automatically no matter where it shows up.
@b-line-num : INTEGER
@b-statement : b-end | b-print | b-goto
             | b-let | b-input | b-if
b-rem : REM
b-end : /"end"
b-print : /"print" [b-printable] (/";" [b-printable])*
@b-printable : STRING | b-expr
b-goto : /"goto" b-expr
b-let : [/"let"] b-id /"=" (b-expr | STRING)
b-if : /"if" b-expr /"then" (b-statement | b-expr)
                   [/"else" (b-statement | b-expr)]
b-input : /"input" b-id
# We splice the b-id so we get the identifier in rules where it shows up, but
# also the syntax-property will be set on the syntax object
@b-id : ID
# These recursive rules enforce the correct order of operations. b-sum also
# does subtraction because they have the same precedence. Same thing with
# product doing mod, exp, and division.
b-expr : b-or-expr
b-or-expr : [b-or-expr "or"] b-and-expr
b-and-expr : [b-and-expr "and"] b-not-expr
b-not-expr : ["not"] b-comp-expr
b-comp-expr : [b-comp-expr ("="|"<"|">"|"<>")] b-sum
b-sum : [b-sum ("+"|"-")] b-product
b-product : [b-product ("*"|"/"|"mod")] b-neg
b-neg : ["-"] b-expt
b-expt : [b-expt "^"] b-value
# b-id is used as a value so variables can be used in expressions
@b-value : b-number | b-id | /"(" b-expr /")"
@b-number : INTEGER | DECIMAL
