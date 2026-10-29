BOOT=src/boot
OBJ =obj

gcc = /usr/opt/cross/bin/i686-elf-gcc
ld = /usr/opt/cross/bin/i686-elf-ld
CFLAGS = -m32 -ffreestanding -Wall -Wextra

default: ASM C MAKE_IMG run

ASM:
	nasm -f bin $(BOOT)/boot.asm -o $(OBJ)/boot.bin
	nasm -f bin $(BOOT)/loader.asm -o $(OBJ)/loader.bin

C:
	$(gcc) $(CFLAGS) -c src/kernel.c -o $(OBJ)/kernel.o

MAKE_IMG:
	ld -m elf_i386 -T linker.ld --oformat binary -o $(OBJ)/kernel.bin $(OBJ)/*.o
	dd if=/dev/zero of=os.img bs=1M count=10 conv=notrunc
	dd if=$(OBJ)/boot.bin of=os.img bs=512 conv=notrunc
	dd if=$(OBJ)/loader.bin of=os.img bs=512 seek=1 conv=notrunc
	dd if=$(OBJ)/kernel.bin of=os.img bs=512 seek=2 conv=notrunc

run:
	qemu-system-x86_64 -m 512 -drive format=raw,file=os.img

debug:
	qemu-system-i386 -drive format=raw,file=os.img -S -s

clear:
	rm $(OBJ)/*.bin $(OBJ)/*.o
