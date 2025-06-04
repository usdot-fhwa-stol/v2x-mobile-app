# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(asn1_plugin_library VERSION 0.0.1 LANGUAGES C)

file(GLOB_RECURSE SRC_FILES
    "${PROJECT_SOURCE_DIR}/Classes/generated-files/2024/*.c"
)


add_library(asn1_plugin SHARED
    ${SRC_FILES}
)

set_target_properties(asn1_plugin PROPERTIES
  PUBLIC_HEADER asn1_plugin.h
  OUTPUT_NAME "asn1_plugin"
)

target_compile_definitions(asn1_plugin PUBLIC DART_SHARED_LIB)
