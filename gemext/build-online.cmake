# Build Gemini3D external libraries using internet connection to download
# options:
#
# -Dprefix: where to install libraries under (default ~/libgem_<compiler_id>)
# -Dtarget: which target9s) to build (default all)

cmake_minimum_required(VERSION 3.20)

option(find "find bigger libraries like HDF5" on)
option(mumps_only "only build MUMPS")

include(${CMAKE_CURRENT_LIST_DIR}/cmake/git.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/compiler_id.cmake)

set(CMAKE_EXECUTE_PROCESS_COMMAND_ECHO STDOUT)

# random build dir to avoid confusion with reused build dir
if(NOT bindir)
execute_process(COMMAND mktemp -d OUTPUT_VARIABLE bindir OUTPUT_STRIP_TRAILING_WHITESPACE RESULT_VARIABLE ret)
if(NOT ret EQUAL 0)
  string(RANDOM LENGTH 6 r)
  set(bindir /tmp/build_${r})
endif()
endif()

set(args -Dfind:BOOL=${find} -Dmumps_only:BOOL=${mumps_only})

if(prefix)
  list(APPEND args -DCMAKE_INSTALL_PREFIX:PATH=${prefix})
endif()

message(STATUS "Building Gemini3D external libraries in ${bindir} with options:
${args}")

execute_process(
COMMAND ${CMAKE_COMMAND} ${args}
-B${bindir} -S${CMAKE_CURRENT_LIST_DIR}
COMMAND_ERROR_IS_FATAL ANY
)

# don't specify cmake --build --parallel to avoid confusion when build errors happen in one library
# each library itself is built in parallel,
# so adding --parallel here doesn't really help build speed.
execute_process(
COMMAND ${CMAKE_COMMAND} --build ${bindir}
COMMAND_ERROR_IS_FATAL ANY
)

# the add_subdirectory() libraries need to be installed
execute_process(
COMMAND ${CMAKE_COMMAND} --install ${bindir}
COMMAND_ERROR_IS_FATAL ANY
)
