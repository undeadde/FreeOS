; hello-os
; TAB=4
CYLS	EQU		10			; �������泣��CYLS=10
		ORG 	0x7c00 		; ָ�������װ�ص�ַ
		
; �����Ǳ�׼FAT12��ʽ����ר�õĴ��룬����C0-H0-S1
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
; ��ȡ����C0-H0-S2 �� C9-H1-S18, 512 * 17 +512 * 18 + 1024 * 9 * 18 = 183808 bytes װ���ڴ��ַ0x8200 ~ 0xa3ff��
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
readloop:
		MOV		SI,0		; ��¼ʧ�ܴ����ļĴ���
retry:		
		MOV		DL,0x00		; ��һ��������
		MOV		AH,0x02		; AH=0x02 : �������
		MOV		AL,1		; 1������			
		INT		0x13		; ���ô���BIOS
		JNC		next		; û�г�����ת��next
		ADD		SI,1		; ��SI��1
		CMP		SI,5		; SI��5�Ƚ�
		JAE		error		; SI >= 5 �������
		MOV		AH,0x00         
		MOV		DL,0x00		; A������
		INT		0x13		; ���ô���BIOS
		JMP		retry

next:
		MOV 	AX,ES		;���ڴ��ַ����0x200,��һ��������ʼ
		ADD 	AX,0x0020
		MOV 	ES,AX		; ��Ϊû��ADD ES, 0x20ָ�������΢�Ƹ���
		ADD 	CL,1		;��һ������
		CMP		CL,18		; �Ƚ�CL��18
		JBE		readloop	;18�����������������ȡ������һ���ŵ�
		MOV 	CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop    ; ��ͷ2��Ӧ�ı�������δ��ȡ�������ȡ����������ͱ���2���ŵ�
		MOV		DH,0
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop	
; ��������̺����CPUֹͣ״̬

; ������̿�ʼ����haribote.sys������
		JMP		0xc200

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
