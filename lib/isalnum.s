* isalnum.s
* Itagaki Fumihiko 15-Feb-91  Create.

.xref isalpha
.xref isdigit

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
		jsr	isalpha
		beq	return

		jmp	isdigit

return:
		rts

.end
