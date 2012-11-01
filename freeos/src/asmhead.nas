; haribote-os boot asm
; TAB=4

BOTPAK	EQU		0x00280000			; 要加载bootpack
DSKCAC	EQU		0x00100000			; 磁盘高速缓存的位置
DSKCAC0	EQU		0x00008000		; 磁盘高速缓存的位置（实模式）
;有关BOOT_INFO
CYLS	EQU			0x0ff0			; 设定启动区
LEDS	EQU			0x0ff1			
VMODE	EQU			0x0ff2			; 关于颜色数目的信息
SCRNX	EQU			0x0ff4			; 分辨率的X
SCRNY	EQU			0x0ff6			; 分辨率的Y
VRAM	EQU			0x0ff8			; 图像缓冲区的开始地址

		ORG			0xc200			; 如果这个程序被加载
		MOV		AL,0x13			; VGA显卡，320*200*8位彩色
		MOV		AH,0x00			
		INT			0x10
		MOV		BYTE	[VMODE],8	; 画面模式
		MOV		WORD	[SCRNX],320
		MOV		WORD	[SCRNY],200
		MOV		DWORD	[VRAM],0x000a0000

;用BIOS取的键盘上的各种led灯的状态
		MOV		AH,0x02
		INT		0x16			; keyboard
		MOV		[LEDS],AL	

; PIC，它不接受任何中断
;AT兼容的机器说明的是，如果你初始化PIC，
;如果你不这样做该死的东西CLI之前，我会挂断曾经在一段时间内
;初始化PIC稍后会做

		MOV 	AL,0xff
		OUT 	0x21,AL
		NOP 					; 似乎有一个模型，这样就不会工作，不断OUT指令
		OUT 	0xa1,AL

		CLI 					; CPU中断禁止水平进一步

; 为了能够访问1MB以上的存储器CPU，设置A20GATE

		CALL	waitkbdout
		MOV 	AL,0xd1
		OUT 	0x64,AL
		CALL	waitkbdout
		MOV 	AL,0xdf 		; enable A20
		OUT 	0x60,AL
		CALL	waitkbdout

; 受保护的模式转变

[INSTRSET "i486p"]				; 声明486系列

		LGDT	[GDTR0] 		;设置临时GDT
		MOV 	EAX,CR0
		AND 	EAX,0x7fffffff	;（因为禁令分页）0位31
		OR		EAX,0x00000001	; （用于迁移保护模式）被设置为1的bit0
		MOV 	CR0,EAX
		JMP 	pipelineflush
pipelineflush:
		MOV 	AX,1*8			;  32位读写段
		MOV 	DS,AX
		MOV 	ES,AX
		MOV 	FS,AX
		MOV 	GS,AX
		MOV 	SS,AX

; 转让bootpack

		MOV 	ESI,bootpack		;源
		MOV 	EDI,BOTPAK		; 转发目的地
		MOV 	ECX,512*1024/4
		CALL	memcpy

; 甚至当你在磁盘上的数据传输到原来的位置

; 首先，从引导扇区

		MOV 	ESI,0x7c00		; 源
		MOV 	EDI,DSKCAC		; 转发目的地
		MOV 	ECX,512/4
		CALL	memcpy

; 所有的休息

		MOV 	ESI,DSKCAC0+512 ;  源
		MOV 	EDI,DSKCAC+512	; 转发目的地
		MOV 	ECX,0
		MOV 	CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4	; 转换到/ 4的气缸数的字节数
		SUB 	ECX,512/4		; 扣除该款额的IPL
		CALL	memcpy

; asmhead这不是因为我必须完成整个事情，
;	离开休息bootpack的

; bootpack开始

		MOV 	EBX,BOTPAK
		MOV 	ECX,[EBX+16]
		ADD 	ECX,3			; ECX += 3;
		SHR 	ECX,2			; ECX /= 4;
		JZ		skip			; 有没有被转移
		MOV 	ESI,[EBX+20]	; 源
		ADD 	ESI,EBX
		MOV 	EDI,[EBX+12]	; 转发目的地
		CALL	memcpy
skip:
		MOV 	ESP,[EBX+12]	; 堆栈中的初始值
		JMP 	DWORD 2*8:0x0000001b

waitkbdout:
		IN		 AL,0x64
		AND 	 AL,0x02
		JNZ 	waitkbdout		; 与是非零的结果waitkbdout
		RET

memcpy:
		MOV 	EAX,[ESI]
		ADD 	ESI,4
		MOV 	[EDI],EAX
		ADD 	EDI,4
		SUB 	ECX,1
		JNZ 	memcpy			; 减法结果的是不为0至memcpy（复制）
		RET
; memcpy	如果你没有忘记，可写在地址大小前缀字符串指令

		ALIGNB	16
GDT0:
		RESB	8				; ヌルセレクタ
		DW		0xffff,0x0000,0x9200,0x00cf ; 32位读写段
		DW		0xffff,0x0000,0x9a28,0x0047 ; 段的32位可执行文件bootpack

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16
bootpack:

