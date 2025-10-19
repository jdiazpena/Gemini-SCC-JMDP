set(CMAKE_EXECUTE_PROCESS_COMMAND_ECHO STDOUT)

find_file(cfg
NAMES ${cfg_name}
HINTS ${bindir}
NO_DEFAULT_PATH
)
if(NOT cfg)
  message(FATAL_ERROR "${name}: did not find ${cfg_name} in ${bindir}")
endif()

execute_process(
COMMAND ${CMAKE_CPACK_COMMAND}
-G TBZ2
--config ${cfg}
-B ${bindir}
RESULT_VARIABLE ret
ERROR_VARIABLE err
)
# "-B ${bindir}" in case the sub-project has an arbitrary CPACK_PACKAGE_DIRECTORY specified in itself
# -DCPACK_PACKAGE_INSTALL_DIRECTORY="" didn't help for HDF5 with arbitrary source-package-only subdir HDF_Group/HDF5/${HDF5_VERSION}
# -DCPACK_PRE_BUILD_SCRIPTS=${CMAKE_CURRENT_LIST_DIR}/cpack_hdf5.cmake didn't get triggered--many such options don't work when fed into CPack command line

if(NOT ret EQUAL 0)
  message(FATAL_ERROR "${name}: failed to package using ${cfg}: ${ret}:
  ${err}")
endif()

if(cfg MATCHES "CPackSourceConfig.cmake$")
  set(archive ${bindir}/${name}.tar.bz2)
else()
  set(archive ${bindir}/${name}-${sys_name}.tar.bz2)
endif()

if(NOT EXISTS ${archive})
  message(FATAL_ERROR "${name}: package archive not found: ${archive}")
endif()
file(COPY ${archive} DESTINATION ${pkgdir}/)
