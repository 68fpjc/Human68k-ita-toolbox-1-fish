* getpass.s
* Itagaki Fumihiko 16-Jun-91  Create.

.include doscall.h
.include chrcode.h

.text

****************************************************************
* getpass - �W�����͂���G�R�[������1�s���͂���iCR �܂Łj
*
* CALL
*      A0     ���̓o�b�t�@
*      D0.L   �ő���̓o�C�g���iCR�͊܂܂Ȃ��j
*      A1     �v�����v�g������̐擪�A�h���X
*
* RETURN
*      D0.L   ���͕������iCR�͊܂܂Ȃ��j
*      CCR    TST.L D0
****************************************************************
.xdef getpass

getpass:
		movem.l	d1-d2/a0,-(a7)
		moveq	#0,d1
		move.l	d0,d2
		move.l	a1,-(a7)
		DOS	_PRINT
		addq.l	#4,a7
getpass_loop:
		cmp.l	d2,d1
		beq	getpass_done

		clr.w	-(a7)
		DOS	_FGETC
		addq.l	#2,a7
		tst.l	d0
		bmi	getpass_done

		cmp.b	#CR,d0
		beq	getpass_done

		move.b	d0,(a0)+
		addq.l	#1,d1
		bra	getpass_loop

getpass_done:
		move.l	d1,d0
		movem.l	(a7)+,d1-d2/a0
		rts

.end
