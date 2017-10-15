GCC := i686-elf-gcc
GCCGO := i686-elf-gccgo
NASM := nasm
GRUB_MKRESCUE := grub-mkrescue

ISO_BUILD := build/iso

default: build


build: porcupine.iso


kernel.bin: boot.o kernel.o runtime/libgo.so
	$(GCC) -T linker.ld -o $@ -ffreestanding -nostdlib -lgcc $^

kernel.o: kernel.go
	$(GCCGO) -c kernel.go -fgo-prefix=porcupine

runtime/libgo.so: runtime/libgo.c
	$(GCC) -shared -c $^ -o $@ -std=gnu99 -ffreestanding

boot.o: boot.asm
	$(NASM) -felf32 boot.asm -o boot.o

porcupine.iso: kernel.bin
	mkdir -p $(ISO_BUILD)/boot/grub
	cp kernel.bin $(ISO_BUILD)/boot/kernel.bin
	cp grub.cfg $(ISO_BUILD)/boot/grub/grub.cfg
	$(GRUB_MKRESCUE) -o $@ $(ISO_BUILD)


clean: 
	rm -f *.o
	rm -f **/*.so
	rm -f *.bin
	rm -f *.iso
	rm -rf $(ISO_BUILD)
