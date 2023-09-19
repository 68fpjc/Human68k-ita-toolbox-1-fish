* headtail.s
* Itagaki Fumihiko 14-Aug-90  Create.

.include limits.h

.xref skip_root
.xref find_slashes

.text

****************************************************************
* headtail - �p�X���̃t�@�C�����̈ʒu
*
* CALL
*      A0     �p�X���̐擪�A�h���X
*
* RETURN
*      A1     �t�@�C�����̃A�h���X
*      D0.L   �h���C�u�{�f�B���N�g�����̒����i�Ō�� / �܂��� \ �̕����܂ށj
*      CCR    TST.L D0
*****************************************************************
.xdef headtail

headtail:
		move.l	a0,-(a7)
		jsr	skip_root
loop:
		movea.l	a0,a1
		jsr	find_slashes
		tst.b	(a0)+
		bne	loop

		movea.l	(a7)+,a0
		move.l	a1,d0
		sub.l	a0,d0
		rts
*****************************************************************

.end
