* isalnum.s
* Itagaki Fumihiko 15-Feb-91  Create.

.text

****************************************************************
* isalnum - �����͉p������
*
* CALL
*      D0.B   ����
*
* RETURN
*      ZF     �^�Ȃ�� 1
*****************************************************************
.xdef isalnum

isalnum:
		bsr	isalpha
		bne	isdigit
		rts

.end
