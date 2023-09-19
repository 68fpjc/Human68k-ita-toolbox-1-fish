* printfi.s
* Itagaki Fumihiko 21-Apr-91  Create.

.xref strlen

.text

****************************************************************
* printfi - �����O�E���[�h�l�������ɏ]���ďo�͂���
*
* CALL
*      D0.L   �l
*      D1.L   bit 0 : 0=�E�l��  1=���l��
*      D2.B   �E�l�߂̂Ƃ��A�����̌��Ԃ𖄂߂镶���R�[�h
*      D3.L   �ŏ��t�B�[���h���i�o�C�g���j
*      D4.L   ���Ȃ��Ƃ��o�͂��鐔���̌���
*      A0     �l�𕶎���ɕϊ�����T�u�E���[�`���̃G���g���[�E�A�h���X
*             ���̃T�u�E���[�`���ɑ΂��C34B�̃o�b�t�@�̐擪�A�h���X��
*             A0�ɗ^���ČĂяo���BD1-D4 �͂��̂܂ܓn���D
*             �S�Ẵ��W�X�^��ۑ�������̂łȂ���΂Ȃ�Ȃ��D
*      A1     �����̏o�͂��s�Ȃ��T�u�E���[�`���̃G���g���[�E�A�h���X
*             ���̃T�u�E���[�`���ɑ΂��A�����R�[�h��D0.B�ɗ^���ČĂяo���D
*             �S�Ẵ��W�X�^��ۑ�������̂łȂ���΂Ȃ�Ȃ��D
*      A2     prefix�̐擪�A�h���X
*             0 �Ȃ�Ώo�͂��Ȃ��D
*
* RETURN
*      D0.L   �o�͂���������
*****************************************************************
.xdef printfi

printfi:
		link	a6,#-34				*  ������o�b�t�@���m�ۂ���
		movem.l	d3-d6/a0/a2-a3,-(a7)
		movea.l	a0,a3
		lea	-34(a6),a0			*  A0 : ������o�b�t�@�̐擪�A�h���X
		jsr	(a3)				*  �l�𕶎���ɕϊ�
		movea.l	a0,a3				*  A3 : ������o�b�t�@�̐擪�A�h���X
	*
	*  A0 �ɁA�������Ƃ΂��Đ������n�܂�ʒu�����߂�
	*
		move.b	(a0)+,d0
		cmp.b	#'-',d0
		beq	with_sign

		cmp.b	#'+',d0
		beq	with_sign

		cmp.b	#' ',d0
		beq	with_sign
no_sign:
		subq.l	#1,a0
with_sign:
	*
	*  D4.L �ɒǉ����ׂ����������߂�
	*
		jsr	strlen
		move.l	d0,d5				*  D5.L : �����̌���
		sub.l	d0,d4
		bhs	precpadlen_ok

		moveq	#0,d4
precpadlen_ok:
	*
	*  D6.L ��prefix�̒��������߂�
	*
		moveq	#0,d6
		cmpa.l	#0,a2
		beq	prefixlen_ok

		exg	a0,a2
		jsr	strlen
		exg	a0,a2
		move.l	d0,d6
prefixlen_ok:
	*
	*  D3.L ��pad���ׂ��o�C�g�������߂�
	*
		move.l	a0,d0
		sub.l	a3,d0				*  D0 = �����̒���
		add.l	d6,d0				*     + prefix�̒���
		add.l	d4,d0				*     + �ǉ�����
		add.l	d5,d0				*     + �����̌���
		sub.l	d0,d3
		bcc	fieldpadlen_ok

		moveq	#0,d3
fieldpadlen_ok:
		add.l	d3,d0
		move.l	d0,d5				*  D5.L : �o�͂��鑍������

		btst	#0,d1
		bne	left_justify
	*
	*  �E�l�߁D' '��pad
	*
		cmp.b	#'0',d2
		beq	left_justify_zeropad

		move.b	d2,d0
		bsr	pad				*  �t�B�[���h��pad����
		bsr	sign_and_prefix			*  ������prefix���o�͂���
		bsr	digits				*  ���������o�͂���
		bra	done

left_justify_zeropad:
	*
	*  �E�l�߁D'0'��pad
	*
		bsr	sign_and_prefix			*  ������prefix���o�͂���
		move.b	d2,d0
		bsr	pad				*  �t�B�[���h��pad����
		bsr	digits				*  ���������o�͂���
		bra	done

left_justify:
	*
	*  ���l��
	*
		bsr	sign_and_prefix			*  ������prefix���o�͂���
		bsr	digits				*  ���������o�͂���
		moveq	#' ',d0				*  ' '��
		bsr	pad				*  �t�B�[���h��pad����
done:
		move.l	d5,d0
		movem.l	(a7)+,d3-d6/a0/a2-a3
		unlk	a6
		rts
****************
sign_and_prefix:
		cmpa.l	a0,a3
		beq	prefix

		move.b	(a3),d0
		jsr	(a1)
prefix:
		tst.l	d6
		beq	prefix_done

		exg	a0,a2
		bsr	puts
		exg	a0,a2
prefix_done:
		rts
****************
digits:
		tst.l	d4
		beq	puts

		moveq	#'0',d0
		exg	d3,d4
		bsr	pad
		exg	d3,d4
puts:
		move.b	(a0)+,d0
		beq	puts_done

		jsr	(a1)
		bra	puts
****************
pad_high_loop:
		swap	d3
pad_low_loop:
		jsr	(a1)
pad:
		dbra	d3,pad_low_loop

		swap	d3
		dbra	d3,pad_high_loop
puts_done:
		rts
****************

.end
