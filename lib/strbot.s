* strbot.s
* Itagaki Fumihiko 16-Jul-90  Create.

.xref strlen

.text

****************************************************************
* strbot - ������̖����𓾂�
*
* CALL
*      A0     ������̐擪�A�h���X
*
* RETURN
*      D0.L   ������̒���
*      A0     ������̖���(NUL)�̃A�h���X
*****************************************************************
.xdef strbot

strbot:
		jsr	strlen
		lea	(a0,d0.l),a0
		rts

.end
