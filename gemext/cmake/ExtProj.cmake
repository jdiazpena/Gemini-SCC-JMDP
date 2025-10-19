include(ExternalProject)


function(extproj name cmake_args depends)

if(IS_DIRECTORY ${name})
  set(src_path ${name})
  cmake_path(GET src_path STEM name)
else()
  set(src_path)
endif()

# PREPEND so that user arguments can override these defaults
list(PREPEND cmake_args
-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
-DCMAKE_PREFIX_PATH:PATH=${CMAKE_INSTALL_PREFIX}
-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
-DBUILD_TESTING:BOOL=false
-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
-DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
-DCMAKE_TLS_VERIFY:BOOL=${CMAKE_TLS_VERIFY}
)
if(CMAKE_TOOLCHAIN_FILE)
  list(APPEND cmake_args -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${CMAKE_TOOLCHAIN_FILE})
endif()
if(package)
  list(APPEND cmake_args
  -DCPACK_SOURCE_PACKAGE_FILE_NAME=${name}
  -DCPACK_PACKAGE_FILE_NAME=${name}-${CMAKE_SYSTEM_NAME}
  )
  file(APPEND ${manifest_txt}
  "${name}.tar.bz2
${name}-${CMAKE_SYSTEM_NAME}.tar.bz2
")
endif()

# builds each project in parallel, without needing to build all projects simultaneously in parallel.
# this greatly aids debugging while maintaining speed of build overall.
set(build_parallel ${CMAKE_COMMAND} --build <BINARY_DIR> --parallel)

set(extproj_args
CMAKE_ARGS ${cmake_args}
DEPENDS ${depends}
CONFIGURE_HANDLED_BY_BUILD true
USES_TERMINAL_DOWNLOAD true
USES_TERMINAL_UPDATE true
USES_TERMINAL_CONFIGURE true
USES_TERMINAL_BUILD true
USES_TERMINAL_INSTALL true
USES_TERMINAL_TEST true
)
if(package)
  list(APPEND extproj_args INSTALL_COMMAND "")
endif()

# --- cache_args for repos that need list args


# --- select repo type

if(IS_DIRECTORY "${src_path}")

  message(STATUS "${name}: ${src_path}")

  ExternalProject_Add(${name}
  SOURCE_DIR ${src_path}
  BUILD_COMMAND ${build_parallel}
  TEST_COMMAND ""
  ${extproj_args}
  )

elseif(EXISTS "${src_path}")
  # archive file on this computer or network drive

  if(name STREQUAL "hdf5")
    # special handling due to custom HDF5 archive layout
    # need to strip extra directories HDF_Group/HDF5/${HDF5_VERSION}
    find_program(tar NAMES tar)
    if(NOT tar)
      message(FATAL_ERROR "Could not find tar program")
    endif()

    set(_ext_src ${PROJECT_BINARY_DIR}/${name})
    file(MAKE_DIRECTORY ${_ext_src})

    execute_process(
    COMMAND ${tar} --extract --strip-components=4 --directory ${_ext_src} --file ${src_path}
    RESULT_VARIABLE ret
    )
    if(NOT ret EQUAL "0")
      message(FATAL_ERROR "${name}: could not extract source archive ${src_path}")
    endif()

    message(STATUS "${name}: using extracted source ${_ext_src}")

    ExternalProject_Add(${name}
    SOURCE_DIR ${_ext_src}
    BUILD_COMMAND ${build_parallel}
    TEST_COMMAND ""
    ${extproj_args}
    )

  else()
    # default archive without extra custom top-level directories
    message(STATUS "${name}: using source archive ${src_path}")

    ExternalProject_Add(${name}
    URL ${src_path}
    BUILD_COMMAND ${build_parallel}
    TEST_COMMAND ""
    ${extproj_args}
    )
  endif()

else()

  string(JSON url GET ${json_meta} "${name}" "url")

  if("${url}" MATCHES ".git$")
    string(JSON tag GET ${json_meta} ${name} tag)
    set(download_args
    GIT_REPOSITORY ${url}
    GIT_TAG ${tag}
    GIT_PROGRESS true
    GIT_SHALLOW true
    )
  else()
    set(download_args
    URL ${url}
    )
  endif()

  ExternalProject_Add(${name}
  ${download_args}
  BUILD_COMMAND ${build_parallel}
  TEST_COMMAND ""
  ${extproj_args}
  )
endif()


if(package)

ExternalProject_Add_Step(${name} CPackSource
COMMAND ${CMAKE_COMMAND}
  -Dpkgdir:PATH=${PROJECT_BINARY_DIR}/package
  -Dbindir:PATH=<BINARY_DIR>
  -Dname=${name}
  -Dcfg_name=CPackSourceConfig.cmake
  -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/package/cpack_run.cmake
DEPENDEES configure
)

ExternalProject_Add_Step(${name} CPackBinary
COMMAND ${CMAKE_COMMAND}
  -Dpkgdir:PATH=${PROJECT_BINARY_DIR}/package
  -Dbindir:PATH=<BINARY_DIR>
  -Dname=${name}
  -Dcfg_name=CPackConfig.cmake
  -Dsys_name=${CMAKE_SYSTEM_NAME}
  -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/package/cpack_run.cmake
DEPENDEES "CPackSource;build"
)
# CPackSource is a dependee to avoid race condition in ${pkgdir}/_CPack_Packaging directory.

endif()

endfunction(extproj)
