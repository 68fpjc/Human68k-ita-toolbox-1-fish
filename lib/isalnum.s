* isalnum.s
* Itagaki Fumihiko 15-Feb-91  Create.

.xref isalpha
.xref isdigit

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
		jsr	isalpha
		beq	return

		jmp	isdigit

return:
		rts

.end
