import random

# Step 1: Grammar Definition
def define_grammar():
    """Defines the grammar for Boolean expressions."""
    return {
        'expr': ['and(expr, expr)', 'or(expr, expr)', 'not(expr)', 'var'],
        'var': ['A', 'B', 'C']
    }
    
print(define_grammar())

def generate_expression(grammar, symbol='expr', max_depth=3):
    """Generates a random expression based on the grammar."""
    if max_depth <= 0 or symbol not in grammar:
        return random.choice(grammar.get('var', ['A']))
    rule = random.choice(grammar[symbol])
    if symbol == 'var':
        return rule
    parts = rule.split('(')[0]
    if parts == 'not':
        return f"not({generate_expression(grammar, 'expr', max_depth - 1)})"
    elif parts in ['and', 'or']:
        left = generate_expression(grammar, 'expr', max_depth - 1)
        right = generate_expression(grammar, 'expr', max_depth - 1)
        return f"{parts}({left}, {right})"
    return rule

# Step 2: Generate Population
def generate_population(grammar, size, max_depth):
    """Generates a population of random expressions."""
    return [generate_expression(grammar, max_depth=max_depth) for _ in range(size)]

# Step 3: Fitness Function
def evaluate_expression(expr, inputs):
    """Evaluates a Boolean expression for given inputs."""
    if expr in inputs:
        return inputs[expr]
    if expr.startswith('not'):
        sub_expr = expr[4:-1]
        return not evaluate_expression(sub_expr, inputs)
    elif expr.startswith(('and', 'or')):
        op, rest = expr.split('(', 1)[0], expr.split('(', 1)[1][:-1]
        left, right = rest.split(',', 1)
        left_val = evaluate_expression(left.strip(), inputs)
        right_val = evaluate_expression(right.strip(), inputs)
        return (left_val and right_val) if op == 'and' else (left_val or right_val)
    return False  # Fallback for invalid expressions

def fitness(expr, truth_table):
    """Calculates fitness as the number of incorrect outputs."""
    errors = 0
    for inputs, expected in truth_table:
        try:
            result = evaluate_expression(expr, inputs)
            if result != expected:
                errors += 1
        except:
            errors += len(truth_table)  # Penalize invalid expressions
    return errors

# Step 4: Selection
def select_individual(population, fitnesses):
    """Selects an individual using tournament selection."""
    tournament_size = 3
    indices = random.sample(range(len(population)), tournament_size)
    tournament = [(population[i], fitnesses[i]) for i in indices]
    best = min(tournament, key=lambda x: x[1])
    return best[0]

# Step 5: Termination and Main Loop
def run_gggp(pop_size=50, generations=20, max_depth=3):
    """Runs the GGGP with only the specified steps."""
    grammar = define_grammar()
    truth_table = [
        ({'A': True, 'B': True, 'C': True}, True),
        ({'A': True, 'B': True, 'C': False}, True),
        ({'A': True, 'B': False, 'C': True}, True),
        ({'A': True, 'B': False, 'C': False}, True),
        ({'A': False, 'B': True, 'C': True}, False),
        ({'A': False, 'B': True, 'C': False}, False),
        ({'A': False, 'B': False, 'C': True}, False),
        ({'A': False, 'B': False, 'C': False}, False)
    ]
    population = generate_population(grammar, pop_size, max_depth)
    for gen in range(generations):
        fitnesses = [fitness(expr, truth_table) for expr in population]
        if min(fitnesses) == 0:  # Termination condition: perfect solution found
            best_idx = fitnesses.index(0)
            return population[best_idx], 0
        # For demo, just select individuals without evolving (crossover/mutation omitted)
        new_population = [select_individual(population, fitnesses) for _ in range(pop_size)]
        population = new_population
    fitnesses = [fitness(expr, truth_table) for expr in population]
    best_idx = fitnesses.index(min(fitnesses))
    return population[best_idx], fitnesses[best_idx]

# Test the modules
if __name__ == "__main__":
    # Test Grammar Definition
    grammar = define_grammar()
    expr = generate_expression(grammar)
    print(f"Test Grammar: Generated expression: {expr}")

    # Test Population Generation
    pop = generate_population(grammar, 5, 3)
    print(f"Test Population: Sample expressions: {pop[:2]}")

    # Test Fitness Function
    truth_table = [({'A': True, 'B': False, 'C': True}, True)]
    fit = fitness("or(A, C)", truth_table)
    print(f"Test Fitness: Fitness of 'or(A, C)': {fit}")

    # Test Selection
    pop = ["A", "not(A)", "and(A, B)"]
    fitnesses = [2, 1, 3]
    selected = select_individual(pop, fitnesses)
    print(f"Test Selection: Selected individual: {selected}")

    # Run GGGP
    best_expr, best_fit = run_gggp()
    print(f"Best expression: {best_expr}, Fitness: {best_fit}")