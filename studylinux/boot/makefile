as=nasm

all:mbr setup head

mbr:
	$(as)  -o  mbr.o mbr.s
	
setup:
	$(as)  -o  setup.o setup.s
	
head:
	$(as) -o head.o head.s
