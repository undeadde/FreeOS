; hello-os
; TAB=4
		ORG 	0x7c00 		; ָ�������װ�ص�ַ
		
; �����Ǳ�׼FAT12��ʽ����ר�õĴ���
		JMP		entry		; 0xeb, 0x4e
		DB		0x90		
		DB		"Haribote"	; ������������
		DW		512			; ÿ�������Ĵ�С
		DB		1			; �صĴ�С
		DW		1			; FAT����ʼλ��
		DB		2			; FAT�ĸ���
		DW		224			; ��Ŀ¼�Ĵ�С
		DW		2880		; ���̴�С
		DB		0xf0		; ���̵�����
		DW		9			; FAT �ĳ���
		DW		18			; 1���ŵ��м�������
		DW		2			; ��ͷ��
		DD		0			; ��ʹ�÷���
		DD		2880		; ��дһ�δ��̴�С
		DB		0,0,0x29	; ���岻�����̶�
		DD		0xffffffff	; �����Ǿ�����
		DB		"HARIBOTEOS"; ���̵�����
		DB		"FAT12   "	; ���̸�ʽ����
		RESB		18		; �ȿճ�18�ֽ�

; ��������
entry:
		MOV		AX,0		;��ʼ���Ĵ���
		MOV 	SS,AX
		MOV 	SP,0x7c00
		MOV		DS,AX

; ������ CH/CL/DH/DL �ֱ�Ϊ���棬��������ͷ��������
		MOV 	AX,0x0820
		MOV 	ES,AX
		MOV		BX,0		; ָ����������ַ [ES:BX] = ES*16+BX
		
		MOV		CH,0		; ����0
		MOV		DH,0		; ��ͷ0
		MOV		CL,2		; ����2

		MOV		AH,0x02		; AH=0x02 : �������
		MOV		AL,1		; 1������

		MOV		DL,0x00		; A������
		INT		0x13		; ���ô���BIOS
		JC		error

; ��������̺����CPUֹͣ״̬

fin:
		HLT					; CPUֹͣ
		JMP		fin			; ����ѭ��

error:
		MOV		SI,msg
putloop:
		MOV 	AL,[SI]
		ADD 	SI,1		; ��SI��1
		CMP		AL,0
		
		JE		fin
		MOV		AH,0x0e		; ��ʾһ������
		MOV		BX,15		; ָ���ַ���ɫ
		INT		0x10		; �����Կ�BIOS
		JMP		putloop
msg:
		DB		0x0a, 0x0a	; ����
		DB		"load error"
		DB		0x0a		; ����
		DB		0
		RESB		0x7dfe-$; ��д0x00��ֱ��0x7dfe

		DB		0x55, 0xaa
