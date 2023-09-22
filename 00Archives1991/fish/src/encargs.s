*****************************************************************
* EncodeFishArgs - �������т��G���R�[�h���ăR�}���h���C�����쐬����
*
* CALL
*      A0     �R�}���h���C���̃A�h���X
*      D0.W   �R�}���h���C���̗e��
*      A1     ��������
*      D1.W   �����̐�
*
* RETURN
*      A0     �R�}���h���C���̎��̃A�h���X�i�����ł�$00�͒u���Ȃ��j
*
*      D0.L   �� : �R�}���h���C���̎c��e��
*             �� : �e�ʕs��
*
*      CCR    TST.L D0
*
* NOTE
*      �����̐��� 0 �łȂ���΁A�R�}���h���C���̍ŏ��ɂ͋󔒂� 1�����u�����
*****************************************************************

	.TEXT
	.XDEF	EncodeFishArgs

EncodeFishArgs:
		movem.l	d1-d3/a1-a2,-(a7)
		move.w	d0,d2
		bra	start

encode_loop:
		subq.w	#1,d2
		bcs	over

		move.b	#' ',(a0)+

		moveq	#0,d3		* D3 : ���݂̃N�I�[�g�̏��
		move.b	(a1),d0
		beq	begin_quote
encode_one_loop:
		move.b	(a1),d0
		tst.b	d3
		bne	quoted

		tst.b	d0
		beq	continue

		cmp.b	#'"',d0
		beq	begin_quote

		cmp.b	#"'",d0
		beq	begin_quote

		cmp.b	#' ',d0
		beq	quote_white_space

		cmp.b	#$09,d0
		blo	dup

		cmp.b	#$0d,d0
		bhi	dup
quote_white_space:
		movea.l	a1,a2
find_quote_character:
		move.b	(a2)+,d0
		beq	begin_quote

		cmp.b	#'"',d0
		beq	begin_quote

		cmp.b	#"'",d0
		beq	begin_quote

		bra	find_quote_character

begin_quote:
		*  D0 �� " �łȂ���� " �ŁA�����Ȃ��� ' �ŃN�I�[�g���J�n����
		moveq	#'"',d3
		cmp.b	d0,d3
		bne	insert_quote_char

		moveq	#"'",d3
insert_quote_char:
		move.b	d3,d0
		bra	insert

close_quote:
		move.b	d3,d0
		moveq	#0,d3
		bra	insert

quoted:
		tst.b	d0
		beq	close_quote

		cmp.b	d3,d0
		beq	close_quote
dup:
		addq.l	#1,a1
insert:
		subq.w	#1,d2
		bcs	over

		move.b	d0,(a0)+
		bra	encode_one_loop

continue:
		addq.l	#1,a1
start:
		dbra	d1,encode_loop

		moveq	#0,d0
		move.w	d2,d0
return:
		movem.l	(a7)+,d1-d3/a1-a2
		rts

over:
		moveq	#-1,d0
		bra	return

	.END
