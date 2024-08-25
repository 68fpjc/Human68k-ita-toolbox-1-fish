* isalnum.s
* Itagaki Fumihiko 15-Feb-91  Create.

.text

****************************************************************
* isalnum - 文字は英数字か
*
* CALL
*      D0.B   文字
*
* RETURN
*      ZF     真ならば 1
*****************************************************************
.xdef isalnum

isalnum:
		bsr	isalpha
		bne	isdigit
		rts

.end
