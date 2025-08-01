;; --- Helpers ---

;; Select element at index from list
(: selectByIndex (-> Expression Number Atom))
(= (selectByIndex $expr $index)
    (if (== $index 0)
        (car-atom $expr)
        (selectByIndex (cdr-atom $expr) (- $index 1))))

;; Get size of a list
(: size (-> Expression Number))
(= (size $xs) (size-atom $xs))

;; Check if element is member of list
(: isMember (-> Atom Expression Bool))
(= (isMember $x $list)
    (not (== (collapse (intersection (superpose ($x)) (superpose $list))) ())))

;; Add element uniquely to list
(: cons-unique (-> Atom Expression Expression))
(= (cons-unique $x $xs)
    (if (isMember $x $xs) $xs (cons-atom $x $xs)))

;; Sample k unique indices from 0..n-1 (for tournament selection)
(: tournament-sample (-> Number Number Expression Expression))
(= (tournament-sample $n 0 $acc) $acc)
(= (tournament-sample $n $k $acc)
    (let* (
        ($range (- $n 1))
        ($idx (random-int &rng 0 $range))
        ($next (cons-unique $idx $acc))
        ($nextk (if (isMember $idx $acc) $k (- $k 1)))
    )
        (tournament-sample $n $nextk $next)))

;; Find index of max fitness in list of indices
(: argmax-index (-> Expression Expression Number))
(= (argmax-index $indices $fitnesses)
    (argmax-index-helper (cdr-atom $indices) $fitnesses (car-atom $indices) (selectByIndex $fitnesses (car-atom $indices))))
(: argmax-index-helper (-> Expression Expression Number Number Number))
(= (argmax-index-helper $indices $fitnesses $best-idx $best-val)
    (if (== $indices ())
        $best-idx
        (let* (
            ($i (car-atom $indices))
            ($val (selectByIndex $fitnesses $i))
            ($new-best-idx (if (> $val $best-val) $i $best-idx))
            ($new-best-val (if (> $val $best-val) $val $best-val))
        )
            (argmax-index-helper (cdr-atom $indices) $fitnesses $new-best-idx $new-best-val))))

;; Tournament selection: choose best individual from k random samples
(: tournament-selection (-> Expression Expression Number Atom))
(= (tournament-selection $population $fitnesses $k)
    (let* (
        ($n (size $population))
        ($indices (tournament-sample $n $k ()))
        ($best-idx (argmax-index $indices $fitnesses))
    )
        (selectByIndex $population $best-idx)))

;; Reverse list helper
(: reverse (-> Expression Expression))
(= (reverse $xs) (reverse-helper $xs ()))
(: reverse-helper (-> Expression Expression Expression))
(= (reverse-helper $xs $acc)
    (if (== $xs ()) $acc (reverse-helper (cdr-atom $xs) (cons-atom (car-atom $xs) $acc))))

;; --- Boolean Expression Grammar Generation ---

;; Grammar terminals
(: terminals (-> Expression))
(= (terminals) (A B))

;; Grammar operators
(: operators (-> Expression))
(= (operators) (AND OR NOT))

;; Generate a random terminal
(: random-terminal (-> Atom))
(= (random-terminal)
    (let* (
        ($r (random-int &rng 0 1))
    )
    (if (== $r 0) A B)))

;; Generate a random operator
(: random-operator (-> Atom))
(= (random-operator)
    (let* (
        ($r (random-int &rng 0 2))
    )
    (if (== $r 0) AND (if (== $r 1) OR NOT))))

;; Generate random expression tree of depth $depth
(: gen-expr (-> Number Expression))
(= (gen-expr 0) (random-terminal))
(= (gen-expr $depth)
    (let* (
        ($op (random-operator))
    )
        (if (== $op NOT)
            (list $op (gen-expr (- $depth 1)))
            (list $op (gen-expr (- $depth 1)) (gen-expr (- $depth 1))))))

;; --- Evaluation and Fitness ---

;; Evaluate Boolean expression given values for A and B
(: eval-expr (-> Number Number Expression Number))
(= (eval-expr $a $b A) $a)
(= (eval-expr $a $b B) $b)
(= (eval-expr $a $b (NOT $x))
    (if (== (eval-expr $a $b $x) 1) 0 1))
(= (eval-expr $a $b (AND $x $y))
    (if (and (== (eval-expr $a $b $x) 1) (== (eval-expr $a $b $y) 1)) 1 0))
