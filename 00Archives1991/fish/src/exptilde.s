* exptilde.s
* Itagaki Fumihiko 30-Sep-90  Create.

.include limits.h

.text

****************************************************************
* expand_tilde_word - ��̒��� ~ ��W�J����
*
* CALL
*      A0     ~ ���܂ތ�̐擪�A�h���X�D��� ', " and/or \ �ɂ��N�I�[�g���D
*             �i������ MAXWORDLEN �ȓ��ł��邱�Ɓj
*
*      A1     �W�J����o�b�t�@�̃A�h���X
*      D1.W   �o�b�t�@�̗e��
*
* RETURN
*      A1     �o�b�t�@�̎��̊i�[�ʒu
*
*      D0.L   �O�Ȃ�ΐ���
*             �����Ȃ�΃G���[
*                  -1  �o�b�t�@�̗e�ʂ𒴂���
*
*      D1.L   ���ʃ��[�h�͎c��o�b�t�@�e��
*             ��ʃ��[�h�͔j��
*****************************************************************
.xdef expand_tilde_word

expand_tilde_word:
		movem.l	d1/d6-d7/a0/a2,-(a7)
		move.w	d0,d7
		beq	expand_tilde_word_over

		move.b	#'~',d0
		bsr	qstrchr
		beq	just_copy
just_copy:


		move.w	d1,d6
		movea.l	a1,a2
		moveq	#0,d1
		bsr	unpack1
		tst.w	d0
		bne	unpack_word_error

		moveq	#0,d0
		move.w	d1,d0
unpack_word_return:
		move.w	d6,d1
		movem.l	(a7)+,d1/d6-d7/a0/a2
		rts

expand_tilde_word_over:
		moveq	#-1,d0
		bra	unpack_word_return

unpack_word_error:
		swap	d0
		clr.w	d0
		swap	d0
		neg.l	d0
		bra	unpack_word_return
