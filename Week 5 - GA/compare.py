import sys
import numpy as np
import matplotlib.pyplot as plt
from ypstruct import structure
import ga
import dfo
# Test Functions
def sphere(x):
   return sum(x**2)
def rastrigin(x):
   return 10*len(x) + sum(x**2 - 10*np.cos(2*np.pi*x))
FUNCTIONS = {'Sphere': sphere, 'Rastrigin': rastrigin}
# Settings (both algorithms: 100 individuals, 1000 iterations, 30-D, [-5.12, 5.12])
NRUNS = int(sys.argv[1]) if len(sys.argv) > 1 else 10
MAXIT = 1000
def make_problem(costfunc):
   problem = structure()
   problem.costfunc = costfunc
   problem.nvar = 30
   problem.varmin = -5.12
   problem.varmax = 5.12
   return problem
def ga_params():
   params = structure()
   params.maxit = MAXIT
   params.npop = 100
   params.beta = 1
   params.pc = 1
   params.gamma = 0.1
   params.mu = 0.01
   params.sigma = 0.1
   params.verbose = False
   return params
def dfo_params():
   params = structure()
   params.maxit = MAXIT
   params.npop = 100
   params.delta = 0.001
   params.verbose = False
   return params
ALGORITHMS = {'GA': (ga, ga_params), 'DFO': (dfo, dfo_params)}
# Run Experiments
curves = {}
print("{} runs each, {} iterations, 30-D\n".format(NRUNS, MAXIT))
print("{:<10} {:<4} {:>11} {:>11} {:>11} {:>11} {:>11}".format(
   'Function', 'Alg', 'Mean', 'Median', 'Min', 'Max', 'Std'))
for fname, f in FUNCTIONS.items():
   for aname, (alg, make_params) in ALGORITHMS.items():
       runs = []
       for r in range(NRUNS):
           np.random.seed(r)
           runs.append(alg.run(make_problem(f), make_params()).bestcost)
       runs = np.array(runs)
       curves[(fname, aname)] = np.median(runs, axis=0)
       final = runs[:, -1]
       print("{:<10} {:<4} {:>11.4g} {:>11.4g} {:>11.4g} {:>11.4g} {:>11.4g}".format(
           fname, aname, final.mean(), np.median(final), final.min(), final.max(), final.std()))
# Results: median convergence curves
fig, axes = plt.subplots(1, 2, figsize=(11, 4))
for ax, fname in zip(axes, FUNCTIONS):
   for aname in ALGORITHMS:
       ax.semilogy(curves[(fname, aname)], label=aname)
   ax.set_xlim(0, MAXIT)
   ax.set_xlabel('Iterations')
   ax.set_ylabel('Best Cost (median of {} runs)'.format(NRUNS))
   ax.set_title('{} (30-D)'.format(fname))
   ax.grid(True)
   ax.legend()
plt.tight_layout()
plt.savefig('ga_vs_dfo.png', dpi=120)
plt.show()
