cmake_minimum_required(VERSION 3.0)

project(VulkanTutorial)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")

add_subdirectory(lib/glfw)
add_subdirectory(lib/glm)

file(GLOB_RECURSE CXX_SOURCES CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")

set(SHADER_FILES
	${CMAKE_CURRENT_SOURCE_DIR}/shaders/shader.vert
	${CMAKE_CURRENT_SOURCE_DIR}/shaders/shader.frag
)

set(SHADER_BINARIES
	${CMAKE_CURRENT_SOURCE_DIR}/bin/shader.vert.spv
	${CMAKE_CURRENT_SOURCE_DIR}/bin/shader.frag.spv
)

add_custom_command(
	OUTPUT bin
	COMMAND mkdir ./bin
	COMMENT "Creating bin directory"
)

add_custom_command(
	OUTPUT ${SHADER_BINARIES}
	COMMAND python3 ${CMAKE_CURRENT_SOURCE_DIR}/compile_shaders.py ${SHADER_FILES}
	DEPENDS ${SHADER_FILES}
	COMMENT "Compiling shaders"
)

add_custom_target(CompileShaders ALL DEPENDS ${SHADER_BINARIES})

add_executable("${CMAKE_PROJECT_NAME}")
target_sources("${CMAKE_PROJECT_NAME}" PRIVATE "${CXX_SOURCES}")

target_include_directories("${CMAKE_PROJECT_NAME}" PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/lib/glfw/include")
target_include_directories("${CMAKE_PROJECT_NAME}" PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/lib/glm/glm")
target_include_directories("${CMAKE_PROJECT_NAME}" PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/lib/stb")

find_package(Vulkan REQUIRED)

target_link_libraries("${CMAKE_PROJECT_NAME}" PRIVATE Vulkan::Vulkan glm glfw)