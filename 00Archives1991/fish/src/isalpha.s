* isalpha.s
* Itagaki Fumihiko 04-Jan-90  Create.

.text

****************************************************************
* isalpha - �����͉p������
*
* CALL
*      D0.B   ����
*
* RETURN
*      ZF     �^�Ȃ�� 1
*****************************************************************
.xdef isalpha

isalpha:
		bsr	islower
		bne	isupper
		rts

.end
