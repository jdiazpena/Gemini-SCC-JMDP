# Creates archive file of archive filess from all packages Git tags.
# This is to avoid problems with having ~ million files in a single archive.

cmake_minimum_required(VERSION 3.19...3.25)
# to save JSON metadata requires CMake >= 3.19

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/git.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../cmake/tar.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../cmake/system_meta.cmake)

set(CMAKE_EXECUTE_PROCESS_COMMAND_ECHO STDOUT)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../cmake)

if(NOT DEFINED outdir)
  set(outdir ~/gemini_package)
endif()
get_filename_component(outdir ${outdir} ABSOLUTE)

if(NOT DEFINED top_archive)
  set(top_archive ${outdir}/gemini_package.tar)
endif()

if(NOT DEFINED packages)

set(packages
gemini3d external
ffilesystem
h5fortran hdf5 zlib
glow hwm14 msis
lapack
scalapack scalapack_src
mumps mumps_src
)

endif()

option(CMAKE_TLS_VERIFY "Verify TLS certs" on)

# --- functions

function(download_archive pkg url archive sha256)

# assume archive directly
file(DOWNLOAD ${url} ${archive}
EXPECTED_HASH SHA256=${sha256}
SHOW_PROGRESS
STATUS ret
)
list(GET ret 0 stat)
if(stat EQUAL 0)
  message(STATUS "${pkg}: ${ret}")
else()
  message(FATAL_ERROR "${pkg}: archive download failed: ${ret}")
endif()

endfunction(download_archive)


# --- main program

file(MAKE_DIRECTORY ${outdir})
message(STATUS "Packing archives under ${outdir}")

file(READ ${CMAKE_CURRENT_LIST_DIR}/../cmake/libraries.json meta)

set(jsonfile ${outdir}/manifest.json)
set(manifest_txt ${outdir}/manifest.txt)

file(WRITE ${manifest_txt}
"manifest.json
")

system_meta(${jsonfile})


foreach(pkg IN LISTS packages)

set(wd ${outdir}/${pkg})

string(JSON url GET ${meta} ${pkg} url)


if(pkg STREQUAL "mumps_src")
  set(archive_name ${pkg}.tar.gz)
else()
  set(archive_name ${pkg}.tar.bz2)
endif()
set(archive ${outdir}/${archive_name})

if(url MATCHES "\.git$")
  # clone shallow, then make archive
  message(STATUS "${pkg}: Git: ${url}")

  string(JSON ${pkg}_tag GET ${meta} ${pkg} "tag")

  git_clone(${pkg} ${url} ${${pkg}_tag} ${wd})

  tar_create(${pkg} ${archive} ${wd})

else()
  message(STATUS "${pkg}: archive: ${url} => ${archive}")

  string(JSON ${pkg}_sha256 GET ${meta} ${pkg} sha256)

  download_archive(${pkg} ${url} ${archive} ${${pkg}_sha256})
endif()

# meta for this package
string(JSON json SET ${json} "packages" ${pkg} "{}")
string(JSON json SET ${json} "packages" ${pkg} "archive" \"${archive_name}\")

if(${pkg}_tag)
  string(JSON json SET ${json} "packages" ${pkg} "tag" \"${${pkg}_tag}\")
endif()

string(TIMESTAMP time UTC)
string(JSON json SET ${json} "packages" ${pkg} "time" \"${time}\")

file(SHA256 ${archive} sha256)
string(JSON json SET ${json} "packages" ${pkg} "sha256" \"${sha256}\")

message(DEBUG "${json}")
file(WRITE ${jsonfile} "${json}")
file(APPEND ${manifest_txt}
"${archive_name}
")
# write meta for each file in case of error, so that we don't waste prior effort

endforeach()

# append build-offline.cmake
file(APPEND ${manifest_txt} "build-offline.cmake")
file(COPY ${CMAKE_CURRENT_LIST_DIR}/../build-offline.cmake DESTINATION ${outdir}/)


# --- create one big archive file of all the archive files above

message(STATUS "Creating top-level archive ${top_archive} of:
${packages}")

execute_process(
COMMAND ${CMAKE_COMMAND} -E tar c ${top_archive} --files-from=${manifest_txt}
RESULT_VARIABLE ret
ERROR_VARIABLE err
WORKING_DIRECTORY ${outdir}
)
if(NOT ret EQUAL 0)
  message(FATAL_ERROR "Failed to create archive ${top_archive}:
  ${ret}: ${err}")
endif()

# --- GPG sign big archive file
find_package(GPG)

if(GPG_FOUND)
  gpg_sign(${top_archive})
  file(COPY ${top_archive}.asc DESTINATION ${outdir}/)
  message(STATUS "signed ${top_archive} in ${top_archive}.asc")
else()
  message(WARNING "could not GPG sign ${top_archive} as GPG is not present/working.")
endif()

message(STATUS "Complete: ${top_archive}")
