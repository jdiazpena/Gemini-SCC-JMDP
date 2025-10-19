cmake_minimum_required(VERSION 3.19)

if(NOT bindir)
  execute_process(COMMAND mktemp -d OUTPUT_VARIABLE bindir OUTPUT_STRIP_TRAILING_WHITESPACE RESULT_VARIABLE ret)
  if(NOT ret EQUAL 0)
    set(bindir /tmp/mpi3_check)
  endif()
endif()

set(sdir ${CMAKE_CURRENT_LIST_DIR}/scripts/mpi/test)

execute_process(COMMAND ${CMAKE_COMMAND} -B ${bindir} -S ${sdir} COMMAND_ERROR_IS_FATAL ANY)

execute_process(COMMAND ${CMAKE_COMMAND} --build ${bindir} COMMAND_ERROR_IS_FATAL ANY)

execute_process(COMMAND ${CMAKE_CTEST_COMMAND} --test-dir ${bindir} COMMAND_ERROR_IS_FATAL ANY)

cmake_host_system_information(RESULT hostname QUERY HOSTNAME)

message(STATUS "OK: MPI-3 on ${hostname}")
