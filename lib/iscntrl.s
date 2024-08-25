* iscntrl.s
* Itagaki Fumihiko 13-Apr-91  Create.

.text

****************************************************************
* iscntrl - 文字は制御文字か
*
* CALL
*      D0.B   文字
*
* RETURN
*      ZF     真ならば 1
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