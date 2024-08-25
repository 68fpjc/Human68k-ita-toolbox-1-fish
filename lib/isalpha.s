* isalpha.s
* Itagaki Fumihiko 04-Jan-90  Create.

.xref islower
.xref isupper

.text

****************************************************************
* isalpha - 文字は英文字か
*
* CALL
*      D0.B   文字
*
* RETURN
*      ZF     真ならば 1
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