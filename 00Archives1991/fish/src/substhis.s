* substhis.s
* Itagaki Fumihiko 29-Jul-90  Create.

.include ../src/fish.h
.include ../src/modify.h

.xref strmem
.xref for1str
.xref isdigit
.xref eputs
.xref enputs
.xref fornstrs
.xref modify
.xref strlen
.xref memmove_inc
.xref too_long_line
.xref free
.xref issjis
.xref find_shellvar
.xref scanchar2
.xref isspace
.xref strchr
.xref prev_search
.xref his_nlines_now
.xref hiswork
.xref his_end
.xref memcmp
.xref atou
.xref his_toplineno
.xref syntax_error
.xref pre_perror
.xref msg_too_large_number
.xref itoa
.xref skip_space
.xref ecputs
.xref msg_colon_blank
.xref str_nul

****************************************************************
* wordlistmem - �P����т��炠�镶�����T���o��
*
* CALL
*      A0     �P����т̐擪�A�h���X
*      D0.W   �P�ꐔ
*      A1     ����������̐擪�A�h���X
*      D1.L   ����������̒���
*      D2.B   0 �ȊO�Ȃ�� ANK�p�����̑啶���Ə���������ʂ��Ȃ�
*
* RETURN
*      D0.W   �c��P�ꐔ�i���������P����܂ށj
*             0 �Ȃ猩����Ȃ�����
*      A0     ���������A�h���X�D������Ȃ����0
*      D2.L   ���������P��̔ԍ�
****************************************************************
.xdef wordlistmem

wordlistmem:
		movem.l	d1/d3-d4,-(a7)
		move.l	d1,d4				* D4.W : ����������̒���
		move.b	d2,d1				* D1.B : case independent flag
		move.w	d0,d3				* D3.W : �P�ꐔ
		moveq	#0,d2				* D2.L : �P��ԍ��J�E���^
		bra	wordlistmem_continue

wordlistmem_loop:
		move.l	d4,d0
		bsr	strmem				* �������T��
		bne	wordlistmem_done		* ��������

		bsr	for1str
		addq.l	#1,d2
wordlistmem_continue:
		dbra	d3,wordlistmem_loop

		moveq	#0,d0
wordlistmem_done:
		movea.l	d0,a0
		move.w	d3,d0
		addq.w	#1,d0
		movem.l	(a7)+,d1/d3-d4
		rts
****************************************************************
.xdef backup_history

backup_history:
		tst.l	d0
		beq	backup_done

		move.l	d0,-(a7)
backup_loop:
		suba.w	-2(a0),a0			* �|�C���^��O�̍s�Ɉړ��@�i�������j
		subq.l	#1,d0
		bne	backup_loop

		move.l	(a7)+,d0
backup_done:
		rts
