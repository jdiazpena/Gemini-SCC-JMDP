
function(system_meta jsonfile)

# metadata creation
if(EXISTS ${jsonfile})
  file(READ ${jsonfile} json)
else()
  set(json "{}")
endif()
message(STATUS "Writing package metadata to ${jsonfile}")

# system metadata
string(JSON json SET ${json} "system" "{}")

if(tar)

  execute_process(COMMAND ${tar} --version
  OUTPUT_VARIABLE tar_version
  OUTPUT_STRIP_TRAILING_WHITESPACE
  RESULT_VARIABLE ret
  )
  if(NOT ret EQUAL 0)
    message(FATAL_ERROR "tar ${tar} isn't working: ${ret}")
  endif()

  string(JSON json SET ${json} "system" "tar" \"${tar_version}\")

endif(tar)

if(GIT_FOUND)
  string(JSON json SET ${json} "system" "git" \"${GIT_VERSION_STRING}\")
endif()

string(JSON json SET ${json} "system" "cmake" \"${CMAKE_VERSION}\")
string(TIMESTAMP time UTC)
string(JSON json SET ${json} "system" "time" \"${time}\")

string(JSON m ERROR_VARIABLE e GET "packages")
if(NOT m)
  string(JSON json SET ${json} "packages" "{}")
endif()

set(json ${json} PARENT_SCOPE)

endfunction(system_meta)
