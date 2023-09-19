* pathname.s
* Itagaki Fumihiko 14-Aug-90  Create.
*
* This contains pathname controll routines.

.include limits.h
.include ../src/var.h

.xref strbot
.xref strlen
.xref strfor1
.xref headtail
.xref cat_pathname
.xref fish_getenv

.text

****************************************************************
* suffix - �t�@�C�����̊g���q���̃A�h���X
*
* CALL
*      A0     �t�@�C�����̐擪�A�h���X
*
* RETURN
*      A0     �g���q���̃A�h���X�i�e.�f�̈ʒu�D�e.�f��������΍Ō�� NUL ���w���j
*      CCR    TST.B (A0)
*
* NOTE
*      �e/�f��e\�f�̓`�F�b�N���Ȃ��D
*****************************************************************
.xdef suffix

suffix:
		movem.l	d0/a1-a2,-(a7)
		movea.l	a0,a2
		bsr	strbot
		movea.l	a0,a1
search_suffix:
		cmpa.l	a2,a1
		beq	suffix_return

		cmpi.b	#'.',-(a1)
		bne	search_suffix

		movea.l	a1,a0
suffix_return:
		movem.l	(a7)+,d0/a1-a2
		tst.b	(a0)
		rts
****************************************************************
* split_pathname - �p�X���𕪊�����
*
* CALL
*      A0     �p�X���̐擪�A�h���X
*
* RETURN
*      A1     �f�B���N�g�����̃A�h���X
*      A2     �t�@�C�����̃A�h���X
*      A3     �g���q���̃A�h���X�i�e.�f�̈ʒu�D�e.�f��������΍Ō�� NUL ���w���j
*      D0.L   �h���C�u�{�f�B���N�g�����̒����i�Ō�́e/�f�̕����܂ށj
*      D1.L   �f�B���N�g�����̒����i�Ō�́e/�f�̕����܂ށj
*      D2.L   �t�@�C�����i�T�t�B�b�N�X���͊܂܂Ȃ��j�̒���
*      D3.L   �T�t�B�b�N�X���̒����i�e.�f�̕����܂ށj
*****************************************************************
.xdef split_pathname

split_pathname:
	*  A2 �Ƀt�@�C�����̐擪�A�h���X
	*  D0 �Ƀh���C�u�{�f�B���N�g�����̒����i�Ō�� / �̕����܂ށj�𓾂�

		bsr	headtail
		movea.l	a1,a2			*  A2   : �t�@�C�����̐擪�A�h���X

	*  A1 �Ƀf�B���N�g�����̐擪�A�h���X
	*  D1 �Ƀf�B���N�g�����̒����i�Ō�� / �̕����܂ށj�𓾂�

		movea.l	a0,a1
		movem.l	d0/a0,-(a7)		*  D0 �� A0 ���Z�[�u����
		move.l	d0,d1
		cmp.l	#2,d1
		blo	split_pathname_1

		cmpi.b	#':',1(a1)
		bne	split_pathname_1

		addq.l	#2,a1
		subq.l	#2,d1
split_pathname_1:
		movea.l	a2,a0
		bsr	suffix
		movea.l	a0,a3			*  A3   : �T�t�B�b�N�X���̃A�h���X�i�e.�f����j
		bsr	strlen
		move.l	d0,d3			*  D3.L : �T�t�B�b�N�X���̒����i�e.�f���܂ށj
		move.l	a3,d2
		sub.l	a2,d2			*  D2.L : �T�t�B�b�N�X���̒����i�T�t�B�b�N�X���͊܂܂Ȃ��j
split_pathname_return:
		movem.l	(a7)+,d0/a0		*  D0 �� A0 �����߂�
		rts
*****************************************************************
* make_sys_pathname - �V�X�e���E�t�@�C���̃p�X���𐶐�����
*
* CALL
*      A0     ���ʂ��i�[����o�b�t�@�iMAXPATH+1�o�C�g�K�v�j
*      A1     $SYSROOT���̃p�X��
*
* RETURN
*      ������ MAXPATH �𒴂����ꍇ�ɂ͕���
*****************************************************************
.xdef make_sys_pathname

make_sys_pathname:
		movem.l	d0/a0-a3,-(a7)
		movea.l	a1,a2
		movea.l	a0,a3
		lea	word_sysroot,a0
		bsr	fish_getenv
		lea	str_nul,a1
		beq	make_sys_pathname_1

		movea.l	d0,a0
		lea	var_body(a0),a0
		bsr	strfor1
		movea.l	a0,a1
make_sys_pathname_1:
		movea.l	a3,a0
		bsr	cat_pathname
make_sys_pathname_return:
		movem.l	(a7)+,d0/a0-a3
		rts
*****************************************************************
.data

word_sysroot:		dc.b	'SYSROOT'
str_nul:		dc.b	0

*****************************************************************

.end
