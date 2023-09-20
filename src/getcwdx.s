* getcwdx.s
* Itagaki Fumihiko 25-Apr-91  Create.

.xref issjis
.xref tolower
.xref strcpy
.xref get_shellvar
.xref isfullpath
.xref make_sys_pathname

.xref word_home

.xref doscall_pathname

.xref flag_refersysroot
.xref cwd

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
		movem.l	d0/a1,-(a7)
		lea	cwd(a5),a1
		jsr	strcpy
		movem.l	(a7)+,d0/a1
		tst.b	d0
		beq	return
****************************************************************
* abbrev_directory - �f�B���N�g�����ȗ��`�ɏ���������
*
* CALL
*      A0     �f�B���N�g�����i�h���C�u�������S�p�X�j
*
* RETURN
*      D0.L   ~�ŏ����������Ȃ�� 1�C�����Ȃ��� 0�D
*      CCR    TST.B D0
*
* DESCRIPTION
*      A0 �̎w���̈�𒼐ڏ���������
*      �����������͂Ȃ�Ȃ�������v
*      �f�B���N�g�����̓h���C�u�������S�p�X�łȂ���΂Ȃ�Ȃ�
*      �f�B���N�g�����̃f�B���N�g���̋�؂�� / �łȂ���΂Ȃ�Ȃ�
****************************************************************
abbrev_directory:
		bsr	is_under_home
		beq	return

		movem.l	a0-a1,-(a7)
		lea	(a0,d0.l),a1
		move.b	#'~',(a0)+
		jsr	strcpy
		movem.l	(a7)+,a0-a1
		moveq	#1,d0
return:
		rts
****************************************************************
* is_under_home - �f�B���N�g�������z�[���E�f�B���N�g�������ǂ���
*
* CALL
*      A0     �f�B���N�g�����i�h���C�u�������S�p�X�j
*
* RETURN
*      D0.L   $home���ł���A$home �����[�g�E�f�B���N�g���łȂ�
*             ��΁A~�ɑ����ׂ������܂ł̃I�t�Z�b�g
*             �����łȂ���� 0
*
*      CCR    TST.L D0
*
* NOTE
*      �f�B���N�g�����̓h���C�u�������S�p�X�łȂ���΂Ȃ�Ȃ�
*      �f�B���N�g�����̃f�B���N�g���̋�؂�� / �łȂ���΂Ȃ�Ȃ�
****************************************************************
.xdef is_under_home

is_under_home:
		movem.l	d1-d2/a0-a2,-(a7)
		moveq	#0,d2			*  D2.L : ����
		movea.l	a0,a2			*  A2 : �f�B���N�g�����̐擪�A�h���X
		lea	word_home,a0		*  �V�F���ϐ� home
		bsr	get_shellvar		*  ��
		beq	is_under_home_return	*  �͖�������ł���

		tst.b	flag_refersysroot(a5)
		beq	is_under_home_home_ok

		cmpi.b	#'/',(a0)
		bne	is_under_home_home_ok

		movea.l	a0,a1
		lea	doscall_pathname,a0
		jsr	make_sys_pathname
		bmi	is_under_home_return
is_under_home_home_ok:
		jsr	isfullpath		*  $home[1] �͊��S�p�X��
		bne	is_under_home_return	*  �ł͂Ȃ�

		tst.b	3(a0)			*  $home[1] ��
		beq	is_under_home_return	*  ���[�g�E�f�B���N�g���ł���

		move.b	(a0),d0			*  $home[1] �̃h���C�u��
		bsr	tolower			*  ���������ɂ���
		move.b	d0,d1			*  D1.B �Ɋi�[
		move.b	(a2),d0			*  �f�B���N�g�����̃h���C�u��
		bsr	tolower			*  ���������ɂ���
		cmp.b	d1,d0			*  ��r
		bne	is_under_home_return	*  ��v���Ȃ�

		lea	2(a2),a1		*  A1 : �f�B���N�g������ @: �̎��̃A�h���X
		addq.l	#2,a0			*  A0 : $home[1] �� @: �̎��̃A�h���X
is_under_home_compare_loop:
		move.b	(a0)+,d0
		beq	is_under_home_check_bottom

		jsr	issjis
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
		jsr	issjis
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
		bne	is_under_home_return
is_under_home_true:
		move.l	a1,d2
		sub.l	a2,d2
is_under_home_return:
		move.l	d2,d0
		movem.l	(a7)+,d1-d2/a0-a2
		rts
****************************************************************

.end
