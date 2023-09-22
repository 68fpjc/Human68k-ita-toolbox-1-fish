* wordlist.s
* Itagaki Fumihiko 11-Aug-90  Create.

.include ../src/fish.h

.xref issjis
.xref toupper
.xref skip_space
.xref strchr
.xref strlen
.xref strcmp
.xref strmove
.xref rotate
.xref too_many_words
.xref too_long_line
.xref too_long_word
.xref word_separators

****************************************************************
.xdef for1str

for1str:
		tst.b	(a0)+
		bne	for1str

		rts
*****************************************************************
.xdef fornstrs

fornstrs:
		tst.w	d0
		beq	fornstrs_end

		move.w	d0,-(a7)
		subq.w	#1,d0
fornstrs_loop:
		bsr	for1str
		dbra	d0,fornstrs_loop

		move.w	(a7)+,d0
fornstrs_end:
		rts
****************************************************************
* make_wordlist - �P����т����
*
* CALL
*      A0     source line address
*      A1     destination word list buffer address (MAXWORDLISTSIZE)
*
* RETURN
*      D0.L   �����Ȃ�ΐ����D���ʃ��[�h�͌ꐔ�D
*             �����Ȃ�΃G���[�D
*
*      CCR    TST.L D0
*
* NOTE
*      �󔒂ŋ�؂��Ă����Ƃ��Ɨ��ȒP��Ƃ��Ĉ��������
*           (  )  ;  |  ||  &  &&  <  <<  >  >>  �i�ȏ�� csh �Ɠ����j
*           <=  >=  <<=  >>=  &=  |=
*      �G�X�P�[�v����Ă��Ȃ� $ �ɑ��������͓��ʂȈӖ��������Ȃ�
*      �G�X�P�[�v����Ă��Ȃ� $ �̒���� { ������Ƃ��A���Ɍ����� }
*      �܂ł̕����͓��ʂȈӖ��������Ȃ�
*****************************************************************
.xdef make_wordlist

make_wordlist:
		movem.l	d1-d6/a0-a1,-(a7)
		moveq	#0,d1			*  D1.W : �P�ꐔ
		move.w	#MAXWORDLISTSIZE,d2
make_wordlist_loop:
		bsr	skip_space		*  �󔒂��X�L�b�v����
		move.b	(a0)+,d0		*  �ŏ��̕�����
		beq	make_wordlist_done	*  NUL�Ȃ�ΏI���

		addq.w	#1,d1
		cmp.w	#MAXWORDS,d1
		bhi	make_wordlist_too_many_words

		move.w	#MAXWORDLEN+1,d3	* �P��̏I����NUL�̕������肷��

		bsr	is_not_word_separator
		beq	make_wordlist_normal_word

		cmp.b	#'>',d0
		beq	special_word_less_greater

		cmp.b	#'<',d0
		beq	special_word_less_greater

		cmp.b	#'|',d0
		beq	special_word_and_or

		cmp.b	#'&',d0
		beq	special_word_and_or

		bra	special_word_1

special_word_less_greater:
		cmp.b	(a0),d0
		bne	special_word_is_assignment

		cmpi.b	#'=',1(a0)
		beq	special_word_3

		bra	special_word_2

special_word_and_or:
		cmp.b	(a0),d0
		beq	special_word_2
special_word_is_assignment:
		cmpi.b	#'=',(a0)
		beq	special_word_2

		bra	special_word_1

special_word_3:
		bsr	make_wordlist_store1
		bne	make_wordlist_error

		move.b	(a0)+,d0
special_word_2:
		bsr	make_wordlist_store1
		bne	make_wordlist_error

		move.b	(a0)+,d0
special_word_1:
		bsr	make_wordlist_store1
		bne	make_wordlist_error
make_wordlist_terminate_word:
		moveq	#0,d0
		bsr	make_wordlist_store1
		bne	make_wordlist_error

		bra	make_wordlist_loop
****************
make_wordlist_normal_word:
		subq.l	#1,a0
		moveq	#0,d5			*  D5 : ${}���x��
		moveq	#0,d0
make_wordlist_normal_loop_0:
		move.b	d0,d4			*  D4 : �N�I�[�g�t���O
make_wordlist_normal_loop_1:
		moveq	#0,d6			*  D6 : �u$ �̎��v�t���O
make_wordlist_normal_loop_2:
		move.b	(a0)+,d0
		bsr	make_wordlist_store1
		bne	make_wordlist_error

		tst.b	d0
		beq	make_wordlist_done

		bsr	issjis
		beq	make_wordlist_dup_more_1

		cmp.b	d4,d0
		bne	make_wordlist_not_close_quote

			moveq	#0,d4
			bra	make_wordlist_check_term

make_wordlist_not_close_quote:
		cmp.b	#'{',d0
		bne	make_wordlist_not_open_brace

			tst.b	d6
			beq	make_wordlist_check_term

			addq.l	#1,d5
			bra	make_wordlist_check_term

make_wordlist_not_open_brace:
		cmp.b	#'}',d0
		bne	make_wordlist_not_close_brace

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
			tst.b	d4
			bne	make_wordlist_normal_loop_2

			tst.l	d5
			bne	make_wordlist_normal_loop_2

			cmpi.b	#'{',(a0)
			bne	make_wordlist_normal_loop_2

			addq.l	#1,d5
			move.b	(a0)+,d0
			bsr	make_wordlist_store1
			bne	make_wordlist_error

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

		move.b	(a0),d0
		bsr	issjis
		beq	make_wordlist_normal_loop_1
make_wordlist_dup_more_1:
		move.b	(a0)+,d0
		bsr	make_wordlist_store1
		bne	make_wordlist_error

		tst.b	d0
		beq	make_wordlist_done
make_wordlist_check_term:
		tst.b	d4
		bne	make_wordlist_normal_loop_1

		tst.l	d5
		bne	make_wordlist_normal_loop_1

		move.b	(a0),d0
		bsr	is_not_word_separator
		beq	make_wordlist_normal_loop_1

		bra	make_wordlist_terminate_word
****************
make_wordlist_done:
		move.l	d1,d0
make_wordlist_return:
		movem.l	(a7)+,d1-d6/a0-a1
		rts
********************************
make_wordlist_too_many_words:
		bsr	too_many_words
make_wordlist_error:
		moveq	#-1,d0
		bra	make_wordlist_return
****************************************************************
make_wordlist_store1:
		subq.w	#1,d2
		bcs	too_long_line

		subq.w	#1,d3
		bcs	too_long_word

		move.b	d0,(a1)+
		cmp.b	d0,d0				* �[���E�t���O���Z�b�g����
		rts
****************************************************************
.xdef is_not_word_separator

is_not_word_separator:
		move.l	a0,-(a7)
		lea	word_separators,a0
		and.w	#$ff,d0
		bsr	strchr
		movea.l	(a7)+,a0
		rts
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
		movem.l	d0-d1/a0-a1,-(a7)
		move.w	d0,d1
		bra	copy_wordlist_continue

copy_wordlist_loop:
		bsr	strmove
copy_wordlist_continue:
		dbra	d1,copy_wordlist_loop

		movem.l	(a7)+,d0-d1/a0-a1
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

		bsr	for1str
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

sort_wordlist:
		movem.l	d0-d2/a0-a3,-(a7)
		move.w	d0,d1
		movea.l	a0,a2
		bsr	fornstrs
		exg	a0,a2
sort_wordlist_loop2:
		cmp.w	#2,d1
		blo	sort_wordlist_done

		subq.w	#1,d1
		move.w	d1,d2
		subq.w	#1,d2
		movea.l	a0,a3
		movea.l	a0,a1
sort_wordlist_loop1:
		bsr	for1str
		bsr	strcmp
		bhs	sort_wordlist_loop1_continue

		movea.l	a0,a1
sort_wordlist_loop1_continue:
		dbra	d2,sort_wordlist_loop1

		movea.l	a3,a0
		cmpa.l	a0,a1
		beq	sort_wordlist_loop2_continue

		bsr	rotate
sort_wordlist_loop2_continue:
		bsr	for1str
		bra	sort_wordlist_loop2

sort_wordlist_done:
		movem.l	(a7)+,d0-d2/a0-a3
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
*      D1.W   �P��̍ŏ��̖�������ׂ������̒���
*      D2.B   0 �Ȃ�Α啶���Ə���������ʂ���
*
* RETURN
*      D0.L   �ŏ��̋��ʕ����̒���
*****************************************************************
.xdef common_spell

common_spell:
		movem.l	d1-d6/a0-a1,-(a7)
		moveq	#0,d4
		move.w	d0,d5
		beq	common_spell_done

		subq.w	#1,d5
		swap	d1
		clr.w	d1
		swap	d1
		lea	(a0,d1.l),a1
common_spell_loop1:
		move.w	d5,d3
		movea.l	a1,a0
		move.b	(a1)+,d0
		beq	common_spell_done

		bsr	issjis
		beq	common_spell_sjis
****************
		tst.b	d2
		beq	common_spell_ank_1

		bsr	toupper
common_spell_ank_1:
		move.b	d0,d6
		bra	common_spell_ank_continue

common_spell_ank_loop:
		bsr	for1str
		add.l	d1,a0
		move.b	(a0),d0
		tst.b	d2
		beq	common_spell_ank_2

		bsr	toupper
common_spell_ank_2:
		cmp.b	d6,d0
		bne	common_spell_done
common_spell_ank_continue:
		dbra	d3,common_spell_ank_loop

		addq.l	#1,d1
		addq.l	#1,d4
		bra	common_spell_loop1
****************
common_spell_sjis:
		lsl.w	#8,d0
		move.b	(a1)+,d0
		beq	common_spell_done

		bra	common_spell_sjis_continue

common_spell_sjis_loop:
		bsr	for1str
		add.l	d1,a0
		move.b	(a0),d6
		lsl.l	#8,d6
		move.b	1(a0),d6
		cmp.w	d0,d6
		bne	common_spell_done
common_spell_sjis_continue:
		dbra	d3,common_spell_sjis_loop

		addq.l	#2,d1
		addq.l	#2,d4
		bra	common_spell_loop1
****************
common_spell_done:
		move.l	d4,d0
		movem.l	(a7)+,d1-d6/a0-a1
		rts

.end
