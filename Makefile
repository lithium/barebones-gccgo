GCC := i686-elf-gcc
GCCGO := i686-elf-gccgo
NASM := nasm

default: build


build: kernel.bin


kernel.bin: boot.o kernel.o runtime/libgo.so
	$(GCC) -T linker.ld -o $@ -ffreestanding -nostdlib -lgcc $^

kernel.o: kernel.go
	$(GCCGO) -c kernel.go -fgo-prefix=porcupine

runtime/libgo.so: runtime/libgo.c
	$(GCC) -shared -c $^ -o $@ -std=gnu99 -ffreestanding

boot.o: boot.asm
	$(NASM) -felf32 boot.asm -o boot.o

clean: 
	rm -f *.o
	rm -f **/*.so
	rm -f *.bin
