* drvchk.s
* Itagaki Fumihiko 04-Jan-91  Create.

.include doscall.h
.include error.h

.xref toupper

.text

*****************************************************************
* drvchkp - �p�X�����h���C�u���������Ă���Ȃ��
*           ���̃f�B�X�N�E�h���C�u����������
*
* CALL
*      A0     �p�X��
*
* RETURN
*      D0.L   �G���[�E�R�[�h
*      CCR    TST.L D0
*
* DIAGNOSTIC
*      �G���[�Ȃ�Έȉ��̕����R�[�h��Ԃ��D
*
*           EBADDRVNAME
*           ENODRV
*           ENOMEDIA
*           EBADMEDIA
*           EDRVNOTREADY
*
*      �����Ȃ��� 0 ��Ԃ��D
*****************************************************************
.xdef drvchkp

drvchkp:
		move.b	(a0),d0
		beq	ok_return

		cmpi.b	#':',1(a0)
		bne	ok_return
*****************************************************************
* drvchk - �f�B�X�N�E�h���C�u����������
*
* CALL
*      D0.B   �h���C�u��
*
* RETURN
*      D0.L   �G���[�E�R�[�h
*      CCR    TST.L D0
*
* DIAGNOSTIC
*      �G���[�Ȃ�Έȉ��̕����R�[�h��Ԃ��D
*
*           EBADDRVNAME
*           ENODRV
*           ENOMEDIA
*           EBADMEDIA
*           EDRVNOTREADY
*
*      �����Ȃ��� 0 ��Ԃ��D
*****************************************************************
.xdef drvchk

drvchk:
		movem.l	d1-d2,-(a7)
		move.l	#EBADDRVNAME,d2
		jsr	toupper
		sub.b	#'A',d0
		blo	drvchk_done		* �h���C�u��������

		cmp.b	#'Z'-'A',d0
		bhi	drvchk_done		* �h���C�u��������

		moveq	#0,d1
		move.b	d0,d1			* D1.W : �h���C�u�ԍ��iA=0, B=1, ...)
		DOS	_CURDRV
		move.w	d0,-(a7)
		DOS	_CHGDRV
		addq.l	#2,a7
		move.l	#ENODRV,d2
		cmp.w	d0,d1
		bhs	drvchk_done		* �h���C�u������

		move.w	d1,d0
		addq.w	#1,d0
		move.w	d0,-(a7)
		DOS	_DRVCTRL
		addq.l	#2,a7
		move.l	#ENOMEDIA,d2
		btst	#1,d0
		beq	drvchk_done		* ���f�B�A������

		move.l	#EBADMEDIA,d2
		btst	#0,d0
		bne	drvchk_done		* ���f�B�A��}��

		move.l	#EDRVNOTREADY,d2
		btst	#2,d0
		bne	drvchk_done		* �h���C�u�E�m�b�g�E���f�B

		moveq	#0,d2
drvchk_done:
		move.l	d2,d0
		movem.l	(a7)+,d1-d2
		rts

ok_return:
		moveq	#0,d0
		rts

.end
