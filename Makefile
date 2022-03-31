SRC_DIR := src
OUT_DIR := out/debug/cortex-m4/softfp
OBJ_DIR := obj/debug/cortex-m4/softfp
TMP_DIR := $(abspath tmp)

# Use ./tmp for temporary files, instead of C:\cygwin64\tmp
export TMP=$(TMP_DIR)

GCC_DIR ?= gcc

# Compiler/linker binary
CC      := "$(GCC_DIR)/bin/arm-none-eabi-gcc"
LD      := $(CC)

# Common options
FLAGS   := -g -O0 -mthumb -mcpu=cortex-m4 -mfloat-abi=softfp -mfpu=fpv4-sp-d16 -nostartfiles

# Compiler options
CFLAGS  := $(FLAGS) -c

# Linker options:
# - enable extra verbosity
# - store the intermediate files permanently
LDFLAGS := $(FLAGS) -v -save-temps

# Source files
SOURCES := $(sort $(wildcard $(SRC_DIR)/*.c))

# Object files
OBJECTS := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SOURCES))

# Target application
TARGET  := $(OUT_DIR)/app.elf

# Build target depends on the target ELF file
# Also, this creates all output directories
build: $(OBJ_DIR) $(OUT_DIR) $(TMP_DIR) $(TARGET)

# Clean target removes all target directories
clean:
	rm -rf $(OBJ_DIR) $(OUT_DIR)

# Create directory for object files
$(OBJ_DIR):
	mkdir -p $@

# Create directory for target application files
$(OUT_DIR):
	mkdir -p $@

# Create directory for intermediate files
$(TMP_DIR):
	mkdir -p $@

# Define recipe for compiler command
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $< -o $@

# Define recipe for linker command
# Use response file to avoid linker error:
# gcc/bin/arm-none-eabi-gcc: Argument list too long
$(TARGET): $(OBJECTS)
	echo $^ > $(OBJ_DIR)/objlist.rsp
	$(LD) $(LDFLAGS) @$(OBJ_DIR)/objlist.rsp -o $@

# Define internal recipe to generate src directory
gen_src:
	@rm -rf $(SRC_DIR)
	@mkdir -p $(SRC_DIR)
	for x in {a..z}; do \
	for y in {a..z}; do \
	touch $(SRC_DIR)/`printf "$$x"'%.0s' {1..26}``printf "$$y"'%.0s' {1..26}`.c; \
	done; \
	done

.PHONY: build clean gen_src
