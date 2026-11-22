import numpy as np
import matplotlib.pyplot as plt
from ypstruct import structure
import ga
# Sphere Test Function
def sphere(x):
   return sum(x**2)
# Problem Definition
problem = structure()
problem.costfunc = sphere
problem.nvar = 30
problem.varmin = -5.12   # same bound for every dimension
problem.varmax =  5.12
# GA Parameters
params = structure()
params.maxit = 100
params.npop = 100
params.beta = 1
params.pc = 1
params.gamma = 0.1
params.mu = 0.01
params.sigma = 0.1
# Run GA
out = ga.run(problem, params)
# Results
plt.semilogy(out.bestcost)
# plt.plot(out.bestcost)
plt.xlim(0, params.maxit)
plt.xlabel('Iterations')
plt.ylabel('Best Cost')
plt.title('Genetic Algorithm (GA)')
plt.grid(True)
plt.show()
