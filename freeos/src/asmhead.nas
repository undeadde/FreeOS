; haribote-os boot asm
; TAB=4

BOTPAK	EQU		0x00280000			; Ҫ����bootpack
DSKCAC	EQU		0x00100000			; ���̸��ٻ����λ��
DSKCAC0	EQU		0x00008000		; ���̸��ٻ����λ�ã�ʵģʽ��
;�й�BOOT_INFO
CYLS	EQU			0x0ff0			; �趨������
LEDS	EQU			0x0ff1			
VMODE	EQU			0x0ff2			; ������ɫ��Ŀ����Ϣ
SCRNX	EQU			0x0ff4			; �ֱ��ʵ�X
SCRNY	EQU			0x0ff6			; �ֱ��ʵ�Y
VRAM	EQU			0x0ff8			; ͼ�񻺳����Ŀ�ʼ��ַ

		ORG			0xc200			; ���������򱻼���
		MOV		AL,0x13			; VGA�Կ���320*200*8λ��ɫ
		MOV		AH,0x00			
		INT			0x10
		MOV		BYTE	[VMODE],8	; ����ģʽ
		MOV		WORD	[SCRNX],320
		MOV		WORD	[SCRNY],200
		MOV		DWORD	[VRAM],0x000a0000

;��BIOSȡ�ļ����ϵĸ���led�Ƶ�״̬
		MOV		AH,0x02
		INT		0x16			; keyboard
		MOV		[LEDS],AL	

; PIC�����������κ��ж�
;AT���ݵĻ���˵�����ǣ�������ʼ��PIC��
;����㲻�����������Ķ���CLI֮ǰ���һ�Ҷ�������һ��ʱ����
;��ʼ��PIC�Ժ����

		MOV 	AL,0xff
		OUT 	0x21,AL
		NOP 					; �ƺ���һ��ģ�ͣ������Ͳ��Ṥ��������OUTָ��
		OUT 	0xa1,AL

		CLI 					; CPU�жϽ�ֹˮƽ��һ��

; Ϊ���ܹ�����1MB���ϵĴ洢��CPU������A20GATE

		CALL	waitkbdout
		MOV 	AL,0xd1
		OUT 	0x64,AL
		CALL	waitkbdout
		MOV 	AL,0xdf 		; enable A20
		OUT 	0x60,AL
		CALL	waitkbdout

; �ܱ�����ģʽת��

[INSTRSET "i486p"]				; ����486ϵ��

		LGDT	[GDTR0] 		;������ʱGDT
		MOV 	EAX,CR0
		AND 	EAX,0x7fffffff	;����Ϊ�����ҳ��0λ31
		OR		EAX,0x00000001	; ������Ǩ�Ʊ���ģʽ��������Ϊ1��bit0
		MOV 	CR0,EAX
		JMP 	pipelineflush
pipelineflush:
		MOV 	AX,1*8			;  32λ��д��
		MOV 	DS,AX
		MOV 	ES,AX
		MOV 	FS,AX
		MOV 	GS,AX
		MOV 	SS,AX

; ת��bootpack

		MOV 	ESI,bootpack		;Դ
		MOV 	EDI,BOTPAK		; ת��Ŀ�ĵ�
		MOV 	ECX,512*1024/4
		CALL	memcpy

; ���������ڴ����ϵ����ݴ��䵽ԭ����λ��

; ���ȣ�����������

		MOV 	ESI,0x7c00		; Դ
		MOV 	EDI,DSKCAC		; ת��Ŀ�ĵ�
		MOV 	ECX,512/4
		CALL	memcpy

; ���е���Ϣ

		MOV 	ESI,DSKCAC0+512 ;  Դ
		MOV 	EDI,DSKCAC+512	; ת��Ŀ�ĵ�
		MOV 	ECX,0
		MOV 	CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4	; ת����/ 4�����������ֽ���
		SUB 	ECX,512/4		; �۳��ÿ���IPL
		CALL	memcpy

; asmhead�ⲻ����Ϊ�ұ�������������飬
;	�뿪��Ϣbootpack��

; bootpack��ʼ

		MOV 	EBX,BOTPAK
		MOV 	ECX,[EBX+16]
		ADD 	ECX,3			; ECX += 3;
		SHR 	ECX,2			; ECX /= 4;
		JZ		skip			; ��û�б�ת��
		MOV 	ESI,[EBX+20]	; Դ
		ADD 	ESI,EBX
		MOV 	EDI,[EBX+12]	; ת��Ŀ�ĵ�
		CALL	memcpy
skip:
		MOV 	ESP,[EBX+12]	; ��ջ�еĳ�ʼֵ
		JMP 	DWORD 2*8:0x0000001b

waitkbdout:
		IN		 AL,0x64
		AND 	 AL,0x02
		JNZ 	waitkbdout		; ���Ƿ���Ľ��waitkbdout
		RET

memcpy:
		MOV 	EAX,[ESI]
		ADD 	ESI,4
		MOV 	[EDI],EAX
		ADD 	EDI,4
		SUB 	ECX,1
		JNZ 	memcpy			; ����������ǲ�Ϊ0��memcpy�����ƣ�
		RET
; memcpy	�����û�����ǣ���д�ڵ�ַ��Сǰ׺�ַ���ָ��

		ALIGNB	16
GDT0:
		RESB	8				; �̥륻�쥯��
		DW		0xffff,0x0000,0x9200,0x00cf ; 32λ��д��
		DW		0xffff,0x0000,0x9a28,0x0047 ; �ε�32λ��ִ���ļ�bootpack

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16
bootpack:

