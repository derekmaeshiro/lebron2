# --- Environment Setup ---
# Using ?= allows these to be overridden by environment variables (useful for CI/Docker)
ARM_DIR ?= ${ARM_DIRECTORY}
OPEN_OCD_DIR ?= ${TOOLS_OPEN_OCD_DIR_PATH}

# --- Toolchain Paths ---
ARM_BIN_DIR = $(ARM_DIR)/bin
CC = $(ARM_BIN_DIR)/arm-none-eabi-gcc
OBJCOPY = $(ARM_BIN_DIR)/arm-none-eabi-objcopy
SIZE = $(ARM_BIN_DIR)/arm-none-eabi-size

# --- OpenOCD Setup ---
OPEN_OCD = openocd
OPEN_OCD_STLINK = $(OPEN_OCD_DIR)/interface/stlink.cfg
OPEN_OCD_TARGET = $(OPEN_OCD_DIR)/target/stm32f4x.cfg

# --- Project Structure ---
TARGET_NAME = lebron
BUILD_DIR = build/$(TARGET_NAME)
OBJ_DIR = $(BUILD_DIR)/obj
BIN_DIR = $(BUILD_DIR)/bin

TARGET_ELF = $(BIN_DIR)/$(TARGET_NAME).elf
TARGET_BIN = $(BIN_DIR)/$(TARGET_NAME).bin

# --- Source Files ---
# Core application sources
SOURCES = \
    src/main.c \
    src/startup_stm32f446retx.o \
    
# Automatically swap .c extensions for .o pathing inside the build tree
OBJECTS = $(patsubst %.c, $(OBJ_DIR)/%.o, $(SOURCES))

# --- Include Directories ---
INCLUDE_DIRS = \
    -I$(ARM_DIR)/include \
    -I./src \
    -I./external \
    -I./

# --- Build Configuration Flags ---
MCU_FLAGS = -mcpu=cortex-m4 -mthumb -mfloat-abi=softfp -mfpu=fpv4-sp-d16
DEFINES   = -DSTM32F446xx -DPRINTF_INCLUDE_CONFIG_H

CFLAGS    = $(MCU_FLAGS) $(DEFINES) $(INCLUDE_DIRS) -O0 -g -Wall -Wextra -DSTM32F446xx

# Linker setup
LINKER_SCRIPT = src/STM32F446RETX_FLASH.ld
LDFLAGS   = $(MCU_FLAGS) --specs=nosys.specs -T$(LINKER_SCRIPT)

# --- Build Rules ---
.PHONY: all clean flash size static

all: $(TARGET_BIN) size

# 1. Link object files into the ELF output
$(TARGET_ELF): $(OBJECTS)
	@mkdir -p $(dir $@)
	$(CC) $(LDFLAGS) $^ -lm -o $@

# 2. Compile source files into object files
$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

# 3. Extract raw binary format for the flash utility
$(TARGET_BIN): $(TARGET_ELF)
	$(OBJCOPY) -O binary $< $@

# --- Utility Targets ---
flash: $(TARGET_BIN)
	$(OPEN_OCD) -f $(OPEN_OCD_STLINK) -f $(OPEN_OCD_TARGET) -c "program $(TARGET_ELF) verify reset exit"

size: $(TARGET_ELF)
	@$(SIZE) $(TARGET_ELF)

# 4. Run static analysis using cppcheck
static:
	cppcheck --inline-suppr --enable=all --suppress=missingIncludeSystem --suppress=*:external/* --error-exitcode=1 -I./src -I./external -I./ src/
clean:
	rm -rf build/