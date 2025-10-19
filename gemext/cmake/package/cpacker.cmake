set(CPACK_GENERATOR "TBZ2")
set(CPACK_SOURCE_GENERATOR "TBZ2")

set(CPACK_SOURCE_PACKAGE_FILE_NAME "external")
set(CPACK_PACKAGE_FILE_NAME "external-${CMAKE_SYSTEM_NAME}")
set(CPACK_PACKAGE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/package)

set(CPACK_POST_BUILD_SCRIPTS ${CMAKE_CURRENT_LIST_DIR}/cpackSign.cmake)

# not .gitignore as its regex syntax is more advanced than CMake
set(CPACK_SOURCE_IGNORE_FILES .git/ .github/ .vscode/ .mypy_cache/ _CPack_Packages/
${CMAKE_BINARY_DIR}/ ${PROJECT_BINARY_DIR}/
archive/ build*/
)

include(CPack)
