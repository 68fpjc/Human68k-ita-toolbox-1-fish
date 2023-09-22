* stat.s
* Itagaki Fumihiko 07-Mar-91  Create.

.include doscall.h
.include limits.h

.xref test_drive_path
.xref includes_dos_wildcard
.xref tailptr
.xref memmove_inc
.xref strcpy
.xref stricmp
.xref dos_allfile

.text

****************************************************************
* stat - �t�@�C���̏��𓾂�
*
* CALL
*      A0     �t�@�C�����̐擪�A�h���X
*      A1     statbuf
*
* RETURN
*      (A1)   ��񂪏������܂��
*      D0.L   ��������ΐ��C�����Ȃ��Ε�
*      CCR    TST.L D0
*****************************************************************
.xdef stat

searchnamebuf = -(MAXPATH+1)
pad = searchnamebuf-(searchnamebuf.MOD.2)

stat:
		link	a6,#pad
		movem.l	a1-a3,-(a7)
		movea.l	a1,a3			* A3 : statbuf
		bsr	test_drive_path
		bne	stat_fail

		bsr	includes_dos_wildcard	* Human68k �̃��C���h�J�[�h���܂��
		bne	stat_fail		* ����Ȃ�Ζ���

		movea.l	a0,a1			* A1 : top of search filename
		bsr	tailptr
		cmp.l	#MAXHEAD,d0
		bhi	stat_fail

		movea.l	a0,a2
		lea	searchnamebuf(a6),a0
		bsr	memmove_inc
		lea	dos_allfile,a1
		bsr	strcpy
		move.w	#$3f,-(a7)		* ���ׂẴG���g������������
		pea	searchnamebuf(a6)
		move.l	a3,-(a7)
		DOS	_FILES
		lea	10(a7),a7
		movea.l	a2,a0
		lea	30(a3),a1
stat_loop:
		tst.l	d0
		bmi	stat_fail

		bsr	stricmp
		beq	stat_ok

		move.l	a3,-(a7)
		DOS	_NFILES
		addq.l	#4,a7
		bra	stat_loop

stat_fail:
		moveq	#-1,d0
		bra	stat_return

stat_ok:
		moveq	#0,d0
stat_return:
		movem.l	(a7)+,a1-a3
		unlk	a6
		rts
****************************************************************

.end
