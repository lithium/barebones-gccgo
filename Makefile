NASM := nasm

clean: boot.o
	rm $^

boot.o: boot.asm
	$(NASM) -felf32 boot.asm -o boot.o

