import numpy as np
from ypstruct import structure
# Dispersive Flies Optimisation (standard DFO, al-Rifaie 2014)
# Same interface as ga.run(problem, params) so the two can be compared directly.
def run(problem, params):
    # Problem Information
   costfunc = problem.costfunc
   nvar = problem.nvar
   varmin = np.broadcast_to(problem.varmin, (nvar,)).astype(float)
   varmax = np.broadcast_to(problem.varmax, (nvar,)).astype(float)
    # Parameters
   maxit = params.maxit
   npop = params.npop
   delta = params.get('delta', 0.001)      # disturbance threshold
   verbose = params.get('verbose', True)
    # Initialize Flies
   X = np.random.uniform(varmin, varmax, (npop, nvar))
   fitness = np.array([costfunc(x) for x in X])
   s = np.argmin(fitness)
    # Best Solution Ever Found
   bestsol = structure()
   bestsol.position = X[s].copy()
   bestsol.cost = fitness[s]
    # Best Cost of Iterations
   bestcost = np.empty(maxit)
    # Main Loop
   for it in range(maxit):
        # Update each fly (the swarm's best fly is kept: elitism)
       for i in range(npop):
           if i == s:
               continue
            # Best neighbour in a ring topology
           left, right = (i - 1) % npop, (i + 1) % npop
           bn = left if fitness[left] < fitness[right] else right
            for d in range(nvar):
               # Disturbance: restart this dimension at random
               if np.random.rand() < delta:
                   X[i, d] = np.random.uniform(varmin[d], varmax[d])
                   continue
                u = np.random.rand()
               X[i, d] = X[bn, d] + u * (X[s, d] - X[i, d])
                # Out of bounds: restart this dimension at random
               if X[i, d] < varmin[d] or X[i, d] > varmax[d]:
                   X[i, d] = np.random.uniform(varmin[d], varmax[d])
        # Evaluate and find the swarm's best fly
       fitness = np.array([costfunc(x) for x in X])
       s = np.argmin(fitness)
       if fitness[s] < bestsol.cost:
           bestsol.position = X[s].copy()
           bestsol.cost = fitness[s]
        # Store Best Cost
       bestcost[it] = bestsol.cost
        if verbose:
           print("Iteration {}: Best Cost = {}".format(it, bestcost[it]))
    # Output
   out = structure()
   out.pop = X
   out.bestsol = bestsol
   out.bestcost = bestcost
   return out
