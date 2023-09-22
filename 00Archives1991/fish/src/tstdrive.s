* tstdrive.s
* Itagaki Fumihiko 04-Jan-91  Create.

.include doscall.h
.include error.h

.xref toupper
.xref perror

.text

*****************************************************************
* test_drive - �h���C�u����������
*
* CALL
*      D0.B   �h���C�u��
*
* RETURN
*      D0.L   �G���[�E�R�[�h
*      CCR    TST.L D0
*****************************************************************
.xdef test_drive

test_drive:
		movem.l	d1-d2,-(a7)
		move.l	#EBADDRVNAME,d2
		bsr	toupper
		sub.b	#'A',d0
		blo	test_drive_done		* �h���C�u��������

		cmp.b	#'Z'-'A',d0
		bhi	test_drive_done		* �h���C�u��������

		moveq	#0,d1
		move.b	d0,d1			* D1.W : �h���C�u�ԍ��iA=0, B=1, ...)
		DOS	_CURDRV
		move.w	d0,-(a7)
		DOS	_CHGDRV
		addq.l	#2,a7
		move.l	#ENODRV,d2
		cmp.w	d0,d1
		bhs	test_drive_done		* �h���C�u������

		move.w	d1,d0
		addq.w	#1,d0
		move.w	d0,-(a7)
		DOS	_DRVCTRL
		addq.l	#2,a7
		move.l	#ENOMEDIA,d2
		btst	#1,d0
		beq	test_drive_done		* ���f�B�A������

		move.l	#EBADMEDIA,d2
		btst	#0,d0
		bne	test_drive_done		* ���f�B�A��}��

		move.l	#EDRVNOTREADY,d2
		btst	#2,d0
		bne	test_drive_done		* �h���C�u�E�m�b�g�E���f�B

		moveq	#0,d2
test_drive_done:
		move.l	d2,d0
		movem.l	(a7)+,d1-d2
		rts
*****************************************************************
* test_drive_perror - �h���C�u���������A�G���[�Ȃ�΃��b�Z�[�W��\������
*
* CALL
*      D0.B   �h���C�u��
*
* RETURN
*      D0.L   �G���[�E�R�[�h
*      CCR    TST.L D0
*****************************************************************
.xdef test_drive_perror

test_drive_perror:
		link	a6,#-2
		move.l	a0,-(a7)
		lea	-2(a6),a0
		move.b	d0,(a0)
		clr.b	1(a0)
		bsr	test_drive
		beq	test_drive_perror_return

		bsr	perror
test_drive_perror_return:
		movea.l	(a7)+,a0
		unlk	a6
		tst.l	d0
		rts
*****************************************************************
* test_drive_path - �p�X�����h���C�u���������Ă���Ȃ�΁A
*                   ���̃h���C�u����������
*
* CALL
*      A0     �p�X��
*
* RETURN
*      D0.L   �G���[�E�R�[�h
*      CCR    TST.L D0
*****************************************************************
.xdef test_drive_path

test_drive_path:
		move.b	(a0),d0
		beq	test_drive_pass

		cmpi.b	#':',1(a0)
		beq	test_drive
test_drive_pass:
		moveq	#0,d0
		rts
*****************************************************************
* test_drive_path_perror - �p�X�����h���C�u���������Ă���Ȃ�΁A
*                          ���̃h���C�u���������A�G���[�Ȃ��
*                          ���b�Z�[�W��\������
*
* CALL
*      A0     �p�X��
*
* RETURN
*      D0.L   �G���[�E�R�[�h
*      CCR    TST.L D0
*****************************************************************
.xdef test_drive_path_perror

test_drive_path_perror:
		move.b	(a0),d0
		beq	test_drive_pass

		cmpi.b	#':',1(a0)
		beq	test_drive_perror

		bra	test_drive_pass

.end
