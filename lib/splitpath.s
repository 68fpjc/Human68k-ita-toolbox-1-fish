* splitpath.s
* Itagaki Fumihiko 14-Aug-90  Create.

.xref strlen
.xref headtail
.xref suffix

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

		jsr	headtail
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
		jsr	suffix
		movea.l	a0,a3			*  A3   : �T�t�B�b�N�X���̃A�h���X�i�e.�f����j
		jsr	strlen
		move.l	d0,d3			*  D3.L : �T�t�B�b�N�X���̒����i�e.�f���܂ށj
		move.l	a3,d2
		sub.l	a2,d2			*  D2.L : �t�@�C�����̒����i�T�t�B�b�N�X���͊܂܂Ȃ��j
split_pathname_return:
		movem.l	(a7)+,d0/a0		*  D0 �� A0 �����߂�
		rts

.end
