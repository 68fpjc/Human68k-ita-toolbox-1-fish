* fgetc.s
* Itagaki Fumihiko 23-Feb-91  Create.

.include doscall.h
.include chrcode.h

*****************************************************************
* fgets - �t�@�C������1�s�ǂݎ��
*
* CALL
*      A0     ���̓o�b�t�@�̐擪�A�h���X
*      D0.W   �t�@�C���E�n���h��
*      D1.W   ���͍ő�o�C�g���i�Ō�� NUL �̕��͊��肵�Ȃ��j
*
* RETURN
*      A0     ���͕��������i��
*
*      D0.L   ��: �G���[�E�R�[�h
*             0 : ���͗L��
*             1 : �o�b�t�@�E�I�[�o�[
*
*      D1.W   �c����͉\�o�C�g���i�Ō�� NUL �̕��͊��肵�Ȃ��j
*
*      CCR    TST.L D0
*
* NOTE
*      D0.L==0 �̏ꍇ�A�Ō�̉��s�͍폜����Ă���
*      ������̏ꍇ�ɂ��o�b�t�@�� NUL �ŏI�[����Ă���
*****************************************************************
.xdef fgets

fgets:
		move.w	d0,-(a7)
fgets_loop:
		DOS	_FGETC
		tst.l	d0
		bmi	fgets_return

		cmp.b	#LF,d0
		beq	fgets_lf

		cmp.b	#CR,d0
		bne	fgets_input_one

		DOS	_FGETC
		tst.l	d0
		bmi	fgets_return

		cmp.b	#LF,d0
		beq	fgets_lf

		subq.w	#1,d1
		bcs	fgets_over

		move.b	#CR,(a0)+
fgets_input_one:
		subq.w	#1,d1
		bcs	fgets_over

		move.b	d0,(a0)+
		bra	fgets_loop

fgets_lf:
		moveq	#0,d0
fgets_return:
		clr.b	(a0)
		addq.l	#2,a7
		tst.l	d0
		rts

fgets_over:
		moveq	#1,d0
		bra	fgets_return

.end
