* iscntrl.s
* Itagaki Fumihiko 13-Apr-91  Create.

.text

****************************************************************
* iscntrl - �����͐��䕶����
*
* CALL
*      D0.B   ����
*
* RETURN
*      ZF     �^�Ȃ�� 1
*****************************************************************
.xdef iscntrl

iscntrl:
		cmp.b	#$20,d0
		blo	true

		cmp.b	#$7f,d0
		rts

true:
		cmp.b	d0,d0
		rts

.end
