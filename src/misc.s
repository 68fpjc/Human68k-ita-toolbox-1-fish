.include doscall.h
.include chrcode.h

.xref iscntrl
.xref isodigit
.xref issjis
.xref utoa
.xref strlen
.xref strcpy
.xref strpcmp
.xref strfor1
.xref xmalloc
.xref scan_octal
.xref printfi
.xref str_newline

.text

*****************************************************************
* isnotttyin - ���͂��[���ł��邩�ǂ����𒲂ׂ�
*
* CALL
*      D0.W   �t�@�C���E�n���h��
*
* RETURN
*      D0.L   ���ʃo�C�g�͒[���Ȃ�� $FF, �����Ȃ��� $00
*             ��ʂ͔j��
*      CCR    TST.B D0
*****************************************************************
****************************************************************
* isblkdev - �L�����N�^�E�f�o�C�X���ǂ����𒲂ׂ�
*
* CALL
*      D0.W   �t�@�C���E�n���h��
*
* RETURN
*      D0.L   ���ʃo�C�g�̓u���b�N�E�f�o�C�X�Ȃ�� $00�C�L�����N�^�E�f�o�C�X�Ȃ�� $FF
*             ��ʂ͔j��
*      CCR    TST.B D0
*****************************************************************
.xdef isnotttyin
.xdef isblkdev

isnotttyin:
isblkdev:
		move.w	d0,-(a7)
		clr.w	-(a7)
		DOS	_IOCTRL
		addq.l	#4,a7
		btst	#7,d0
		sne	d0
		tst.b	d0
		rts
*****************************************************************
* xcputs -
*
* CALL
*      A0     points string
*      A1     function pointer prints normal character
*      A2     function pointer prints conroll character
*****************************************************************
xcputs:
		movem.l	d0/a0,-(a7)
xcputs_loop:
		move.b	(a0)+,d0
		beq	xcputs_done

		bsr	issjis
		beq	xcputs_sjis

		jsr	(a2)
		bra	xcputs_loop

xcputs_sjis:
		tst.b	(a0)
		beq	xcputs_done

		jsr	(a1)
		move.b	(a0)+,d0
		jsr	(a1)
		bra	xcputs_loop

xcputs_done:
		movem.l	(a7)+,d0/a0
		rts
*****************************************************************
.xdef cputc
.xdef putc

cputc:
		jsr	iscntrl
		bne	putc

		move.l	d0,-(a7)
		moveq	#'^',d0
		bsr	putc
		move.l	(a7),d0
		add.b	#$40,d0
		and.b	#$7f,d0
		bsr	putc
		move.l	(a7)+,d0
		rts

putc:
		move.l	d0,-(a7)
		move.w	d0,-(a7)
		DOS	_PUTCHAR
		addq.l	#2,a7
		move.l	(a7)+,d0
		rts
*****************************************************************
.xdef ecputc
.xdef eputc

ecputc:
		cmp.b	#$20,d0
		bhs	eputc

		move.l	d0,-(a7)
		moveq	#'^',d0
		bsr	eputc
		move.l	(a7),d0
		add.b	#$40,d0
		bsr	eputc
		move.l	(a7)+,d0
		rts

eputc:
		move.l	d0,-(a7)
		move.l	#1,-(a7)
		pea	7(a7)
		move.w	#2,-(a7)
		DOS	_WRITE
		lea	10(a7),a7
		move.l	(a7)+,d0
		rts
****************************************************************
.xdef puts

puts:
		move.l	d0,-(a7)
		move.l	a0,-(a7)
		DOS	_PRINT
		addq.l	#4,a7
		move.l	(a7)+,d0
		rts
****************************************************************
.xdef eputs

eputs:
		move.l	d0,-(a7)
		bsr	strlen
		move.l	d0,-(a7)
		move.l	a0,-(a7)
		move.w	#2,-(a7)
		DOS	_WRITE
		lea	10(a7),a7
		move.l	(a7)+,d0
		rts
****************************************************************
.xdef enputs
.xdef eput_newline

enputs:
		bsr	eputs
eput_newline:
		move.l	d0,-(a7)
		move.l	#2,-(a7)
		pea	str_newline
		move.w	#2,-(a7)
		DOS	_WRITE
		lea	10(a7),a7
		move.l	(a7)+,d0
		rts
*****************************************************************
.xdef cputs

cputs:
		movem.l	a1-a2,-(a7)
		lea	putc(pc),a1
		lea	cputc(pc),a2
		bsr	xcputs
		movem.l	(a7)+,a1-a2
		rts
*****************************************************************
.xdef ecputs

ecputs:
		movem.l	a1-a2,-(a7)
		lea	eputc(pc),a1
		lea	ecputc(pc),a2
		bsr	xcputs
		movem.l	(a7)+,a1-a2
		rts
*****************************************************************
.xdef nputs
.xdef put_newline

nputs:
		bsr	puts
put_newline:
		movem.l	d0/a0,-(a7)
		lea	str_newline,a0
		bsr	puts
		movem.l	(a7)+,d0/a0
		rts
*****************************************************************
.xdef put_space

put_space:
		move.l	d0,-(a7)
		moveq	#$20,d0
		bsr	putc
		move.l	(a7)+,d0
		rts
*****************************************************************
.xdef put_tab

put_tab:
		move.l	d0,-(a7)
		move.w	#HT,d0
		bsr	putc
		move.l	(a7)+,d0
		rts
*****************************************************************
.xdef printu

printu:
		movem.l	a0-a2,-(a7)
		lea	utoa(pc),a0			*  �����Ȃ�10�i�ϊ�
		lea	putc(pc),a1
		suba.l	a2,a2
		bsr	printfi
		movem.l	(a7)+,a0-a2
		rts
*****************************************************************
.xdef basic_escape_sequence

basic_escape_sequence:
		movem.l	d1,-(a7)
		moveq	#'\',d1
		cmp.b	#'\',d0
		beq	basic_escape_sequence_matched

		moveq	#BL,d1
		cmp.b	#'a',d0
		beq	basic_escape_sequence_matched

		moveq	#BS,d1
		cmp.b	#'b',d0
		beq	basic_escape_sequence_matched

		moveq	#FS,d1
		cmp.b	#'f',d0
		beq	basic_escape_sequence_matched

		moveq	#CR,d1
		cmp.b	#'r',d0
		beq	basic_escape_sequence_matched

		moveq	#HT,d1
		cmp.b	#'t',d0
		beq	basic_escape_sequence_matched

		moveq	#VT,d1
		cmp.b	#'v',d0
		beq	basic_escape_sequence_matched

		moveq	#LF,d1
		cmp.b	#'n',d0
		bne	basic_escape_sequence_return
basic_escape_sequence_matched:
		move.l	d1,d0
		cmp.b	d1,d0				*  always EQ
basic_escape_sequence_return:
		movem.l	(a7)+,d1
		rts
*****************************************************************
* putsex - �G�X�P�[�v�t���P����o�͂���
*
* CALL
*      A0     �P��̃A�h���X
*      A1     1�����o�̓��[�`���̃A�h���X
*
* RETURN
*      D0     \c ���������Ȃ�� 1�C�����Ȃ��� 0
*      CCR    TST.L D0
*****************************************************************
.xdef putsex

putsex:
		movem.l	d1-d3/a0,-(a7)
		moveq	#0,d3
putsex_loop:
		move.b	(a0)+,d0
		beq	putsex_done

		bsr	issjis
		beq	putsex_sjis

		cmp.b	#'\',d0
		bne	putsex_normal

		move.b	(a0),d0
		bsr	basic_escape_sequence
		beq	putsex_escape_0

		jsr	isodigit
		beq	putsex_octal

		cmp.b	#'c',d0
		bne	putsex_escape_normal

		moveq	#1,d3
		bra	putsex_escape_2

putsex_escape_0:
		cmp.b	#LF,d0
		bne	putsex_escape_1

		moveq	#CR,d0
		jsr	(a1)
		moveq	#LF,d0
putsex_escape_1:
		jsr	(a1)
putsex_escape_2:
		addq.l	#1,a0
		bra	putsex_loop

putsex_octal:
		moveq	#2,d0
		jsr	scan_octal
		bra	putsex_normal

putsex_escape_normal:
		moveq	#'\',d0
		bra	putsex_normal

putsex_sjis:
		jsr	(a1)
		move.b	(a0)+,d0
		beq	putsex_done
putsex_normal:
		jsr	(a1)
		bra	putsex_loop

putsex_done:
		move.l	d3,d0
		movem.l	(a7)+,d1-d3/a0
		rts
*****************************************************************
* putse - �G�X�P�[�v�t���P���W���o�͂ɏo�͂���
*
* CALL
*      A0     �P��̃A�h���X
*
* RETURN
*      D0     \c ���������Ȃ�� 1�C�����Ȃ��� 0
*      CCR    TST.L D0
*****************************************************************
.xdef putse

putse:
		move.l	a1,-(a7)
		lea	putc(pc),a1
		bsr	putsex
		movea.l	(a7)+,a1
		rts
*****************************************************************
* eputse - �G�X�P�[�v�t���P���W���G���[�o�͂ɏo�͂���
*
* CALL
*      A0     �P��̃A�h���X
*
* RETURN
*      D0     \c ���������Ȃ�� 1�C�����Ȃ��� 0
*      CCR    TST.L D0
*****************************************************************
.xdef eputse

eputse:
		move.l	a1,-(a7)
		lea	eputc(pc),a1
		bsr	putsex
		movea.l	(a7)+,a1
		rts
*****************************************************************
* strdup - ���������m�ۂ��ĕ�����𕡐�����
*
* CALL
*      A0     ������̐擪�A�h���X
*
* RETURN
*      D0     ��������������̐擪�A�h���X
*             ���������m�ۂł��Ȃ������Ȃ�� 0
*      CCR    TST.L D0
*****************************************************************
.xdef strdup

strdup:
		bsr	strlen
		addq.l	#1,d0
		bsr	xmalloc
		beq	strdup_return

		movem.l	a0-a1,-(a7)
		movea.l	a0,a1
		movea.l	d0,a0
		bsr	strcpy
		move.l	a0,d0
		movem.l	(a7)+,a0-a1
strdup_return:
		rts
*****************************************************************
* wordlistpcmp - �����񂪒P�ꃊ�X�g���̂ǂꂩ�̃p�^�[���Ƀ}�b�`
*                ���邩�ǂ����𒲂ׂ�
*
* CALL
*      A0     �P�ꃊ�X�g�̐擪�A�h���X
*      D0.W   �P�ꃊ�X�g�̒P�ꐔ
*      A1     ������
*
* RETURN
*      A0     �}�b�`�����p�^�[���̐擪�A�h���X
*      CCR    �}�b�`������̂��������Ȃ�� Z
*****************************************************************
.xdef wordlistpcmp

wordlistpcmp:
		movem.l	d0-d1,-(a7)
		move.w	d0,d1
		bra	wordlistpcmp_continue

wordlistpcmp_loop:
		moveq	#0,d0
		exg	a0,a1
		jsr	strpcmp
		exg	a0,a1
		beq	wordlistpcmp_return	*  ����̍�ƃf�B���N�g�����󂯓����

		bsr	strfor1
wordlistpcmp_continue:
		dbra	d1,wordlistpcmp_loop

		moveq	#1,d0
wordlistpcmp_return:
		movem.l	(a7)+,d0-d1
		rts
*****************************************************************

.end
