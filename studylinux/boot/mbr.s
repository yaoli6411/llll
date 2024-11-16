section mbr vstart=0x7c00

mov ax,600h
mov bx,700h
mov cx,0
mov dx,0x184f
int 10h

    mov ax,0x9000
    mov es,ax
load_setup:
    mov	dx,0x0080					
    mov	cx,0x0002				
    mov	bx,0x0200				
    mov	ax,0x0204		
    int	0x13					
    jnc	ok_load_setup 			

    xor	dl, dl			
    xor	ah, ah
    int	0x13
    jmp	load_setup 		

ok_load_setup:

    			 
   
jmp 0x9000:0x0200


times 510-($-$$) db 0
db 0x55,0xaa
