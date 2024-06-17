%include "OSWork.inc"
%include "OSLib.inc"

; PageDirBase0	equ	200000h	; 页目录起始地址
; PageTblBase0	equ	201000h	; 页表起始地址
; PageDirBase0	equ	210000h	; 页目录起始地址
; PageTblBase1	equ	211000h	; 页表起始地址

; LinearAddr	equ	00401000h	; 特定线性地址
; ProcTask0	equ	00401000h	; 任务0物理地址
; ProcTask1	equ	00501000h	; 任务1物理地址

org 0100h
	jmp	LABEL_BEGIN

[SECTION .gdt]
; GDT定义
LABEL_GDT:			Descriptor			0,			 	  0,	0	; 空描述符
LABEL_DESC_NORMAL:	Descriptor			0,			 0ffffh,	DA_DRW	
LABEL_DESC_FLAT_C:	Descriptor  	    0,     		0fffffh, 	DA_CR | DA_32 | DA_LIMIT_4K	; 0 ~ 4G线性地址

; 用户代码段
LABEL_DESC_FLAT_RW:	Descriptor      	0,     		0fffffh, 	DA_DRW | DA_LIMIT_4K	; 0 ~ 4G

; 系统数据段
LABEL_DESC_DATA:	Descriptor			0, 		DataLen - 1, 	DA_DRW	; data段
LABEL_DESC_CODE32:	Descriptor			0, SegCode32Len - 1,	DA_CR | DA_32	; 非一致代码段，32位
LABEL_DESC_STACK:	Descriptor			0,       TopOfStack, 	DA_DRWA | DA_32
LABEL_DESC_VIDEO:	Descriptor	  0B8000h,           0ffffh, 	DA_DRW | DA_DPL3	; 显存首地址

; 任务段
LABEL_DESC_LDT0:	Descriptor			0,		LDT0Len - 1,	DA_LDT
LABEL_DESC_TSS0:	Descriptor			0,		TSS0Len - 1,	DA_386TSS
; LABEL_DESC_LDT1:	Descriptor			0,		LDT1Len - 1,	DA_LDT
; LABEL_DESC_TSS1:	Descriptor			0,		TSS1Len - 1,	DA_386TSS
; End Of GDT


GdtLen	equ	$ - LABEL_GDT
GdtPtr	dw	GdtLen - 1
		dd  0

; Selector定义
SelectorNormal		equ	LABEL_DESC_NORMAL	- LABEL_GDT
SelectorFlatC		equ	LABEL_DESC_FLAT_C	- LABEL_GDT
SelectorFlatRW		equ	LABEL_DESC_FLAT_RW	- LABEL_GDT

SelectorData		equ	LABEL_DESC_DATA		- LABEL_GDT
SelectorCode32		equ	LABEL_DESC_CODE32	- LABEL_GDT
SelectorStack		equ	LABEL_DESC_STACK	- LABEL_GDT
SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT

SelectorLDT0		equ	LABEL_DESC_LDT0		- LABEL_GDT
SelectorTSS0		equ	LABEL_DESC_TSS0		- LABEL_GDT
; SelectorLDT1		equ	LABEL_DESC_LDT1		- LABEL_GDT
; SelectorTSS1		equ	LABEL_DESC_TSS1		- LABEL_GDT
; Selector定义结束

[SECTION .tss0]
ALIGN	32
[BITS	32]
LABEL_TSS0:
	DD 0
	DD TopOfTask0Stack0
	DD SelectorLDT0Stack0
	DD 0, 0
	DD 0, 0
	DD 0	; CR3 (PDBR)
	DD 0
	DD 0x200
	DD 0, 0, 0, 0	; EAX, ECX, EDX, EBX
	DD TopOfTask0Stack3, 0, 0, 0
	DD 0, SelectorLDT0Code3, SelectorLDT0Stack3
	DD SelectorLDT0
	DD 0x08000000
TSS0Len	equ	$ - LABEL_TSS0	


