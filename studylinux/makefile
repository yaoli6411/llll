as=nasm
cc=gcc-4.4
cf=-c -m32 -o 
LD=ld -Ttext 0x94000 -e main  -m elf_i386 -o
all:mbr main _kernel write 


mbr:
	@(cd boot;make)
	
main:
	@(cd init;make )	
	
_kernel:
	@(cd kernel;make)	
write:
	dd if=/home/liyao/Desktop/studylinux/boot/mbr.o of=/home/liyao/Desktop/bochs/studylinux/hd60M.img bs=512 count=1  conv=notrunc
	dd if=/home/liyao/Desktop/studylinux/boot/setup.o of=/home/liyao/Desktop/bochs/studylinux/hd60M.img bs=512 count=4 seek=1  conv=notrunc
	dd if=/home/liyao/Desktop/studylinux/boot/head.o of=/home/liyao/Desktop/bochs/studylinux/hd60M.img bs=512 count=4 seek=5  conv=notrunc
	dd if=/home/liyao/Desktop/studylinux/kernel.bin of=/home/liyao/Desktop/bochs/studylinux/hd60M.img bs=512 count=200 seek=9  conv=notrunc
	$(LD) kernel.bin /home/liyao/Desktop/studylinux/init/main.o /home/liyao/Desktop/studylinux/kernel/print.o
	

	/home/liyao/Desktop/studylinux.sh
	
	
	
