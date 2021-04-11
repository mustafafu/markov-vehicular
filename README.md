# Vehicular Communications: Connectivity Analysis Using Markov Chain

## Please cite if you use this repository in your research:
```
C. Tunc, M. F. Özkoç, F. Fund and S. S. Panwar, "The Blind Side: Latency Challenges in Millimeter Wave Networks for Connected Vehicle Applications," in IEEE Transactions on Vehicular Technology, vol. 70, no. 1, pp. 529-542, Jan. 2021, doi: 10.1109/TVT.2020.3046501.
```

```
C. Tunc, M. F. Özkoç and S. Panwar, "Millimeter Wave Coverage and Blockage Duration Analysis for Vehicular Communications," 2019 IEEE 90th Vehicular Technology Conference (VTC2019-Fall), Honolulu, HI, USA, 2019, pp. 1-6, doi: 10.1109/VTCFall.2019.8891537.
```
Link to IEEE xplore:
```
https://ieeexplore.ieee.org/document/9303460
```
```
https://ieeexplore.ieee.org/document/8891537
```

Highway vehicle scenario where the outage probability and the blockage duration are computed theoretically using Markov Chain. To validate our calculations, we run simulations using real world vehicle class dimensions. We use a deterministic, geometry based LOS channel, where the communicating vehicle said to be out of service when the LOS link between the vehicle and roadside units (RSUs) are blocked by other vehicles traveling on adjacent lanes.

## Theoretical Computations
To do the thoretical calculations on HPC,
```bash
git clone https://github.com/mustafafu/markov-vehicular.git
```
cd to theory folder,
```bash
sbatch --array=1-5 submit_theory.sbatch
```
where each instance computes one combination of parameters:
 * height of the RSUs
 * height of the communicating vehicle
 * in which lane the communicating vehicle travels. (always on lane 4 now but can be changed)
 
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

