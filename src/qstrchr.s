* qstrchr.s
* Itagaki Fumihiko 23-Sep-90  Create.

.xref issjis

.text

****************************************************************
* qstrchr - �����񂩂炠�镶����T���o���D
*           �A�� ' " ` �̑΂̒��̕����� \ �̒���̕����͖�������D
*           ' " ` \ ��T�����Ƃ͂ł���D
*           �����񒆂̃V�t�g�i�h�r�����͖�������D
*           �V�t�g�i�h�r������T�����Ƃ͂ł��Ȃ��D
*
* CALL
*      A0     ��������w���|�C���^
*      D0.B   ��������
*
* RETURN
*      A0     �ŏ��Ɍ��������������ʒu���w���D
*             ����������������Ȃ������ꍇ�ɂ́C�Ō��NUL�������w���D
*      CCR    TST.B (A0)
*****************************************************************
.xdef qstrchr

qstrchr:
		movem.l	d1-d2,-(a7)
		move.b	d0,d1
		moveq	#0,d2				* D2 : �N�I�[�g�E�t���O
qstrchr_loop:
		move.b	(a0)+,d0
		beq	qstrchr_break

		jsr	issjis
		beq	qstrchr_skip_one

		tst.b	d2
		beq	qstrchr_1

		cmp.b	d2,d0
		bne	qstrchr_loop
qstrchr_flip_quote:
		eor.b	d0,d2
		bra	qstrchr_loop

qstrchr_1:
		cmp.b	d1,d0
		beq	qstrchr_break

		cmp.b	#'"',d0
		beq	qstrchr_flip_quote

		cmp.b	#"'",d0
		beq	qstrchr_flip_quote

		cmp.b	#'`',d0
		beq	qstrchr_flip_quote

		cmp.b	#'\',d0
		bne	qstrchr_loop

		move.b	(a0)+,d0
		beq	qstrchr_break

		jsr	issjis
		bne	qstrchr_loop
qstrchr_skip_one:
		move.b	(a0)+,d0
		bne	qstrchr_loop
qstrchr_break:
		movem.l	(a7)+,d1-d2
		tst.b	-(a0)
		rts

.end
