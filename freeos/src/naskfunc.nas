; naskfunc
;TAB=4

[FORMAT "WCOFF"]			; ����Ŀ���ļ���ģʽ
[INSTRSET "i486p"]			; ����ʹ��486ϵ��
[BITS	32] 					; ����32λģʽ�õĻ�������
[FILE "naskfunc.nas"]			; Դ�ļ�����Ϣ
		GLOBAL	_io_hlt,_write_mem8		; �����а����ĺ�����

[SECTION	.text]			; Ŀ���ļ���д����Щ֮����д����

_io_hlt:	; void io_hlt(void);
		HLT
		RET
_write_mem8:	; void write_mem8(int addr, int data);
		MOV 	ECX,[ESP+4] 	; [ESP+4]�д�ŵ�ַ���������ECX
		MOV 	AL,[ESP+8]	; [ESP+8]�д�����ݣ��������AL
		MOV 	[ECX],AL	; ������д���ڴ��ַ
		RET

		
