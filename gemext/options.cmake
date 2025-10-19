message(STATUS "${PROJECT_NAME} CMake ${CMAKE_VERSION} Toolchain ${CMAKE_TOOLCHAIN_FILE}")
cmake_host_system_information(RESULT host_ramMB QUERY TOTAL_PHYSICAL_MEMORY)
cmake_host_system_information(RESULT host_cpu QUERY PROCESSOR_DESCRIPTION)
math(EXPR host_ramGB "${host_ramMB} / 1000")
message(STATUS "${host_ramGB} GB RAM on ${CMAKE_HOST_SYSTEM_NAME} ${CMAKE_HOST_SYSTEM_VERSION} with ${CMAKE_HOST_SYSTEM_PROCESSOR} ${host_cpu}")

# --- user options

option(BUILD_SHARED_LIBS "Build shared libraries")

option(package "recursively create source and binary packages with CPack")

if(local)
  get_filename_component(local ${local} ABSOLUTE)

  if(NOT IS_DIRECTORY ${local})
    message(FATAL_ERROR "Local directory ${local} does not exist")
  endif()
endif()

option(find "Attempt to find numeric libraries--saves CI build time, but may slow runtime performance.")

option(amr "build packages used for AMR")

option(scotch "MUMPS Scotch + METIS ordering (PORD is default and always used)")

option(hdf5_parallel "HDF5 parallel I/O using MPI")

option(EP_UPDATE_DISCONNECTED "false (default): check for updated Git remote. true: check for updates on each CMake configure")

set(CMAKE_EP_GIT_REMOTE_UPDATE_STRATEGY "CHECKOUT")

option(mumps_only "only build MUMPS stack, not other libs")
option(CMAKE_TLS_VERIFY "Verify TLS certs" on)

# --- config checks
get_property(is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(is_multi_config)
  if(CMAKE_GENERATOR MATCHES "Ninja")
    set(suggest Ninja)
  elseif(WIN32)
    set(suggest "MinGW Makefiles")
  else()
    set(suggest "Unix Makefiles")
  endif()
  message(FATAL_ERROR "Please use a single configuration generator like:
  cmake -G \"${suggest}\"
  ")
endif()

# --- avoid stray compiler wrappers
set(CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH false)

# --- CMake Module search path (for Find*.cmake)
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

get_filename_component(CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX} ABSOLUTE)
# file(MAKE_DIRECTORY) doesn't halt execution. We do this to make a useful error message.
file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX}/cmake)
if(NOT IS_DIRECTORY ${CMAKE_INSTALL_PREFIX}/cmake)
  message(FATAL_ERROR "Failed to create ${CMAKE_INSTALL_PREFIX}/cmake
  Please set CMAKE_INSTALL_PREFIX to a writable location")
endif()

message(STATUS "CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}
ensure this is the directory you wish to install libraries to.")

file(GENERATE OUTPUT .gitignore CONTENT "*")

# --- check for updated external projects when "false"
set_property(DIRECTORY PROPERTY EP_UPDATE_DISCONNECTED ${EP_UPDATE_DISCONNECTED})

# --- read JSON with URLs for each library
file(READ ${PROJECT_SOURCE_DIR}/cmake/libraries.json json_meta)
