* substcom.s
* Itagaki Fumihiko 25-Nov-90  Create.

.include doscall.h
.include limits.h
.include chrcode.h
.include ../src/fish.h

.xref issjis
.xref isspace3
.xref jstrchr
.xref copy_wordlist
.xref dup1
.xref dup1_2
.xref dup1_with_escaping
.xref dup1_with_escaping_in_quote
.xref eputc
.xref enputs
.xref fgetc
.xref tmpfile
.xref redirect
.xref unredirect
.xref perror
.xref fclose
.xref remove
.xref fork_and_wait
.xref manage_signals
.xref too_many_words
.xref too_long_word
.xref too_long_line
.xref msg_unmatched

.xref tmpline
.xref not_execute
.xref mainjmp
.xref stackp

.text

****************************************************************
abort:
		movea.l	stackp(a5),a7
		movea.l	mainjmp(a5),a0
		jmp	(a0)
****************************************************************
unmatched:
		moveq	#'`',d0
		bsr	eputc
		bsr	eputc
		lea	msg_unmatched,a0
		bsr	enputs
		moveq	#-4,d0
		rts
****************************************************************
* subst_command - �R�}���h�u��������
*
* CALL
*      A0     �\�[�X�ƂȂ�P��̐擪�A�h���X
*      A1     �i�[����o�b�t�@�̐擪�A�h���X
*      D0.W   �W�J�ꐔ�̌��x�DD2.B��0�̂Ƃ��ɂ͖���
*      D1.W   �o�b�t�@�̗e��
*
* RETURN
*      A0     �\�[�X�̏I�[�̎��̈ʒu
*             �������G���[�̂Ƃ��ɂ͕ۏ؂���Ȃ�
*
*      A1     �o�b�t�@�̎��̊i�[�ʒu
*             �������G���[�̂Ƃ��ɂ͕ۏ؂���Ȃ�
*
*      D0.L   �����Ȃ�ΐ����D���ʃ��[�h�͓W�J�ꐔ
*             �����Ȃ�΃G���[�D
*                  -1  �W�J�ꐔ�����x�𒴂���
*                  -2  �o�b�t�@�̗e�ʂ𒴂���
*                  -3  �P��̒������K��𒴂���
*                  -4  ���o�̓G���[�C�R�}���h�E�G���[���i���b�Z�[�W��\������j
*
*      D1.L   ���ʃ��[�h�͎c��o�b�t�@�e��
*             �������G���[�̂Ƃ��ɂ͕ۏ؂���Ȃ�
*             ��ʃ��[�h�͔j��
*
*      CCR    TST.L D0
*****************************************************************
.xdef subst_command

sourcep = -4
substtopp = sourcep-4
tmpfiledesc = sourcep-4
tmpfilename = tmpfiledesc-(((MAXPATH+1)+1)>>1<<1)
quote_char = tmpfilename-1
escape = quote_char-1
interrupted = escape-1
pad = interrupted-1		*  �����o�E���_���ɍ��킹��

subst_command:
		link	a6,#pad
		movem.l	d2-d7/a2,-(a7)
		clr.b	quote_char(a6)			* �N�I�[�g�E�t���O
		move.l	#-1,tmpfiledesc(a6)		* �ꎞ�t�@�C���f�X�N���v�^
		move.w	#MAXWORDLEN,d2			* D2.W : �P��̒����̍ő�l
		move.w	d0,d3				* D3.W : �P�ꐔ�̏��
		moveq	#0,d4				* D4.W : ���������P�ꐔ�J�E���^
		moveq	#1,d5				* D5.B : �u�V���Ȍ�Ƃ���v�t���O
subst_command_loop:
		move.b	(a0)+,d0
		beq	subst_command_done

		bsr	issjis
		beq	subst_command_dup2

		tst.b	quote_char(a6)
		beq	subst_command_not_in_quote

		cmp.b	quote_char(a6),d0
		beq	subst_command_quote

		cmpi.b	#'"',quote_char(a6)
		beq	subst_command_check_accent
		bra	subst_command_dup1

subst_command_quote:
		eor.b	d0,quote_char(a6)
		bra	subst_command_dup1

subst_command_not_in_quote:
		cmp.b	#'\',d0
		beq	subst_command_escape

		cmp.b	#'"',d0
		beq	subst_command_quote

		cmp.b	#"'",d0
		beq	subst_command_quote
subst_command_check_accent:
		cmp.b	#'`',d0
		bne	subst_command_dup1
********************************
		movea.l	a0,a2
subst_command_search_bottom:
		move.b	(a0)+,d0
		beq	subst_command_unmatched

		cmp.b	quote_char(a6),d0
		beq	subst_command_unmatched

		bsr	issjis
		bne	subst_command_search_bottom_not_sjis

		tst.b	(a0)+
		beq	subst_command_unmatched

		bra	subst_command_search_bottom

subst_command_search_bottom_not_sjis:
		cmp.b	#'`',d0
		bne	subst_command_search_bottom

		move.l	a0,d0
		subq.l	#1,d0
		sub.l	a2,d0
		movem.l	a0-a1,-(a7)
		movea.l	a2,a0
		lea	tmpfilename(a6),a1
		bsr	subst_command_redirect
		movem.l	(a7)+,a0-a1
		bmi	subst_command_return

		tst.b	not_execute(a5)
		bne	subst_command_loop

		move.l	d0,tmpfiledesc(a6)
		st	d7				*  first_flag = TRUE;
		move.l	a0,sourcep(a6)

		sf	interrupted(a6)
		move.l	mainjmp(a5),-(a7)
		move.l	stackp(a5),-(a7)
		move.l	a6,-(a7)
		lea	substcom_interrupted(pc),a0
		move.l	a7,stackp(a5)
		move.l	a0,mainjmp(a5)
substcom_skiploop:
		move.l	tmpfiledesc(a6),d0
		bsr	fgetc
		bmi	substcom_input_done

		bsr	is_separator
		beq	substcom_skiploop

		tst.b	d7
		bne	substcom_dup_start

		move.b	d0,d6
		tst.b	quote_char(a6)
		beq	subst_command_terminate_word_1

		moveq	#'"',d0
		bsr	dup1
		bmi	subst_command_return
subst_command_terminate_word_1:
		moveq	#0,d0
		moveq	#1,d2
		bsr	dup1
		bmi	subst_command_return

		moveq	#1,d5
		tst.b	quote_char(a6)
		beq	subst_command_terminate_word_2

		moveq	#'"',d0
		bsr	dup1
		bmi	subst_command_return
subst_command_terminate_word_2:
		move.b	d6,d0
substcom_dup_start:
		sf	d7				*  sjis_flag = FALSE;
substcom_duploop:
		tst.b	d7
		bne	i_dup_normal

		tst.b	quote_char(a6)
		bne	i_check_character_2

		cmp.b	#'\',d0
		beq	i_dup1_with_escaping

		cmp.b	#"'",d0
		beq	i_dup1_with_escaping
i_check_character_2:
		cmp.b	#'"',d0
		beq	i_dup1_with_escaping
i_dup_normal:
		bsr	dup1
		bra	i_dup1_check

i_dup1_with_escaping:
		tst.b	quote_char(a6)
		bne	i_dup1_in_quote

		bsr	dup1_with_escaping
		bra	i_dup1_check

i_dup1_in_quote:
		bsr	dup1_with_escaping_in_quote
i_dup1_check:
		bmi	subst_command_return

		tst.b	d7
		bne	i_dup1_next0

		bsr	issjis
		bne	i_dup1_next

		st	d7				*  sjis_flag = TRUE;
		bra	i_dup1_next

i_dup1_next0:
		sf	d7				*  sjis_flag = FALSE;
i_dup1_next:
		move.l	tmpfiledesc(a6),d0
		bsr	fgetc
		bmi	substcom_input_done

		tst.b	d7
		bne	substcom_duploop

		bsr	is_separator
		bne	substcom_duploop

		sf	d7				*  first_flag = FALSE;
		bra	substcom_skiploop
****************
is_separator:
		tst.b	d0
		beq	is_separator_return

		tst.b	quote_char(a6)
		beq	isspace3

		cmp.b	#LF,d0
		beq	is_separator_return

		cmp.b	#CR,d0
is_separator_return:
		rts
****************
substcom_interrupted:
		movea.l	(a7),a6
		st	interrupted(a6)
substcom_input_done:
		addq.l	#4,a7
		move.l	(a7)+,stackp(a5)
		move.l	(a7)+,mainjmp(a5)
		bsr	subst_command_erase_tmp
		tst.b	interrupted(a6)
		bne	abort

		move.l	#-1,tmpfiledesc(a6)
		movea.l	sourcep(a6),a0
		bra	subst_command_loop
********************************
subst_command_escape:
		bsr	dup1
		bmi	subst_command_return

		move.b	(a0)+,d0
		beq	subst_command_done

		bsr	issjis
		bne	subst_command_dup1
subst_command_dup2:
		bsr	dup1
		bmi	subst_command_return

		move.b	(a0)+,d0
		beq	subst_command_done
subst_command_dup1:
		bsr	dup1
		bmi	subst_command_return

		bra	subst_command_loop
********************************
subst_command_done:
		moveq	#0,d0
		move.w	d4,d0
		tst.b	d5
		bne	subst_command_return

		moveq	#0,d0
		moveq	#1,d2
		bsr	dup1
		bmi	subst_command_return

		moveq	#0,d0
		move.w	d4,d0
subst_command_return:
		tst.l	tmpfiledesc(a6)
		bmi	subst_command_return1

		bsr	subst_command_erase_tmp
subst_command_return1:
		movem.l	(a7)+,d2-d7/a2
		unlk	a6
		tst.l	d0
		rts


subst_command_unmatched:
		bsr	unmatched
		bra	subst_command_return


subst_command_erase_tmp:
		movem.l	d0/a0,-(a7)
		move.l	tmpfiledesc(a6),d0
		lea	tmpfilename(a6),a0
		bsr	erase_tmp
		movem.l	(a7)+,d0/a0
		rts
****************************************************************
* subst_command_2 - �R�}���h�u��������
*
* CALL
*      A0     �\�[�X�ƂȂ�P��̐擪�A�h���X
*      A1     �i�[����o�b�t�@�̐擪�A�h���X
*      D1.W   �o�b�t�@�̗e�ʁi�Ō�ɒu�����NUL���͊܂܂Ȃ��j
*
* RETURN
*      A0     �\�[�X�̏I�[�̎��̈ʒu
*             �������G���[�̂Ƃ��ɂ͕ۏ؂���Ȃ�
*
*      A1     �o�b�t�@�̎��̊i�[�ʒu
*             �������G���[�̂Ƃ��ɂ͕ۏ؂���Ȃ�
*
*      D0.L   0�Ȃ�ΐ���
*             �����Ȃ�΃G���[
*                  -1  �W�J�ꐔ�����x�𒴂���
*                  -2  �o�b�t�@�̗e�ʂ𒴂���
*                  -3  �P��̒������K��𒴂���
*                  -4  ���o�̓G���[�C�R�}���h�E�G���[���i���b�Z�[�W��\������j
*
*      D1.L   ���ʃ��[�h�͎c��o�b�t�@�e��
*             �������G���[�̂Ƃ��ɂ͕ۏ؂���Ȃ�
*             ��ʃ��[�h�͔j��
*
*      CCR    TST.L D0
*****************************************************************
.xdef subst_command_2

sourcep = -4
tmpfiledesc = sourcep-4
tmpfilename = tmpfiledesc-(((MAXPATH+1)+1)>>1<<1)
interrupted = tmpfilename-1
pad = interrupted-1		*  �����o�E���_���ɍ��킹��

subst_command_2:
		link	a6,#pad
		movem.l	a2-a3,-(a7)
		move.l	#-1,tmpfiledesc(a6)
subst_command_2_loop:
		move.b	(a0)+,d0
		beq	subst_command_2_done

		bsr	issjis
		beq	subst_command_2_dup2

		cmp.b	#'\',d0
		beq	subst_command_2_escape

		cmp.b	#'`',d0
		bne	subst_command_2_dup1
********************************
		movea.l	a0,a2
		moveq	#'`',d0
		bsr	jstrchr
		beq	subst_command_2_unmatched

		move.l	a0,d0
		sub.l	a2,d0
		addq.l	#1,a0
		movem.l	a0-a1,-(a7)
		movea.l	a2,a0
		lea	tmpfilename(a6),a1
		bsr	subst_command_redirect
		movem.l	(a7)+,a0-a1
		bmi	subst_command_2_return

		tst.b	not_execute(a5)
		bne	subst_command_2_loop

		move.l	d0,tmpfiledesc(a6)
		move.l	a0,sourcep(a6)
		movea.l	a1,a3

		sf	interrupted(a6)
		move.l	mainjmp(a5),-(a7)
		move.l	stackp(a5),-(a7)
		move.l	a6,-(a7)
		lea	substcom2_interrupted(pc),a0
		move.l	a7,stackp(a5)
		move.l	a0,mainjmp(a5)
subst_command_2_read_loop:
		move.l	tmpfiledesc(a6),d0
		bsr	fgetc
		bmi	subst_command_2_read_done
subst_command_2_read_loop_1:
		cmp.b	#LF,d0
		bne	subst_command_2_read_loop_dup1

		move.l	tmpfiledesc(a6),d0
		bsr	fgetc
		bmi	subst_command_2_read_done0

		movem.l	d0,-(a7)
		moveq	#LF,d0
		bsr	dup1_2
		movem.l	(a7)+,d0
		bmi	subst_command_2_return
		bra	subst_command_2_read_loop_1

subst_command_2_read_loop_dup1:
		bsr	dup1_2
		bmi	subst_command_2_return
		bra	subst_command_2_read_loop

subst_command_2_read_done0:
		cmpa.l	a3,a1
		bls	subst_command_2_read_done

		cmpi.b	#CR,-1(a1)
		bne	subst_command_2_read_done

		subq.l	#1,a1
		addq.w	#1,d1
		bra	subst_command_2_read_done

substcom2_interrupted:
		movea.l	(a7),a6
		st	interrupted(a6)
subst_command_2_read_done:
		addq.l	#4,a7
		move.l	(a7)+,stackp(a5)
		move.l	(a7)+,mainjmp(a5)
		bsr	subst_command_2_erase_tmp
		tst.b	interrupted(a6)
		bne	abort

		move.l	#-1,tmpfiledesc(a6)
		movea.l	sourcep(a6),a0
		bra	subst_command_2_loop

subst_command_2_escape:
		move.b	(a0)+,d0
		cmp.b	#'`',d0
		beq	subst_command_2_dup1

		cmp.b	#'\',d0
		beq	subst_command_2_dup1

		subq.l	#1,a0
		moveq	#'\',d0
		bra	subst_command_2_dup1

subst_command_2_dup2:
		bsr	dup1_2
		bmi	subst_command_2_return

		move.b	(a0)+,d0
		beq	subst_command_2_done
subst_command_2_dup1:
		bsr	dup1_2
		bmi	subst_command_2_return

		bra	subst_command_2_loop

subst_command_2_done:
		clr.b	(a1)+
		moveq	#0,d0
subst_command_2_return:
		tst.l	tmpfiledesc(a6)
		bmi	subst_command_2_return1

		bsr	subst_command_2_erase_tmp
subst_command_2_return1:
		movem.l	(a7)+,a2-a3
		unlk	a6
		tst.l	d0
		rts


subst_command_2_unmatched:
		bsr	unmatched
		bra	subst_command_2_return


subst_command_2_erase_tmp:
		movem.l	d0/a0,-(a7)
		move.l	tmpfiledesc(a6),d0
		lea	tmpfilename(a6),a0
		bsr	erase_tmp
		movem.l	(a7)+,d0/a0
		rts
****************************************************************
save_stdout = -4
pad = save_stdout-0

subst_command_redirect:
		link	a6,#pad
		move.l	#-1,save_stdout(a6)
		movem.l	d1-d3/a2,-(a7)
		move.l	d0,d3				*  D3.L : �P�ꐔ
		tst.b	not_execute(a5)
		bne	subst_command_redirect_1

		exg	a0,a1
		bsr	tmpfile
		exg	a0,a1
		bmi	subst_command_redirect_error1

		move.l	d0,d2				*  D2.L : �t�@�C���E�n���h��
		move.l	d0,d1
		moveq	#1,d0				*  �W���o�͂�
		bsr	redirect			*  ���_�C���N�g
		bmi	subst_command_redirect_error2

		move.l	d0,save_stdout(a6)
subst_command_redirect_1:
		move.l	mainjmp(a5),-(a7)
		move.l	stackp(a5),-(a7)
		movem.l	d2/a1/a6,-(a7)
		move.l	a7,stackp(a5)
		lea	subst_command_redirect_interrupted(pc),a2
		move.l	a2,mainjmp(a5)
		move.w	d3,d0
		moveq	#0,d1
		move.b	not_execute(a5),d2
		lea	subst_command_unredirect(pc),a1
		bsr	fork_and_wait
		movem.l	(a7)+,d2/a1/a6
		move.l	(a7)+,stackp(a5)
		move.l	(a7)+,mainjmp(a5)
		moveq	#0,d0
		tst.b	not_execute(a5)
		bne	subst_command_redirect_return

		clr.w	-(a7)				* �擪
		clr.l	-(a7)				* �@�܂�
		move.w	d2,-(a7)			*
		DOS	_SEEK				* �@�V�[�N����
		addq.l	#8,a7
		move.l	d2,d0				* �t�@�C���E�n���h����Ԃ�
subst_command_redirect_return:
		movem.l	(a7)+,d1-d3/a2
		unlk	a6
		rts


subst_command_redirect_error2:
		exg	a0,a1
		bsr	perror
		move.l	d2,d0
		bsr	erase_tmp
		exg	a0,a1
subst_command_redirect_error1:
		moveq	#-4,d0
		bra	subst_command_redirect_return


subst_command_redirect_interrupted:
		movem.l	(a7)+,d2/a1/a6
		move.l	(a7)+,stackp(a5)
		move.l	(a7)+,mainjmp(a5)
		bsr	subst_command_unredirect
		move.l	d0,-(a7)
		move.l	d2,d0
		movea.l	a1,a0
		bsr	erase_tmp
		move.l	(a7)+,d0
		bra	abort


subst_command_unredirect:
		movem.l	d0/a0,-(a7)
		moveq	#1,d0
		lea	save_stdout(a6),a0
		bsr	unredirect
		movem.l	(a7)+,d0/a0
		rts
****************************************************************
erase_tmp:
		bsr	fclose
		bra	remove
****************************************************************
* subst_command_wordlist - �P����т̊e�P��ɂ��ăR�}���h�u��������
*
* CALL
*      A0     �i�[�̈�̐擪�D�������тƏd�Ȃ��Ă��Ă��ǂ��D
*      A1     �������т̐擪
*      D0.W   �ꐔ
*
* RETURN
*      (tmpline)   �j�󂳂��
*
*      D0.L   �����Ȃ�ΐ����D���ʃ��[�h�͓W�J��̌ꐔ
*             �����Ȃ�΃G���[
*
*      CCR    TST.L D0
****************************************************************
.xdef subst_command_wordlist

subst_command_wordlist:
		movem.l	d1-d3/a0-a1,-(a7)
		move.w	#MAXWORDLISTSIZE,d1	* D1 : �ő啶����
		moveq	#0,d3			* D3 : �W�J��̌ꐔ
		move.w	d0,d2			* D2 : �����J�E���^
		move.l	a0,-(a7)
		lea	tmpline(a5),a0		* �ꎞ�̈��
		bsr	copy_wordlist		* �������т���U�R�s�[���Ă�����\�[�X�Ƃ���
		movea.l	(a7)+,a1
		bra	subst_wordlist_continue

subst_wordlist_loop:
		move.w	#MAXWORDS,d0
		sub.w	d3,d0
		bsr	subst_command
		bmi	subst_wordlist_subst_error

		add.w	d0,d3
subst_wordlist_continue:
		dbra	d2,subst_wordlist_loop

		moveq	#0,d0
		move.w	d3,d0
subst_wordlist_return:
		movem.l	(a7)+,d1-d3/a0-a1
		tst.l	d0
		rts


subst_wordlist_subst_error:
		cmp.l	#-1,d0
		beq	subst_wordlist_too_many_words

		cmp.l	#-2,d0
		beq	subst_wordlist_too_long_line

		cmp.l	#-3,d0
		beq	subst_wordlist_too_long_word

		bra	subst_wordlist_error

subst_wordlist_too_many_words:
		bsr	too_many_words
		bra	subst_wordlist_error

subst_wordlist_too_long_word:
		bsr	too_long_word
		bra	subst_wordlist_error

subst_wordlist_too_long_line:
		bsr	too_long_line
subst_wordlist_error:
		moveq	#-1,d0
		bra	subst_wordlist_return

.end
