section haed vstart=0x91000
[bits 32]
xor eax,eax
mov ax,data_sector
mov gs,ax
mov ax,data_sector2
mov es,ax
mov fs,ax
mov byte[gs:0],'P'


mov byte[gs:2],'w'
mov byte[gs:4],'e'
mov byte[gs:6],'l'
mov byte[gs:8],'c'
mov byte[gs:0xa],'o'
mov byte[gs:0xc],'m'
mov byte[gs:0xe],'e'
mov byte[gs:0x10],' '
mov byte[gs:0x12],'t'
mov byte[gs:0x14],'o'
mov byte[gs:0x16],' '
mov byte[gs:0x18],'h'
mov byte[gs:0x1a],'e'
mov byte[gs:0x1c],'a'
mov byte[gs:0x1e],'d'



;set directory page at 0x1000

mov ax,data_sector2
mov ds,ax

;directory page table
mov dword[0x1000],0x00002007   ;directory1
mov dword[0x1000+4],0x00003007 ;directory2
mov dword[0x1000+8],0x00004007 ;directory3
mov dword[0x1000+12],0x00005007;directory4

;page table set value


mov eax,0x00000007
mov ebx,0x2000
mov ecx,4096
movement:		;0x0-0xffffff
mov dword[ebx],eax
add ebx,4
add eax,0x1000
loop movement

    mov eax,0x00001000					;/* pg_dir is at 0x1000 */
    mov  cr3,eax				;/* cr3 - page directory start */
     ; 设置启动使用分页处理(cr0的PG标志，位31)
    mov  eax,cr0
    or  eax,0x80000000		;# 添上PG标志
    mov cr0,eax	
;done----------------------------------------


lidt [idt_48]
lgdt [gdt_48]

;
mov ax,data_sector2
mov ss,ax
call kernel_init
xchg bx,bx
push 0x94000
pop esp
jmp code_sector3:0x94000




jmp $  
data_sector equ (0x0002<<3)
data_sector2 equ (0x0004<<3)
code_sector3 equ (0x0003<<3)

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
kernel_init:
;xchg bx,bx
    xor eax, eax                                                ;清空eax
    xor ebx, ebx		                                ;清空ebx, ebx记录程序头表地址
    xor ecx, ecx		                                ;清空ecx, cx记录程序头表中的program header数量
    xor edx, edx		                                ;清空edx, dx 记录program header尺寸

    mov dx, [0x70000+ 42]	                ; 偏移文件42字节处的属性是e_phentsize,表示program header table中每个program header大小
    mov ebx, [0x70000 + 28]                ; 偏移文件开始部分28字节的地方是e_phoff,表示program header table的偏移，ebx中是第1 个program header在文件中的偏移量
					                                    ; 其实该值是0x34,不过还是谨慎一点，这里来读取实际值
    add ebx, 0x70000                       ; 现在ebx中存着第一个program header的内存地址
    mov cx, [0x70000 + 44]                 ; 偏移文件开始部分44字节的地方是e_phnum,表示有几个program header
.each_segment:
    cmp byte [ebx + 0], 0	                    ; 若p_type等于 PT_NULL,说明此program header未使用。
    je .PTNULL

                                                        ;为函数memcpy压入参数,参数是从右往左依然压入.函数原型类似于 memcpy(dst,src,size)
    push dword [ebx + 16]		                        ; program header中偏移16字节的地方是p_filesz,压入函数memcpy的第三个参数:size
    mov eax, [ebx + 4]			                        ; 距程序头偏移量为4字节的位置是p_offset，该值是本program header 所表示的段相对于文件的偏移
    add eax, 0x70000	                    ; 加上kernel.bin被加载到的物理地址,eax为该段的物理地址
    push eax				                            ; 压入函数memcpy的第二个参数:源地址
    push dword [ebx + 8]			                    ; 压入函数memcpy的第一个参数:目的地址,偏移程序头8字节的位置是p_vaddr，这就是目的地址
    call mem_cpy				                        ; 调用mem_cpy完成段复制
    add esp,12				                            ; 清理栈中压入的三个参数
.PTNULL:
   add ebx, edx				                            ; edx为program header大小,即e_phentsize,在此ebx指向下一个program header 
   loop .each_segment
   ret

                                                        ;----------  逐字节拷贝 mem_cpy(dst,src,size) ------------
                                                        ;输入:栈中三个参数(dst,src,size)
                                                        ;输出:无
                                                        ;---------------------------------------------------------
mem_cpy:
;xchg bx,bx		      
    cld                                                 ;将FLAG的方向标志位DF清零，rep在执行循环时候si，di就会加1
    push ebp                                            ;这两句指令是在进行栈框架构建
    mov ebp, esp
    push ecx		                                    ; rep指令用到了ecx，但ecx对于外层段的循环还有用，故先入栈备份
    mov edi, [ebp + 8]	                                ; dst，edi与esi作为偏移，没有指定段寄存器的话，默认是ss寄存器进行配合
    mov esi, [ebp + 12]	                                ; src
    mov ecx, [ebp + 16]	                                ; size
    rep movsb		                                    ; 逐字节拷贝

                                                        ;恢复环境
    pop ecx		
    pop ebp
    ret


msg db 'welcome to head.s'
