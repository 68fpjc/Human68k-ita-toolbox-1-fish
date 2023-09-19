* getcwdx.s
* Itagaki Fumihiko 25-Apr-91  Create.

.xref issjis
.xref tolower
.xref toupper
.xref strcpy
.xref for1str
.xref isabsolute
.xref getcwd
.xref find_shellvar
.xref word_home

.text

****************************************************************
* getcwdx - �J�����g�E���[�L���O�E�f�B���N�g���𓾂�
*
* CALL
*      A0     �i�[����o�b�t�@�̃A�h���X�iMAXPATH+1�o�C�g�K�v�j
*      D0.B   ��0�Ȃ�� ~�ȗ����s��
*
* RETURN
*      D0.L   �ŉ��ʃo�C�g�́A~�ȗ��������Ȃ�Δ�0
*             ��ʃo�C�g�͕s��
*
*      CCR    TST.B D0
****************************************************************
.xdef getcwdx

getcwdx:
		bsr	getcwd
		tst.b	d0
		beq	return
****************************************************************
* abbrev_directory - �f�B���N�g�����ȗ��`�ɏ���������
*
* CALL
*      A0     �f�B���N�g����
*
* RETURN
*      D0.L   �ŉ��ʃo�C�g�́A~�ŏ����������Ȃ�Δ�0
*             ��ʃo�C�g�͕s��
*
*      CCR    TST.B D0
*
* DESCRIPTION
*      A0 �̎w���̈�𒼐ڏ���������
*      �����������͂Ȃ�Ȃ�������v
*      �Ȃ��A�f�B���N�g�����̃f�B���N�g���̋�؂�� / �łȂ���΂Ȃ�Ȃ�
****************************************************************
.xdef abbrev_directory

abbrev_directory:
		bsr	is_under_home
		beq	return

		movem.l	a0-a1,-(a7)
		lea	(a0,d0.l),a1
		move.b	#'~',(a0)+
		bsr	strcpy
		movem.l	(a7)+,a0-a1
		moveq	#1,d0
return:
		rts
****************************************************************
* is_under_home - �f�B���N�g�������z�[���E�f�B���N�g�������ǂ���
*
* CALL
*      A0     �f�B���N�g����
*
* RETURN
*      D0.L   �ŉ��ʃo�C�g�́A~�ŏ����������Ȃ�Δ�0
*             ��ʃo�C�g�͕s��
*
*      CCR    TST.B D0
*
* DESCRIPTION
*      A0 �̎w���̈�𒼐ڏ���������
*      �����������͂Ȃ�Ȃ�������v
*      �Ȃ��A�f�B���N�g�����̃f�B���N�g���̋�؂�� / �łȂ���΂Ȃ�Ȃ�
****************************************************************
.xdef is_under_home

is_under_home:
		movem.l	d1-d2/a0-a2,-(a7)
		moveq	#0,d2			*  D2.L : ����
		movea.l	a0,a2			*  A2 : �f�B���N�g�����̐擪�A�h���X
		bsr	isabsolute		*  �f�B���N�g�����͐�΃p�X
		bne	is_under_home_return	*  �ł͂Ȃ�

		lea	word_home,a0		*  �V�F���ϐ� home
		bsr	find_shellvar		*  ��
		beq	is_under_home_return	*  �͖���

		addq.l	#2,a0
		tst.w	(a0)+			*  �V�F���ϐ� home �̒P�ꐔ
		beq	is_under_home_return	*  �� 0 �ł���

		bsr	for1str			*  A0 : $home[1]
		bsr	isabsolute		*  $home[1] �͐�΃p�X��
		bne	is_under_home_return	*  �ł͂Ȃ�

		move.b	(a0),d0			*  $home[1] �̃h���C�u��
		bsr	toupper			*  ��啶���ɂ���
		move.b	d0,d1			*  D1.B �Ɋi�[
		move.b	(a2),d0			*  �f�B���N�g�����̃h���C�u��
		bsr	toupper			*  ��啶���ɂ���
		cmp.b	d1,d0			*  ��r
		bne	is_under_home_return	*  ��v���Ȃ�

		movea.l	a2,a1
		addq.l	#3,a1			*  A1 : �f�B���N�g������ @:/ �̎��̃A�h���X
		addq.l	#3,a0			*  A0 : $home[1] �� @:/ �̎��̃A�h���X
is_under_home_compare_loop:
		move.b	(a0)+,d0
		beq	is_under_home_check_bottom

		bsr	issjis
		beq	is_under_home_compare_sjis

		bsr	tolower
		cmp.b	#'\',d0
		bne	is_under_home_compare_1

		moveq	#'/',d0
is_under_home_compare_1:
		cmp.b	#'/',d0
		bne	is_under_home_compare_ank

		tst.b	(a0)
		beq	is_under_home_check_bottom
is_under_home_compare_ank:
		move.b	d0,d1
		move.b	(a1)+,d0
		bsr	tolower
		cmp.b	d1,d0
		bra	is_under_home_check_one

is_under_home_compare_sjis:
		move.b	d0,d1
		move.b	(a1)+,d0
		bsr	issjis
		bne	is_under_home_return

		cmp.b	d1,d0
		bne	is_under_home_return

		move.b	(a0)+,d0
		beq	is_under_home_return

		cmp.b	(a1)+,d0
is_under_home_check_one:
		bne	is_under_home_return
		bra	is_under_home_compare_loop

is_under_home_check_bottom:
		move.b	(a1),d0
		beq	is_under_home_true

		cmp.b	#'/',d0
		beq	is_under_home_true

		cmp.b	#'\',d0
		bne	is_under_home
is_under_home_true:
		move.l	a1,d2
		sub.l	a2,d2
is_under_home_return:
		move.l	d2,d0
		movem.l	(a7)+,d1-d2/a0-a2
		rts
****************************************************************

.end
