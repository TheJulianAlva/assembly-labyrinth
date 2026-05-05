AS      := nasm
DOCKER_IMAGE := codeneomatrix/nasm
DOCKER_VOL   := C:\Users\julia\OneDrive\Documentos\assembly-labyrinth
LD      := ld
ASFLAGS := -f elf32 -g -F dwarf -I include/
LDFLAGS := -m elf_i386 -e _start

BUILD   := build
SRC     := src
TARGET  := $(BUILD)/assembly-labyrinth

SRCS := $(wildcard $(SRC)/*.asm)
OBJS := $(patsubst $(SRC)/%.asm, $(BUILD)/%.o, $(SRCS))
INCS := $(wildcard include/*.inc)

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

$(BUILD)/%.o: $(SRC)/%.asm $(INCS) | $(BUILD)
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD):
	mkdir -p $(BUILD)

run: all
	$(TARGET)


clean:
	rm -rf $(BUILD)
