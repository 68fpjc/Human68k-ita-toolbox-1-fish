* modifier.s
* Itagaki Fumihiko 01-Jan-91  Create.

.include limits.h

.text

****************************************************************
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
.xdef parse_word_selecter

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
is_not_subst_separator:
		tst.b	d0
		beq	is_not_subst_separator_return	* EQ

		cmp.w	#$100,d0
		bhi	is_not_subst_separator_return	* NE

		bsr	isspace
		beq	is_not_subst_separator_return	* EQ

		bsr	iscsym
is_not_subst_separator_return:
		rts
****************************************************************
* check_modifier - �P��C���q���`�F�b�N����
*
* CALL
*      A0     �C���q���X�g�̐擪�A�h���X
*
* RETURN
*      A0     ���@�ȏC���q���X�g���т̎��̃A�h���X���w��
*      D0.L   bit 0   :q
*             bit 1   :p
*             bit 2   Bad substitute.
*             other   0
*
* DESCRIPTION
*
*      �ȉ��̏C���q�̕��т�F�߂�
*		:h
*		:t
*		:r
*		:e
*		:d
*		:f
*		:s<c><str1><c><str2>[<c>]
*		:gh
*		:gt
*		:gr
*		:ge
*		:gd
*		:gf
*		:gs<c><str1><c><str2>[<c>]
*		:q
*		:p
*
****************************************************************
.xdef check_modifier

check_modifier:
		movem.l	d1/a1,-(a7)
		moveq	#0,d1
check_modifier_loop:
		cmpi.b	#':',(a0)
		bne	check_modifier_done

		movea.l	a0,a1
		addq.l	#1,a0
		moveq	#0,d0
		move.b	(a0)+,d0
		cmp.b	#'q',d0
		beq	set_modifier_q

		cmp.b	#'p',d0
		beq	set_modifier_p

		cmp.b	#'g',d0
		bne	check_modifier_1

		move.b	(a0)+,d0
check_modifier_1:
		cmp.b	#'s',d0
		bne	check_not_modifier_s
		*{
			bsr	scan1char
			bsr	is_not_subst_separator
			beq	check_modifier_bad_subst

			bsr	estrchr
			beq	check_modifier_done

			bsr	for1char
			bsr	estrchr
			beq	check_modifier_done

			bsr	for1char
			bra	check_modifier_loop
		*}
check_not_modifier_s:
		move.l	a0,-(a7)
		lea	str_modifier_xrhtedf,a0
		bsr	strchr
		movea.l	(a7)+,a0
		bne	check_modifier_loop

		movea.l	a1,a0
check_modifier_done:
		move.l	d1,d0
		movem.l	(a7)+,d1/a1
		rts

check_modifier_bad_subst:
		bset	#2,d1
		bra	check_modifier_done

set_modifier_q:
		bset	#0,d1
		bra	check_modifier_loop

set_modifier_p:
		bset	#1,d1
		bra	check_modifier_loop
****************************************************************
* modify - �P����C������
*
* CALL
*      A0     �P��̐擪�A�h���X�i���F���̗̈悪���ڏ�����������j
*      A1     �C���q���X�g�̐擪�A�h���X
*      D0.W   0 �ȊO�Ȃ�� :g �ȊO�𖳌��Ƃ���
*
* RETURN
*      (A0).. �C�����ꂽ�P��
*      D0.L   0 : ��薳��
*             1 : Modifier failed.
*             2 : No prev lhs.
*             3 : No prev sub.
*      D1.L   ���̒P��ɑ΂��ėL���� :x ���������Ȃ�� 'x' �����Ȃ��� NUL
*
* DESCRIPTION
*
*	:h				�p�X���̃h���C�u�{�f�B���N�g�������i�Ō��/�͊܂܂Ȃ��j
*	:t				�p�X���̃t�@�C�������i�g���q���܂ށj
*	:r				�p�X���̍Ō�̊g���q�ȊO�̕���
*	:e				�p�X���̍Ō�̊g���q�����i.�͊܂܂Ȃ��j
*	:d				�p�X���̃h���C�u�������i:�͊܂܂Ȃ��j
*	:f				�p�X���̃h���C�u���ȊO�̕���
*	:s<c><str1><c><str2>[<c>]	str1 �� str2 �ɒu��������
*	:gh				:h ��S�P��ɓK�p
*	:gt				:t ��S�P��ɓK�p
*	:gr				:r ��S�P��ɓK�p
*	:ge				:e ��S�P��ɓK�p
*	:gd				:d ��S�P��ɓK�p
*	:gf				:f ��S�P��ɓK�p
*	:gs<c><str1><c><str2>[<c>]	:s ��S�P��ɓK�p
*
*      ��L�ȊO�̏C���q�͖�������̂ŗ\�߃`�F�b�N���Ă����K�v������
*
****************************************************************
.xdef modify

