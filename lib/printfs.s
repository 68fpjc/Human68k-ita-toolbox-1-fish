* printfs.s
* Itagaki Fumihiko 21-Apr-91  Create.

.xref strlen

.text

****************************************************************
* printfs - ������������ɏ]���ďo�͂���
*
* CALL
*      A0     �o�͂��镶����̐擪�A�h���X
*
*      A1     �����̏o�͂��s�Ȃ��T�u�E���[�`���̃G���g���[�E�A�h���X
*             �����R�[�h��D0.B�ɗ^���Ă��̃T�u�E���[�`�����Ăяo��
*
*      D1.L   ���Ȃ��Ƃ��o�͂��镶�����i�o�C�g���j
*
*      D2.L   bit 0 : 0=�E�l��  1=���l��
*             bit 1 : 1= D1.L�̕������i�o�C�g���j�𒴂��ďo�͂��Ȃ�
*
*      D3.B   �E�l�߂̂Ƃ��A�����̌��Ԃ𖄂߂镶���R�[�h
*
* RETURN
*      D0.L   �o�͂����������i�o�C�g���j
*****************************************************************
.xdef printfs

printfs:
		movem.l	d1-d7/a0/a2-a6,-(a7)
		jsr	strlen
		move.l	d0,d4			* D4.L : �o�͂��镶����̕������i�o�C�g���j
		move.l	d1,d5
		sub.l	d0,d5			* D5.L : pad���镶�����i�o�C�g���j
		bcc	pad_ok

		moveq	#0,d5
		btst	#1,d2
		beq	pad_ok

		move.l	d1,d4
pad_ok:
		move.l	d4,d1
		add.l	d5,d1			* D1.L : �o�͂��鑍������
		bsr	pad			* ������pad����
		*
		*  ��������o�͂���
		*
		tst.l	d4
		beq	output_string_done

		movem.l	d1-d2/d5,-(a7)
output_string_loop:
		move.b	(a0)+,d0
		movem.l	d4/a0-a1,-(a7)
		jsr	(a1)
		movem.l	(a7)+,d4/a0-a1
		subq.l	#1,d4
		bne	output_string_loop

		movem.l	(a7)+,d1-d2/d5
output_string_done:
		bchg	#0,d2			* pad�����𔽓]
		moveq	#' ',d3			* �E����pad�����͕K����
		bsr	pad			* �E����pad����
		move.l	d1,d0
		movem.l	(a7)+,d1-d7/a0/a2-a6
		rts
*
*
*
pad:
		btst	#0,d2			* pad�������Ⴄ�Ȃ��
		bne	pad_done		* pad���Ȃ�

		tst.l	d5			* pad���镶������0�Ȃ��
		beq	pad_done		* pad���Ȃ�

		movem.l	d1-d2/d4,-(a7)
		move.b	d3,d0
pad_loop:
		movem.l	d0/d5/a1,-(a7)
		jsr	(a1)
		movem.l	(a7)+,d0/d5/a1
		subq.l	#1,d5
		bne	pad_loop

		movem.l	(a7)+,d1-d2/d4
pad_done:
		rts

.end
