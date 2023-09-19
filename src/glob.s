* glob.s
* Itagaki Fumihiko 02-Sep-90  Create.

.include doscall.h
.include limits.h
.include stat.h
.include ../src/fish.h

.xref issjis
.xref strlen
.xref strcpy
.xref stpcpy
.xref strmove
.xref strpcmp
.xref strfor1
.xref sort_wordlist
.xref copy_wordlist
.xref escape_quoted
.xref strip_quotes
.xref strip_excessive_slashes
.xref is_slash_or_backslash
.xref drvchkp
.xref no_match
.xref too_many_words
.xref too_long_line
.xref dos_allfile
.xref builtin_table

.xref tmpword1
.xref pathname_buf
.xref doscall_pathname

.xref tmpline
.xref flag_ciglob
.xref flag_nonomatch

.text

****************************************************************
* check_wildcard - ��Ƀ��C���h�J�[�h���܂܂�Ă��邩�ǂ������ׂ�
*
* CALL
*      A0     �� (may be contains ", ', and/or \)
*
* DESCRIPTION
*      ��Ƀ��C���h�J�[�h���܂܂�Ă��邩�ǂ������ׁA���������
*      �ŏ��Ɍ����������C���h�J�[�h������Ԃ��A������� 0 ��
*      �Ԃ��B
*
* RETURN
*      D0.L   ���ʃo�C�g�͍ŏ��Ɍ����������C���h�J�[�h����
*      CCR    TST.L D0
****************************************************************
.xdef check_wildcard

check_wildcard:
		movem.l	d1/a0,-(a7)
		moveq	#0,d1
check_wildcard_loop:
		move.b	(a0)+,d0
		beq	no_wildcard

		bsr	issjis
		beq	check_wildcard_skip1

		tst.b	d1
		beq	check_wildcard_1

		cmp.b	d1,d0
		bne	check_wildcard_loop
check_wildcard_quote:
		eor.b	d0,d1
		bra	check_wildcard_loop

check_wildcard_1:
		cmp.b	#'*',d0
		beq	check_wildcard_done

		cmp.b	#'?',d0
		beq	check_wildcard_done

		cmp.b	#'[',d0
		beq	check_wildcard_done

		cmp.b	#'"',d0
		beq	check_wildcard_quote

		cmp.b	#"'",d0
		beq	check_wildcard_quote

		cmp.b	#'\',d0
		bne	check_wildcard_loop

		move.b	(a0)+,d0
		beq	no_wildcard

		bsr	issjis
		bne	check_wildcard_loop
check_wildcard_skip1:
		move.b	(a0)+,d0
		bne	check_wildcard_loop
no_wildcard:
		moveq	#0,d0
		bra	check_wild_return

check_wildcard_done:
		moveq	#-1,d1
		move.b	d0,d1
		exg	d0,d1
check_wild_return:
		movem.l	(a7)+,d1/a0
		tst.l	d0
		rts
****************************************************************
.xdef get_1char

get_1char:
		move.b	(a2)+,d0
		cmp.b	#'\',d0
		bne	get_1char_done

		move.b	(a2)+,d0
get_1char_done:
		tst.b	d0
		rts
****************************************************************
copychar:
		move.l	d1,-(a7)
		move.l	d0,d1
		beq	copychar_done

copychar_loop:
		bsr	get_1char
		move.b	d0,(a0)+
		subq.l	#1,d1
		bne	copychar_loop
copychar_done:
		move.l	(a7)+,d1
		rts
****************************************************************
glob_skip_slashes:
		move.l	d1,-(a7)
		moveq	#0,d1
		subq.l	#4,a7
glob_skip_slashes_loop:
		move.l	a2,(a7)
		addq.l	#1,d1
		bsr	get_1char
		bsr	is_slash_or_backslash
		beq	glob_skip_slashes_loop

		subq.l	#1,d1
		move.l	d1,d0
		movea.l	(a7)+,a2
		move.l	(a7)+,d1
		rts
****************************************************************
* globsub
*
* CALL
*      (pathname_buf)  ��������f�B���N�g���̃p�X���D
*                      MAXPATH+1�o�C�g�̗e�ʂ��K�v�D
*      A0     pathname_buf�ɃZ�b�g���ꂽ������̃P�c
*      A2     ��������t�@�C�����imay be contains \�j
*      D2.W   �ċA�̐[���D�ŏ���0
*      A3     �K�������t�@�C�������i�[����o�b�t�@���w��
*      D3.W   �W�J������̌��x
*      D4.W   �o�b�t�@�̗e��
*
* RETURN
*      D0.L   �����Ȃ�ΐ���D
*                  0: �p�X���̃f�B���N�g�����[�߂��� or �p�X�������߂���
*                  1: �ő�ꐔ�𒴂���
*                  2: �o�b�t�@�̗e�ʂ�����Ȃ�
*                  4: ���̑��̃G���[�B�i] ���Ȃ��Ȃǁj���b�Z�[�W���\�������B
*
*      D1.W   �K��������������������
*             D1>D3 �ƂȂ����� D0.L �� 1 ���Z�b�g���ď����𒆎~����
*
*      D4.W   �o�b�t�@�ɒǉ�������������������
*             ����Ȃ��Ȃ����� D0.L �� 2 ���Z�b�g���ď����𒆎~����
*
*      A3     �o�b�t�@�̎��̊i�[�ʒu
*
*      D5/A0-A2     �j��
*
* NOTE
*      33��߂܂ōċA����D�X�^�b�N�ɒ��ӁI
*
*      �Q�l�܂łɏ����Ă����ƁCHuman68k�ł́C��΃p�X���̃f�B���N�g����
*      �i�h���C�u���͊܂܂Ȃ��D�ŏ��� / ����Ō�� / �܂Łj�̒����́C
*      �ő�64�����Ƃ�������������D
*      �Ƃ������Ƃ́C���[�g�E�f�B���N�g����1���Ƃ���ƁC�T�u�f�B���N�g����
*      31���܂ł��������D�i32�����ƁC�����t�@�C�������L�q�ł��Ȃ��j
*      ���������āC32��̃f�B���N�g��������1��̃t�@�C�������C���Ȃ킿�C33��
*      �̍ċA�ŏ[���Ȕ��ł���D
*
*      �Ȃ��C��΃p�X�͐������ł����Ă��C���΃p�X���Ɛ����𒴂���ꍇ������
*      ���C����͔F�߂��C���΃p�X�ł����Ă���΃p�X�̐��������̂܂ܓK�p����
*      ���Ƃɂ����D�i�X�^�b�N��o�b�t�@��ÓI�Ɉ��S�Ɋm�ۂ��邽�߁j
****************************************************************
curdot   = -4
curbot   = curdot-4
slashlen = curbot-4
dirlen   = slashlen-4
statbuf  = dirlen-STATBUFSIZE

globsub:
		link	a6,#statbuf

		move.l	a2,curdot(a6)
scan_subdir:
		move.l	a2,curbot(a6)
		bsr	get_1char
		beq	scan_subdir_done

		bsr	is_slash_or_backslash
		beq	scan_subdir_done

		bsr	issjis
		bne	scan_subdir

		tst.b	(a2)+
		bne	scan_subdir

		subq.l	#1,a2
scan_subdir_done:
		movea.l	curbot(a6),a2
		bsr	glob_skip_slashes
		move.l	d0,slashlen(a6)
		*
		move.l	a0,d0
		lea	pathname_buf,a1
		sub.l	a1,d0
		cmp.l	#MAXHEAD,d0
		bhi	globsub_error0

		move.l	d0,dirlen(a6)
		lea	doscall_pathname,a0
		bsr	stpcpy
		lea	dos_allfile,a1
		bsr	strcpy
		lea	doscall_pathname,a0
		bsr	strip_excessive_slashes
		move.w	#MODEVAL_ALL,-(a7)
		move.l	a0,-(a7)
		pea	statbuf(a6)
		DOS	_FILES
		lea	10(a7),a7
globsub_loop:
		tst.l	d0
		bmi	globsub_return

		move.b	statbuf+ST_MODE(a6),d0
		btst	#MODEBIT_DIR,d0			*  �f�B���N�g���Ȃ�
		bne	globsub_mode_ok			*  �悵

		btst	#MODEBIT_VOL,d0			*  �{�����[���E���x����
		bne	globsub_next			*  ���O
globsub_mode_ok:
		lea	statbuf+ST_NAME(a6),a0
		movea.l	curdot(a6),a1
		cmpi.b	#'.',(a0)
		bne	globsub_compare

		cmpi.b	#'.',(a1)
		beq	globsub_compare

		cmpi.b	#'\',(a1)
		bne	globsub_next

		cmpi.b	#'.',1(a1)
		bne	globsub_next
globsub_compare:
		movea.l	curbot(a6),a2
		move.b	(a2),d5
		clr.b	(a2)
		move.b	flag_ciglob(a5),d0
		bsr	strpcmp
		move.b	d5,(a2)
		tst.l	d0
		bmi	globsub_error4
		bne	globsub_next

		bsr	strlen
		add.l	slashlen(a6),d0
		add.l	dirlen(a6),d0
		cmp.l	#MAXPATH,d0
		bhi	globsub_error0

		movea.l	a0,a1
		lea	pathname_buf,a0
		add.l	dirlen(a6),a0
		bsr	stpcpy
		move.l	slashlen(a6),d0
		bsr	copychar
		clr.b	(a0)
		tst.b	(a2)
		beq	globsub_terminal

		addq.w	#1,d2
		cmp.w	#MAXDIRDEPTH,d2
		bhi	globsub_error0

		bsr	globsub				***!! �ċA !!***
		subq.w	#1,d2
		tst.l	d0
		bpl	globsub_return
		bra	globsub_next

globsub_terminal:
		moveq	#1,d0
		addq.w	#1,d1
		cmp.w	d3,d1
		bhi	globsub_return

		lea	pathname_buf,a1
		move.l	a0,d0
		addq.l	#1,d0
		sub.l	a1,d0
		sub.l	d0,d4
		bcs	globsub_buffer_full

		movea.l	a3,a0
		bsr	strmove
		movea.l	a0,a3
globsub_next:
		pea	statbuf(a6)
		DOS	_NFILES
		addq.l	#4,a7
		bra	globsub_loop

globsub_buffer_full:
		moveq	#2,d0
globsub_return:
		unlk	a6
		rts

globsub_error0:
		moveq	#0,d0
		bra	globsub_return

globsub_error4:
		moveq	#4,d0
		bra	globsub_return
****************************************************************
* glob - evaluate filename with wildcard
*
* CALL
*      A0     ���C���h�J�[�h���܂ރt�@�C�����D', " and/or \ �ɂ��N�I�[�g����
*      A1     �K�������t�@�C�������i�[����o�b�t�@���w��
*      D0.W   �W�J������̌��x
*      D1.W   �o�b�t�@�̗e��
*
* RETURN
*      A1     �o�b�t�@�̎��̊i�[�ʒu
*
*      D0.L   �����Ȃ�ΐ����D���ʃ��[�h�͓K���������D
*             �����Ȃ�΃G���[�D
*                  -1  �K��������̂̌������x�𒴂���
*                  -2  �o�b�t�@�̗e�ʂ𒴂���
*                  -4  ���̑��̃G���[�D���b�Z�[�W���\�������D
*                           �p�X���̃f�B���N�g�����[�߂��� or �p�X�������߂���D
*
*      D1.L   ���ʃ��[�h�͎c��o�b�t�@�e��
*             ��ʃ��[�h�͔j��
*
*      CCR    TST.L D0
*****************************************************************
.xdef glob

glob:
		movem.l	d2-d6/a0/a2-a4,-(a7)
		move.w	d0,d3			* D3.W : �ő�W�J��
		moveq	#0,d4
		move.w	d1,d4			* D4.L : �o�b�t�@�e��
		move.w	d1,d5
		movea.l	a1,a4			* A4 : �W�J�o�b�t�@�̐擪
		movea.l	a1,a3			* A3 : �W�J�o�b�t�@
		lea	tmpword1,a1
		bsr	escape_quoted		* A1 : �N�I�[�g���G�X�P�[�v�ɑウ������������
		moveq	#0,d1			* D1.W : �K���������𓾂�

		movea.l	a1,a2
		bsr	get_1char
		cmp.b	#'~',d0
		bne	glob_real

		bsr	get_1char
		cmp.b	#'~',d0
		bne	glob_real

		bsr	get_1char
		bsr	is_slash_or_backslash
		bne	glob_real
****************
glob_builtin:
		bsr	glob_skip_slashes
		addq.l	#3,d0				*  3 == strlen("~~/")
		move.l	d0,d2
		exg	a1,a2
		movem.l	a0/a4,-(a7)
		lea	builtin_table,a4
glob_builtin_loop:
		move.l	(a4),d0
		beq	glob_builtin_nomore

		movea.l	d0,a0
		moveq	#0,d0				*  case dependent
		bsr	strpcmp
		tst.l	d0
		bmi	glob_builtin_error4
		bne	glob_builtin_continue

		moveq	#1,d0
		addq.w	#1,d1
		cmp.w	d3,d1
		bhi	glob_builtin_done

		bsr	strlen
		add.l	d2,d0
		addq.l	#1,d0
		sub.l	d0,d4
		bcs	glob_builtin_buffer_full
					* A0:entry     A1:pat(com)  A2:pat(top)  A3:buf
		exg	a0,a3		* A0:buf       A1:pat(com)               A3:entry
		move.l	d2,d0
		move.l	a2,-(a7)
		bsr	copychar
		movea.l	(a7)+,a2
		move.l	a1,-(a7)
		movea.l	a3,a1		*              A1:entry
		bsr	strmove
		movea.l	(a7)+,a1	*              A1:pat(com)
		exg	a0,a3		* A0:entry                               A3:buf
glob_builtin_continue:
		lea	10(a4),a4
		bra	glob_builtin_loop

glob_builtin_error4:
		moveq	#4,d0
		bra	glob_builtin_done

glob_builtin_buffer_full:
		moveq	#2,d0
		bra	glob_builtin_done

glob_builtin_nomore:
		moveq	#-1,d0
glob_builtin_done:
		movem.l	(a7)+,a0/a4
		tst.l	d0
		beq	glob_nothing
		bpl	glob_error

		moveq	#0,d0
		move.w	d1,d0
		movea.l	a4,a0
		bra	glob_done
****************
glob_real:
						* A0 : ���̌���������
		movea.l	a1,a2			* A2 : �N�I�[�g���G�X�P�[�v�ɑウ������������
		lea	pathname_buf,a1
		movem.l	d1/a0,-(a7)
		moveq	#MAXPATH,d6
		movea.l	a2,a0
		bsr	get_1char
		beq	get_firstdir_done

		bsr	is_slash_or_backslash
		beq	copy_root

		bsr	issjis
		beq	get_firstdir_done

		move.b	d0,d1
		bsr	get_1char
		cmp.b	#':',d0
		bne	get_firstdir_done

		subq.l	#2,d6
		bcs	get_firstdir_error

		move.b	d1,(a1)+
		move.b	d0,(a1)+
copy_root_loop:
		movea.l	a2,a0
		bsr	get_1char
		bsr	is_slash_or_backslash
		bne	get_firstdir_done
copy_root:
		subq.l	#1,d6
		bcs	get_firstdir_error

		move.b	d0,(a1)+
		bra	copy_root_loop

get_firstdir_done:
		clr.b	(a1)
		movea.l	a0,a2
		cmp.w	d6,d6
get_firstdir_error:
		movem.l	(a7)+,d1/a0
		bcs	glob_error_1

		bclr	#31,d0
		move.l	a0,-(a7)
		lea	pathname_buf,a0
		bsr	drvchkp
		movea.l	(a7)+,a0
		bmi	glob_nothing

		movem.l	d5/a0,-(a7)
		movea.l	a1,a0
		moveq	#0,d2
		bsr	globsub
		movem.l	(a7)+,d5/a0
		tst.l	d0
		beq	glob_nothing
		bpl	glob_error

		moveq	#0,d0
		move.w	d1,d0
		movea.l	a4,a0
		bsr	sort_wordlist
glob_done:
		movea.l	a3,a1
		move.w	d4,d1
		movem.l	(a7)+,d2-d6/a0/a2-a4
		tst.l	d0
		rts

glob_nothing:
		moveq	#0,d0
		move.l	d5,d1
		bra	glob_done

glob_error:
		neg.l	d0
		bra	glob_done

glob_error_1:
		moveq	#-1,d0
		bra	glob_done
****************************************************************
* glob_wordlist - �������т̊e��ɂ��ăt�@�C�����W�J������
*                 ���łɃN�I�[�g���O���Ă��܂�
*
* CALL
*      A0     �i�[�̈�̐擪�D�������тƏd�Ȃ��Ă��Ă��ǂ��D
*      A1     �������т̐擪
*      D0.W   �ꐔ
*
* RETURN
*      D0.L   �����Ȃ�ΐ����D���ʃ��[�h�͓W�J��̌ꐔ
*             �����Ȃ�΃G���[
*
*      (tmpline)   �j�󂳂��
*      (A0)   �j��
*
*      CCR    TST.L D0
****************************************************************
.xdef glob_wordlist

glob_wordlist:
		movem.l	d1-d5/a0-a2,-(a7)
		move.w	#MAXWORDLISTSIZE,d1	*  D1 : �ő啶����
		move.w	d0,d2			*  D2 : �����J�E���^
		moveq	#0,d3			*  D3 : �W�J��̌ꐔ
		moveq	#0,d4			*  D4 : glob status := 0 .. ���C���h�J�[�h�͂܂��Ȃ�
		moveq	#-1,d5			*  D5.W := no match �̂Ƃ��̃A�N�V����
		move.l	a0,-(a7)
		lea	tmpline(a5),a0		*  �ꎞ�̈��
		bsr	copy_wordlist		*  �������т���U�R�s�[���Ă�����\�[�X�Ƃ���
		movea.l	(a7)+,a1
		bra	glob_wordlist_continue

glob_wordlist_loop:
		bsr	check_wildcard
		beq	glob_wordlist_just_copy

		*  ���C���h�J�[�h������

		move.w	#MAXWORDS,d0
		sub.w	d3,d0
		bsr	glob
		bmi	glob_wordlist_glob_error	*  error
		bne	glob_wordlist_glob_found	*  match found

		*  no match

		tst.w	d5
		bpl	glob_wordlist_glob_1

		moveq	#0,d5
		move.b	flag_nonomatch(a5),d5
glob_wordlist_glob_1:
		beq	glob_wordlist_glob_2		*  unset nonomatch

		moveq	#1,d4				*  D4 := 1 .. ���C���h�J�[�h��������
							*             �}�b�`�����i���Ƃɂ���j
		cmp.b	#1,d5
		bne	glob_wordlist_just_copy		*  set nonomatch .. �P����R�s�[����
		*  set nonomatch=drop .. �P����̂Ă�
glob_wordlist_glob_2:
		*  unset nonomatch .. �P����̂Ă�
		tst.l	d4
		bne	glob_wordlist_glob_next

		moveq	#-1,d4				*  D4 := -1 .. ���C���h�J�[�h��������
							*              �}�b�`������̂͂܂��Ȃ�
		bra	glob_wordlist_glob_next

glob_wordlist_glob_found:
		add.w	d0,d3
		moveq	#1,d4				*  D4 := 1 .. ���C���h�J�[�h��������
							*             �}�b�`����
glob_wordlist_glob_next:
		bsr	strfor1
		bra	glob_wordlist_continue

glob_wordlist_just_copy:
		movea.l	a0,a2
		bsr	strfor1
		exg	a0,a2
		bsr	strip_quotes
		bsr	strlen
		addq.w	#1,d0
		sub.w	d0,d1
		bmi	glob_wordlist_too_long_line

		cmp.w	#MAXWORDS,d3
		bhs	glob_wordlist_too_many_words

		addq.w	#1,d3
		exg	a0,a1
		bsr	strmove
		exg	a0,a1
		movea.l	a2,a0
glob_wordlist_continue:
		dbra	d2,glob_wordlist_loop

		tst.l	d4
		bmi	glob_wordlist_no_match

		moveq	#0,d0
		move.w	d3,d0
glob_wordlist_return:
		movem.l	(a7)+,d1-d5/a0-a2
		tst.l	d0
		rts

glob_wordlist_glob_error:
		cmp.w	#-1,d0
		beq	glob_wordlist_too_many_words

		cmp.w	#-2,d0
		beq	glob_wordlist_too_long_line

		bra	glob_wordlist_error

glob_wordlist_no_match:
		bsr	no_match
		bra	glob_wordlist_error

glob_wordlist_too_many_words:
		bsr	too_many_words
		bra	glob_wordlist_error

glob_wordlist_too_long_line:
		bsr	too_long_line
glob_wordlist_error:
		moveq	#-1,d0
		bra	glob_wordlist_return

.end
