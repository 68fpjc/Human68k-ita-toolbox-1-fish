* wordlist.s
* Itagaki Fumihiko 11-Aug-90  Create.

.include ../src/fish.h

.xref isspace2
.xref issjis
.xref tolower
.xref skip_space
.xref strlen
.xref strcmp
.xref strmove
.xref strfor1
.xref strforn
.xref memmovi
.xref rotate
.xref is_word_separator
.xref too_many_words
.xref too_long_line
.xref too_long_word

****************************************************************
* make_wordlist - �P����т����
*
* CALL
*      A0     source line address
*      A1     destination word list buffer address (MAXWORDLISTSIZE)
*      D1.W   �o�b�t�@�̗e��
*
* RETURN
*      D0.L   �����Ȃ�ΐ����D���ʃ��[�h�͌ꐔ�D
*             �����Ȃ�΃G���[�D
*
*      D1.W   �o�b�t�@�̎c��e��
*
*      A1     �o�b�t�@�̎��̊i�[�ʒu���w��
*
*      CCR    TST.L D0
*
* NOTE
*      �󔒂ŋ�؂��Ă����Ƃ��Ɨ��ȒP��Ƃ��Ĉ��������
*           (  )  ;  |  ||  &  &&  <  <<  >  >>  �i�ȏ�� csh �Ɠ����j
*           <=  >=  <<=  >>=  &=  |=
*
*      �G�X�P�[�v����Ă��Ȃ� $ ����� $? �ɑ��������͓��ʂȈӖ�����
*      ���Ȃ�
*
*      �G�X�P�[�v����Ă��Ȃ� $ �̒���� { ������Ƃ��A���Ɍ����� }
*      �܂ł̕����͓��ʂȈӖ��������Ȃ�
*****************************************************************
.xdef make_wordlist

make_wordlist:
		movem.l	d2-d6/a0/a2,-(a7)
		moveq	#0,d2			*  D2.W : �P�ꐔ
make_wordlist_loop:
		jsr	skip_space		*  �󔒂��X�L�b�v����
		movea.l	a0,a2
		move.b	(a2)+,d0		*  �ŏ��̕�����
		beq	make_wordlist_done	*  NUL�Ȃ�ΏI���

		addq.w	#1,d2
		cmp.w	#MAXWORDS,d2
		bhi	make_wordlist_too_many_words

		move.w	#MAXWORDLEN+1,d3	* �P��̏I����NUL�̕������肷��

		bsr	isspace2
		beq	special_word_1

		cmp.b	#';',d0
		beq	special_word_1

		cmp.b	#'(',d0
		beq	special_word_1

		cmp.b	#')',d0
		beq	special_word_1

		cmp.b	#'>',d0
		beq	special_word_less_great

		cmp.b	#'<',d0
		beq	special_word_less_great

		cmp.b	#'|',d0
		beq	special_word_and_or

		cmp.b	#'&',d0
		beq	special_word_and_or

		subq.l	#1,a2
		moveq	#0,d5			*  D5 : ${}���x��
		moveq	#0,d0
make_wordlist_normal_loop_0:
		move.b	d0,d4			*  D4 : �N�I�[�g�E�t���O
make_wordlist_normal_loop_1:
		moveq	#0,d6			*  D6 : -1:$�̎��C1:$?�̎�
make_wordlist_normal_loop_2:
		move.b	(a2),d0
		beq	make_wordlist_terminate_word

		addq.l	#1,a2
		bsr	issjis
		beq	make_wordlist_dup_sjis

		cmp.b	d4,d0
		bne	make_wordlist_not_close_quote

			moveq	#0,d4
			bra	make_wordlist_check_term

make_wordlist_not_close_quote:
		cmp.b	#'{',d0
		bne	make_wordlist_not_open_brace

			tst.b	d6
			bpl	make_wordlist_check_term

			addq.l	#1,d5
			bra	make_wordlist_check_term

make_wordlist_not_open_brace:
		cmp.b	#'}',d0
		bne	make_wordlist_not_close_brace

			tst.l	d5
			beq	make_wordlist_check_term

			subq.l	#1,d5
			bra	make_wordlist_check_term

make_wordlist_not_close_brace:
		cmp.b	#"'",d4
		beq	make_wordlist_normal_loop_1

		cmp.b	#"`",d4
		beq	make_wordlist_normal_loop_1

		cmp.b	#'$',d0
		bne	make_wordlist_not_doller

			tst.b	d6
			bne	make_wordlist_check_term

			moveq	#1,d6
			cmpi.b	#'?',(a2)
			beq	make_wordlist_doller_1

			moveq	#-1,d6
			cmpi.b	#'{',(a2)
			bne	make_wordlist_normal_loop_2

			tst.b	d4
			bne	make_wordlist_normal_loop_2

			tst.l	d5
			bne	make_wordlist_normal_loop_2

			addq.l	#1,d5
make_wordlist_doller_1:
			addq.l	#1,a2
			bra	make_wordlist_normal_loop_2

make_wordlist_not_doller:
		tst.b	d4
		bne	make_wordlist_normal_loop_1

		cmp.b	#'"',d0
		beq	make_wordlist_normal_loop_0

		cmp.b	#"'",d0
		beq	make_wordlist_normal_loop_0

		cmp.b	#'`',d0
		beq	make_wordlist_normal_loop_0

		cmp.b	#'\',d0
		bne	make_wordlist_check_term

		move.b	(a2),d0
		bsr	issjis
		beq	make_wordlist_normal_loop_1
make_wordlist_dup_sjis:
		tst.b	(a2)
		beq	make_wordlist_terminate_word

		addq.l	#1,a2
make_wordlist_check_term:
		tst.b	d4
		bne	make_wordlist_normal_loop_1

		tst.l	d5
		bne	make_wordlist_normal_loop_1

		move.b	(a2),d0
		bsr	is_word_separator
		bne	make_wordlist_normal_loop_1

		bra	make_wordlist_terminate_word
****************
special_word_less_great:
		cmp.b	(a2),d0
		bne	special_word_is_assignment

		cmp.b	#'<',d0
		bne	special_word_double_less_great

		cmp.b	1(a2),d0
		beq	special_word_3
special_word_double_less_great:
		cmpi.b	#'=',1(a2)
		beq	special_word_3

		bra	special_word_2

special_word_and_or:
		cmp.b	(a2),d0
		beq	special_word_2
special_word_is_assignment:
		cmpi.b	#'=',(a2)
		beq	special_word_2

		bra	special_word_1

special_word_3:
		addq.l	#1,a2
special_word_2:
		addq.l	#1,a2
special_word_1:
make_wordlist_terminate_word:
		move.l	a2,d0
		sub.l	a0,d0
		addq.l	#1,d0
		cmp.l	#$ffff,d0
		bhi	too_long_line

		sub.w	d0,d1
		bcs	make_wordlist_too_long_line

		sub.w	d0,d3
		bcs	make_wordlist_too_long_word

		subq.l	#1,d0
		exg	a0,a1
		bsr	memmovi
		clr.b	(a0)+
		exg	a0,a1
		bra	make_wordlist_loop
****************
make_wordlist_done:
		move.l	d2,d0
make_wordlist_return:
		movem.l	(a7)+,d2-d6/a0/a2
		rts
********************************
make_wordlist_too_long_line:
		bsr	too_long_line
		bra	make_wordlist_error

make_wordlist_too_long_word:
		bsr	too_long_word
		bra	make_wordlist_error

make_wordlist_too_many_words:
		bsr	too_many_words
make_wordlist_error:
		moveq	#-1,d0
		bra	make_wordlist_return
****************************************************************
* words_to_line - �P����т��s�ɂ���
*
* CALL
*      A0     �P����т̐擪�A�h���X
*      D0.W   �P�ꐔ
*
* RETURN
*      none.
*****************************************************************
.xdef words_to_line

words_to_line:
		movem.l	d0/a0,-(a7)
		subq.w	#1,d0
		blo	words_to_line_null
		bra	words_to_line_continue

words_to_line_loop:
		bsr	strfor1
		move.b	#' ',-1(a0)
words_to_line_continue:
		dbra	d0,words_to_line_loop
words_to_line_return:
		movem.l	(a7)+,d0/a0
		rts

words_to_line_null:
		clr.b	(a0)
		bra	words_to_line_return
****************************************************************
* copy_wordlist - �P����т��R�s�[����
*
* CALL
*      A0     destination buffer
*      A1     source word list
*      D0.W   number of words
*
* RETURN
*      none
*****************************************************************
.xdef copy_wordlist

copy_wordlist:
		movem.l	d0/a0-a1,-(a7)
		bra	copy_wordlist_continue

copy_wordlist_loop:
		bsr	strmove
copy_wordlist_continue:
		dbra	d0,copy_wordlist_loop

		movem.l	(a7)+,d0/a0-a1
		rts
****************************************************************
* find_close_paren - find ) in wordlist
*
* CALL
*      A0     �P�����
*      D0.W   �P�ꐔ
*
* RETURN
*      A0     ) ���w���i��������΁j
*
*      D0.L   �i�񂾒P�ꐔ
*             �����Ȃ�Ό�����Ȃ��������Ƃ������Ă���
*
*      CCR    TST.L D0
*****************************************************************
.xdef find_close_paren

find_close_paren:
		movem.l	d1,-(a7)
		moveq	#0,d1
		bra	find_close_paren_start

find_close_paren_loop:
		cmpi.b	#')',(a0)
		beq	close_paren_found

		bsr	strfor1
		addq.w	#1,d1
find_close_paren_start:
		dbra	d0,find_close_paren_loop

		moveq	#-1,d0
find_close_paren_return:
		movem.l	(a7)+,d1
		rts

close_paren_found:
		move.l	d1,d0
		bra	find_close_paren_return
****************************************************************
* sort_wordlist - �P��̕��т��\�[�g����
*
* CALL
*      A0     �P�����
*      D0.W   �P�ꐔ
*      A4     ��r���[�`���̃G���g���E�A�h���X
*
* RETURN
*      �Ȃ�
*
* NOTE
*      �A���S���Y���͒P���I��@�D�x���D���s���Ԃ�pow(N,2)�̃I�[�_�[�D
*      �����͔z������񂵂Ă���̂œ��ɒx���D
*      ����ł͂���D
*****************************************************************
.xdef sort_wordlist
.xdef sort_wordlist_x

sort_wordlist:
		move.l	a4,-(a7)
		lea	strcmp(pc),a4
		bsr	sort_wordlist_x
		movea.l	(a7)+,a4
		rts

sort_wordlist_x:
		movem.l	d0-d2/a0-a3,-(a7)
		move.w	d0,d1				*  D1.W : �v�f��
		movea.l	a0,a2
		bsr	strforn
		exg	a0,a2				*  A0:�ŏ��̗v�f  A2:�Ō�̗v�f�̎�
sort_wordlist_loop2:
		cmp.w	#2,d1
		blo	sort_wordlist_done

		*  A0 �ȍ~�̍ŏ��̒P��̃A�h���X�� A1 �ɓ���
		movea.l	a0,a3
		subq.w	#1,d1
		move.w	d1,d2
		bra	sort_wordlist_loop1_start

sort_wordlist_loop1:
		bsr	strfor1
		jsr	(a4)
		bhs	sort_wordlist_loop1_continue
sort_wordlist_loop1_start:
		movea.l	a0,a1
sort_wordlist_loop1_continue:
		dbra	d2,sort_wordlist_loop1

		movea.l	a3,a0
		cmpa.l	a0,a1				*  �擪�̒P�ꂪ�ŏ��Ȃ�
		beq	sort_wordlist_loop2_continue	*  �������Ȃ�

		bsr	rotate
sort_wordlist_loop2_continue:
		bsr	strfor1
		bra	sort_wordlist_loop2

sort_wordlist_done:
		movem.l	(a7)+,d0-d2/a0-a3
		rts
****************************************************************
* uniq_wordlist - �P��̕��т̒��ŗאڂ��Ă���d���P����폜����
*
* CALL
*      A0     �P�����
*      D0.W   �P�ꐔ
*
* RETURN
*      D0.L   ���ʃ��[�h�͒P�ꐔ�D��ʂ͔j��
*****************************************************************
.xdef uniq_wordlist

uniq_wordlist:
		movem.l	d1-d2/a0-a2,-(a7)
		moveq	#0,d2
		movea.l	a0,a1				*  A1 : ��r����P��̃A�h���X
		move.w	d0,d1				*  D1.W : A1�ȍ~�̒P�ꐔ
uniq_wordlist_loop1:
		cmp.w	#2,d1
		blo	uniq_wordlist_done

		bsr	strfor1
		subq.w	#1,d1
		addq.w	#1,d2
		bsr	strcmp
		bne	uniq_wordlist_continue

		subq.w	#2,d1
		bcs	uniq_wordlist_return

		movea.l	a0,a2
uniq_wordlist_loop2:
		bsr	strfor1
		bsr	strcmp
		dbne	d1,uniq_wordlist_loop2
		beq	uniq_wordlist_return

		addq.w	#1,d1
		move.w	d1,d0
		movea.l	a0,a1
		movea.l	a2,a0
		bsr	copy_wordlist
uniq_wordlist_continue:
		movea.l	a0,a1
		bra	uniq_wordlist_loop1

uniq_wordlist_done:
		add.w	d1,d2
uniq_wordlist_return:
		move.w	d2,d0
		movem.l	(a7)+,d1-d2/a0-a2
		rts
****************************************************************
* is_all_same_word - �P��̕��т̒��̒P�ꂪ���ׂē����ł��邩�ǂ����𒲂ׂ�
*
* CALL
*      A0     �P�����
*      D0.W   �P�ꐔ
*
* RETURN
*      D0.L   ���ׂē����Ȃ�� 0
*      CCR    TST.L D0
*****************************************************************
.xdef is_all_same_word

is_all_same_word:
		movem.l	d1/a0-a1,-(a7)
		move.w	d0,d1
		moveq	#0,d0
		subq.w	#2,d1
		bcs	is_all_same_word_return

		movea.l	a0,a1
is_all_same_word_loop:
		bsr	strfor1
		bsr	strcmp
		dbne	d1,is_all_same_word_loop
is_all_same_word_return:
		movem.l	(a7)+,d1/a0-a1
		tst.l	d0
		rts
****************************************************************
* wordlistlen - ����т̒���
*
* CALL
*      A0     �P�����
*      D0.W   �P�ꐔ
*
* RETURN
*      D0.L   �P����т̃o�C�g��
*****************************************************************
.xdef wordlistlen

wordlistlen:
		movem.l	d1-d2/a0,-(a7)
		moveq	#0,d2
		move.w	d0,d1
		bra	wordlistlen_start

wordlistlen_loop:
		bsr	strlen
		addq.l	#1,d0
		add.l	d0,d2
		add.l	d0,a0
wordlistlen_start:
		dbra	d1,wordlistlen_loop

		move.l	d2,d0
		movem.l	(a7)+,d1-d2/a0
		rts
****************************************************************
* common_spell - �P����т̍ŏ��̋��ʕ����̒����𓾂�
*
* CALL
*      A0     �P�����
*      D0.W   �P�ꐔ
*      D1.L   �P��̍ŏ��̖�������ׂ������̒���
*      D2.B   0 �Ȃ�Α啶���Ə���������ʂ���
*
* RETURN
*      D0.L   �ŏ��̋��ʕ����̒���
*****************************************************************
.xdef common_spell

common_spell:
		movem.l	d1-d6/a0-a1,-(a7)
		moveq	#0,d4				*  ���ʕ����̒����J�E���^
		move.w	d0,d5				*  D5.W : �P�ꐔ
		beq	common_spell_done

		subq.w	#1,d5
		lea	(a0,d1.l),a1
common_spell_loop1:
		move.w	d5,d3				*  D3.W : �P�ꐔ�J�E���^
		movea.l	a1,a0
		move.b	(a1)+,d0
		beq	common_spell_done		*  ���������͖����c����܂�

		bsr	issjis
		beq	common_spell_sjis
****************
		tst.b	d2				*  �啶���Ə����������
		beq	common_spell_ank_1		*  ���Ȃ��Ȃ�

		bsr	tolower				*  tolower ���Ă���
common_spell_ank_1:
		move.b	d0,d6
		bra	common_spell_ank_continue

common_spell_ank_loop:
		bsr	strfor1
		add.l	d1,a0
		move.b	(a0),d0
		tst.b	d2				*  �i�啶���Ə����������
		beq	common_spell_ank_2		*    ���Ȃ��Ȃ�

		bsr	tolower				*    tolower ���Ă���j
common_spell_ank_2:
		cmp.b	d6,d0				*  ��r����D
		bne	common_spell_done		*  ��v���Ȃ��P�ꂪ����c�����܂�
common_spell_ank_continue:
		dbra	d3,common_spell_ank_loop

		*  1�o�C�g�L�΂��Ă���ɔ�r����

		addq.l	#1,d1
		addq.l	#1,d4
		bra	common_spell_loop1
****************
common_spell_sjis:
		lsl.w	#8,d0
		move.b	(a1)+,d0
		beq	common_spell_done		*  ���̒P��ɂ͂��������͖����c����܂�

		bra	common_spell_sjis_continue

common_spell_sjis_loop:
		bsr	strfor1
		add.l	d1,a0
		move.b	(a0),d6
		lsl.l	#8,d6
		move.b	1(a0),d6
		cmp.w	d0,d6
		bne	common_spell_done		*  ��v���Ȃ��P�ꂪ����c����܂�
common_spell_sjis_continue:
		dbra	d3,common_spell_sjis_loop

		*  2�o�C�g�L�΂��Ă���ɔ�r����

		addq.l	#2,d1
		addq.l	#2,d4
		bra	common_spell_loop1
****************
common_spell_done:
		move.l	d4,d0
		movem.l	(a7)+,d1-d6/a0-a1
		rts

.if 0
****************************************************************
* delete_dotnames - �\�[�g���ꂽ�P�ꃊ�X�g���� '.' �Ŏn�܂�P����폜����
*
* CALL
*      A0     �P�����
*      D0.W   �P�ꐔ
*
* RETURN
*      D0.L   ���ʃ��[�h�͒P�ꐔ�D��ʂ͔j��
****************************************************************
.xdef delete_dotnames

delete_dotnames:
		movem.l	d1-d2/a0-a1,-(a7)
		move.w	d0,d1				*  D1.W : ���̒P�ꐔ
		bra	find_dotname_continue

find_dotname_loop:
		cmpi.b	#'.',(a0)
		bhs	find_dotname_done

		bsr	strfor1
find_dotname_continue:
		dbra	d0,find_dotname_loop
find_dotname_done:
		movea.l	a0,a1				*  A1 : �폜�J�n�A�h���X
		moveq	#0,d2				*  D2.W �ɍ폜�P�ꐔ���J�E���g����
		addq.w	#1,d0
		bra	find_nondotname_continue

find_nondotname_loop:
		cmpi.b	#'.',(a0)
		bne	nondotname_found

		bsr	strfor1
		addq.w	#1,d2
find_nondotname_continue:
		dbra	d0,find_nondotname_loop
nondotname_found:
		cmpa.l	a0,a1
		beq	delete_dotnames_return		*  '.' �Ŏn�܂�P��͖�������

		addq.w	#1,d0
		bsr	wordlistlen
		exg	a0,a1
		bsr	memmovi
		sub.w	d2,d1
delete_dotnames_return:
		move.w	d1,d0
		movem.l	(a7)+,d1-d2/a0-a1
		rts
.endif

.end