modify:
		movem.l	d2-d5/a1-a5,-(a7)
		movea.l	a1,a4
		move.w	d0,d4
		moveq	#0,d5			* D5 : :x�t���O
modify_loop:
		cmpi.b	#':',(a4)+
		bne	modify_done

		cmpi.b	#'g',(a4)+
		beq	modifier_ok

		subq.l	#1,a4
		tst.w	d4
		bne	modify_next
modifier_ok:
		cmpi.b	#'x',(a4)
		beq	modify_quote

		cmpi.b	#'s',(a4)
		beq	modify_subst

		bsr	test_pathname
		cmpi.b	#'r',(a4)
		beq	modify_root

		cmpi.b	#'h',(a4)
		beq	modify_head

		cmpi.b	#'t',(a4)
		beq	modify_tail

		cmpi.b	#'e',(a4)
		beq	modify_extention

		cmpi.b	#'d',(a4)
		beq	modify_drive

		cmpi.b	#'f',(a4)
		beq	modify_file

		bra	modify_next
****************
modify_extention:
		movea.l	a3,a1
		tst.b	(a2)
		beq	modify_file

		lea	1(a3),a2
modify_tail:
		movea.l	a2,a1
modify_file:
		bsr	strcpy
		bra	modify_next

modify_drive:
		sub.l	d1,d0
		beq	modify_cut

		subq.l	#1,d0
		bra	modify_cut

modify_root:
		add.l	d2,d0
		bra	modify_cut

modify_head:
		tst.l	d0
		beq	modify_next

		subq.l	#1,d0
		cmpi.b	#'/',(a0,d0.l)
		beq	modify_cut

		cmpi.b	#'\',(a0,d0.l)
		beq	modify_cut

		addq.l	#1,d0
modify_cut:
		clr.b	(a0,d0.l)
		bra	modify_next
****************
modify_subst:

