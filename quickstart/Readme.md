# HPC batch example for SCC

[HPC](https://hpc-wiki.info/hpc/Getting_Started)
generally use a
[job batch system](https://hpc-wiki.info/hpc/Batch-Scheduler).
The more resources are requested (CPU count, maximum length of job) the longer you wait for the job to start, so that the system is shared fairly.

Building all the Gemini3D associated libraries each batch job helps ensure your latest code is being used.

The gemini3d.job script is programmatic to help avoid typos from repeated information.

## Using BU SCC HPC

The username and password are the same as every other bu.edu service.

```sh
ssh scc2.bu.edu
```

Another choice is the [OnDemand HPC web interface](https://www.bu.edu/tech/support/research/system-usage/connect-scc/scc-ondemand/),
which allows use of a remote graphical desktop.

To run a simulation that takes more than about 10 minutes uses the
[SCC HPC batch system](https://www.bu.edu/tech/support/research/system-usage/running-jobs/submitting-jobs/).

## Select HPC nodes

The gemini3d.job parameter:

```sh
#$ -pe mpi_28_tasks_per_node 56
```

where "448" is the maximum -- you may want to start with less than that.
The smallest is 28, in steps of 28 up to 448. The "56" means requesting 56 CPU cores. The HPC systems "charges" by how many CPU cores * time used.
Requesting more CPU cores means waiting longer for job to start as the system is shared.

[HPC nodes available](https://www.bu.edu/tech/support/research/computing-resources/tech-summary/)

## library / compiler selection

The HPC "module" system is used to load modern compilers and libraries.
Since the same modules are often used for many jobs, we create a script like "gcc.sh" that is used by many job scripts.
For robustness, Gemini3D builds almost everything it uses.

## Run HPC job

Although our "gemini3d.job" rebuilds Gemini3D each time to be sure we're using the latest code, when setting up Gemini3D you might wish to do this interactively in case of errors.

Try running interactively:

```sh
./gemini3d.job
```

Submit the same scripts as an HPC job:

```sh
qsub gemini3d.job
```

## Check job status

```sh
watch qstat -u $(whoami)
```

When the job is done, files are created by the batcher like:

```
gemini3d.job.e$JOB_ID
gemini3d.job.o$JOB_ID
```

Check the *.e$JOB_ID file to see if something crashed.
This file is small or empty if no errors happened.
The *.o$JOB_ID file may be a megabyte or more of text with feedback from Gemini3D on what it was doing.


## Troubleshooting

On SCC, you may get an error message like:

> Gemini3D requires MPI-3 Fortran support.
> Please build MPI and set environment variable MPI_ROOT=~/openmpi so Gemini3D and other progams can find this new OpenMP.

```sh
cmake -Dprefix=~/openmpi -P /usr3/graduate/mhirsch/code/gemext/scripts/build_openmpi.cmake
```

In this case, run that command to build OpenMPI and edit the file "gcc.sh" to add the line to use your custom-built OpenMPI:

```sh
export MPI_ROOT=~/openmpi
```

That will take 10 minutes or so the first time.
