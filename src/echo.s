* echo.s
* Itagaki Fumihiko 19-Jul-90  Create.
* Itagaki Fumihiko 17-Aug-91  �d�l�ύX

.xref strfor1
.xref str_space

.text

****************************************************************
* echo - �P����т̊e�P����C�ԂɂP�����̋󔒂�}�݂Ȃ��珇�ɏo�͂���
*
* CALL
*      A0     �P����т̐擪�A�h���X
*      A1     �P����o�͂���T�u���[�`���̃G���g���E�A�h���X
*             ���̃T�u���[�`�����Ăяo���ہCD0.L �̓N���A����D
*      D0.W   �P�ꐔ
*
* RETURN
*      D0.L   A1 �������T�u���[�`������߂����Ƃ��� D0.L �� ��OR
*      CCR    TST.L D0
****************************************************************
.xdef echo

echo:
		movem.l	d1-d2/a0,-(a7)
		moveq	#0,d1
		move.w	d0,d2			*  D2.W : ���[�v�E�J�E���^
		beq	done

		subq.w	#1,d2
		bra	start

loop:
		move.l	a0,-(a7)
		lea	str_space,a0
		jsr	(a1)
		move.l	(a7)+,a0
		bsr	strfor1
start:
		moveq	#0,d0
		jsr	(a1)
		or.l	d0,d1
		dbra	d2,loop
done:
		move.l	d1,d0
		movem.l	(a7)+,d1-d2/a0
		rts

.end
