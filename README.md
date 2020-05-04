# Vehicular Communications: Connectivity Analysis Using Markov Chain
Highway vehicle scenario where the outage probability and the blockage duration are computed theoretically using Markov Chain. To validate our calculations, we run simulations using real world vehicle class dimensions. We use a deterministic, geometry based LOS channel, where the communicating vehicle said to be out of service when the LOS link between the vehicle and roadside units (RSUs) are blocked by other vehicles traveling on adjacent lanes.

## Theoretical Computations
To do the thoretical calculations on HPC,
```bash
git clone https://github.com/mustafafu/markov-vehicular.git
```
cd to theory folder,
```bash
sbatch --array=1-10 submit_theory.sbatch
```
where each instance computes one combination of parameters:
 * height of the RSUs
 * height of the communicating vehicle
 * in which lane the communicating vehicle travels.
 
 ## Realistic Simulation

To reproduce the experiment on HPC,
```bash
git clone https://github.com/mustafafu/markov-vehicular.git
```

cd to Simulation folder,
```bash
sbatch --array=1-250 submit.sbatch
```
where the array input can be any multiple of the full parameter sweep space length. for example, to try 5 different BS heights and 1 to 5 number of RSUs in the coverage area, a job can be submitted with arrays 1-25. To have more data, any multiple of 25 can be submitted and combining script can be used to process the data afterwards. 