[SECTION .data]	 ; 数据段
ALIGN	32
[BITS	32]
LABEL_DATA:
; 实模式下使用符号
_szPMMessage:			db	"In Protect Mode now...", 0Ah, 0Ah, 0	; 进入保护模式后显示此字符串
_szMemChkTitle:			db	"BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0	; 进入保护模式后显示此字符串
_szRAMSize				db	"RAM size:", 0
_szReturn				db	0Ah, 0
; 变量
_dwMCRNumber:			dd	0	; Memory Check Result
_dwDispPos:				dd	(80 * 6 + 0) * 2	; 屏幕第 6 行, 第 0 列。
_dwMemSize:				dd	0
_ARDStruct:				; Address Range Descriptor Structure
	_dwBaseAddrLow:		dd	0
	_dwBaseAddrHigh:	dd	0
	_dwLengthLow:		dd	0
	_dwLengthHigh:		dd	0
	_dwType:			dd	0
_PageTableNumber		dd	0
_SavedIDTR:				dd	0	; 用于保存 IDTR
						dd	0
_SavedIMREG:			db	0	; 中断屏蔽寄存器值

_MemChkBuf:	times	256	db	0
; 保护模式下使用这些符号
szPMMessage			equ	_szPMMessage	- $$
szMemChkTitle		equ	_szMemChkTitle	- $$
szRAMSize			equ	_szRAMSize	- $$
szReturn			equ	_szReturn	- $$
dwDispPos			equ	_dwDispPos	- $$
dwMemSize			equ	_dwMemSize	- $$
dwMCRNumber			equ	_dwMCRNumber	- $$
ARDStruct			equ	_ARDStruct	- $$
	dwBaseAddrLow	equ	_dwBaseAddrLow	- $$
	dwBaseAddrHigh	equ	_dwBaseAddrHigh	- $$
	dwLengthLow		equ	_dwLengthLow	- $$
	dwLengthHigh	equ	_dwLengthHigh	- $$
	dwType			equ	_dwType		- $$
MemChkBuf			equ	_MemChkBuf	- $$
SavedIDTR			equ	_SavedIDTR	- $$
SavedIMREG			equ	_SavedIMREG	- $$
PageTableNumber		equ	_PageTableNumber- $$

DataLen				equ	$ - LABEL_DATA
; End Of [SECTION .data]

; 全局堆栈段
[SECTION .gs]
ALIGN	32
[BITS	32]
LABEL_STACK:
	times 512 db 0

TopOfStack	equ	$ - LABEL_STACK - 1
; End Of [SECTION .gs]

; 16位代码段，进入保护模式
[SECTION .s16]
[BITS	16]
LABEL_BEGIN:
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, 0100h


	; 得到内存数
	mov	ebx, 0
	mov	di, _MemChkBuf
.loop:
	mov	eax, 0E820h
	mov	ecx, 20
	mov	edx, 0534D4150h
	int	15h
	jc	LABEL_MEM_CHK_FAIL
	add	di, 20
	inc	dword [_dwMCRNumber]
	cmp	ebx, 0
	jne	.loop
	jmp	LABEL_MEM_CHK_OK
LABEL_MEM_CHK_FAIL:
	mov	dword [_dwMCRNumber], 0
