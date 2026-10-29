BOOT:=src/boot
OBJ :=obj

default: ASM MAKE_IMG run

ASM:
	nasm -f bin $(BOOT)/boot.asm -o $(OBJ)/boot.bin
	nasm -f bin $(BOOT)/loader.asm -o $(OBJ)/loader.bin

MAKE_IMG:
	dd if=$(OBJ)/boot.bin of=os.img bs=512 conv=notrunc
	dd if=$(OBJ)/loader.bin of=os.img bs=512 seek=1 conv=notrunc

run:
	qemu-system-x86_64 -m 512 -drive format=raw,file=os.img

debug:
	qemu-system-i386 -drive format=raw,file=os.img -S -s

clear:
	rm $(OBJ)/*.bin $(OBJ)/*.o
