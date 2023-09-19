* drvchk.s
* Itagaki Fumihiko 04-Jan-91  Create.

.include doscall.h
.include error.h

.xref toupper

.text
*****************************************************************
* drvchkp - �p�X���̃f�B�X�N�E�h���C�u���ǂݍ��݉\���ǂ�������������
*
* CALL
*      A0     �p�X��
*      D0.L   MSB: 1 �Ȃ珑�����݂ɑ΂��Ẵ`�F�b�N���s��
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
*****************************************************************
* drvchk - �f�B�X�N�E�h���C�u���ǂݍ��݉\���ǂ�������������
*
* CALL
*      D0.L   ���ʃo�C�g: �h���C�u��
*             MSB: 1 �Ȃ珑�����݂ɑ΂��Ẵ`�F�b�N���s��
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
.xdef drvchk

drvchkp:
		move.b	(a0),d0
		beq	drvchk_current

		cmpi.b	#':',1(a0)
		beq	drvchk
drvchk_current:
		swap	d0
		move.w	d0,-(a7)
		DOS	_CURDRV
		add.b	#'A',d0
		swap	d0
		move.w	(a7)+,d0
		swap	d0
drvchk:
		movem.l	d1-d3,-(a7)
		move.l	d0,d3
		move.l	#EBADDRVNAME,d1
		jsr	toupper
		sub.b	#'A',d0
		blo	drvchk_done		* �h���C�u��������

		cmp.b	#'Z'-'A',d0
		bhi	drvchk_done		* �h���C�u��������

		moveq	#0,d2
		move.b	d0,d2			* D1.W : �h���C�u�ԍ��iA=0, B=1, ...)
		DOS	_CURDRV
		move.w	d0,-(a7)
		DOS	_CHGDRV
		addq.l	#2,a7
		move.l	#ENODRV,d1
		cmp.w	d0,d2
		bhs	drvchk_done		* �h���C�u������

		move.w	d2,d0
		addq.w	#1,d0
		move.w	d0,-(a7)
		DOS	_DRVCTRL
		addq.l	#2,a7
		move.l	#ENOMEDIA,d1
		btst	#1,d0
		beq	drvchk_done		* ���f�B�A������

		move.l	#EBADMEDIA,d1
		btst	#0,d0
		bne	drvchk_done		* ���f�B�A��}��

		move.l	#EDRVNOTREADY,d1
		btst	#2,d0
		bne	drvchk_done		* �h���C�u�E�m�b�g�E���f�B

		btst	#31,d3
		beq	drvchk_ok

		move.l	#EWRITEPROTECTED,d1
		btst	#3,d0				* write protect
		bne	drvchk_done
drvchk_ok:
		moveq	#0,d1
drvchk_done:
		move.l	d1,d0
		movem.l	(a7)+,d1-d3
		rts

.end
