# Fix Arrow 19.0.1's pinned Boost download URL: boostorg.jfrog.io has been
# retired; the same sources now live at archives.boost.io (repacked archive,
# so pair this with the updated SHA256 in
# cmake/in/arrow.cpp.thirdparty.versions.txt.in).
# No-op when a mirror rewrite (patch_arrow_thirdparty_mirror.cmake) already
# replaced the URLs.
set(_toolchain_file "${ARROW_SOURCE_DIR}/cpp/cmake_modules/ThirdpartyToolchain.cmake")
if(NOT EXISTS "${_toolchain_file}")
    message(FATAL_ERROR "Arrow ThirdpartyToolchain.cmake not found: ${_toolchain_file}")
endif()
file(READ "${_toolchain_file}" _content)
if(NOT _content MATCHES "boostorg.jfrog.io")
    message(STATUS "Arrow ThirdpartyToolchain.cmake: Boost URL already migrated, skipping")
    return()
endif()
string(REPLACE
    "boostorg.jfrog.io/artifactory/main/release"
    "archives.boost.io/release"
    _content "${_content}")
file(WRITE "${_toolchain_file}" "${_content}")
message(STATUS "Arrow ThirdpartyToolchain.cmake: Boost URL migrated to archives.boost.io")
