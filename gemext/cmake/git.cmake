find_package(Git REQUIRED)

function(git_clone pkg url tag dir)

# NOTE: "git archive" doesn't work with most modern servers.

get_filename_component(dir ${dir} ABSOLUTE)

if(IS_DIRECTORY ${dir})
  # same branch?
  execute_process(COMMAND ${GIT_EXECUTABLE} -C ${dir} branch --show-current
  RESULT_VARIABLE ret
  OUTPUT_STRIP_TRAILING_WHITESPACE
  OUTPUT_VARIABLE branch
  )
  if(ret EQUAL 0 AND branch STREQUAL "${tag}")
    message(STATUS "${pkg}: Already on Git branch ${branch}")
    return()
  endif()

  # same tag?
  execute_process(COMMAND ${GIT_EXECUTABLE} -C ${dir} describe --tags
  RESULT_VARIABLE ret
  OUTPUT_STRIP_TRAILING_WHITESPACE
  OUTPUT_VARIABLE tag
  )
  if(ret EQUAL 0 AND tag STREQUAL "${tag}")
    message(STATUS "${pkg}: Already up-to-date with Git tag ${tag}")
    return()
  endif()
endif()

execute_process(
COMMAND ${GIT_EXECUTABLE} clone ${url} --depth 1 --branch ${tag} --single-branch ${dir}
RESULT_VARIABLE ret
)

if(NOT ret EQUAL 0)
  message(FATAL_ERROR "${pkg}: Failed to Git clone ${url} to ${dir}: ${ret}")
endif()

endfunction(git_clone)
