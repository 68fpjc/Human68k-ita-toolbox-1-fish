* echo.s
* Itagaki Fumihiko 19-Jul-90  Create.

.text

****************************************************************
* echo - �P����т̊e�P����A�ԂɂP�����̋󔒂�}�݂Ȃ��珇�ɏo�͂���
*
* CALL
*      A0     �P����т̐擪�A�h���X
*      A1     �P����o�͂���T�u�E���[�`���̃G���g���E�A�h���X
*      A2     �P����т��o�͂��I������ɂP�x�����Ăяo���T�u�E���[�`����
*             �G���g���E�A�h���X�i0L �Ȃ�ΌĂяo���Ȃ��j
*      D0.W   �P�ꐔ
*
* RETURN
*      ����
****************************************************************
.xdef echo

echo:
		tst.w	d0
		beq	return

		movem.l	d0/a0,-(a7)
		subq.w	#1,d0
		bra	start

loop:
		move.l	a0,-(a7)
		lea	str_space,a0
		jsr	(a1)
		move.l	(a7)+,a0
		bsr	for1str
start:
		jsr	(a1)
		dbra	d0,loop

		cmpa.l	#0,a2
		beq	done

		jsr	(a2)
done:
		movem.l	(a7)+,d0/a0
return:
		rts

.end
