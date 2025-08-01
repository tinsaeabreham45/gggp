# Boolean Expression Generator

This project implements a Boolean expression generator and genetic algorithm components using a metta-like language. It generates random Boolean expressions, creates populations, and performs uniform crossover operations. The fitness evaluation part is included but commented out for testing purposes.

## Features

- **Random Expression Generation**: Creates Boolean expressions with operators (`AND`, `OR`, `NOT`) and terminals (`A`, `B`) up to a specified depth.
- **Population Generation**: Generates a population of random Boolean expressions.
- **Uniform Crossover**: Implements a genetic algorithm crossover operation to combine two parent expressions into two offspring.
- **Commented Fitness Evaluation**: Includes (but does not execute) code for evaluating expressions against a target function (`A AND B`) using truth table inputs.

## Prerequisites

- metta 
- Python integration for random number generation (via `random.random` and `random.randint`).

## Usage

### Step 1: Random Number Setup
The code binds Python's `random` module for generating random numbers:
```metta
! (bind! random (py-atom random))
```

### Step 2: Grammar Setup
Defines a grammar for Boolean expressions with terminals (`A`, `B`) and operators (`AND`, `OR`, `NOT`):
```metta
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
```

### Step 3: Generating Expressions
The `generate_expr` function creates a random Boolean expression up to a specified depth:
```metta
! (generate_expr 3)
```
This might produce expressions like `(A AND (NOT B))` or `((A OR B) AND B)`.

### Step 4: Generating Populations
The `generate_population` function creates a list of `n` random expressions:
```metta
! (generate_population 3)
```
This generates a list of three random expressions, each with a depth of 5.

### Step 5: Uniform Crossover
The `uniform-crossover` function combines two parent expressions to produce two offspring:
```metta
! (uniform-crossover (generate_expr 3) (generate_expr 3))
```
This performs a crossover operation, swapping elements between the two expressions with a 50% probability for each element.

### Example Output
Running `(generate_population 3)` might produce:
```metta
((A AND (NOT B)) (B OR (A AND B)) (NOT (A OR B)))
```

Running `(uniform-crossover (generate_expr 3) (generate_expr 3))` might produce two offspring like:
```metta
(((A OR B) AND B) (NOT (A AND B)))
```

## Commented Fitness Evaluation
The fitness evaluation code (commented out) evaluates expressions against the target function `A AND B` using a truth table:
- Inputs: `((A 0) (B 0))`, `((A 0) (B 1))`, `((A 1) (B 0))`, `((A 1) (B 1))`
- Fitness is the number of inputs where the expression matches the target function.
To enable, uncomment the fitness-related code and run:
```metta
! (fitness (generate_expr 3))
```

## Code Structure

- **Random Setup**: Binds Python's random module.
- **Grammar**: Defines rules for valid Boolean expressions.
- **Generator**: Recursively generates expressions and populations.
- **Crossover**: Implements uniform crossover for genetic algorithms.
- **Reverse Helper**: Utility for reversing lists used in crossover.
- **Fitness (Commented)**: Evaluates expression fitness against a target function.

## Notes

- The fitness evaluation is commented out to focus on testing expression generation and crossover.
- The code assumes a metta environment with Python integration.
- Adjust the depth parameter in `generate_expr` or population size in `generate_population` for different complexity levels.

## Future Improvements

- Uncomment and test the fitness evaluation for a complete genetic algorithm.
- Add mutation operations to complement crossover.
- Support additional operators or terminals for more complex expressions.