tmp_search_str = -(((MAXSEARCHLEN+1)+1)>>1<<1)
tmp_subst_str = tmp_search_str-(((MAXSUBSTLEN+1)+1)>>1<<1)

		addq.l	#1,a4
		exg	a0,a4
		bsr	scan1char		* D0.W : ��؂蕶��
		exg	a0,a4
		bsr	is_not_subst_separator
		beq	modify_done		* �G���[

		link	a6,#tmp_subst_str
		exg	a0,a4
		lea	tmp_search_str(a6),a1
		moveq	#MAXSEARCHLEN+1,d1
		bsr	scan_subst_str
		move.l	d1,d2			* D2.L : MAXSEARCHLEN+1-����������̒���

		lea	tmp_subst_str(a6),a1
		moveq	#MAXSUBSTLEN+1,d1
		bsr	scan_subst_str
		move.l	d1,d3			* D3.L : MAXSUBSTLEN+1-�u��������̒���
		beq	subst_done		* �G���[

		tst.l	d2
		beq	subst_done		* �G���[

		cmp.w	#MAXSEARCHLEN+1,d2
		beq	search_str_ok

		move.l	a0,-(a7)
		lea	tmp_search_str(a6),a1
		lea	search_str,a0
		bsr	strcpy
		move.l	(a7)+,a0
search_str_ok:
		lea	search_str,a1
		tst.b	(a1)
.if 0




		exg	a0,a4
		move.l	d1,d0
		exg	a0,a1
		bsr	put_and_get_hist_search_str
		exg	a0,a1			* A1 : ����������
		move.l	d0,d1			* D1.L : ����������̒���
		beq	no_prev_lhs

		bsr	strmem
		beq	subst_done

		*  ���āA������������c�u�����˂΂Ȃ�܂��ȁc
		movea.l	d0,a3			* A3 �͌������ꏊ

		*  �u�������񂪉��o�C�g�ɂȂ邩�𒲂ׂ悤
		*  �i& �������Ă��邩������Ȃ������₱�����j
		moveq	#0,d3			* D3.L �ɒu��������̒��������߂�
		movea.l	a2,a5			* A5 �͂��̃��[�v�ł̈ꎞ�|�C���^
		move.l	d2,d4			* D4.L �͂��̃��[�v�ł̈ꎞ�J�E���^
subst_count_replace:
		tst.l	d4
		beq	subst_count_replace_done

		subq.l	#1,d4
		move.b	(a5)+,d0
		cmp.b	#'&',d0
		beq	subst_count_replace_ampersand

		cmp.b	#'\',d0
		bne	subst_count_replace_normal

		tst.l	d4
		beq	subst_count_replace_normal

		cmpi.b	#'&',(a5)
		beq	subst_count_replace_hide_escape

		bra	subst_count_replace_normal

subst_count_replace_hide_escape:
		move.b	(a5)+,d0
		subq.l	#1,d3
subst_count_replace_normal:
		addq.l	#1,d3
		bsr	issjis
		bne	subst_count_replace

		tst.l	d4
		beq	subst_count_replace_done

		subq.l	#1,d4
		addq.l	#1,a5
		addq.l	#1,d3
		bra	subst_count_replace

subst_count_replace_ampersand:
		add.l	d1,d3
		bra	subst_count_replace

subst_count_replace_done:

		*  ����ł́A�������������邱�ƂɂȂ�̂��H
		move.l	d3,d4
		sub.l	d1,d4			* D4.L : �������镶����
		bmi	subst_fat_ok
		beq	subst_fat_ok

		*  �����镪�������g�����炵�Ă����܂��傤
		*    A3+D1 .. A3+D1+strlen(A3+D1)  ->  A3+D1+D4 .. A3+D1+strlen(A3+D1)+D4
		movem.l	a0-a1,-(a7)
		lea	(a3,d1.l),a0
		bsr	strlen
		addq.l	#1,d0
		lea	(a0,d0.l),a1
		lea	(a1,d4.l),a0
		bsr	memmove_dec
		movem.l	(a7)+,a0-a1
subst_fat_ok:
		*  ����ł͒u���������u���Ă䂫�܂��傤
		bra	subst_store_continue

subst_store:
		move.b	(a2)+,d0
		cmp.b	#'&',d0
		beq	subst_store_stem

		move.b	d0,(a3)+
		bra	subst_store_continue

subst_store_stem:
		move.l	a1,-(a7)
		exg	a0,a3
		move.l	d1,d0
		bsr	memmove_inc
		exg	a0,a3
		movea.l	(a7)+,a1
subst_store_continue:
		dbra	d2,subst_store

		*  D4.L �����Ȃ�� -D4.L �����󂢂Ă���̂ŁA�؂�l�߂�
		tst.l	d4
		bpl	subst_done

		neg.l	d4
		exg	a0,a3
		lea	(a0,d4.l),a1
		bsr	strcpy
		exg	a0,a3
.endif
subst_done:
		unlk	a6
		bra	modify_loop
****************
modify_quote:
		move.b	(a4),d5
****************
modify_next:
		exg	a0,a4
		bsr	for1char
		exg	a0,a4
		bra	modify_loop

modify_done:
		move.l	d5,d1
		movem.l	(a7)+,d2-d5/a1-a5
		rts

no_prev_lhs:
		moveq	#2,d0
		bra	modify_done

bad_substitute:
		moveq	#3,d0
		bra	modify_done

modify_subst_lhs_too_long:
		moveq	#4,d0
		bra	modify_done
****************************************************************
scan_subst_str:
		movem.l	d2/a2,-(a7)
		move.w	d0,d2
scan_subst_str_loop:
		movea.l	a0,a2
		bsr	scan1char
		cmp.w	d2,d0
		beq	scan_subst_str_done

		cmp.w	#'\',d0
		bne	scan_subst_str_dup

		bsr	scan1char
		cmp.w	d2,d0
		beq	scan_subst_str_dup

		movea.l	a2,a0
		bsr	scan1char
scan_subst_str_dup:
		cmp.w	#$100,d0
		blo	scan_subst_str_dup1

		tst.l	d1
		beq	scan_subst_str_loop

		ror.w	#8,d0
		move.b	d0,(a1)+
		subq.l	#1,d1
		rol.w	#8,d0
scan_subst_str_dup1:
		tst.b	d0
		beq	scan_subst_str_eos

		tst.l	d1
		beq	scan_subst_str_loop

		move.b	d0,(a1)+
		subq.l	#1,d1
		bra	scan_subst_str_loop

scan_subst_str_eos:
		subq.l	#1,a0
scan_subst_str_done:
		move.w	d2,d0
		tst.l	d1
		beq	scan_subst_str_return

		clr.b	(a1)
scan_subst_str_return:
		movem.l	(a7)+,d2/a2
		rts
****************************************************************
.data

.xdef special_word_selecters_2

special_word_selecters:		dc.b	'%'
special_word_selecters_2:	dc.b	'-*^$',0

str_modifier_xrhtedf:		dc.b	'xrhtedf',0

.end
