# USAGE:
# cmake -Dprefix=~/mpi -P build_openmpi.cmake
cmake_minimum_required(VERSION 3.20)

if(prefix)
  list(APPEND args -DCMAKE_INSTALL_PREFIX:PATH=${prefix})
endif()

if(NOT bindir)
  execute_process(COMMAND mktemp -d OUTPUT_VARIABLE bindir OUTPUT_STRIP_TRAILING_WHITESPACE RESULT_VARIABLE ret)
  if(NOT ret EQUAL 0)
    string(RANDOM LENGTH 6 r)
    set(bindir /tmp/build_${r})
  endif()
endif()

execute_process(COMMAND ${CMAKE_COMMAND}
  ${args}
  -B${bindir}
  -S${CMAKE_CURRENT_LIST_DIR}/mpi
RESULT_VARIABLE ret
)

if(ret EQUAL 0)
  message(STATUS "MPI build in ${bindir}")
else()
  message(FATAL_ERROR "MPI failed to configure.")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} --build ${bindir}
RESULT_VARIABLE ret
)

if(ret EQUAL 0)
  message(STATUS "MPI install complete.")
else()
  message(FATAL_ERROR "MPI failed to build and install.")
endif()
