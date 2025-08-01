; Step 1: Python random
! (bind! random (py-atom random))

; Step 2: Grammar setup
! (bind! &grammar (new-space))
! (add-atom &grammar (start expr))
! (add-atom &grammar (expr (expr opr expr)))
! (add-atom &grammar (expr (opr expr)))
! (add-atom &grammar (expr (term)))
! (add-atom &grammar (opr AND))
! (add-atom &grammar (opr OR))
! (add-atom &grammar (opr NOT))
! (add-atom &grammar (term A))
! (add-atom &grammar (term B))
! (done)

; Step 3: Generator
(= (generate_expr $depth)
    (if (== $depth 0)
        ; Base case: randomly pick a term (wrapped)
        (if (< ((py-atom random.random)) 0.5)
            (A)
            (B))
        ; randomly pick expression type
        (let* 
            (
                ($choice ((py-atom random.randint) 0 2))
                ($next (- $depth 1))
            )
            ; Case: Binary expr (expr opr expr)
            (if (== $choice 0)
                ((generate_expr $next) (generate_opr) (generate_expr $next))
            ; Case: Unary expr (opr expr)
            (if (== $choice 1)
                ((generate_opr_unary) (generate_expr $next))
            ; Case: Just a term
                (generate_expr 0)))
        )
    )
)


(= (generate_opr)
    (if (< ((py-atom random.random)) 0.5) AND OR)
)

(= (generate_opr_unary) NOT)

; Test generation
! (generate_expr 3)

; Population generator
(= (generate_population $n)
    (if (== $n 0)
        ()
        (cons (generate_expr 5) (generate_population (- $n 1)))
    )
)
! (generate_population 3)

; Reverse helper
(= (reverse $xs)
    (reverse-helper $xs ())
)
(= (reverse-helper $xs $acc)
    (if (== $xs ()) $acc (reverse-helper (cdr-atom $xs) (cons-atom (car-atom $xs) $acc)))
)

; Uniform crossover
(= (uniform-crossover $p1 $p2)
    (uniform-crossover-helper $p1 $p2 () ())
)
(= (uniform-crossover-helper $p1 $p2 $acc1 $acc2)
    (if (or (== $p1 ()) (== $p2 ()))
        ((reverse $acc1) (reverse $acc2)) ; return safely if any input ends
        (let* (
            ($g1 (car-atom $p1))
            ($g2 (car-atom $p2))
            ($rest1 (cdr-atom $p1))
            ($rest2 (cdr-atom $p2))
            ($r (random-float &rng 0 1))
            ($new1 (if (< $r 0.5) (cons-atom $g1 $acc1) (cons-atom $g2 $acc1)))
            ($new2 (if (< $r 0.5) (cons-atom $g2 $acc2) (cons-atom $g1 $acc2)))
        )
            (uniform-crossover-helper $rest1 $rest2 $new1 $new2)
        )
    )
)
 

; Test crossover with generated expressions
!(bind! p1 (generate_expr 3))
!(bind! p2 (generate_expr 3))
; ! (generate_expr 3)
! (uniform-crossover (generate_expr 3) (generate_expr 3))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FITNESS PART COMMENTED OUT for testing population & crossover
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; (=
;   (truth-inputs) 
;    (quote (
;       ((A 0) (B 0))
;       ((A 0) (B 1))
;       ((A 1) (B 0))
;       ((A 1) (B 1))
;    ))
; )

; (=
;   (target-fn $A $B) 
;    (and $A $B)
; )

; ; Evaluates a terminal
; (= (eval_expr A $bindings) (lookup A $bindings))
; (= (eval_expr B $bindings) (lookup B $bindings))

; ; Evaluates NOT
; (= (eval_expr (NOT $x) $bindings)
;    (not (eval_expr $x $bindings)))

; ; Evaluates AND
; (= (eval_expr ($x AND $y) $bindings)
;    (and (eval_expr $x $bindings) (eval_expr $y $bindings)))

; ; Evaluates OR
; (= (eval_expr ($x OR $y) $bindings)
;    (or (eval_expr $x $bindings) (eval_expr $y $bindings)))

; (= (lookup $key ((, $key $val) . $rest)) $val)
; (= (lookup $key ($other . $rest)) (lookup $key $rest))

; (=
;   (fitness $expr)
;    (let $inputs (truth-inputs)
;      (fitness_helper $expr $inputs 0))
; )

; (=
;   (fitness_helper $expr $inputs $score)
;    (if (== $inputs ())
;        $score
;        (let $binding (car $inputs)
;          (let $expected (target-fn (lookup A $binding) (lookup B $binding))
;            (let $actual (eval_expr $expr $binding)
;              (let $new_score (if (== $expected $actual) (+ $score 1) $score)
;                (fitness_helper $expr (cdr $inputs) $new_score))))))
; )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Test uniform crossover by generating population and crossing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ! (car (car $crossover_result))


; ! (let* (
;     ($pop (generate_population 2))
;     ($p1 (car $pop))
;     ($p2 (car (cdr $pop)))
;     ($offspring (uniform-crossover $p1 $p2))
; )
;     (list
;        (tuple "Parent 1:" $p1)
;        (tuple "Parent 2:" $p2)
;        (tuple "Child 1:" (car-atom $offspring))
;        (tuple "Child 2:" (car-atom (cdr-atom $offspring)))
;     )
; )
