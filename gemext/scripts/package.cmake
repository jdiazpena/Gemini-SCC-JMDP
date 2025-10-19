# Creates archive file of archive files from CPack.
# This is to avoid problems with having ~ million files in a single archive.
# this allows for an offline-installer script
#
# The top-level package will be under this repo's build/gemini_package.tar

cmake_minimum_required(VERSION 3.17...3.25)

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/system_meta.cmake)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../cmake)

set(CMAKE_EXECUTE_PROCESS_COMMAND_ECHO STDOUT)

get_filename_component(build_dir ${CMAKE_CURRENT_LIST_DIR}/../build ABSOLUTE)
set(pkgdir ${build_dir}/package)

set(top_archive ${pkgdir}/gemini_package.tar)

set(manifest_txt ${pkgdir}/manifest.txt)

if(WIN32)
  set(CMAKE_SYSTEM_NAME Windows)
elseif(APPLE)
  set(CMAKE_SYSTEM_NAME Darwin)
elseif(UNIX)
  set(CMAKE_SYSTEM_NAME Linux)
else()
  message(FATAL_ERROR "Unknown operating system")
endif()

# --- configure

set(args
-DCMAKE_INSTALL_PREFIX:PATH=${build_dir}
-DCMAKE_PREFIX_PATH:PATH=${build_dir}
-Dpackage:BOOL=true
-Dfind:BOOL=false
-Dmanifest_txt:FILEPATH=${manifest_txt}
)

message(STATUS "package Gemini3D external libraries in ${pkgdir} with options:
${args}")

execute_process(
COMMAND ${CMAKE_COMMAND} ${args}
-B${build_dir}
-S${CMAKE_CURRENT_LIST_DIR}/..
RESULT_VARIABLE ret
)

if(NOT ret EQUAL 0)
  message(FATAL_ERROR "Gemini3D external libraries failed to configure: ${ret}")
endif()

# --- build and CPack (via ExternalProject)

execute_process(
COMMAND ${CMAKE_COMMAND} --build ${build_dir}
RESULT_VARIABLE ret
)

if(ret EQUAL 0)
  message(STATUS "Gemini3D external libraries build complete.")
else()
  message(FATAL_ERROR "Gemini3D external libraries failed to build: ${ret}")
endif()

# --- CPack gemini3d/external itself

file(APPEND ${manifest_txt}
"external.tar.bz2
external-${CMAKE_SYSTEM_NAME}.tar.bz2
")

execute_process(
COMMAND ${CMAKE_COMMAND}
-Dpkgdir:PATH=${build_dir}/package
-Dbindir:PATH=${build_dir}
-Dname=external
-Dcfg_name=CPackSourceConfig.cmake
-P ${CMAKE_CURRENT_LIST_DIR}/../cmake/package/cpack_run.cmake
RESULT_VARIABLE ret
)
if(NOT ret EQUAL 0)
  message(FATAL_ERROR "Gemini3D/external libraries failed to source package: ${ret}")
endif()

execute_process(
COMMAND ${CMAKE_COMMAND}
-Dpkgdir:PATH=${build_dir}/package
-Dbindir:PATH=${build_dir}
-Dname=external
-Dcfg_name=CPackConfig.cmake
-Dsys_name=${CMAKE_SYSTEM_NAME}
-P ${CMAKE_CURRENT_LIST_DIR}/../cmake/package/cpack_run.cmake
RESULT_VARIABLE ret
)
if(NOT ret EQUAL 0)
  message(FATAL_ERROR "Gemini3D/external libraries failed to binary package: ${ret}")
endif()

# --- prepare for top archive

file(READ ${CMAKE_CURRENT_LIST_DIR}/../cmake/libraries.json meta)

set(jsonfile ${pkgdir}/manifest.json)

system_meta(${jsonfile})

file(APPEND ${manifest_txt}
"build-offline.cmake
libraries.json
")
file(COPY
${CMAKE_CURRENT_LIST_DIR}/build-offline.cmake
${CMAKE_CURRENT_LIST_DIR}/../cmake/libraries.json
DESTINATION ${pkgdir}/
)

# --- create big archive file of CPack archive files

message(STATUS "Creating top-level source archive ${top_archive}")

execute_process(
COMMAND ${CMAKE_COMMAND} -E tar c ${top_archive} --files-from=${manifest_txt}
RESULT_VARIABLE ret
ERROR_VARIABLE err
WORKING_DIRECTORY ${pkgdir}
)
if(NOT ret EQUAL 0)
  message(FATAL_ERROR "Failed to create archive ${top_archive}:
  ${ret}: ${err}")
endif()

# --- GPG sign big archive file
find_package(GPG)

if(GPG_FOUND)
  gpg_sign(${top_archive})
  file(COPY ${top_archive}.asc DESTINATION ${pkgdir}/)
  message(STATUS "signed ${top_archive} in ${top_archive}.asc")
else()
  message(WARNING "could not GPG sign ${top_archive} as GPG is not present/working.")
endif()

message(STATUS "Complete: ${top_archive}")
