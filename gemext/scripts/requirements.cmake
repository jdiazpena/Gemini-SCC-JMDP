# prints Gemini3D prereqs on stdout
#  cmake -P scripts/requirements.cmake

cmake_minimum_required(VERSION 3.19)

set(prereq_file ${CMAKE_CURRENT_LIST_DIR}/requirements.json)

# --- helper functions

function(read_prereqs sys_id)

  file(READ ${prereq_file} json)

  set(prereqs)

  string(JSON N LENGTH ${json} ${sys_id} pkgs)
  math(EXPR N "${N}-1")
  foreach(i RANGE ${N})
    string(JSON _u GET ${json} ${sys_id} pkgs ${i})
    list(APPEND prereqs ${_u})
  endforeach()

  string(JSON cmd GET ${json} ${sys_id} cmd)

  string(REPLACE ";" " " prereqs "${prereqs}")
  set(prereqs ${prereqs} PARENT_SCOPE)
  set(cmd ${cmd} PARENT_SCOPE)

endfunction(read_prereqs)

# --- main program

if(APPLE)
  set(names brew port)
elseif(UNIX)
  set(names apt yum pacman zypper)
endif()

foreach(t IN LISTS names)
  find_program(${t} NAMES ${t})
  if(${t})
    read_prereqs(${t})
    execute_process(COMMAND ${CMAKE_COMMAND} -E echo "${cmd} ${prereqs}")
    return()
  endif()
endforeach()

message(FATAL_ERROR "Package manager not found ${names}")
