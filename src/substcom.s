* substcom.s
* Itagaki Fumihiko 25-Nov-90  Create.

.include doscall.h
.include limits.h
.include chrcode.h
.include ../src/fish.h

.xref issjis
.xref isspace
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
.xref fork
.xref manage_signals
.xref set_status
.xref too_many_words
.xref too_long_word
.xref too_long_line
.xref msg_unmatched

.xref tmpline
.xref not_execute

.text

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

tmpfilename = -(((MAXPATH+1)+1)>>1<<1)
tmpfiledesc = tmpfilename-4
quote_char = tmpfiledesc-1
escape = quote_char-1
pad = escape-0			*  �����o�E���_���ɍ��킹��

subst_command:
		link	a6,#pad
		movem.l	d2-d7/a2-a3,-(a7)
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
		movea.l	a0,a3
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
		beq	isspace

		cmp.b	#LF,d0
		beq	is_separator_return

		cmp.b	#CR,d0
is_separator_return:
		rts
****************
substcom_input_done:
		move.l	tmpfiledesc(a6),d0
		lea	tmpfilename(a6),a0
		bsr	erase_tmp
		move.l	#-1,tmpfiledesc(a6)
		movea.l	a3,a0
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
		move.w	d4,d0
		tst.b	d5
		bne	subst_command_return

		moveq	#0,d0
		moveq	#1,d2
		bsr	dup1
		bmi	subst_command_return

		move.w	d4,d0
subst_command_return:
		tst.l	tmpfiledesc(a6)
		bmi	subst_command_return1

		movem.l	d0/a0,-(a7)
		move.l	tmpfiledesc(a6),d0
		lea	tmpfilename(a6),a0
		bsr	erase_tmp
		movem.l	(a7)+,d0/a0
subst_command_return1:
		movem.l	(a7)+,d2-d7/a2-a3
		unlk	a6
		tst.l	d0
		rts


subst_command_unmatched:
		bsr	unmatched
		bra	subst_command_return
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

tmpfilename = -(((MAXPATH+1)+1)>>1<<1)

subst_command_2:
		link	a6,#tmpfilename
		movem.l	d7/a2-a4,-(a7)
		moveq	#-1,d7				* D7.L : �ꎞ�t�@�C���f�X�N���v�^
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

		move.l	d0,d7
		movea.l	a0,a3
		movea.l	a1,a4
subst_command_2_read_loop:
		move.w	d7,d0
		bsr	fgetc
		bmi	subst_command_2_read_done
subst_command_2_read_loop_1:
		cmp.b	#LF,d0
		bne	subst_command_2_read_loop_dup1

		move.w	d7,d0
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
		cmpa.l	a4,a1
		bls	subst_command_2_read_done

		cmpi.b	#CR,-1(a1)
		bne	subst_command_2_read_done

		subq.l	#1,a1
		addq.w	#1,d1
subst_command_2_read_done:
		move.w	d7,d0
		lea	tmpfilename(a6),a0
		bsr	erase_tmp
		moveq	#-1,d7
		movea.l	a3,a0
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
		tst.l	d7
		bmi	subst_command_2_return1

		movem.l	d0/a0,-(a7)
		move.w	d7,d0
		lea	tmpfilename(a6),a0
		bsr	erase_tmp
		movem.l	(a7)+,d0/a0
subst_command_2_return1:
		movem.l	(a7)+,d7/a2-a4
		unlk	a6
		tst.l	d0
		rts


subst_command_2_unmatched:
		bsr	unmatched
		bra	subst_command_2_return
****************************************************************
subst_command_redirect:
		movem.l	d1-d3,-(a7)
		move.l	d0,d3				*  D3.L : �P�ꐔ
		tst.b	not_execute(a5)
		bne	subst_command_redirect_1

		exg	a0,a1
		bsr	tmpfile
		exg	a0,a1
		bmi	subst_command_redirect_error

		move.l	d0,d2				*  D2.L : �t�@�C���E�n���h��
		move.l	d0,d1
		moveq	#1,d0				*  �W���o�͂�
		bsr	redirect			*  ���_�C���N�g
		bmi	subst_command_redirect_perror
subst_command_redirect_1:
		movem.l	d0-d2,-(a7)
		move.w	d3,d0
		moveq	#0,d1
		move.b	not_execute(a5),d2
		bsr	fork
		move.l	d0,d3				*  D3.L : fork �� status
		movem.l	(a7)+,d0-d2
		tst.b	not_execute(a5)
		bne	subst_command_redirect_2

		move.l	d0,d1
		moveq	#1,d0
		bsr	unredirect
subst_command_redirect_2:
		move.l	d3,d0
		beq	subst_command_fork_success

		bsr	set_status
		clr.b	d3
		cmp.l	#$200,d3
		beq	signal_raised

		cmp.l	#$300,d3
		beq	signal_raised
subst_command_fork_success:
		tst.b	not_execute(a5)
		bne	subst_command_redirect_3

		clr.w	-(a7)				* �擪
		clr.l	-(a7)				* �@�܂�
		move.w	d2,-(a7)			* �@
		DOS	_SEEK				* �@�V�[�N����
		addq.l	#8,a7
		move.l	d2,d0				* �t�@�C���E�n���h����Ԃ�
subst_command_redirect_return:
		movem.l	(a7)+,d1-d3
		rts

subst_command_redirect_3:
		moveq	#0,d0
		bra	subst_command_redirect_return

subst_command_redirect_perror:
		bsr	perror
subst_command_redirect_error:
		moveq	#-4,d0
		bra	subst_command_redirect_return

signal_raised:
		exg	d0,d2
		exg	a0,a1
		bsr	erase_tmp
		exg	a0,a1
		exg	d0,d2
		bra	manage_signals
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
