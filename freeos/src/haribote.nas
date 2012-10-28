; haribote-os
; TAB=4

;�й�BOOT_INFO
CYLS	EQU		0x0ff0			; �趨������
LEDS	EQU		0x0ff1			
VMODE	EQU		0x0ff2			; ������ɫ��Ŀ����Ϣ
SCRNX	EQU		0x0ff4			; �ֱ��ʵ�X
SCRNY	EQU		0x0ff6			; �ֱ��ʵ�Y
VRAM	EQU		0x0ff8			; ͼ�񻺳����Ŀ�ʼ��ַ

		ORG		0xc200			; ���������򱻼���
		MOV		AL,0x13			; VGA�Կ���320*200*8λ��ɫ
		MOV		AH,0x00			
		INT		0x10
		MOV		BYTE	[VMODE],8	; ����ģʽ
		MOV		WORD	[SCRNX],320
		MOV		WORD	[SCRNY],200
		MOV		DWORD	[VRAM],0x000a0000

;��BIOSȡ�ļ����ϵĸ���led�Ƶ�״̬
		MOV		AH,0x02
		MOV		0x16			; keyboard
		MOV		[LEDS],AL		
fin:
		HLT
		JMP		fin
