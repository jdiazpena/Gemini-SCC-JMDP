if(CRAY OR DEFINED ENV{MKLROOT})
  add_custom_target(scalapack)
  return()
endif()

set(scalapack_args
-DBUILD_SINGLE:BOOL=false
-DBUILD_DOUBLE:BOOL=true
-DBUILD_COMPLEX:BOOL=false
-DBUILD_COMPLEX16:BOOL=false
)

if(MPI_ROOT)
  list(APPEND scalapack_args -DMPI_ROOT:PATH=${MPI_ROOT})
endif()

set(scalapack_deps)
if(NOT LAPACK_FOUND)
  set(scalapack_deps lapack)
endif()

if(local)
  list(APPEND scalapack_args -Dlocal:PATH=${local})
endif()

extproj(scalapack "${scalapack_args}" "${scalapack_deps}")
