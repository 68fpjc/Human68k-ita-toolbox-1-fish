* isalpha.s
* Itagaki Fumihiko 04-Jan-90  Create.

.xref islower
.xref isupper

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
		jsr	islower
		beq	return

		jsr	isupper
return:
		rts

.end
