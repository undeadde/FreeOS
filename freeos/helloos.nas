; hello-os
; TAB=4
		ORG 	0x7c00 			; 指明程序的装载地址
		
; 以下是标准FAT12格式软盘专用的代码
		JMP		entry			; 0xeb, 0x4e
		DB		0x90		
		DB		"HELLOIPL"		; 启动区的名称
		DW		512				; 每个扇区的大小
		DB		1				; 簇的大小
		DW		1				; FAT的起始位置
		DB		2				; FAT的个数
		DW		224				; 根目录的大小
		DW		2880			; 磁盘大小
		DB		0xf0			; 磁盘的种类
		DW		9				; FAT 的长度
		DW		18				; 1个磁道有几个扇区
		DW		2				; 磁头数
		DD		0				; 不使用分区
		DD		2880			; 重写一次磁盘大小
		DB		0,0,0x29		; 意义不明，固定
		DD		0xffffffff		; 可能是卷标号码
		DB		"HELLO-OS   "	; 磁盘的名称
		DB		"FAT12   "		; 磁盘格式名称
		RESB	18				; 先空出18字节

; 程序主体
entry:
		MOV		AX,0			;初始化寄存器
		MOV 	SS,AX
		MOV 	SP,0x7c00
		MOV		DS,AX
		MOV 	ES,AX
		
		MOV 	SI,msg
putloop:
		MOV 	AL,[SI]
		ADD 	SI,1			; 给SI加1
		CMP		AL,0
		
		JE		fin
		MOV		AH,0x0e			; 显示一个文字
		MOV		BX,15			; 指定字符颜色
		INT		0x10			; 调用显卡BIOS
		JMP		putloop
fin:	HLT						; 让CPU停止
		JMP		fin				; 无限循环
		
; 信息显示部分
msg:	
		DB		0x0a, 0x0a		; 换行2次
		DB		"hello world"   
		DB      0x0a
		DB		0
		RESB	0x7dfe-$			; 填写0x00，直到0x7dfe

		db		0x55, 0xaa

; 以下是启动区以外部分的输出
		db		0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
		RESB	4600
		DB		0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
		RESB	1469432