****************************************************************
* parse_word_selecter - �P��I���q����͂���
*
* CALL
*      A0     ��͂��镶����̃A�h���X
*
* RETURN
*      A0     ��͂��I�����ʒu��Ԃ�
*      D0.L   �͈͂���ł��G���[�łȂ��P�[�X�Ȃ�� 0�A�����Ȃ��� 1
*      D1.L   �n�_�P��ԍ�
*      D2.L   �I�_�P��ԍ�
*      CCR    TST.L D0
*
*      D1.L �� D2.L �́A���Ȃ�ΒP��I���q�������Ă���P��ԍ��ł��邪�A
*      �P��ԍ������l�ŋL�q����Ă���A���̒l�� MAXWORDS-1 �𒴂��Ă���
*      �ꍇ�ɂ� MAXWORDS ��Ԃ��B
*
*      ���Ȃ�Ύ��̒P��������B
*             -1: �Ō�̒P��
*             -2: �Ō��1�O�̒P��
*             -3: ?str? �Ɉ�v�����P��
*
* DESCRIPTION
*							�͈͂���Ȃ�c
*	�Ȃ�		�ŏ�(0�Ԗ�)����Ō�܂�		�@�󕶎���
*	:*		1�Ԗڂ���Ō�܂�		�@�󕶎���
*	:*-*		1�Ԗڂ���Ō�܂�		�@�󕶎���
*	:-*		�ŏ�(0�Ԗ�)����Ō�܂�		�@�󕶎���
*	:<N>*		N�Ԗڂ���Ō�܂�		�@�󕶎���
*	:<N>-*		N�Ԗڂ���Ō�܂�		�@�󕶎���
*	:-		�ŏ�(0�Ԗ�)����Ō��1�O�܂�	�@�G���[
*	:-<N>		�ŏ�(0�Ԗ�)����N�Ԗڂ܂�	�@�G���[
*	:*-		1�Ԗڂ���Ō��1�O�܂�	�@�G���[
*	:*-<M>		1�Ԗڂ���M�Ԗڂ܂�		�@�G���[
*	:<N>		N�Ԗ�				�@�G���[
*	:<N>-		N�Ԗڂ���Ō��1�O�܂�	�@�G���[
*	:<N>-<M>	N�Ԗڂ���M�Ԗڂ܂�		�@�G���[
*
*	N,M:
*		<n>	n�Ԗڂ̒P��		(n)
*		^	1�Ԗڂ̒P��		(1)
*		$	�Ō�̒P��		(-1)
*		%	?str? �Ɉ�v�����P��	(-3)
*
*       �P��I���q�� ^, $, *, -, % �Ŏn�܂��Ă���ꍇ�ɂ�
*       : �͏ȗ����邱�Ƃ��ł���
****************************************************************
parse_word_selecter:
		moveq	#0,d1				* �n�_�P��ԍ� :=  0 : �ŏ�����
		moveq	#-1,d2				* �I�_�P��ԍ� := -1 : �Ō�܂�
		moveq	#0,d0
		move.b	(a0)+,d0
		bsr	is_special_word_selecter
		bne	get_word_selecter

		cmp.b	#':',d0
		beq	parse_word_selecter_1

		subq.l	#1,a0
		bra	parse_word_selecter_done_0

parse_word_selecter_1:
		move.b	(a0)+,d0
		bsr	isdigit
		beq	get_word_selecter

		bsr	is_special_word_selecter
		bne	get_word_selecter

		subq.l	#2,a0
		bra	parse_word_selecter_done_0
****************
get_word_selecter:
		cmp.b	#'*',d0
		beq	parse_word_selecter_asterisk

		cmp.b	#'-',d0
		beq	get_wordno2

		bsr	get_wordno			* �n�_�P��ԍ��𓾂�
		move.b	(a0)+,d0
		cmp.b	#'*',d0
		beq	parse_word_selecter_done_0

		cmp.b	#'-',d0
		beq	get_wordno2

		move.l	d1,d2				* �I�_�P��ԍ� := �n�_�P��ԍ�
		subq.l	#1,a0
		bra	parse_word_selecter_done_1

parse_word_selecter_asterisk:
		moveq	#1,d1				* �n�_�P��ԍ� := 1�Ԗ�
		move.b	(a0)+,d0
		cmp.b	#'-',d0
		beq	get_wordno2

		subq.l	#1,a0
		bra	parse_word_selecter_done_0

get_wordno2:
		move.b	(a0)+,d0
		cmp.b	#'*',d0
		beq	parse_word_selecter_done_0

		exg	d1,d2
		bsr	get_wordno			* �I�_�P��ԍ��𓾂�
		exg	d1,d2
parse_word_selecter_done_1:
		moveq	#1,d0
		rts

parse_word_selecter_done_0:
		moveq	#0,d0
		rts
****************************************************************
fix_wordno:
		cmp.l	#-1,d0
		beq	fix_wordno_last_word

		cmp.l	#-2,d0
		beq	fix_wordno_last_of_last

		cmp.l	#-3,d0
		bne	fix_wordno_test

		move.l	d4,d0
fix_wordno_test:
		cmp.l	d3,d0			* hs (D0 >= D3 || D0 < 0) �Ȃ�΃G���[
		rts

fix_wordno_last_word:
		move.l	d3,d0
		subq.l	#1,d0
		bra	fix_wordno_test

fix_wordno_last_of_last:
		move.l	d3,d0
		subq.l	#2,d0
		bra	fix_wordno_test
*****************************************************************
* expand_history - ! �W�J���s��
*
* CALL
*      A0     �C�x���g�̒P�����
*      D0.W   �C�x���g�̒P�ꐔ
*      A1     �W�J�o�b�t�@�̃A�h���X
*      D1.W   �W�J�o�b�t�@�̗e��
*      A2     �P��I���q�ƒP��C���q���n�܂�A�h���X
*      D2.L   �P��I���q % �̒P��ԍ��i-1:�Y���Ȃ��j
*      D3.L   �u���X�e�[�^�X
*             bit1 : �G���[�E���b�Z�[�W��\�����Ȃ�
*             bit4 : ^str1^str2^flag^ �̓W�J�ł���
*
* RETURN
*      A1     �i�[�����������i��
*      A2     �P��C���q�̎��ɐi��
*      D1.W   �W�J�o�b�t�@�̎c��e��
*      D0.L   �u���X�e�[�^�X
*             bit0 : ���s���Ȃ�
*             bit1 : �\�������s�����Ȃ�
*             bit2 : �o�^���\�������s�����Ȃ�
*****************************************************************
expand_history:
		movem.l	d2-d5/d7/a0,-(a7)
		move.l	d3,d7				*  D7.L : �u���X�e�[�^�X
		btst	#4,d7
		bne	expand_history_modify

		move.l	d1,-(a7)
		moveq	#0,d3
		move.l	d0,d3				*  D3.L : ���̃C�x���g�̒P�ꐔ
		move.l	d2,d4				*  D4.L : % �̒P��ԍ��i-1:�Y���Ȃ��j
		exg	a0,a2
		bsr	parse_word_selecter		*  D1.L : �n�_�ԍ�  D2.L : �I�_�ԍ�
		exg	a0,a2
		move.b	d0,d5				*  D5.B : �u�͈͂���ł��n�j�v�t���O
		move.l	d1,d0
		bsr	fix_wordno
		bhs	expand_history_word_range_empty

		move.l	d2,d1
		exg	d0,d1
		bsr	fix_wordno
		exg	d0,d1
		bhs	expand_history_word_range_empty

		sub.l	d0,d1
		bcc	expand_history_word_range_ok
expand_history_word_range_empty:
		tst.b	d5
		beq	expand_history_empty_range

		btst	#1,d7
		bne	expand_history_empty_range

		lea	msg_subst,a0
		bsr	eputs
		lea	msg_bad_word_selecter,a0
		bsr	enputs
		or.b	#%11,d7
expand_history_empty_range:
		moveq	#0,d0
		moveq	#-1,d1
expand_history_word_range_ok:
		addq.w	#1,d1				*  D1.W : �擾�P�ꐔ
		bsr	fornstrs			*  A0 : �擾�P�����
		move.w	d1,d0				*  D0.W : �擾�P�ꐔ
		move.l	(a7)+,d1
****************
*
*  A0     �P�����
*  D0.W   �P�ꐔ
*  A1     �W�J�o�b�t�@�̃A�h���X
*  D1.W   �o�b�t�@�e��
*  A2     �P��C���q���n�܂�A�h���X
*  D7     �u���X�e�[�^�X
*
expand_history_modify:
		moveq	#0,d4
		move.w	d1,d4				*  D4.L : �o�b�t�@�e��
		move.w	d0,d1				*  D1.W : �擾�P�ꐔ
		exg	a1,a2
		move.w	#%100000000,d0
		btst	#1,d7
		beq	expand_history_modify_1

		bset	#MODIFYSTATBIT_ERROR,d0
expand_history_modify_1:
		btst	#4,d7
		beq	expand_history_modify_2

		bset	#MODIFYSTATBIT_QUICK,d0
expand_history_modify_2:
		bsr	modify
		move.l	a0,d3				*  D3.L : �C�����ꂽ�P����т̐擪�A�h���X
		move.l	d0,d2				*  D2.L : �C���X�e�[�^�X
		btst	#MODIFYSTATBIT_ERROR,d2
		beq	expand_history_modify_noerror

		or.b	#%11,d7
expand_history_modify_noerror:
		btst	#MODIFYSTATBIT_NOMEM,d2
		bne	expand_history_fatal_error

		btst	#MODIFYSTATBIT_OVFLO,d2
		bne	expand_history_over

		exg	a1,a2
		subq.w	#1,d1
		bcs	expand_history_ok
		bra	expand_history_start

expand_history_nullword:
		addq.l	#1,a0
		subq.w	#1,d1
		bcs	expand_history_ok

		bra	expand_history_start

expand_history_loop:
		addq.l	#1,a0
		subq.w	#1,d4
		bcs	expand_history_over

		move.b	#' ',(a1)+			* �󔒂ŋ�؂�
expand_history_start:
		bsr	strlen
		tst.l	d0
		beq	expand_history_nullword

		sub.l	d0,d4
		bcs	expand_history_over

		exg	a0,a1
		bsr	memmove_inc
		exg	a0,a1
		dbra	d1,expand_history_loop
expand_history_ok:
		moveq	#0,d0
		bra	expand_history_done

expand_history_over:
		bsr	too_long_line
expand_history_fatal_error:
		or.b	#%111,d7
expand_history_done:
		btst	#MODIFYSTATBIT_MALLOC,d2
		beq	expand_history_not_free

		exg	d0,d3
		bsr	free
		exg	d0,d3
expand_history_not_free:
		btst	#MODIFYSTATBIT_FAILED,d2
		beq	expand_history_not_failed

		btst	#1,d7
		bne	expand_history_not_failed

		lea	msg_modifier_failed,a0
		bsr	enputs
		or.b	#%11,d7
expand_history_not_failed:
		btst	#MODIFYSTATBIT_P,d2
		beq	expand_history_not_p

		bset	#0,d7
expand_history_not_p:
		move.w	d4,d1
****************
		move.l	d7,d0
		movem.l	(a7)+,d2-d5/d7/a0
		rts
****************************************************************
get_histchar:
		move.b	(a0)+,d0
		beq	get_histchar_return

		bsr	issjis
		bne	get_histchar_return

		lsl.w	#8,d0
		move.b	(a0)+,d0
		bne	get_histchar_return

		clr.w	d0
get_histchar_return:
		rts
****************************************************************
* get_histchars - ���s�� !^ �u�������𓾂�
*
* CALL
*      none
*
* RETURN
*      D0.L   ���ʃ��[�h�� ! �u�������P
*             ��ʃ��[�h�� ^ �u�������Q
****************************************************************
get_histchars:
		move.l	a0,-(a7)
		lea	word_histchars,a0
		bsr	find_shellvar
		beq	get_histchars_default

		moveq	#0,d0
		addq.l	#2,a0
		tst.w	(a0)+
		beq	get_histchars_done

		bsr	for1str

		bsr	get_histchar
		beq	get_histchars_done

		swap	d0
		bsr	get_histchar
		swap	d0
get_histchars_done:
		movea.l	(a7)+,a0
		rts

get_histchars_default:
		move.l	#('^'<<16)|'!',d0
		bra	get_histchars_done
****************************************************************
compare_histchar:
		movea.l	a2,a3
		exg	a0,a3
		bsr	scanchar2
		exg	a0,a3
		cmp.w	d1,d0
		rts
*****************************************************************
* subst_history - ! �u�����s��
*
* CALL
*      A0     �\�[�X������A�h���X
*      A1     �W�J�o�b�t�@�̐擪�A�h���X
*      A2     �Q�Ƃ���P����т̃A�h���X�D0 �Ȃ�Η����C�x���g���Q�Ƃ���
*      D1.W   �W�J�o�b�t�@�̗e��
*      D2.W   �Q�Ƃ���P����т̒P�ꐔ�iA2 �� 0 �łȂ��Ƃ��j
*
* RETURN
*      A0     �\�[�X������̍Ō�� NUL �̎����w��
*      A1     �o�b�t�@�̎��̊i�[�ʒu���w��
*      D1.W   �W�J�o�b�t�@�̎c��e��
*      D0.B   �u���X�e�[�^�X
*             bit0 : ���s���Ȃ�
*             bit1 : �\�������s�����Ȃ�
*             bit2 : �o�^���\�������s�����Ȃ�
*             bit3 : �u�����s��ꂽ
*****************************************************************
.xdef subst_history

itoabuf = -12
histchar = itoabuf-2
braceflag = histchar-1
istr_flag = braceflag-1
quick_modify = istr_flag-1
subst_status = quick_modify-1
pad = subst_status

subst_history:
		link	a6,#pad
		movem.l	d2-d7/a2-a4,-(a7)
		movea.l	a2,a4				* A4 : �Q�ƒP�����
		move.w	d2,d4				* D4.W : �Q�ƒP�ꐔ
		movea.l	a0,a2				* A2 : �\�[�X
		move.w	d1,d7				* D7.W : �W�J�o�b�t�@�̗e��
		clr.b	subst_status(a6)

		bsr	get_histchars
		move.w	d0,histchar(a6)
subst_history_dup_first_blank_loop:
		move.b	(a2)+,d0
		bsr	isspace
		bne	subst_history_dup_first_blank_done

		subq.w	#1,d7
		bcs	subst_hist_over

		move.b	d0,(a1)+
		bra	subst_history_dup_first_blank_loop

subst_history_dup_first_blank_done:
		subq.l	#1,a2
		swap	d0
		move.w	d0,d1
		bsr	compare_histchar
		bne	subst_history_loop

		move.b	#1,quick_modify(a6)
		clr.b	braceflag(a6)
		bra	default_event_1
********************************
subst_history_loop:
		move.b	(a2)+,d0
		beq	subst_history_dup1

		cmp.b	#'\',d0
		beq	escape

		subq.l	#1,a2
		move.w	histchar(a6),d1
		bsr	compare_histchar
		bne	subst_history_dup_char

		move.b	(a3),d0
		beq	subst_history_dup_char

		bsr	isspace
		beq	subst_history_dup_char

		cmp.b	#'=',d0
		beq	subst_history_dup_char

		cmp.b	#'~',d0
		beq	subst_history_dup_char

		cmp.b	#'(',d0
		beq	subst_history_dup_char

		cmp.b	#'\',d0
		beq	subst_history_dup_char

		clr.b	quick_modify(a6)
		movea.l	a3,a2
		move.b	d0,braceflag(a6)
		cmp.b	#'{',d0
		bne	subst_hist_nobrace

		addq.l	#1,a2
subst_hist_nobrace:
		move.b	(a2),d0
		move.w	histchar(a6),d1
		bsr	compare_histchar		*  !!
		beq	default_event

		bsr	isdigit				*  !N
		beq	search_absolute

		cmp.b	#'-',d0				*  !-N
		beq	search_relative

		cmp.b	#'?',d0				*  !?str?
		beq	search_istr
**
**  !str
**
search_str:
		clr.b	istr_flag(a6)
		movea.l	a2,a0				* A0 : str �̐擪
find_str_loop:
		moveq	#0,d0
		move.b	(a2)+,d0
		beq	find_str_done

		bsr	isspace
		beq	find_str_done

		cmp.b	#':',d0
		beq	find_str_done

		move.l	a0,-(a7)
		lea	special_word_selecters_2,a0		*   -  *  $  ^
		bsr	strchr
		movea.l	(a7)+,a0
		bne	find_str_done

		cmp.b	#'}',d0
		beq	find_str_done

		bsr	issjis
		bne	find_str_loop

		move.b	(a2)+,d0
		bne	find_str_loop
find_str_done:
		subq.l	#1,a2				* A2 : ���̃|�C���g
		move.l	a2,d0
		sub.l	a0,d0				* D0.L : str�̒���
		beq	default_event_1
		bra	set_search_str
**
**  !?str?
**
search_istr:
		move.b	#1,istr_flag(a6)
		addq.l	#1,a2				* �P�߂� ? ���X�L�b�v
		movea.l	a2,a0				* A0 : str �̐擪
		moveq	#'?',d0
		bsr	strchr
		exg	a0,a2				* A2 : ���̃|�C���g
		move.l	a2,d0
		sub.l	a0,d0				* D0.L : str�̒���
		cmpi.b	#'?',(a2)
		bne	set_search_str

		addq.l	#1,a2
set_search_str:
		tst.l	d0
		beq	get_hist_search_str

		cmp.l	#MAXSEARCHLEN,d0
		bls	put_hist_search_str_len_ok

		move.l	#MAXSEARCHLEN,d0
put_hist_search_str_len_ok:
		move.l	a1,-(a7)
		movea.l	a0,a1
		lea	prev_search,a0
		bsr	memmove_inc
		movea.l	(a7)+,a1
		clr.b	(a0)
get_hist_search_str:
		lea	prev_search,a0			* A0 : ����������
		bsr	strlen
		move.l	d0,d3				* D3 : ����������̒���
		beq	no_prev_search

		move.l	his_nlines_now,d6		* D6.L : ���݂̗����̍s��
		beq	fail_str			* 0�s�Ȃ�Βu�����s

		move.l	a1,-(a7)			* A1��Ҕ�
		movea.l	a0,a1
		movea.l	hiswork,a3
		adda.l	his_end,a3			* A3 : �����̃|�C���^
		moveq	#-1,d2				* D2.L = -1 .. :%�͖���
search_search_str_loop:
		suba.w	-2(a3),a3			* �|�C���^��O�̍s�Ɉړ��@�i�������j
		lea	2(a3),a0
		move.w	(a0)+,d5			* D5 : ���̍s�̌ꐔ
		beq	search_search_str_next

		tst.b	istr_flag(a6)
		bne	search_search_istr

		move.l	d3,d0				* ������̒�������
		bsr	memcmp				* ��r����
		beq	search_search_str_done
		bra	search_search_str_next

search_search_istr:
		movem.l	d1-d2,-(a7)
		move.w	d5,d0
		move.l	d3,d1
		moveq	#0,d2
		bsr	wordlistmem
		movem.l	(a7)+,d1-d2
		tst.w	d0
		bne	search_search_str_done
search_search_str_next:
		subq.l	#1,d6
		bne	search_search_str_loop
search_search_str_done:
		move.l	(a7)+,a1
		tst.l	d6				* �s���J�E���^
		beq	fail_str

		movea.l	a3,a0
		bra	subst_hist_do_expand_1
**
**  !!  !*  !$  !^
**
default_event:
		movea.l	a3,a2
default_event_1:
		cmpa.l	#0,a4
		beq	last_history_event

		movea.l	a4,a0
		move.w	d4,d0
		moveq	#-1,d2
		bra	subst_hist_do_expand_2

last_history_event:
		moveq	#1,d1
		bra	search_minus_d1
**
**  !-N
**
search_relative:
		movea.l	a2,a0
		addq.l	#1,a0
		bsr	atou
		exg	a0,a2
		bmi	search_minus_d1
		bne	overflow

		tst.l	d1
		bmi	overflow
search_minus_d1:
		cmpa.l	#0,a4
		beq	do_search_minus_d1

		addq.l	#1,d1
		bmi	overflow
do_search_minus_d1:
		move.l	his_toplineno,d0
		add.l	his_nlines_now,d0
		sub.l	d1,d0
		bra	search_n
**
**  !N
**
search_absolute:
		movea.l	a2,a0
		bsr	atou
		exg	a0,a2
		bne	overflow

		move.l	d1,d0
		bmi	overflow
search_n:
		move.l	d0,d3
		beq	fail_n
		bmi	fail_n

		sub.l	his_toplineno,d3	* �����̐擪�̍s�̍s�ԍ�������
		bmi	fail_n

		sub.l	his_nlines_now,d3
		bge	fail_n

		neg.l	d3
		move.l	d3,d0
		movea.l	hiswork,a0
		adda.l	his_end,a0
		bsr	backup_history
		moveq	#-1,d2			* D2.L = -1 .. :%�͖���
subst_hist_do_expand_1:
		addq.l	#2,a0
		move.w	(a0)+,d0		* D0.W : ���̃C�x���g�̒P�ꐔ
subst_hist_do_expand_2:
		*
		* �����ŁA
		*      A0     �C�x���g�̒P�����
		*      A1     �W�J�o�b�t�@�̃A�h���X
		*      A2     �P��I���q�ƒP��C���q���n�܂�A�h���X
		*      D0.W   �C�x���g�̒P�ꐔ
		*      D2.L   �P��I���q % �̒P��ԍ��i-1:�Y���Ȃ��j
		*      D7.W   �W�J�o�b�t�@�̗e��
		*
		move.b	subst_status(a6),d3
		bset	#3,d3
		bclr	#4,d3
		tst.b	quick_modify(a6)
		beq	subst_hist_do_expand_3

		bset	#4,d3
subst_hist_do_expand_3:
		exg	d1,d7
		bsr	expand_history
		exg	d1,d7
		move.b	d0,subst_status(a6)
		btst	#2,d0
		bne	subst_history_fatal_error

		cmpi.b	#'{',braceflag(a6)
		bne	subst_history_loop

		cmpi.b	#'}',(a2)+
		beq	subst_history_loop

		subq.l	#1,a2
		btst.b	#1,subst_status(a6)
		bne	subst_history_loop

		lea	msg_subst,a0
		bsr	eputs
		bsr	syntax_error
		move.b	subst_status(a6),d0
		or.b	#%11,d0
		move.b	d0,subst_status(a6)
		bra	subst_history_loop
********************************
escape:
		move.w	histchar(a6),d1
		bsr	compare_histchar
		beq	subst_history_dup_char

		subq.w	#1,d7
		bcs	subst_hist_over

		move.b	#'\',(a1)+
subst_history_dup_char:
		move.b	(a2)+,d0
		bsr	issjis
		bne	subst_history_dup1
subst_history_dup2:
		move.b	d0,(a1)+
		beq	subst_hist_done

		subq.w	#1,d7
		bcs	subst_hist_over

		move.b	(a2)+,d0
subst_history_dup1:
		move.b	d0,(a1)+
		beq	subst_hist_done

		subq.w	#1,d7
		bcc	subst_history_loop
subst_hist_over:
		btst.b	#1,subst_status(a6)
		bne	subst_history_fatal_error

		bsr	too_long_line
subst_history_fatal_error:
		move.b	subst_status(a6),d0
		or.b	#%111,d0
		move.b	d0,subst_status(a6)
		addq.l	#1,a1
subst_hist_done:
		subq.l	#1,a1
subst_history_return:
		movea.l	a2,a0
		move.w	d7,d1
		move.b	subst_status(a6),d0
		movem.l	(a7)+,d2-d7/a2-a4
		unlk	a6
		rts


overflow:
		btst.b	#1,subst_status(a6)
		bne	error

		move.b	(a2),d0
		clr.b	(a2)
		bsr	pre_perror
		move.b	d0,(a2)
		lea	msg_too_large_number,a0
		bsr	enputs
		bra	error

fail_n:
		btst.b	#1,subst_status(a6)
		bne	error

		lea	itoabuf(a6),a0
		bsr	itoa
		bsr	skip_space
		bsr	ecputs
		lea	msg_colon_blank,a0
		bsr	eputs
		bra	fail

no_prev_search:
		btst.b	#1,subst_status(a6)
		bne	error

		lea	msg_no_prev_search,a0
		bsr	eputs
		bra	error

fail_str:
		btst.b	#1,subst_status(a6)
		bne	error

		lea	prev_search,a0
		bsr	pre_perror
fail:
		lea	msg_event_not_found,a0
		bsr	enputs
error:
		move.b	subst_status(a6),d0
		or.b	#%11,d0
		move.b	d0,subst_status(a6)
		lea	str_nul,a0
		moveq	#0,d0
		moveq	#-1,d2
		bra	subst_hist_do_expand_2
*****************************************************************
is_special_word_selecter:
		move.l	a0,-(a7)
		lea	special_word_selecters,a0
		bsr	strchr
		movea.l	(a7)+,a0
		rts
****************************************************************
get_wordno:
		moveq	#1,d1
		cmp.b	#'^',d0
		beq	get_wordno_return

		moveq	#-1,d1
		cmp.b	#'$',d0
		beq	get_wordno_return

		moveq	#-3,d1
		cmp.b	#'%',d0
		beq	get_wordno_return

		subq.l	#1,a0
		bsr	atou
		bmi	get_wordno_no_wordno
		bne	get_wordno_overflow

		cmp.l	#MAXWORDS,d1
		bls	get_wordno_return
get_wordno_overflow:
		move.l	#MAXWORDS,d1
get_wordno_return:
		rts

get_wordno_no_wordno:
		moveq	#-2,d1
		rts
****************************************************************
.data

.xdef msg_no_prev_search

special_word_selecters:		dc.b	'%'
special_word_selecters_2:	dc.b	'-*^$',0
word_histchars:			dc.b	'histchars',0
msg_event_not_found:		dc.b	'�C�x���g����������܂���',0
msg_subst:			dc.b	'!�u����',0
msg_bad_word_selecter:		dc.b	'�P��I���q�������ł�',0
msg_no_prev_search:		dc.b	'����������̋L���͂���܂���',0
msg_modifier_failed:		dc.b	'������C���͋N����܂���ł���',0
****************************************************************

.end
