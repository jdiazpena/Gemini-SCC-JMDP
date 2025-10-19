# USAGE:
# cmake -Dprefix=~/hdf5 -P build_hdf5.cmake
cmake_minimum_required(VERSION 3.20)

if(NOT prefix)
  message(FATAL_ERROR "Must specify -Dprefix=<path> to install library.")
endif()

set(args -DCMAKE_INSTALL_PREFIX:PATH=${prefix})

if(NOT bindir)
  if(DEFINED ENV{TMPDIR})
    set(bindir $ENV{TMPDIR}/hdf5_build)
  else()
    set(bindir /tmp/hdf5_build)
  endif()
endif()

execute_process(COMMAND ${CMAKE_COMMAND}
  ${args}
  -B${bindir}
  -S${CMAKE_CURRENT_LIST_DIR}/hdf5
RESULT_VARIABLE ret
)

if(ret EQUAL 0)
  message(STATUS "build in ${bindir}")
else()
  message(FATAL_ERROR "failed to configure.")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} --build ${bindir} --parallel
RESULT_VARIABLE ret
)

if(ret EQUAL 0)
  message(STATUS "install complete.")
else()
  message(FATAL_ERROR "failed to build and install.")
endif()
