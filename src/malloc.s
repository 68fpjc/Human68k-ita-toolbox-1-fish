.include ../src/fish.h


.if EXTMALLOC
	.xref MALLOC
	.xref MFREE
	.xref MFREEALL

	.xref lake_top
	.xref tmplake_top
.else
	.include doscall.h
.endif


.text

*****************************************************************
* free, xfree - �m�ۂ������������������
*
* CALL
*      D0.L   �������E�u���b�N�̐擪�A�h���X
*
* RETURN
*      D0.L   �G���[�E�R�[�h
*      CCR    TST.L D0
*
* DESCRIPTION
*      xfree �ł́AD0.L == 0 �̂Ƃ��ɂ͉������Ȃ�
*****************************************************************
.xdef xfree
.xdef free

xfree:
		tst.l	d0
		beq	free_return
free:
		move.l	d0,-(a7)
	.if EXTMALLOC
		bsr	MFREE
	.else
		DOS	_MFREE
	.endif
		addq.l	#4,a7
		tst.l	d0
free_return:
		rts
*****************************************************************
* xfreep - �m�ۂ������������������
*
* CALL
*      A0     �������E�u���b�N�̐擪�A�h���X���i�[����Ă���|�C���^�̃A�h���X
*
* RETURN
*      D0.L   �G���[�E�R�[�h
*      (A0)   �G���[�łȂ���΃N���A�����
*      CCR    TST.L D0
*
* DESCRIPTION
*      (A0) == 0 �̂Ƃ��ɂ͉������Ȃ�
*****************************************************************
.xdef xfreep

xfreep:
		move.l	(a0),d0
		bsr	xfree
		bne	xfreep_return

		clr.l	(a0)
xfreep_return:
		rts
*****************************************************************
* xmalloc - ���������m�ۂ���
*
* CALL
*      D0.L   �m�ۂ���o�C�g��
*
* RETURN
*      D0.L   �m�ۂ����������E�u���b�N�̐擪�A�h���X
*             0 �͊m�ۂł��Ȃ��������Ƃ�����
*
*      CCR    TST.L D0
*****************************************************************
.xdef xmalloc

xmalloc:
		move.l	d0,-(a7)			*  �v����
		move.w	#1,-(a7)			*  �K�v�ŏ��u���b�N����
	.if EXTMALLOC
		bsr	MALLOC
	.else
		DOS	_MALLOC
	.endif
		addq.l	#6,a7
		tst.l	d0
		bpl	xmalloc_return

		moveq	#0,d0
xmalloc_return:
		rts
*****************************************************************
* xmalloct - �ꎞ�I���������m�ۂ���
*
* CALL
*      D0.L   �m�ۂ���o�C�g��
*
* RETURN
*      D0.L   �m�ۂ����������E�u���b�N�̐擪�A�h���X
*             0 �͊m�ۂł��Ȃ��������Ƃ�����
*
*      CCR    TST.L D0
*****************************************************************
.xdef xmalloct

xmalloct:
		bsr	swap_lake
		bsr	xmalloc
swap_lake:
		move.l	tmplake_top(a5),-(a7)
		move.l	lake_top(a5),tmplake_top(a5)
		move.l	(a7)+,lake_top(a5)
		tst.l	d0
		rts
*****************************************************************
* freet - �m�ۂ����ꎞ�I���������������
*
* CALL
*      D0.L   �������E�u���b�N�̐擪�A�h���X
*
* RETURN
*      D0.L   �G���[�E�R�[�h
*      CCR    TST.L D0
*****************************************************************
.xdef freet

freet:
		bsr	swap_lake
		bsr	free
		bra	swap_lake
*****************************************************************
* free_all_tmp - �m�ۂ����ꎞ�I�����������ׂĉ������
*
* CALL
*      none
*
* RETURN
*      D0.L   �G���[�E�R�[�h
*      CCR    TST.L D0
*****************************************************************
.xdef free_all_tmp

free_all_tmp:
	.if EXTMALLOC
		bsr	swap_lake
		bsr	MFREEALL
		bra	swap_lake
	.else
		*  ��p�i�͖��� (^^;
		rts
	.endif
*****************************************************************
* xmallocp - ���������m�ۂ���
*
* CALL
*      D0.L   �m�ۂ���o�C�g��
*      A0     �m�ۂ����������E�u���b�N�̐擪�A�h���X���i�[����|�C���^�̃A�h���X
*
* RETURN
*      D0.L   �m�ۂ����������E�u���b�N�̐擪�A�h���X
*             0 �͊m�ۂł��Ȃ��������Ƃ�����
*      (A0)   D0.L
*      CCR    TST.L D0
*
* DESCRIPTION
*      (A0) != 0 �Ȃ�� xmalloc �����A(A0) �������ċA��
*****************************************************************
.xdef xmallocp

xmallocp:
		tst.l	(a0)
		bne	xmallocp_return

		bsr	xmalloc
		move.l	d0,(a0)
xmallocp_return:
		move.l	(a0),d0
		rts
*****************************************************************

.end
