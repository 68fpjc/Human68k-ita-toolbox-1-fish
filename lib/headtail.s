* headtail.s
* Itagaki Fumihiko 14-Aug-90  Create.

.include limits.h

.xref issjis

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
		move.l	a2,-(a7)
		movea.l	a0,a2
		tst.b	(a2)
		beq	headtail_found

		cmpi.b	#':',1(a2)
		bne	headtail_found

		addq.l	#2,a2
headtail_found:
		movea.l	a2,a1
headtail_loop:
		move.b	(a2)+,d0
		beq	headtail_done

		jsr	issjis
		bne	headtail_check

		move.b	(a2)+,d0
		beq	headtail_done

		bra	headtail_loop

headtail_check:
		cmp.b	#'/',d0
		beq	headtail_found

		cmp.b	#'\',d0
		beq	headtail_found

		bra	headtail_loop

headtail_done:
		move.l	a1,d0
		sub.l	a0,d0
		movea.l	(a7)+,a2
		rts
*****************************************************************

.end
