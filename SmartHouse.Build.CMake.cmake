cmake_minimum_required (VERSION 3.25)

include(FetchContent)

if (CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
	set(SMARTHOUSE_GIT_TAG "" CACHE STRING "Git tag to be used for SmartHouse modules.")

	if(WIN32)
		add_compile_definitions(SMARTHOUSE_WIN32)
	elseif(UNIX)
		add_compile_definitions(SMARTHOUSE_UNIX)
	else()
		add_compile_definitions(SMARTHOUSE_BAREMETAL)
	endif()
endif()

if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/app")
    add_subdirectory("app")
endif()
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src")
    add_subdirectory("src")
endif()
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/test" AND (WIN32 OR UNIX))
    add_subdirectory("test")
endif()

enable_testing()

function(SmartHouseAddDependency git_url git_tag)

    get_filename_component(repo_filename "${git_url}" NAME)

    # Decide which tag/branch to use, or none
    set(_tag_to_use "")
    if(git_tag)
        set(_tag_to_use "${git_tag}")
    elseif(DEFINED SMARTHOUSE_GIT_TAG)
        set(_tag_to_use "${SMARTHOUSE_GIT_TAG}")
    endif()

    # Declare fetch content with or without GIT_TAG
    if(_tag_to_use)
        FetchContent_Declare(
            ${repo_filename}
            GIT_REPOSITORY ${git_url}
            GIT_TAG        ${_tag_to_use}
            GIT_SHALLOW    TRUE
            GIT_PROGRESS   TRUE
        )
    else()
        message(STATUS "No git_tag provided, using repository's default branch for ${repo_filename}")
        FetchContent_Declare(
            ${repo_filename}
            GIT_REPOSITORY ${git_url}
            GIT_SHALLOW    TRUE
            GIT_PROGRESS   TRUE
        )
    endif()

    FetchContent_MakeAvailable(${repo_filename})
endfunction()

function (SmartHouseInitModule)
	# Enable Hot Reload for MSVC compilers if supported.
	if (POLICY CMP0141)
	  cmake_policy(SET CMP0141 NEW)
	  set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
	endif()

endfunction()