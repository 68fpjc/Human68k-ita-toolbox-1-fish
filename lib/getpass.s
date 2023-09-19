* getpass.s
* Itagaki Fumihiko 16-Jun-91  Create.
* Itagaki Fumihiko 28-Dec-91  FGETC����߁A�����INKEY���g��
* Itagaki Fumihiko 26-Jan-92  LF���I�[�Ƃ��ĔF�߂�
* Itagaki Fumihiko 31-Jan-92  �v�����v�g�͕W���G���[�o�͂�write����
* Itagaki Fumihiko 23-Feb-92  �ő���̓o�C�g�������͂���Ă��K���I�[�܂œǂ�

.include doscall.h
.include chrcode.h

.xref strlen

.text

****************************************************************
* getpass - �W�����͂���G�R�[������1�s���͂���iCR�܂���LF�܂Łj
*
* CALL
*      A0     ���̓o�b�t�@
*      D0.L   �ő���̓o�C�g���iCR��LF�͊܂܂Ȃ��j
*      A1     �v�����v�g������̐擪�A�h���X
*
* RETURN
*      D0.L   ���͕������iCR��LF�͊܂܂Ȃ��j
*      CCR    TST.L D0
****************************************************************
.xdef getpass

getpass:
		movem.l	d1-d2/a0,-(a7)
		moveq	#0,d1
		move.l	d0,d2
		exg	a0,a1
		jsr	strlen
		exg	a0,a1
		move.l	d0,-(a7)
		move.l	a1,-(a7)
		move.w	#2,-(a7)
		DOS	_WRITE
		lea	10(a7),a7
getpass_loop:
		DOS	_INKEY
		tst.l	d0
		bmi	getpass_done

		cmp.b	#$04,d0				*  ^D
		beq	getpass_done

		cmp.b	#CR,d0
		beq	getpass_done

		cmp.b	#LF,d0
		beq	getpass_done

		cmp.l	d2,d1
		bhs	getpass_loop

		move.b	d0,(a0)+
		addq.l	#1,d1
		bra	getpass_loop

getpass_done:
		clr.b	(a0)
		move.l	d1,d0
		movem.l	(a7)+,d1-d2/a0
		rts

.end
