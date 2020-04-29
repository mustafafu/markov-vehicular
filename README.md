# Vehicular Communications: Connectivity Analysis Using Markov Chain
Highway vehicle scenario where the outage probability and the blockage duration are computed theoretically using Markov Chain. To validate our calculations, we run simulations using real world vehicle class dimensions. We use a deterministic, geometry based LOS channel, where the communicating vehicle said to be out of service when the LOS link between the vehicle and roadside units (RSUs) are blocked by other vehicles traveling on adjacent lanes.

## Theoretical Computations
To reproduce our experiment in HPC,
```bash
git clone https://github.com/mustafafu/markov-vehicular.git
```
cd to theory folder,
```bash
sbatch --array=1-70 submit_theory.sbatch
```
where each instance computes one combination of parameters:
 * height of the RSUs
 * height of the communicating vehicle
 * in which lane the communicating vehicle travels.
 
 ## Realistic Simulation
