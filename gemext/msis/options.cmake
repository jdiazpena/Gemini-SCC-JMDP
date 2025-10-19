message(STATUS "${PROJECT_NAME} ${PROJECT_VERSION} CMake ${CMAKE_VERSION} Toolchain ${CMAKE_TOOLCHAIN_FILE}")

option(msis2 "use MSIS 2.x neutral atmosphere model" on)

option(${PROJECT_NAME}_BUILD_TESTING "build test programs" ${PROJECT_IS_TOP_LEVEL})

option(${PROJECT_NAME}_BUILD_UTILS "build msis_setup" on)

include(GNUInstallDirs)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT AND PROJECT_IS_TOP_LEVEL)
  set(CMAKE_INSTALL_PREFIX "${PROJECT_BINARY_DIR}/local" CACHE PATH "default install path" FORCE)
endif()

# Necessary for shared library with Visual Studio / Windows oneAPI
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS true)
