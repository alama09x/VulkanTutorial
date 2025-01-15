CXXC = clang++
CC = clang
GLSLC = glslc

LIB = lib
SRC = src

CXXFLAGS = -std=c++23 -O3 -Wall -Wextra
CXXFLAGS += -I$(LIB)/glm/glm -I$(LIB)/glfw/include -I$(LIB)/stb
LDFLAGS = -lvulkan

CMAKE_FLAGS = -G"Unix Makefiles"

SRCS = $(wildcard ./$(SRC)/*.cpp) $(wildcard ./$(SRC)/**/*.cpp)
SRCS += $(wildcard ./$(SRC)/**/**/*.cpp) $(wildcard ./$(SRC)/**/**/**/*.cpp)

OBJS = $(SRCS:.cpp=.o)
BIN = bin

ifeq ($(OS), Windows_NT)
	BINARY = game.exe

	LIBS = $(LIB)/glm/glm/glm.lib $(LIB)/glfw/src/glfw3.lib
	LDFLAGS += $(LIBS)
	LDFLAGS += -lucrt -lmsvcrt -fuse-ld=lld
	LDFLAGS += -lUser32 -lGdi32 -lShell32 -lAdvapi32

	SHELL := pwsh.exe
	.SHELLFLAGS := -NoProfile -Command

	RM_LIB = foreach ($$file in '$(LIBS)')
	RM_LIB += { if (Test-Path $$file) { Remove-Item $$file -Force } }

	RM_BIN = if (Test-Path $(BIN)) { Remove-Item -Recurse -Force -Path $(BIN) }

	RM_OBJ = foreach ($$file in '$(OBJS)')
	RM_OBJ += { if (Test-Path $$file) { Remove-Item $$file -Force } }
else
	BINARY = game

	LIBS = $(LIB)/glm/glm/libglm.a $(LIB)/glfw/src/libglfw3.a
	LDFLAGS += $(LIBS)

	UNAME_S = $(shell uname -s)
	ifeq ($(UNAME_S), Darwin)
		CXXFLAGS += -I${VULKAN_SDK}/include
		LDFLAGS += -L${VULKAN_SDK}/lib -Wl,-rpath,${VULKAN_SDK}/lib
		LDFLAGS += -framework OpenGL -framework IOKit
		LDFLAGS += -framework CoreVideo -framework Cocoa
		LDFLAGS += -framework QuartzCore
		CMAKE_FLAGS += -DCMAKE_OSX_DEPLOYMENT_TARGET=15.0
	endif
	ifeq ($(UNAME_S), Linux)
		LDFLAGS += -lpthread -ldl
	endif

	RM_LIB = rm -f $(LIBS)
	RM_BIN = rm -rf $(BIN)
	RM_OBJ = rm -f $(OBJS)
endif

.PHONY: all clean

all: clean dirs libs shader $(BINARY) run

dirs:
	mkdir $(BIN)

libs:
	cd $(LIB)/glm && cmake $(CMAKE_FLAGS) . && make
	cd $(LIB)/glfw && cmake $(CMAKE_FLAGS) . && make

shader:
	$(GLSLC) ./shaders/shader.vert -o ./$(BIN)/vert.spv
	$(GLSLC) ./shaders/shader.frag -o ./$(BIN)/frag.spv

$(BINARY): $(OBJS)
	$(CXXC) $(CXXFLAGS) -o $(BIN)/$(BINARY) $^ $(LDFLAGS)

%.o: %.cpp
	$(CXXC) -o $@ -c $< $(CXXFLAGS)

run:
	$(BIN)/$(BINARY)

clean:
	$(RM_LIB)
	$(RM_BIN)
	$(RM_OBJ)
