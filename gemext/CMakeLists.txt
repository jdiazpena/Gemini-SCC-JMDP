# builds all Gemini3D external libraries

cmake_minimum_required(VERSION 3.20...3.29)
# Cmake 3.19 string(JSON)
# Cmake 3.20 cmake_path()

if(NOT CMAKE_BUILD_TYPE)
  # ignore ENV{CMAKE_BUILD_TYPE} as we want to directly capture this project's user intent
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Release default")
endif()

include(cmake/toolchain.cmake)

project(GeminiExternalLibs
LANGUAGES C CXX Fortran
VERSION 1.1.1
)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  get_filename_component(home "~" ABSOLUTE)
  string(TOLOWER ${CMAKE_Fortran_COMPILER_ID} ln)
  set(CMAKE_INSTALL_PREFIX ${home}/libgem_${ln} CACHE PATH "default install prefix" FORCE)
endif()

include(options.cmake)

include(cmake/GitSubmodule.cmake)

# --- main program

# NOTE: lists must be passed via CMAKE_CACHE_ARGS using -Dvar:STRING=${var}
# the variable type must be included e.g. STRING

# template function
include(cmake/ExtProj.cmake)
include(cmake/FetchSource.cmake)

# --- avoid Anaconda libraries
if(DEFINED ENV{CONDA_PREFIX})
  list(APPEND CMAKE_IGNORE_PREFIX_PATH $ENV{CONDA_PREFIX})
  list(APPEND CMAKE_IGNORE_PATH $ENV{CONDA_PREFIX}/bin)
  # need CMAKE_IGNORE_PATH for CMake < 3.23
  # and to ensure system env var PATH doesn't interfere
  # despite CMAKE_IGNORE_PREFIX_PATH
endif()

include(cmake/CheckMPI.cmake)
check_mpi()

if(package)
  file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/package)
  if(NOT DEFINED manifest_txt)
    set(manifest_txt ${PROJECT_BINARY_DIR}/package/manifest.txt)
  endif()
  file(WRITE ${manifest_txt}
  "scalapack_src.tar.bz2
mumps_src.tar.gz
")
  fetch_source(scalapack_src git)
  fetch_source(mumps_src archive)
endif()

if(CRAY)
  # install toolchain file for future use
  file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/cmake/cray.cmake DESTINATION ${CMAKE_INSTALL_PREFIX}/cmake/)
endif()


if(NOT mumps_only)
  foreach(t IN ITEMS ffilesystem glow hwm14 h5fortran msis)
    git_submodule(${CMAKE_CURRENT_SOURCE_DIR}/${t})
    add_subdirectory(${t})
  endforeach()
endif()

include(cmake/lapack.cmake)
include(cmake/scalapack.cmake)
include(cmake/mumps.cmake)

# print summary of configuration
include(FeatureSummary)

add_feature_info(Find find "find installed libraries")
add_feature_info(HDF5-MPI hdf5_parallel "HDF5-MPI layer (otherwise, serial HDF5)")
add_feature_info(shared BUILD_SHARED_LIBS "build shared libs (otherwise, build static libs)")
add_feature_info(remote_disconnected EP_UPDATE_DISCONNECTED "don't update remote repositories after first download/confiugre")
add_feature_info(packaging package "preparing new data upoad (for development team)")

feature_summary(WHAT ENABLED_FEATURES DISABLED_FEATURES)

include(cmake/package/cpacker.cmake)
