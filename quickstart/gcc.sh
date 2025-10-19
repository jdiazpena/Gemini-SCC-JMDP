module load git/2.31.1
module load python3
module load cmake

unset MKLROOT
# in case used Intel compiler previously

# if preinstalled MPI doesn't work, need to build OpenMPI per Readme
module load openmpi/4.1.5

# HPC often have some compiler versions that are broken.
# here's one we know works.
module load gcc/12.2.0
