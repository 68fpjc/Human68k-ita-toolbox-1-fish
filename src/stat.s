* stat.s
* Itagaki Fumihiko 07-Mar-91  Create.

.include doscall.h
.include limits.h
.include stat.h

.xref drvchkp
.xref contains_dos_wildcard
.xref headtail
.xref get_fair_pathname
.xref memmovi
.xref strcpy
.xref strcmp

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

searchnamebuf = -(((MAXPATH+1)+1)>>1<<1)

stat:
		movem.l	a0-a3,-(a7)
		movea.l	a1,a3				*  A3 : statbuf
		bsr	get_fair_pathname
		bcs	stat_fail

		bclr	#31,d0
		bsr	drvchkp
		bmi	stat_return

		bsr	contains_dos_wildcard		*  Human68k �̃��C���h�J�[�h���܂��
		bne	stat_fail			*  ����Ȃ�Ζ���

		bsr	headtail
		cmp.l	#MAXHEAD,d0
		bhi	stat_fail

		cmpi.b	#'.',(a1)
		bne	stat_normal

		tst.b	1(a1)
		beq	stat_special

		cmpi.b	#'.',1(a1)
		bne	stat_normal

		tst.b	2(a1)
		bne	stat_normal
		*  . �� .. �� *.* �Ō�������i�����Ȃ��Ό�������Ȃ��j
stat_special:
		movea.l	a1,a2				*  A2 : tail part of search pathname
		movea.l	a0,a1				*  A1 : top of search pathname
		link	a6,#searchnamebuf
		lea	searchnamebuf(a6),a0
		bsr	memmovi
		lea	dos_allfile,a1
		bsr	strcpy
		move.w	#MODEVAL_ALL,-(a7)		*  ���ׂẴG���g������������
		pea	searchnamebuf(a6)
		move.l	a3,-(a7)
		DOS	_FILES
		lea	10(a7),a7
		unlk	a6
		movea.l	a2,a0
		lea	ST_NAME(a3),a1
stat_loop:
		tst.l	d0
		bmi	stat_return

		bsr	strcmp
		beq	stat_return

		move.l	a3,-(a7)
		DOS	_NFILES
		addq.l	#4,a7
		bra	stat_loop

stat_normal:
		move.w	#MODEVAL_ALL,-(a7)		*  ���ׂẴG���g������������
		move.l	a0,-(a7)
		move.l	a3,-(a7)
		DOS	_FILES
		lea	10(a7),a7
		bra	stat_return

stat_fail:
		moveq	#-1,d0
stat_return:
		movem.l	(a7)+,a0-a3
		tst.l	d0
		rts
****************************************************************
* lgetmode - �t�@�C���̑����𓾂�
*
* CALL
*      A0     �t�@�C�����̐擪�A�h���X
*
* RETURN
*      D0.L   ���Ȃ�΃G���[�D���Ȃ�Ή��ʃo�C�g�͑����D
*      CCR    TST.L D0
*
* DESCRIPTION
*      �t�@�C�����V���{���b�N�E�����N�ł���ꍇ�ɂ̓����N���̂�
*      ������Ԃ��D
*****************************************************************
.xdef lgetmode

lgetmode:
		move.l	a0,-(a7)
		bsr	get_fair_pathname
		bcs	lgetmode_fail

		move.w	#-1,-(a7)
		move.l	a0,-(a7)
		DOS	_CHMOD
		addq.l	#6,a7
lgetmode_return:
		movea.l	(a7)+,a0
		tst.l	d0
		rts

lgetmode_fail:
		moveq	#-1,d0
		bra	lgetmode_return
****************************************************************
.end
