section setup vstart=0x90200   
    mov esp,0x91000  ;stack segment=0x90200        
    mov	cx,21	      ;string length
    mov	bx,0x001f     ;page number and status 
    mov	bp,msg1
    mov	ax,0x1301     ;function number and display method
    mov dx,0x1800     ;position	      
    int	0x10

push 0
pop es
push 0x7000
pop es
load_kernel:   
    mov	dx,0x0080					
    mov	cx,0x000a				
    mov	bx,0x0000				
    mov	ax,0x0264		
    int	0x13	
jnc ok_load_kernel
 xor	dl, dl			
 xor	ah, ah
jmp load_kernel
 ok_load_kernel:


push 0
pop es
push 0x9100
pop es
load_head:
    mov	dx,0x0080					
    mov	cx,0x0006				
    mov	bx,0x0000				
    mov	ax,0x0204		
    int	0x13	
jnc ok_head
 xor	dl, dl			
 xor	ah, ah
jmp load_head
 ok_head:
 
 
 
;load gdt and page !!!!!!!!!!!!!!!!how to do this? PE PG setup has four counts=512*4 byte

;memory_get
mov	ah,0x88
	int	0x15
	mov cx,0x400
	mul cx
	shl edx,16
	or edx,eax
	add edx,0x100000
	mov	[mem_addr],edx

in al,0x92
or al,0000_0010b
out 0x92,al

push 0x9000
pop ds
lidt [idt_48]
lgdt [gdt_48]



mov eax,cr0
or eax,0x00000001
mov cr0,eax

;xchg bx,bx
jmp code_sector:0



gdt:
	dw	0,0,0,0		; dummy	;第1个描述符，不用 ;number 0
	; 在GDT表的偏移量是0x08。它是内核代码段选择符的值。
	dw 0x0fff					  ;number 1
	dw 0x1000
	dw 0x9A09
	dw 0x00c0
	;0x10
	dw 0x0fff					  ;number 2
	dw 0x8000
	dw 0x920b
	dw 0x00c0
	
	
	
	dw	0x0fFF		; 8Mb - limit=2047 (2048*4096=8Mb);number 3
	dw	0x0000	; base address=0
	dw	0x9A00		; code read/exec		; 代码段为只读，可执行
	dw	0x00C0		; granularity=4096, 386 ; 颗粒度4K，32位

	dw      0x0fFF		; 8Mb - limit=2047 (2048*4096=8Mb);number 4
	dw	0x0000		; base address=0
	dw	0x9200		; data read/write		; 数据段为可读可写
	dw	0x00C0		; granularity=4096, 386	; 颗粒度4K，32位
	
; 加载中断描述符表寄存器指令lidt要求的6字节操作数。
; 注：CPU要求在进入保护模式之前需设置idt表，因此这里先设置一个长度为0的空表。
idt_48:
	dw	0			; idt limit=0	; idt的限长
	dw	0,0			; idt base=0L	; idt表在线性地址空间中的32位基地址

; 加载全局描述符表寄存器指令lgdt要求的6字节操作数。
gdt_48:		;define gdtr
	
	dw	0x800	; gdt limit=2048, 256 GDT entries 	
						; 表限长2k
	dd	gdt	; gdt base = 0X9xxxx 
						; （线性地址空间）基地址：0x90200 + gdt
code_sector equ (0x0001<<3)
mem_addr dd 0

msg1 db 'welcome to the setup!'


