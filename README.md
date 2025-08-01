# GGGP Boolean Expression Evolver in MeTTa

This project implements a Grammar-Guided Genetic Programming (GGGP) system in [MeTTa](https://github.com/trueagi-io/metta), designed to evolve Boolean logic expressions using a predefined grammar.

## ✅ Implemented Features

### 1. Boolean Grammar Representation
- Expressions are built using a simple Boolean grammar:




### 2. Expression Generator
- Random Boolean expressions are generated with controlled depth.
- Ensures syntactic validity via recursive tree construction.
- Example:
```lisp
(generate_expr 3) ; may output (NOT (AND A B))



### 3. Uniform Crossover Operator
- Implements subtree-based uniform crossover between two parent expressions.

- Randomly swaps corresponding genes (tree nodes) from two parents.

- Returns a pair of valid child expression
- Example:

```lisp
(generate_expr 3) ; may output (NOT (AND A B))
```