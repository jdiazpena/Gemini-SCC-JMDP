if(MUMPS_FOUND)
  add_custom_target(mumps)
  return()
endif()

set(mumps_cmake_args
-Dscotch:BOOL=${scotch}
-Dopenmp:BOOL=false
-Dparallel:BOOL=true
-DBUILD_SINGLE:BOOL=false
-DBUILD_DOUBLE:BOOL=true
-DBUILD_COMPLEX:BOOL=false
-DBUILD_COMPLEX16:BOOL=false
)

if(MPI_ROOT)
  list(APPEND mumps_cmake_args -DMPI_ROOT:PATH=${MPI_ROOT})
endif()

if(MSVC AND BUILD_SHARED_LIBS)
  # long-standing bug in MUMPS that can't handle shared libraries with MSVC (Windows Intel oneAPI)
  list(APPEND mumps_cmake_args -DBUILD_SHARED_LIBS:BOOL=false)
endif()

if(local)
  list(APPEND mumps_cmake_args -Dlocal:PATH=${local})
endif()

if(NOT SCALAPACK_FOUND)
  set(mumps_deps scalapack)
endif()

if(NOT LAPACK_FOUND)
  list(APPEND mumps_deps lapack)
endif()

extproj(mumps "${mumps_cmake_args}" "${mumps_deps}")
