* printfs.s
* Itagaki Fumihiko 21-Apr-91  Create.

.xref strlen

.text

****************************************************************
* printfs - ������������ɏ]���ďo�͂���
*
* CALL
*      A0     �o�͂��镶����̐擪�A�h���X
*      A1     �����̏o�͂��s�Ȃ��T�u�E���[�`���̃G���g���[�E�A�h���X
*             �����R�[�h��D0.B�ɗ^���Ă��̃T�u�E���[�`�����Ăяo���D
*             ���ׂẴ��W�X�^��ۑ�������̂łȂ���΂Ȃ�Ȃ��D
*      D1.L   bit 0 : 0=�E�l��  1=���l��
*      D2.B   �E�l�߂̂Ƃ��A�����̌��Ԃ𖄂߂镶���R�[�h
*      D3.L   �ŏ��t�B�[���h���i�o�C�g���j
*      D4.L   �ő�o�͕����i�o�C�g�j��
*
* RETURN
*      D0.L   �o�͂��������i�o�C�g�j��
*****************************************************************
.xdef printfs

printfs:
		movem.l	d1-d5/a0,-(a7)
	*
	*  D4.L := min(strlen(s), D4.L);	/*  D4.L : �����񂩂�o�͂���o�C�g��  */
	*
		jsr	strlen
		cmp.l	d0,d4
		blo	strlen_ok

		move.l	d0,d4
strlen_ok:
	*
	*  D3.L -= D4.L;
	*  if (D3.L < 0) D6.L = 0;		/*  D3.L : pad����ׂ��o�C�g�� */
	*
		sub.l	d4,d3
		bcc	padlen_ok

		moveq	#0,d3
padlen_ok:
		move.l	d4,d5
		add.l	d3,d5			*  D5.L : �o�͂��鑍������
	*
	*  ������pad����
	*
		bsr	pad
	*
	*  ��������o�͂���
	*
		tst.l	d4
		beq	string_done
string_loop:
		move.b	(a0)+,d0
		jsr	(a1)
		subq.l	#1,d4
		bne	string_loop
string_done:
	*
	*  �E����pad����
	*
		bchg	#0,d1			*  pad�����𔽓]
		moveq	#' ',d2			*  �E����pad�����͕K����
		bsr	pad
	*
	*  return �o�̓o�C�g��
	*
		move.l	d5,d0
		movem.l	(a7)+,d1-d5/a0
		rts
****************
pad:
		btst	#0,d1			*  pad�������Ⴄ�Ȃ��
		bne	pad_return		*  pad���Ȃ�

		tst.l	d3			*  pad����o�C�g���� 0 �Ȃ��
		beq	pad_return		*  pad���Ȃ�

		move.b	d2,d0
pad_loop:
		jsr	(a1)
		subq.l	#1,d3
		bne	pad_loop
pad_return:
		rts
****************

.end
