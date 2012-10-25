; hello-os
; TAB=4
CYLS	EQU		10			; 声明柱面常数CYLS=10
		ORG 	0x7c00 		; 指明程序的装载地址
		
; 以下是标准FAT12格式软盘专用的代码，扇区C0-H0-S1
		JMP		entry		; 0xeb, 0x4e
		DB		0x90		
		DB		"Haribote"	; 启动区的名称
		DW		512			; 每个扇区的大小
		DB		1			; 簇的大小
		DW		1			; FAT的起始位置
		DB		2			; FAT的个数
		DW		224			; 根目录的大小
		DW		2880		; 磁盘大小
		DB		0xf0		; 磁盘的种类
		DW		9			; FAT 的长度
		DW		18			; 1个磁道有几个扇区
		DW		2			; 磁头数
		DD		0			; 不使用分区
		DD		2880		; 重写一次磁盘大小
		DB		0,0,0x29	; 意义不明，固定
		DD		0xffffffff	; 可能是卷标号码
		DB		"HARIBOTEOS"; 磁盘的名称
		DB		"FAT12   "	; 磁盘格式名称
		RESB		18		; 先空出18字节

; 程序主体
; 读取扇区C0-H0-S2 到 C9-H1-S18, 512 * 17 +512 * 18 + 1024 * 9 * 18 = 183808 bytes 装载内存地址0x8200 ~ 0xa3ff处
entry:
		MOV		AX,0		;初始化寄存器
		MOV 	SS,AX
		MOV 	SP,0x7c00
		MOV		DS,AX 

; 读磁盘 CH/CL/DH/DL 分别为柱面，扇区，磁头，驱动器
		MOV 	AX,0x0820
		MOV 	ES,AX
		MOV		BX,0		; 指定缓冲区地址 [ES:BX] = ES*16+BX
		
		MOV		CH,0		; 柱面0
		MOV		DH,0		; 磁头0
		MOV		CL,2		; 扇区2
readloop:
		MOV		SI,0		; 记录失败次数的寄存器
retry:		
		MOV		DL,0x00		; 第一个驱动器
		MOV		AH,0x02		; AH=0x02 : 读入磁盘
		MOV		AL,1		; 1个扇区			
		INT		0x13		; 调用磁盘BIOS
		JNC		next		; 没有出错跳转到next
		ADD		SI,1		; 往SI加1
		CMP		SI,5		; SI和5比较
		JAE		error		; SI >= 5 输出错误
		MOV		AH,0x00         
		MOV		DL,0x00		; A驱动器
		INT		0x13		; 调用磁盘BIOS
		JMP		retry

next:
		MOV 	AX,ES		;把内存地址后移0x200,下一个扇区开始
		ADD 	AX,0x0020
		MOV 	ES,AX		; 因为没有ADD ES, 0x20指令，这里稍微绕个弯
		ADD 	CL,1		;下一个柱面
		CMP		CL,18		; 比较CL和18
		JBE		readloop	;18个柱面以下则继续读取，读完一个磁道
		MOV 	CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop    ; 磁头2对应的背面柱面未读取则继续读取，读完正面和背面2个磁道
		MOV		DH,0
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop	
; 当读完磁盘后进入CPU停止状态

; 读完磁盘开始进入haribote.sys的运行
		JMP		0xc200

error:
		MOV		SI,msg
putloop:
		MOV 	AL,[SI]
		ADD 	SI,1		; 给SI加1
		CMP		AL,0
		
		JE		fin
		MOV		AH,0x0e		; 显示一个文字
		MOV		BX,15		; 指定字符颜色
		INT		0x10		; 调用显卡BIOS
		JMP		putloop
msg:
		DB		0x0a, 0x0a	; 改行
		DB		"load error"
		DB		0x0a		; 改行
		DB		0
		RESB		0x7dfe-$; 填写0x00，直到0x7dfe

		DB		0x55, 0xaa
