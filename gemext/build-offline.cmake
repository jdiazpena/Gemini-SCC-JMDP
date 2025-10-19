# Build Gemini3D external libraries using local tarfile without internet.
#
# options:
#
# -Dprefix: where to install libraries under (default ~/libgem)
# -Dtarfile: where is the tarfile (default ./gemini_package.tar or ~/gemini_package.tar)

cmake_minimum_required(VERSION 3.20)

set(CMAKE_EXECUTE_PROCESS_COMMAND_ECHO STDOUT)

# find tarfile
if(NOT tarfile)
  find_file(tarfile NAMES gemini_package.tar
  PATHS . ENV HOME ENV USERPROFILE
  NO_DEFAULT_PATH
  )
  if(NOT tarfile)
    message(FATAL_ERROR "Could not find gemini_package.tar
    Specify like:
    cmake -Dtarfile=<fullpath to gemini_package.tar> -P ${CMAKE_CURRENT_LIST_FILE}")
  endif()
endif()
get_filename_component(tarfile ${tarfile} ABSOLUTE)
get_filename_component(arcdir ${tarfile} DIRECTORY)

# extract big tarfile
message(STATUS "Extract ${tarfile} to ${arcdir}")
file(ARCHIVE_EXTRACT INPUT ${tarfile} DESTINATION ${arcdir}/)

# build Gemini3D external libraries
set(gemini_ext_tar ${arcdir}/external.tar.bz2)

message(STATUS "Extract Gemini3D/external project ${gemini_ext_tar} in ${arcdir}")
file(ARCHIVE_EXTRACT INPUT ${gemini_ext_tar} DESTINATION ${arcdir}/)

set(srcdir ${arcdir}/external)

execute_process(COMMAND mktemp -d OUTPUT_VARIABLE bindir OUTPUT_STRIP_TRAILING_WHITESPACE RESULT_VARIABLE ret)
if(NOT ret EQUAL 0)
  string(RANDOM LENGTH 6 r)
  set(bindir /tmp/build_${r})
endif()

message(STATUS "offline: build Gemini3D external libraries in ${bindir} with options:
${args}")

execute_process(
COMMAND ${CMAKE_COMMAND} ${args}
-Dlocal:PATH=${arcdir}
-B${bindir} -S${srcdir}
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