(= (eval-expr $a $b (OR $x $y))
    (if (or (== (eval-expr $a $b $x) 1) (== (eval-expr $a $b $y) 1)) 1 0))

;; Target Boolean function: AND
(: target (-> Number Number Number))
(= (target $a $b) (if (and (== $a 1) (== $b 1)) 1 0))

;; Fitness: number of inputs matched by expression to target
(: fitness (-> Expression Number))
(= (fitness $expr)
    (+ 
        (+ 
            (+ 
                (if (== (eval-expr 0 0 $expr) (target 0 0)) 1 0)
                (if (== (eval-expr 0 1 $expr) (target 0 1)) 1 0))
            (if (== (eval-expr 1 0 $expr) (target 1 0)) 1 0))
        (if (== (eval-expr 1 1 $expr) (target 1 1)) 1 0)))

;; --- Genetic Operators ---

;; Mutation: replace a random subtree with a new random expression (depth=1 for simplicity)
(: mutation (-> Expression Expression))
(= (mutation $expr)
    (if (== $expr ())
        (gen-expr 1)
        (let* (
            ($r (random-float &rng 0 1))
        )
            (if (< $r 0.3)  ;; 30% chance to replace subtree
                (gen-expr 1)
                (if (atom? $expr) $expr
                    (let* (
                        ($op (car-atom $expr))
                        ($args (cdr-atom $expr))
                        ($mut-args (map-atom mutation $args))
                    )
                        (cons-atom $op $mut-args)))))))

;; Uniform crossover: swap subtrees randomly (simplified at top level only)
(: uniform-crossover (-> Expression Expression (Expression Expression)))
(= (uniform-crossover $p1 $p2)
    (let* (
        ($r (random-float &rng 0 1))
    )
        (if (< $r 0.5)
            ($p1 $p2)
            ($p2 $p1))))

;; --- Population Initialization ---

(: init-population (-> Number Number Expression))
(= (init-population 0 $depth) ())
(= (init-population $n $depth)
    (cons-atom (gen-expr $depth) (init-population (- $n 1) $depth)))

;; --- Main GA Loop ---

(: run-ga (-> Number Number Number))
(= (run-ga $pop-size $depth $generations)
    (let* (
        ($pop (init-population $pop-size $depth))
    )
        (run-ga-helper $pop $pop-size $depth $generations 0)
    ))

(: run-ga-helper (-> Expression Number Number Number Number))
(= (run-ga-helper $pop $pop-size $depth $generations $gen)
    (if (>= $gen $generations)
        (let* (
            ($fits (map-atom fitness $pop))
            ($best-idx (argmax-index (range $pop-size) $fits))
            ($best (selectByIndex $pop $best-idx))
            ($_ (println "Best individual:" $best "Fitness:" (selectByIndex $fits $best-idx)))
        )
        ())
        (let* (
            ($fits (map-atom fitness $pop))
            ($best-idx (argmax-index (range $pop-size) $fits))
            ($best-fit (selectByIndex $fits $best-idx))
            ($_ (println "Gen" $gen "Best fitness:" $best-fit))
            ;; Create next generation
            ($next-pop (make-offspring $pop $fits $pop-size))
        )
            (run-ga-helper $next-pop $pop-size $depth $generations (+ $gen 1))
        )))

;; Make offspring population using tournament selection, crossover and mutation
(: make-offspring (-> Expression Expression Number Expression))
(= (make-offspring $pop $fits 0 $acc) $acc)
(= (make-offspring $pop $fits $remaining $acc)
    (let* (
        ($p1 (tournament-selection $pop $fits 3))
        ($p2 (tournament-selection $pop $fits 3))
        ($children (uniform-crossover $p1 $p2))
        ($c1 (car-atom $children))
        ($c2 (car-atom (cdr-atom $children)))
        ($c1m (mutation $c1))
        ($c2m (mutation $c2))
        ($new-acc (cons-atom $c1m (cons-atom $c2m $acc)))
    )
        (make-offspring $pop $fits (- $remaining 2) $new-acc)))

;; Range helper
(: range (-> Number Expression))
(= (range 0) ())
(= (range $n)
    (if (> $n 0)
        (cons-atom (- $n 1) (range (- $n 1))) ()))

;; --- Run example ---
(run-ga 1 5 3)


! (random-terminal)
! (random-operator)
! (gen-expr 0)