# Stochastic Diffusion Search (SDS)
## Summary of my understanding of SDS
Stochastic Diffusion Search (SDS) is a multi-agent algorithm that finds where a model best matches within a search space. Each agent holds a hypothesis, a candidate position in the search space. The algorithm repeats two phases:

- **Test:** each agent checks one randomly chosen micro-feature of the model against the search space at its hypothesis. A match makes it active; a mismatch makes it inactive.
- **Diffusion:** each inactive agent picks a random agent. If that agent is active, it copies its hypothesis; otherwise it takes a new random one.

Agents gradually cluster around the best match. SDS is good for partial hypothesis evaluation: each agent tests only one micro-feature per iteration, so steps are cheap, and full evaluation emerges across the population over time.

## Large image as search space, small image as model
Here, a hypothesis is an (x, y) offset where the small image might sit within the large image. A micro-feature could be **one of the values of R, G or B** for a single pixel. An agent picks a random pixel in the model and one of its three colour channels. It then compares that value with the same channel of the corresponding pixel in the search image at its hypothesised offset.


Other possible micro-features:
- **A whole pixel:** compare all three channels at once (stricter test, fewer false matches).
- **Greyscale brightness** of a pixel, which ignores colour shifts.
- **A small patch** (e.g. 3×3 pixels), which carries more information per test.
- **Edge or gradient direction** at a pixel, which is robust to lighting changes.

In real images, exact value matches are fragile because of noise and compression, so a test can count as a match when the values are within a small tolerance.
