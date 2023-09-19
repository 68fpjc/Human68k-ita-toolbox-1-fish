* glob.s
* Itagaki Fumihiko 02-Sep-90  Create.

.include doscall.h
.include limits.h
.include stat.h
.include ../src/fish.h

.xref issjis
.xref strlen
.xref strbot
.xref strcmp
.xref strcpy
.xref stpcpy
.xref strmove
.xref strpcmp
.xref strfor1
.xref memmovi
.xref sort_wordlist
.xref copy_wordlist
.xref escape_quoted
.xref strip_quotes
.xref builtin_dir_match
.xref drvchkp
.xref stat
.xref check_wildcard
.xref find_shellvar
.xref get_var_value
.xref no_match
.xref too_many_words
.xref too_long_line
.xref dos_allfile
.xref builtin_table
.xref word_nonomatch

.xref tmpword1
.xref tmpword2
.xref pathname_buf

.xref tmpline
.xref flag_ciglob
.xref flag_symlinks

.text

****************************************************************
get_1char:
		move.b	(a0)+,d0
		beq	get_1char_done

		cmp.b	#'\',d0
		bne	get_1char_done

		move.b	(a0)+,d0
get_1char_done:
		rts
****************************************************************
* get_firstdir - �t�@�C��������A�h���C�u�L�q�q�i��������΁j��
*                ���[�g�E�f�B���N�g���i��������΁j�����o���D
*
* CALL
*      A0     filename (may be contains \)
*      A1     buffer
*
* RETURN
*      A0     ����
*      (A1)   ���o����������
****************************************************************
get_firstdir:
		movem.l	d0-d1/a1-a2,-(a7)
		sf	d2
get_firstdir_restart:
		movea.l	a0,a2
		bsr	get_1char
		beq	get_firstdir_done

		cmp.b	#'/',d0
		beq	get_firstdir_root

		cmp.b	#'\',d0
		beq	get_firstdir_root

		tst.b	d2
		bne	get_firstdir_done

		bsr	issjis
		beq	get_firstdir_done

		move.b	d0,d1
		bsr	get_1char
		beq	get_firstdir_done

		cmp.b	#':',d0
		bne	get_firstdir_done

		move.b	d1,(a1)+
		move.b	d0,(a1)+
		st	d2
		bra	get_firstdir_restart

get_firstdir_root:
		move.b	d0,(a1)+
		movea.l	a0,a2
get_firstdir_done:
		clr.b	(a1)
		movea.l	a2,a0
		movem.l	(a7)+,d0-d1/a1-a2
		rts
****************************************************************
* get_subdir - pathname �̍ŏ��̃f�B���N�g���������o���B
*
* CALL
*      A0     pathname
*      A1     buffer
*
* RETURN
*      A0     ���� / \/ \\ ���邢�� NUL ���w��
*      (A1)   �ŏ��̃f�B���N�g�����i������ / \/ \\ �͊܂܂Ȃ��j
*      D0.B   �j��
****************************************************************
get_subdir:
		movem.l	d1/a1,-(a7)
get_subdir_loop:
		move.b	(a0),d0
		beq	get_subdir_done

		bsr	issjis
		beq	get_subdir_dup2

		cmp.b	#'/',d0
		beq	get_subdir_done

		cmp.b	#'\',d0
		bne	get_subdir_dup

		cmpi.b	#'/',1(a0)
		beq	get_subdir_done

		cmpi.b	#'\',1(a0)
		beq	get_subdir_done

		addq.l	#1,a0
		move.b	d0,(a1)+
		move.b	(a0),d0
		beq	get_subdir_done

		bsr	issjis
		bne	get_subdir_dup
get_subdir_dup2:
		addq.l	#1,a0
		move.b	d0,(a1)+
		move.b	(a0),d0
		beq	get_subdir_done
get_subdir_dup:
		addq.l	#1,a0
		move.b	d0,(a1)+
		bra	get_subdir_loop

get_subdir_done:
		clr.b	(a1)
		movem.l	(a7)+,d1/a1
		rts
****************************************************************
* globsub
*
* CALL
*      (pathname_buf)  ��������f�B���N�g���̃p�X���DMAXPATH+1�o�C�g���K�v
*      A2     ��������t�@�C�����imay be contains \�j
*      D2.W   �ċA�̐[���D�ŏ���0
*      A3     �K�������t�@�C�������i�[����o�b�t�@���w��
*      D3.W   �W�J������̌��x
*      D4.W   �o�b�t�@�̗e��
*
* RETURN
*      D0.L   �����Ȃ�ΐ���D
*                  0: �p�X���̃f�B���N�g�����[�߂��邩�Chead����MAXHEAD�����𒴂��Ă���
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
*      A0, A1, A2     �j��
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
curdot  = -4
dirbot  = curdot-4
statbuf = dirbot-STATBUFSIZE
l_statbuf = statbuf-STATBUFSIZE

globsub:
		link	a6,#l_statbuf
		move.l	a2,curdot(a6)
		lea	pathname_buf,a0
		move.w	#MODEVAL_ALL,-(a7)
		move.l	a0,-(a7)
		pea	statbuf(a6)
		bsr	strbot
		move.l	a0,dirbot(a6)
		lea	dos_allfile,a1
		bsr	strcpy
		DOS	_FILES
		lea	10(a7),a7
		clr.b	(a0)
globsub_loop:
		tst.l	d0
		bmi	globsub_nomore

		move.b	statbuf+ST_MODE(a6),d0
		btst	#MODEBIT_DIR,d0			*  �f�B���N�g���Ȃ�
		bne	globsub_mode_ok			*  �悵

		btst	#MODEBIT_VOL,d0			*  �{�����[���E���x����
		bne	globsub_next			*  ���O
globsub_mode_ok:
		movea.l	curdot(a6),a0
		lea	tmpword2,a1
		bsr	get_subdir
		movea.l	a0,a2
		lea	statbuf+ST_NAME(a6),a0

		*  �������ꂽ�G���g���� . �Ŏn�܂��Ă��Ȃ���΁A�悵�B
		cmpi.b	#'.',(a0)
		bne	globsub_compare

		*  . �Ŏn�܂�G���g�����A
		*  ���������� . �܂��� \. �Ŏn�܂��Ă���Ȃ�΁A�悵�B
		cmpi.b	#'.',(a1)
		beq	globsub_compare

		cmpi.b	#'\',(a1)
		bne	globsub_next

		cmpi.b	#'.',1(a1)
		bne	globsub_next
globsub_compare:
		move.b	flag_ciglob(a5),d0
		bsr	strpcmp
		bmi	globsub_error4
		bne	globsub_next

		tst.b	(a2)
		beq	globsub_terminal

		movea.l	dirbot(a6),a0
		lea	statbuf+ST_NAME(a6),a1
		bsr	stpcpy
		move.b	statbuf+ST_MODE(a6),d0
		btst	#MODEBIT_DIR,d0
		bne	globsub_continue_dir

		tst.b	flag_symlinks(a5)
		beq	globsub_next

		btst	#MODEBIT_LNK,d0
		beq	globsub_next

		movem.l	a0-a1,-(a7)
		lea	pathname_buf,a0
		lea	l_statbuf(a6),a1
		bsr	stat
		movem.l	(a7)+,a0-a1
		bmi	globsub_next

		btst.b	#MODEBIT_DIR,l_statbuf+ST_MODE(a6)
		beq	globsub_next
globsub_continue_dir:
		move.b	(a2)+,d0
		cmp.b	#'\',d0
		bne	globsub_find_more

		move.b	(a2)+,d0
globsub_find_more:
		move.b	d0,(a0)+
		clr.b	(a0)
		addq.w	#1,d2
		cmp.w	#MAXDIRDEPTH,d2
		bhi	globsub_error0

		movea.l	a2,a0
		bsr	strlen
		cmp.l	#MAXHEAD,d0
		bhi	globsub_error0

		bsr	globsub				***!! �ċA !!***
		subq.w	#1,d2
		tst.l	d0
		bpl	globsub_nomore

		bra	globsub_next

globsub_terminal:
		moveq	#1,d0
		addq.w	#1,d1
		cmp.w	d3,d1
		bhi	globsub_nomore

		lea	pathname_buf,a0
		bsr	strlen
		sub.w	d0,d4		* D0.L��MAXPATH�𒴂��Ȃ����DMAXPATH��32767�ȉ��̔�
		bcs	globsub_buffer_full

		movea.l	a0,a1
		movea.l	a3,a0
		bsr	stpcpy
		movea.l	a0,a3
		lea	statbuf+ST_NAME(a6),a0
		bsr	strlen
		addq.w	#1,d0		* D0.L��MAXTAIL�𒴂��Ȃ����DMAXTAIL��22�̔�
		sub.w	d0,d4
		bcs	globsub_buffer_full

		movea.l	a0,a1
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
globsub_nomore:
		unlk	a6
		rts

globsub_error0:
		moveq	#0,d0
		bra	globsub_nomore

globsub_error4:
		moveq	#4,d0
		bra	globsub_nomore
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
*                           �p�X���̃f�B���N�g�����[�߂���C
*                           �p�X����head����MAXHEAD�����𒴂����C
*
*      D1.L   ���ʃ��[�h�͎c��o�b�t�@�e��
*             ��ʃ��[�h�͔j��
*
*      CCR    TST.L D0
*****************************************************************
.xdef glob

glob:
		movem.l	d2-d5/a0/a2-a4,-(a7)
		move.w	d0,d3			* D3.W : �ő�W�J��
		move.w	d1,d4			* D4.W : �o�b�t�@�e��
		move.w	d1,d5
		movea.l	a1,a4			* A4 : �W�J�o�b�t�@�̐擪
		movea.l	a1,a3			* A3 : �W�J�o�b�t�@
		lea	tmpword1,a1
		bsr	escape_quoted		* A1 : �N�I�[�g���G�X�P�[�v�ɑウ������������
		moveq	#0,d1			* D1.W : �K���������𓾂�

		exg	a0,a1
		bsr	builtin_dir_match
		exg	a0,a1
		beq	glob_real

		move.l	d0,d2
		addq.l	#1,d2			* D2 : �R�s�[���鉼�z�f�B���N�g�����̒���
		cmpi.b	#'\',(a1,d0.l)
		bne	glob_1

		addq.l	#1,d0
glob_1:
		cmpi.b	#'/',(a1,d0.l)
		beq	glob_builtin

		cmpi.b	#'\',(a1,d0.l)
		bne	glob_real
****************
glob_builtin:
		movem.l	a0/a4,-(a7)
		movea.l	a1,a2				*  A2 : ���z�f�B���N�g����
		lea	1(a2,d0.l),a1			*  A1 : ��r�p�^�[��
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
		sub.w	d0,d4
		bcs	glob_builtin_buffer_full
					* A0:entry     A1:pat(com)  A2:pat(top)  A3:buf
		exg	a0,a3		* A0:buf       A1:pat(com)               A3:entry
		move.l	a1,-(a7)
		movea.l	a2,a1		*              A1:pat(top)
		move.l	d2,d0
		bsr	memmovi
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
		exg	a0,a2			* A2 : ���̌���������
		movea.l	a1,a0			* A0 : �N�I�[�g���G�X�P�[�v�ɑウ������������
		lea	pathname_buf,a1
		bsr	get_firstdir
		exg	a0,a2
		exg	a0,a1
		bsr	drvchkp
		exg	a0,a1
		bmi	glob_nothing

		move.l	a0,-(a7)
		moveq	#0,d2
		bsr	globsub
		movea.l	(a7)+,a0
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
		movem.l	(a7)+,d2-d5/a0/a2-a4
		tst.l	d0
		rts

glob_nothing:
		moveq	#0,d0
		move.l	d5,d1
		bra	glob_done

glob_error:
		neg.l	d0
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
		moveq	#-1,d5			*  D5.B := no match �̂Ƃ��̃A�N�V����
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

		tst.l	d5
		bpl	glob_wordlist_glob_1

		bsr	test_nonomatch
		move.l	d0,d5
glob_wordlist_glob_1:
		beq	glob_wordlist_glob_2		*  unset nonomatch

		moveq	#1,d4				*  D4 := 1 .. ���C���h�J�[�h��������
							*             �}�b�`�����i���Ƃɂ���j
		btst	#0,d5
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
****************************************************************
* test_nonomatch - �V�F���ϐ� nonomatch �𒲂ׂ�
*
* CALL
*      none
*
* RETURN
*      D0.L   0 : unset nonomatch
*             1 : set nonomatch
*             2 : set nonomatch=drop
*      CCR    TST.L D0
****************************************************************
.xdef test_nonomatch

test_nonomatch:
		movem.l	d1/a0-a1,-(a7)
		moveq	#0,d1
		lea	word_nonomatch,a0
		bsr	find_shellvar
		beq	test_nonomatch_done		*  unset nonomatch -> 0

		moveq	#1,d1
		bsr	get_var_value
		beq	test_nonomatch_done		*  set nonomatch -> 1

		lea	word_drop,a1
		bsr	strcmp
		bne	test_nonomatch_done		*  set nonomatch=??? -> 1

		moveq	#2,d1				*  set nonomatch=drop -> 2
test_nonomatch_done:
		move.l	d1,d0
		movem.l	(a7)+,d1/a0-a1
		rts
****************************************************************
.data

word_drop:	dc.b	'drop',0

.end
