* isalpha.s
* Itagaki Fumihiko 04-Jan-90  Create.

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
		bsr	islower
		bne	isupper
		rts

.end
