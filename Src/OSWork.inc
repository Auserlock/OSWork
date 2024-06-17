%macro Descriptor 3
    dw %2 & 0FFFFh               ; 段界限 1 (2 字节)
    dw %1 & 0FFFFh               ; 基地址 1 (2 字节)
    db (%1 >> 16) & 0FFh         ; 基地址 2 (1 字节)
    dw ((%2 >> 8) & 0F00h) | (%3 & 0F0FFh) ; 属性 1 + 段界限 2 + 属性 2 (2 字节)
    db (%1 >> 24) & 0FFh         ; 基地址 3 (1 字节)
%endmacro ; 共 8 字节

%macro Gate 4
    dw (%2 & 0FFFFh)             ; 偏移 1 (2 字节)
    dw %1                        ; 选择子 (2 字节)
    dw (%3 & 1Fh) | ((%4 << 8) & 0FF00h) ; 属性 (2 字节)
    dw ((%2 >> 16) & 0FFFFh)     ; 偏移 2 (2 字节)
%endmacro ; 共 8 字节

DA_32        EQU 4000h  ; 0100000000000000 在可执行代码段描述符，D=1使用32位地址
DA_LIMIT_4K  EQU 8000h

DA_DPL0      EQU 00h
DA_DPL1      EQU 20h
DA_DPL2      EQU 40h
DA_DPL3      EQU 60h    ; DPL = 3

DA_DR        EQU 90h
DA_DRW       EQU 92h    ; 10010010  存在的可读写数据段属性值
DA_DRWA      EQU 93h    ; 10010011  存在的已访问可读写数据段类型值
DA_C         EQU 98h    ; 10011000  存在的只执行代码段属性值 
DA_CR        EQU 9Ah
DA_CCO       EQU 9Ch
DA_CCOR      EQU 9Eh

DA_LDT       EQU 82h    ; 10000010 局部描述符表段类型值
DA_TaskGate  EQU 85h
DA_386TSS    EQU 89h    ; 10001001 可用386任务状态段类型值
DA_386CGate  EQU 8Ch    ; 10001100 386调用门类型值
DA_386IGate  EQU 8Eh    
DA_386TGate  EQU 8Fh

SA_RPL0      EQU 0
SA_RPL1      EQU 1
SA_RPL2      EQU 2
SA_RPL3      EQU 3  ; RPL = 3

SA_TIG       EQU 0  ; TI = 0 全局选择子
SA_TIL       EQU 4  ; TI = 1 局部选择子

PG_P         EQU 1
PG_RWR       EQU 0
PG_RWW       EQU 2
PG_USS       EQU 0
PG_USU       EQU 4
