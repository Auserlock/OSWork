%include "OSWork.inc"	; 常量, 宏, 及其他说明

	org 0100h
	jmp LABEL_BEGIN

PageDirBase0	equ	200000h	; 页目录起始地址
PageTblBase0	equ	201000h	; 页表开始地址	2M + 4K
PageDirBase1	equ	210000h	; 2M + 64K
PageTblBase1	equ	211000h

; GDT描述符表定义
[SECTION .gdt]
LABEL_GDT:			Descriptor				0,			 		 0,			0				; 空描述符
; 数据段描述符
LABEL_DESC_NORMAL:	Descriptor				0,				0ffffh,			DA_DRW			; Normal描述符: 存在的可读写数据段属性值
LABEL_DESC_DATA:	Descriptor				0,		   DataLen - 1,			DA_DRW
LABEL_DESC_FLAT_C:	Descriptor             	0,             0fffffh, 		DA_CR | DA_32 | DA_LIMIT_4K	; 0-4G 
; 代码段描述符
LABEL_DESC_CODE16:	Descriptor				0,				0ffffh,			DA_C			; 非一致代码段: 16位
LABEL_DESC_CODE32:	Descriptor				0,	  SegCode32Len - 1,			DA_C + DA_32	; 32位代码段描述符: 存在的只执行代码段属性值, 使用32位地址
LABEL_DESC_VIEDO:	Descriptor		  0B8000h,			    0ffffh,			DA_DRW | DA_DPL3	; 显存首地址
LABEL_DESC_FLAT_RW:	Descriptor				0,			   0fffffh,			DA_DRW | DA_LIMIT_4K	; 0-4G 可读写代码段
; TSS描述符
LABEL_DESC_TSS0:	Descriptor				0,		   TSS0Len - 1,			DA_386TSS	; TSS0描述符
LABEL_DESC_TSS1:	Descriptor				0,		   TSS1Len - 1,			DA_386TSS	; TSS1描述符
; 堆栈描述符
LABEL_DESC_STACK0:	Descriptor				0,		   TopOfStack0,			DA_DRWA | DA_32	; 全局32位Stack0
LABEL_DESC_STACK1:	Descriptor				0,		   TopOfStack1,			DA_DRWA | DA_32	; 全局32位Stack1
; LDT描述符
LABEL_DESC_LDT0:	Descriptor				0,		   LDT0Len - 1,			DA_LDT	; LDT0
LABEL_DESC_LDT1:	Descriptor				0,		   LDT1Len - 1,			DA_LDT	; LDT1
; GDT定义结束