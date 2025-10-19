function(check_mpi)

if(NOT DEFINED MPI_ROOT)
  if(DEFINED ENV{MPI_ROOT})
    set(MPI_ROOT $ENV{MPI_ROOT})
  elseif(DEFINED ENV{I_MPI_ROOT})
    set(MPI_ROOT $ENV{I_MPI_ROOT})
  endif()
endif()

message(STATUS "MPI_ROOT=${MPI_ROOT}")

find_package(MPI COMPONENTS C Fortran)
if(NOT MPI_FOUND)
  message(FATAL_ERROR "MPI library not found. Please set environment variable MPI_ROOT to the path of the MPI library.
For example, if you have ~/openmpi/bin/mpiexec, set env var MPI_ROOT=~/openmpi or specify:
cmake -Bbuild -DMPI_ROOT=~/openmpi")
endif()

if(NOT MPI_3_Fortran_OK)

message(CHECK_START "Checking for MPI-3 Fortran support")

try_compile(MPI_3_Fortran_OK
${CMAKE_CURRENT_BINARY_DIR}/mpi3test
${CMAKE_CURRENT_SOURCE_DIR}/scripts/mpi/test
MPI3test
CMAKE_FLAGS -DMPI_ROOT=${MPI_ROOT}
)
if(MPI_3_Fortran_OK)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
  message(WARNING "Gemini3D requires MPI-3 Fortran support.
Either specify the path to a newer/different MPI library via environment variable MPI_ROOT
or build OpenMPI from source with Fortran MPI-3 support:
cmake -Dprefix=~/openmpi -P ${CMAKE_CURRENT_SOURCE_DIR}/scripts/build_openmpi.cmake")
endif()

endif()

set(MPI_ROOT ${MPI_ROOT} PARENT_SCOPE)

endfunction()
