find_program(tar NAMES tar)
if(NOT tar)
  message(FATAL_ERROR "Could not find tar program")
endif()


function(tar_create pkg archive dir)

set(exclude --exclude-vcs --exclude=.github/)
if(pkg STREQUAL "hdf5")
  list(APPEND exclude --exclude=testfiles/ --exclude=doxygen/ --exclude=java/ --exclude=tools/test/ --exclude=release_docs/ --exclude=c++/ --exclude=examples/ --exclude=configure)
elseif(pkg STREQUAL "lapack")
  list(APPEND exclude --exclude=TESTING/ --exclude=LAPACKE/ --exclude=CBLAS/ --exclude=DOCS/ --exclude=CMAKE/)
elseif(pkg STREQUAL "scalapack_src")
  list(APPEND exclude --exclude=TESTING/ --exclude=TIMING/ --exclude=CMAKE/)
endif()

message(STATUS "${pkg}: create archive ${archive}")
execute_process(
COMMAND ${tar} --create --file ${archive} --bzip2 ${exclude} .
WORKING_DIRECTORY ${dir}
RESULT_VARIABLE ret
ERROR_VARIABLE err
)
if(NOT ret EQUAL 0)
  message(FATAL_ERROR "${pkg}: Failed to create archive ${archive}:
  ${ret}: ${err}")
endif()

endfunction(tar_create)
