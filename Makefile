GCC := i686-elf-gcc
GCCGO := i686-elf-gccgo
NASM := nasm
GRUB_MKRESCUE := grub-mkrescue

OBJ := build
ISO_STAGING := $(OBJ)/iso
BOOTABLE_ISO := porcupine.iso


sources := $(wildcard go/src/**/*.go)
objects := $(addprefix $(OBJ)/, $(notdir $(sources:%.go=%.o)))


default: build $(BOOTABLE_ISO) 


build: 
	mkdir -p $(OBJ)
	echo $(sources)
	echo $(objects)


# link kernel
$(OBJ)/kernel.bin: $(OBJ)/boot.o $(OBJ)/libgo.so $(objects)
	$(GCC) -T boot/linker.ld -o $@ -ffreestanding -nostdlib -lgcc $^

# compile go -> .o
$(OBJ)/%.o: go/src/**/%.go
	$(GCCGO) -static -Werror -nostdlib -nostartfiles -nodefaultlibs -c $^ -o $@ -fgo-prefix=porcupine

# go runtime
$(OBJ)/libgo.so: runtime/libgo.c
	$(GCC) -shared -c $^ -o $@ -std=gnu99 -ffreestanding

# assemble bootloader
$(OBJ)/boot.o: boot/boot.asm
	$(NASM) -felf32 $^ -o $@


# bootable iso 
$(BOOTABLE_ISO): $(OBJ)/kernel.bin
	mkdir -p $(ISO_STAGING)/boot/grub
	cp $(OBJ)/kernel.bin $(ISO_STAGING)/boot/kernel.bin
	cp boot/grub.cfg $(ISO_STAGING)/boot/grub/grub.cfg
	$(GRUB_MKRESCUE) -o $@ $(ISO_STAGING)


clean: 
	rm -rf $(OBJ)
	rm -f $(BOOTABLE_ISO)
