include(ExternalProject)


function(fetch_source name url_type)

set(extproj_args
CMAKE_ARGS ${cmake_args}
UPDATE_DISCONNECTED true
CONFIGURE_HANDLED_BY_BUILD true
)

string(JSON url GET ${json_meta} ${name} url)

if(url_type STREQUAL "git")

string(JSON tag GET ${json_meta} ${name} tag)

ExternalProject_Add(${name}
GIT_REPOSITORY ${url}
GIT_TAG ${tag}
GIT_PROGRESS true
${extproj_args}
CONFIGURE_COMMAND ""
BUILD_COMMAND ${CMAKE_COMMAND} -Dpkg=${name} -Darchive=${PROJECT_BINARY_DIR}/package/${name}.tar.bz2 -Ddir:PATH=<SOURCE_DIR> -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/tar_create.cmake
TEST_COMMAND ""
INSTALL_COMMAND ""
)

elseif(url_type STREQUAL "archive")

string(JSON tag GET ${json_meta} ${name} sha256)

if(url MATCHES ".tar.gz$")
  set(download_name ${name}.tar.gz)
elseif(url MATCHES ".tar.bz2$")
  set(download_name ${name}.tar.bz2)
elseif(url MATCHES ".tar.zst$")
  set(download_name ${name}.tar.zst)
else()
  message(FATAL_ERROR "${name}: unknown source archive type")
endif()

ExternalProject_Add(${name}
URL ${url}
URL_HASH SHA256=${sha256}
${extproj_args}
CONFIGURE_COMMAND ""
BUILD_COMMAND ${CMAKE_COMMAND} -E copy <DOWNLOADED_FILE> ${PROJECT_BINARY_DIR}/package/
TEST_COMMAND ""
INSTALL_COMMAND ""
DOWNLOAD_NO_EXTRACT true
DOWNLOAD_NAME ${download_name}
)

endif()

endfunction(fetch_source)