LABEL_MEM_CHK_OK:

	; 初始化 32 位代码段描述符
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_SEG_CODE32
	mov	word [LABEL_DESC_CODE32 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE32 + 4], al
	mov	byte [LABEL_DESC_CODE32 + 7], ah

	; 初始化数据段描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_DATA
	mov	word [LABEL_DESC_DATA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_DATA + 4], al
	mov	byte [LABEL_DESC_DATA + 7], ah

	; 初始化堆栈段描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_STACK
	mov	word [LABEL_DESC_STACK + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_STACK + 4], al
	mov	byte [LABEL_DESC_STACK + 7], ah

	; 初始化 TSS0 描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_TSS0
	mov	word [LABEL_DESC_TSS0 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_TSS0 + 4], al
	mov	byte [LABEL_DESC_TSS0 + 7], ah

	; 初始化 LDT 在 GDT 中的描述符,LABEL_LDT0为LDT的定义地址
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_LDT0
	mov	word [LABEL_DESC_LDT0 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_LDT0 + 4], al
	mov	byte [LABEL_DESC_LDT0 + 7], ah

	; 初始化 LDT 中的描述符,LABEL_TASK0_CODE3 才是真正的LDT代码
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_TASK0_CODE3
	mov	word [LABEL_LDT0_DESC_CODE_3 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_LDT0_DESC_CODE_3 + 4], al
	mov	byte [LABEL_LDT0_DESC_CODE_3 + 7], ah

	; 初始化 LDT 中的描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_LDT0_STACK0
	mov	word [LABEL_LDT0_DESC_STACK0 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_LDT0_DESC_STACK0 + 4], al
	mov	byte [LABEL_LDT0_DESC_STACK0 + 7], ah

	; 初始化 LDT 中的ring3堆栈描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_LDT0_STACK3
	mov	word [LABEL_LDT0_DESC_STACK3 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_LDT0_DESC_STACK3 + 4], al
	mov	byte [LABEL_LDT0_DESC_STACK3 + 7], ah

	; 为加载 GDTR 作准备
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_GDT			; eax <- gdt 基地址
	mov	dword [GdtPtr + 2], eax	; [GdtPtr + 2] <- gdt 基地址

	; 为加载 IDTR 作准备
	; xor	eax, eax
	; mov	ax, ds
	; shl	eax, 4
	; add	eax, LABEL_IDT			; eax <- idt 基地址
	; mov	dword [IdtPtr + 2], eax	; [IdtPtr + 2] <- idt 基地址

	sidt	[_SavedIDTR]

	; 保存中断屏蔽寄存器(IMREG)值
	; in	al, 21h
	; mov	[_SavedIMREG], al

	; 加载 GDTR
	lgdt	[GdtPtr]

	; 加载 IDTR
	; lidt	[IdtPtr]

	; 关中断
	cli

	; 打开地址线A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al

	; 准备切换到保护模式
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax

	; 真正进入保护模式
	jmp	dword SelectorCode32:0	; 将 SelectorCode32 装入 cs, 并跳转到 Code32Selector:0  处

; 32位代码段，由实模式跳入
[SECTION .s32]
[BITS	32]
LABEL_SEG_CODE32:
	mov	ax, SelectorData
	mov	ds, ax			; 数据段选择子
	mov	es, ax
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子

	mov	ax, SelectorStack
	mov	ss, ax			; 堆栈段选择子
	mov	esp, TopOfStack

	push szPMMessage
	call DispStr
	add esp, 4

	; mov ax, SelectorTSS0
	; ltr ax

	; mov ax, SelectorLDT0
	; lldt ax

	; push SelectorLDT0Stack3
	; push TopOfTask0Stack3
	; push SelectorLDT0Code3
	; push 0
	; retf

	jmp $
SegCode32Len	equ	$ - LABEL_SEG_CODE32 

; LDT描述符定义
[SECTION .ldt0]
LABEL_LDT0:					Descriptor	0,					   0,	0
LABEL_LDT0_DESC_CODE_3:		Descriptor	0,			Task0Len - 1, 	DA_C + DA_32 + DA_DPL3
LABEL_LDT0_DESC_STACK3:		Descriptor	0,		TopOfTask0Stack3,	DA_DRWA + DA_DPL3 + DA_32
LABEL_LDT0_DESC_STACK0:		Descriptor	0,		TopOfTask0Stack0,	DA_DRWA + DA_32

LDT0Len			equ	$ - LABEL_LDT0

SelectorLDT0Code3	equ		LABEL_LDT0_DESC_CODE_3 - LABEL_LDT0 + SA_TIL
SelectorLDT0Stack3	equ		LABEL_LDT0_DESC_STACK3 - LABEL_LDT0 + SA_TIL
SelectorLDT0Stack0	equ		LABEL_LDT0_DESC_STACK0 - LABEL_LDT0 + SA_TIL

[SECTION .ls0]
ALIGN	32
[BITS	32]
LABEL_LDT0_STACK0:
	times 512 db 0
TopOfTask0Stack0	equ	$ - LABEL_LDT0_STACK0 - 1

[SECTION .ls3]
ALIGN	32
[BITS	32]
LABEL_LDT0_STACK3:
	times 512 db 0
TopOfTask0Stack3	equ	$ - LABEL_LDT0_STACK3 - 1

[SECTION	.task0]
ALIGN	32
[BITS	32]
LABEL_TASK0_CODE3:
	mov ax, SelectorVideo
	mov gs, ax

	mov edi, (80 * 13 + 0) * 2
	mov ah, 0Ch
	mov al, 'L'
	mov [gs:edi], ax

	add edi, 2
	mov al, '0'
	mov [gs:edi], ax

	jmp $
Task0Len	equ	$ - LABEL_TASK0_CODE3