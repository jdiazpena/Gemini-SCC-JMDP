# simdir is where simulation output HDF5 files will be written as simulation runs

# exsrc= defined like in gemci.sh
# gmbin= defined like in gemini3d.job

rootdir=/projectnb/semetergrp/gemini3dfbi
rootdirtoshi=/projectnb/burbsp/jmdptemp

configdir=${rootdir}/configfiles/said/
simdir=${rootdir}/gemini3d_sims/240503_said_aeh_15m05J3e3Q175E_512x512x512/

#simdir=${rootdir}/gemini3d_sims/240204_said_v_15m08J05P5e3Q175E_512x512x512/

#python -m gemini3d.run ${configdir} ${simdir} -gemexe ${gmbin}/gemini.bin

#python -m gemini3d.model ${configdir} ${simdir}

mpiexec -np 512  ${gmbin}/gemini.bin ${simdir}


