# No Free Lunch Theorem
The No Free Lunch (NFL) theorem, formulated by Wolpert and Macready (1997), states that:

> No algorithm outperforms all others when performance is averaged over all possible problems. For any two algorithms A and B, average performance of A equals average performance of B.

Real-world problems, however, are not drawn uniformly from all possible problems. They have structure, and effective algorithms exploit it.

In my smart watering system, a neural network predicted watering duration from soil moisture, temperature, humidity, and previous watering patterns. This suited the problem because the relationship was non-linear: the same soil moisture reading could require different durations depending on temperature and humidity.

The same network would be the wrong choice for the pump's safety cutoff, which stops watering when the water tank is nearly empty. This decision has a fixed, known condition, so a simple rule such as "if tank level is below 10%, turn off the pump" is exact, needs no training data, and behaves predictably. Algorithms succeed when their strengths match the problem's structure.
