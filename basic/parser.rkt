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
b-rem : REM
b-end : /"end"
b-print : /"print" [b-printable] (/";" [b-printable])*
@b-printable : STRING | b-expr
b-goto : /"goto" b-expr
b-expr : b-sum
b-sum : b-number (/"+" b-number)*
@b-number : INTEGER | DECIMAL
