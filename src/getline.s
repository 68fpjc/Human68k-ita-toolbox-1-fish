* getline.s
* Itagaki Fumihiko 29-Jul-90  Create.
* Itagaki Fumihiko 16-Aug-91  'complete' �ŁA'.' �Ŏn�܂�G���g��
*                             �i"." �� ".." �������j��⊮����悤�ɂ����D
* Itagaki Fumihiko 29-Aug-91  addsuffix, autolist, recexact
* Itagaki Fumihiko  6-Sep-91  prompt %?

.include doscall.h
.include chrcode.h
.include limits.h
.include stat.h
.include pwd.h
.include ../src/fish.h
.include ../src/source.h
.include ../src/history.h
.include ../src/var.h
.include ../src/function.h

.xref iscntrl
.xref isdigit
.xref issjis
.xref isspace
.xref tolower
.xref toupper
.xref atou
.xref itoa
.xref strbot
.xref jstrchr
.xref strcpy
.xref strcmp
.xref strlen
.xref strfor1
.xref strforn
.xref memcmp
.xref memxcmp
.xref memmovi
.xref memmovd
.xref rotate
.xref skip_space
.xref sort_wordlist
.xref uniq_wordlist
.xref is_all_same_word
.xref putc
.xref cputc
.xref puts
.xref put_newline
.xref printfi
.xref printfs
.xref compile_esch
.xref preparse_fmtout
.xref builtin_dir_match
.xref check_executable_suffix
.xref check_executable_script
.xref isttyin
.xref fgetc
.xref fgets
.xref tfopen
.xref fclose
.xref close_tmpfd
.xref open_passwd
.xref fgetpwent
.xref expand_tilde
.xref contains_dos_wildcard
.xref headtail
.xref cat_pathname
.if 0
.xref findvar
.xref cmd_eval
.xref find_function
.xref source_function
.endif
.xref find_shellvar
.xref get_var_value
.xref svartol
.xref common_spell
.xref getcwdx
.xref search_up_history
.xref search_down_history
.xref is_histchar_canceller
.xref minmaxul
.xref divul
.xref drvchkp
.xref manage_interrupt_signal
.xref too_long_line
.xref statement_table
.xref builtin_table
.xref word_nomatch
.xref word_exact
.xref word_path
.xref word_prompt
.xref word_prompt2
.xref word_status
.xref dos_allfile

.xref congetbuf
.xref tmpargs
.xref tmpword1
.xref tmpword2

.xref history_top
.xref history_bot
.xref current_eventno
.xref current_source
.xref alias_top
.xref shellvar_top
.xref env_top
.xref function_bot
.if 0
.xref function_root
.endif
.xref funcdef_status
.xref switch_status
.xref if_status
.xref loop_status
.xref histchar1
.xref flag_autolist
.xref flag_cifilec
.xref flag_noalias
.xref flag_nobeep
.xref flag_nonullcommandc
.xref flag_recexact
.xref flag_recunexec
.xref flag_usegets
.xref last_congetbuf
.xref keymap
.xref keymacromap
.xref linecutbuf
.xref tmpfd
.xref in_prompt

.text

*****************************************************************
* getline
*
* CALL
*      A0     ���̓o�b�t�@�̐擪
*      D1.W   ���͍ő�o�C�g���i32767�ȉ��D�Ō��NUL���͊��肵�Ȃ��j
*      D2.B   1 �Ȃ�΃R�����g���폜����
*      A1     �v�����v�g�o�̓��[�`���̃G���g���E�A�h���X
*      A2     �����s���̓��[�`���̃G���g���E�A�h���X
*      D7.L   (A2) �ւ̈��� D0.L
*
* RETURN
*      D0.L   0:���͗L��C-1:EOF�C1:���̓G���[
*      D1.W   �c����͉\�o�C�g���i�Ō��NUL���͊��肵�Ȃ��j
*      CCR    TST.L D0
*****************************************************************
.xdef getline

getline:
		movem.l	d3-d5/a0-a4,-(a7)
		moveq	#0,d3				*  D3.B : �S�̃N�I�[�g�E�t���O
getline_more:
		**
		**  �P�����s����͂���
		**
		movea.l	a0,a4
		move.l	d7,d0
		jsr	(a2)
		bne	getline_return

		suba.l	a1,a1
****************
		tst.b	d2
		beq	getline_comment_cut_done
		**
		**  �R�����g��T��
		**
		movea.l	a4,a3
		move.b	d3,d5
		moveq	#0,d4				*  D4.L : {}���x��
find_comment_loop:
		move.b	(a3)+,d0
		beq	find_comment_break

		bsr	issjis
		beq	find_comment_skip_one

		tst.l	d4
		beq	find_comment_0

		cmp.b	#'}',d0
		bne	find_comment_0

		subq.l	#1,d4
find_comment_0:
		tst.b	d5
		beq	find_comment_1

		cmp.b	d5,d0
		bne	find_comment_loop
find_comment_flip_quote:
		eor.b	d0,d5
		bra	find_comment_loop

find_comment_1:
		tst.l	d4
		bne	find_comment_2

		cmp.b	#'#',d0
		beq	find_comment_break
find_comment_2:
		cmp.b	#'\',d0
		beq	find_comment_ignore_next_char

		cmp.b	#'"',d0
		beq	find_comment_flip_quote

		cmp.b	#"'",d0
		beq	find_comment_flip_quote

		cmp.b	#'`',d0
		beq	find_comment_flip_quote

		cmp.b	#'!',d0
		beq	find_comment_special

		cmp.b	#'$',d0
		bne	find_comment_loop

		cmpi.b	#'@',(a3)
		beq	find_comment_special_var

		cmpi.b	#'%',(a3)
		bne	find_comment_special
find_comment_special_var:
		addq.l	#1,a3
find_comment_special:
		cmpi.b	#'{',(a3)
		bne	find_comment_ignore_next_char

		addq.l	#1,a3
		addq.l	#1,d4
		bra	find_comment_loop

find_comment_ignore_next_char:
		move.b	(a3)+,d0
		beq	find_comment_break

		bsr	issjis
		bne	find_comment_loop
find_comment_skip_one:
		move.b	(a3)+,d0
		bne	find_comment_loop
find_comment_break:
		**
		**  �R�����g���폜����
		**
		clr.b	-(a3)
		move.l	a0,d0
		sub.l	a3,d0
		add.w	d0,d1
		movea.l	a3,a0
getline_comment_cut_done:
		**
		**  �s�p�����`�F�b�N����
		**
		movea.l	a4,a3
getline_cont_check_loop:
		cmpa.l	a0,a3
		beq	getline_newline_not_escaped

		move.b	(a3)+,d0
		bsr	issjis
		beq	getline_cont_check_sjis

		cmp.b	#'"',d0
		beq	getline_cont_check_quote

		cmp.b	#"'",d0
		beq	getline_cont_check_quote

		cmp.b	#'`',d0
		beq	getline_cont_check_quote

		tst.b	d3
		bne	getline_cont_check_loop

		cmp.b	#'\',d0
		bne	getline_cont_check_loop

		cmpa.l	a0,a3
		beq	getline_newline_escaped

		move.b	(a3),d0
		bsr	issjis
		beq	getline_cont_check_loop
getline_cont_check_skip:
		addq.l	#1,a3
		bra	getline_cont_check_loop

getline_cont_check_quote:
		tst.b	d3
		beq	getline_cont_check_quote_open

		cmp.b	d3,d0
		bne	getline_cont_check_loop
getline_cont_check_quote_open:
		eor.b	d0,d3
		bra	getline_cont_check_loop

getline_cont_check_sjis:
		cmpa.l	a0,a3
		bne	getline_cont_check_skip
getline_newline_not_escaped:
		tst.b	d3
		beq	getline_done
		*
		*  �N�I�[�g�����Ă��Ȃ��B
		*  ���s�𕜋A���s�Ƃ��ăN�I�[�g����B
		*
		subq.w	#2,d1
		bcs	getline_over

		move.b	#CR,(a0)+
		move.b	#LF,(a0)+
		clr.b	(a0)
		bra	getline_more

getline_newline_escaped:
		*
		*  ���s�� \ �ŃG�X�P�[�v����Ă���B
		*  \����菜���A���s��}�������ɍs�p������B
		*
		addq.w	#1,d1
		clr.b	-(a0)
		bra	getline_more

getline_done:
		moveq	#0,d0
getline_return:
		movem.l	(a7)+,d3-d5/a0-a4
		rts

getline_over:
		moveq	#1,d0
		bra	getline_return
*****************************************************************
* getline_phigical
*
* CALL
*      A0     ���̓o�b�t�@�̐擪
*      A1     �v�����v�g�o�̓��[�`���̃G���g���E�A�h���X
*      D0.W   ���̓t�@�C���E�n���h��
*      D1.W   ���͍ő�o�C�g���i32767�ȉ��D�Ō��NUL���͊��肵�Ȃ��j
*
* RETURN
*      A0     ���͕��������i��
*      D0.L   0:���͗L��C-1:EOF�C1:���̓G���[
*      D1.W   �c����͉\�o�C�g���i�Ō��NUL���͊��肵�Ȃ��j
*      CCR    TST.L D0
*****************************************************************
.xdef getline_phigical

getline_phigical:
		tst.l	current_source(a5)
		beq	getline_phigical_stdin

		bsr	getline_phigical_script
		bra	getline_phigical_1

getline_phigical_stdin:
		bsr	getline_file
getline_phigical_1:
		beq	getline_phigical_return
		bpl	too_long_line
getline_phigical_return:
		rts
****************
getline_phigical_script:
		DOS	_KEYSNS				*  To allow interrupt
		movem.l	a1-a2,-(a7)
		movea.l	current_source(a5),a2
		movea.l	SOURCE_POINTER(a2),a1
		movea.l	SOURCE_BOT(a2),a2
		bsr	getline_script_sub
		bmi	getline_phigical_script_return

		movea.l	current_source(a5),a2
		move.l	a1,SOURCE_POINTER(a2)
		addq.l	#1,SOURCE_LINENO(a2)
getline_phigical_script_return:
		movem.l	(a7)+,a1-a2
		tst.l	d0
		rts
*****************************************************************
getline_script_sub:
		move.l	d2,-(a7)
		moveq	#0,d2
getline_script_sub_loop:
		cmpa.l	a2,a1
		bhs	getline_script_sub_eof

		move.b	(a1)+,d0
		cmp.b	#LF,d0
		beq	getline_script_sub_lf

		cmp.b	#CR,d0
		bne	getline_script_sub_dup1

		cmpa.l	a2,a1
		bhs	getline_script_sub_eof

		cmpi.b	#LF,(a1)
		beq	getline_script_sub_crlf
getline_script_sub_dup1:
		subq.w	#1,d1
		bcs	getline_script_sub_over

		move.b	d0,(a0)+
		bra	getline_script_sub_loop

getline_script_sub_over:
		addq.w	#1,d1
		moveq	#1,d2
		bra	getline_script_sub_loop

getline_script_sub_crlf:
		addq.l	#1,a1
getline_script_sub_lf:
		clr.b	(a0)
getline_script_sub_return:
		move.l	d2,d0
		move.l	(a7)+,d2
		tst.l	d0
		rts

getline_script_sub_eof:
		moveq	#-1,d2
		bra	getline_script_sub_return
*****************************************************************
.xdef getline_file

getline_file:
		movem.l	d0,-(a7)
		bsr	isttyin
		movem.l	(a7)+,d0
		bne	getline_console

		bra	fgets
*****************************************************************
getline_console:
		bsr	put_prompt
		tst.b	flag_usegets(a5)
		beq	getline_x

getline_standard_console:
		move.l	a1,-(a7)

		move.l	a0,-(a7)
		lea	congetbuf,a0
		move.l	a0,-(a7)
		move.b	#255,(a0)+

		lea	last_congetbuf(a5),a1
		move.b	(a1)+,(a0)+
		bsr	strcpy
		DOS	_GETS
		addq.l	#4,a7
		bsr	put_newline
		lea	congetbuf+1,a0
		tst.b	(a0)+
		beq	getline_console_done

		bsr	skip_space
		tst.b	(a0)
		beq	getline_console_done

		lea	congetbuf+1,a1
		lea	last_congetbuf(a5),a0
		move.b	(a1)+,(a0)+
		bsr	strcpy
getline_console_done:
		movea.l	(a7)+,a0

		lea	congetbuf+1,a1
		clr.w	d0
		move.b	(a1)+,d0
		sub.w	d0,d1
		bcs	getline_console_over

		bsr	memmovi
getline_console_ok:
		clr.b	(a0)
		moveq	#0,d0
getline_console_return:
		movea.l	(a7)+,a1
		rts

getline_console_over:
		moveq	#1,d0
		bra	getline_console_return

getline_console_eof:
		moveq	#-1,d0
		bra	getline_console_return
*****************************************************************

put_prompt_ptr = -4
macro_ptr = put_prompt_ptr-4
line_top = macro_ptr-4
x_histptr = line_top-4
input_handle = x_histptr-4
mark = input_handle-2
point = mark-2
nbytes = point-2
keymap_offset = nbytes-2
quote = keymap_offset-1
killing = quote-1
x_histflag = killing-1
pad = x_histflag-1				*  �����o�E���_���[�ɍ��킹��

getline_x:
		link	a6,#pad
		movem.l	d2-d7/a1-a3,-(a7)
		move.w	d0,input_handle(a6)
		move.l	a0,line_top(a6)
		move.l	a1,put_prompt_ptr(a6)
		clr.l	macro_ptr(a6)
		clr.w	nbytes(a6)
		clr.w	point(a6)
		move.w	#-1,mark(a6)
getline_x_0:
		sf	quote(a6)
getline_x_1:
		bsr	reset_history_ptr
getline_x_2:
		sf	killing(a6)
getline_x_3:
		clr.w	keymap_offset(a6)
getline_x_4:
		bsr	getline_x_getc
		bmi	getline_x_eof

		tst.b	quote(a6)
		bne	x_self_insert

		tst.b	d0
		bmi	x_self_insert

		moveq	#0,d2
		move.b	d0,d2
		add.w	keymap_offset(a6),d2
		lea	keymap(a5),a0
		moveq	#0,d3
		move.b	(a0,d2.l),d3
		lsl.l	#2,d3
		lea	key_function_jump_table,a0
		movea.l	(a0,d3.l),a0
		jmp	(a0)
********************************
*  list-or-eof
********************************
********************************
*  eof
********************************
x_list_or_eof:
		tst.w	nbytes(a6)
		bne	x_list
x_eof:
		bsr	iscntrl
		sne	d1
		bsr	cputc
		moveq	#2,d0
		tst.b	d1
		beq	x_eof_1

		moveq	#1,d0
x_eof_1:
		bsr	backward_cursor
getline_x_eof:
		moveq	#-1,d0
getline_x_return:
		movem.l	(a7)+,d2-d7/a1-a3
		unlk	a6
		rts
********************************
reset_history_ptr:
		movea.l	history_bot(a5),a0
		move.l	a0,x_histptr(a6)
		clr.b	x_histflag(a6)
		rts
********************************
*  self-insert
********************************
x_self_insert:
		move.b	d0,d4				*  D4.B : ��P�o�C�g
		moveq	#1,d2				*  D2.W : �}������o�C�g��
		bsr	issjis
		sne	d3				*  D3.B : �u�V�t�gJIS�����ł���v
		bne	x_self_insert_1

		bsr	getline_x_getc
		bmi	getline_x_eof

		move.b	d0,d5				*  D5.B : �V�t�gJIS�̑�Q�o�C�g
		moveq	#2,d2
x_self_insert_1:
		bsr	open_columns
		bcs	x_self_insert_over

		move.b	d4,(a0)
		tst.b	d3
		bne	x_self_insert_2

		move.b	d5,1(a0)
x_self_insert_2:
		bsr	post_insert_job
x_self_insert_done:
		bra	getline_x_0

x_self_insert_over:
		bsr	beep
		bra	x_self_insert_done
********************************
*  error
********************************
x_error:
		bsr	beep
		bra	getline_x_2
********************************
*  macro
********************************
x_macro:
		tst.l	macro_ptr(a6)
		bne	x_error				*  �}�N���Ń}�N���͌Ăяo���Ȃ��̂�

		lea	keymacromap(a5),a0
		lsl.l	#2,d2
		move.l	(a0,d2.l),macro_ptr(a6)
		bra	getline_x_2
********************************
*  prefix-1
********************************
x_prefix_1:
		move.w	#128,keymap_offset(a6)
		bra	getline_x_4
********************************
*  prefix-2
********************************
x_prefix_2:
		move.w	#256,keymap_offset(a6)
		bra	getline_x_4
********************************
*  abort
********************************
x_abort:
		bsr	cputc
		bsr	put_newline
		bra	manage_interrupt_signal
********************************
*  cr
********************************
x_accept_line:
		bsr	eol_newline
		movea.l	line_top(a6),a0
		move.w	nbytes(a6),d0
		lea	(a0,d0.w),a0
		clr.b	(a0)
		moveq	#0,d0
		bra	getline_x_return
********************************
*  quoted-insert
********************************
x_quoted_insert:
		st	quote(a6)
		bra	getline_x_2
********************************
*  redraw
********************************
********************************
*  clear-and-redraw
********************************
x_clear_and_redraw:
		lea	t_clear,a0
		bsr	puts
		bra	x_redraw_1

x_redraw:
		bsr	eol_newline
x_redraw_1:
		bsr	redraw_with_prompt
		bra	getline_x_2
********************************
*  set-mark
********************************
x_set_mark:
		move.w	point(a6),mark(a6)
		bra	getline_x_2
********************************
*  exchange-point-and-mark
********************************
x_exg_point_and_mark:
		move.w	mark(a6),d0
		bmi	x_error

		move.w	point(a6),mark(a6)
x_goto:
		move.w	point(a6),d2			*  D2.W : point
		move.w	d0,point(a6)
		movea.l	line_top(a6),a0
		lea	backward_cursor_x(pc),a1
		cmp.w	d0,d2
		bhi	x_exg_point_and_mark_2

		lea	forward_cursor_x(pc),a1
		exg	d0,d2
x_exg_point_and_mark_2:
		lea	(a0,d0.w),a0
		sub.w	d0,d2
		move.w	d2,d0
		jsr	(a1)
		bra	getline_x_2
********************************
*  search-character
********************************
x_search_character:
		bsr	getline_x_getletter
		bmi	getline_x_eof

		movea.l	line_top(a6),a0
		move.w	nbytes(a6),d2
		clr.b	(a0,d2.w)
		move.w	point(a6),d4
		cmp.w	d2,d4
		beq	x_search_char_1

		exg	d0,d4
		bsr	x_size_forward
		exg	d0,d4
		add.w	d2,d4
		lea	(a0,d4.w),a0
		bsr	jstrchr
		bne	x_search_char_ok
x_search_char_1:
		movea.l	line_top(a6),a0
		bsr	jstrchr
		beq	x_error
x_search_char_ok:
		move.l	a0,d0
		movea.l	line_top(a6),a0
		sub.l	a0,d0
		bra	x_goto
********************************
*  beginning-of-line
********************************
x_bol:
		bsr	moveto_bol
		bra	getline_x_2
********************************
*  end-of-line
********************************
x_eol:
		bsr	move_cursor_to_eol
		move.w	nbytes(a6),point(a6)
		bra	getline_x_2
********************************
*  backward-char
********************************
x_backward_char:
		bsr	move_letter_backward
		bra	getline_x_2
********************************
*  forward-char
********************************
x_forward_char:
		bsr	move_letter_forward
		bra	getline_x_2
********************************
*  backward-word
********************************
x_backward_word:
		bsr	move_word_backward
		bra	getline_x_2
********************************
*  forward-word
********************************
x_forward_word:
		bsr	move_word_forward
		bra	getline_x_2
********************************
*  delete-backward-char
********************************
x_del_back_char:
		bsr	move_letter_backward
		move.w	point(a6),d4
xp_delete:
		bsr	delete_region
		bra	getline_x_1
********************************
*  delete-forward-char-or-list-or-eof
********************************
********************************
*  delete-forward-char-or-list
********************************
********************************
*  delete-forward-char
********************************
x_del_for_char_or_list_or_eof:
		tst.w	nbytes(a6)
		beq	x_eof
x_del_for_char_or_list:
		move.w	point(a6),d0
		cmp.w	nbytes(a6),d0
		beq	x_list
x_del_for_char:
		move.w	point(a6),d4
		bsr	forward_letter
		move.w	d4,point(a6)
		bra	xp_delete
********************************
*  kill-backward-word
********************************
x_kill_back_word:
		bsr	backward_word
		move.w	point(a6),d4
		moveq	#3,d7
		bra	x_kill_region_backward_1
********************************
*  kill-forward-word
********************************
x_kill_for_word:
		move.w	point(a6),d4
		bsr	forward_word
		moveq	#1,d7
		bra	x_kill_or_copy_region_2
********************************
*  kill-whole-line
********************************
x_kill_whole_line:
		bsr	moveto_bol
********************************
*  kill-to-eol
********************************
x_kill_eol:
		move.w	nbytes(a6),d4
x_kill_eol_1:
		moveq	#1,d7
		bra	x_kill_or_copy_region_1
********************************
*  kill-to-bol
********************************
x_kill_bol:
		moveq	#0,d4
		bra	x_kill_eol_1
********************************
*  kill-region
********************************
********************************
*  copy-region
********************************
x_copy_region:
		moveq	#0,d7
		bra	x_kill_or_copy_region

x_kill_region:
		moveq	#1,d7
x_kill_or_copy_region:
		move.w	mark(a6),d0
		bmi	x_error

		move.w	d0,d4				*  D4.W : mark
x_kill_or_copy_region_1:
		move.w	point(a6),d2			*  D2.W : point
		cmp.w	d4,d2
		bhs	x_kill_region_backward

		exg	d2,d4
		bsr	compile_region
x_kill_or_copy_region_2:
		move.w	d4,point(a6)
x_kill_or_copy_region_3:
		move.b	d7,d0
		bsr	copy_region_to_buffer
		btst	#0,d7
		beq	x_kill_or_copy_region_done

		bsr	delete_region
x_kill_or_copy_region_done:
		bsr	reset_history_ptr
		bra	getline_x_3

x_kill_region_backward:
		bset	#1,d7
		bsr	compile_region
x_kill_region_backward_1:
		btst	#0,d7
		beq	x_kill_or_copy_region_3

		move.l	d3,d0
		bsr	backward_cursor
		bra	x_kill_or_copy_region_2

compile_region:
		movea.l	line_top(a6),a0
		lea	(a0,d4.w),a0
		sub.w	d4,d2
		move.w	d2,d0
		bsr	region_width
		move.l	d0,d3
		rts
********************************
*  yank
********************************
x_yank:
		lea	linecutbuf(a5),a0
		bsr	strlen
		move.l	d0,d2
		movea.l	a0,a1
x_copy:
		bsr	open_columns
		bcs	x_over

		move.l	d2,d0
		move.l	a0,-(a7)
		bsr	memmovi
		movea.l	(a7)+,a0
		bsr	post_insert_job
		bra	getline_x_1

x_over:
		bsr	beep
		bra	getline_x_1
********************************
*  copy-prev-word
********************************
x_copy_prev_word:
		move.w	point(a6),-(a7)
		bsr	backward_word
		move.w	point(a6),d0
		move.w	(a7)+,point(a6)
		movea.l	line_top(a6),a1
		lea	(a1,d0.w),a1
		bra	x_copy
********************************
*  upcase-char
********************************
x_upcase_char:
		lea	toupper(pc),a1
chcase_char:
		moveq	#1,d0
chcase:
		bsr	chcase_sub
		bra	getline_x_1

chcase_sub:
		move.w	point(a6),d4
		add.w	d0,d4
chcase_loop:
		move.w	point(a6),d3
		cmp.w	nbytes(a6),d3
		beq	chcase_done

		cmp.w	d4,d3
		bhs	chcase_done

		movea.l	line_top(a6),a0
		move.b	(a0,d3.w),d0
		jsr	(a1)
		cmp.b	(a0,d3.w),d0
		beq	chcase_char_not_changed

		move.b	d0,(a0,d3.w)
		bsr	putc
		bsr	forward_letter
		bra	chcase_loop

chcase_char_not_changed:
		bsr	move_letter_forward
		bra	chcase_loop

chcase_done:
		rts
********************************
*  downcase-char
********************************
x_downcase_char:
		lea	tolower(pc),a1
		bra	chcase_char
********************************
*  upcase-word
********************************
x_upcase_word:
		lea	toupper(pc),a1
chcase_word:
		move.w	point(a6),-(a7)
		bsr	forward_word
		move.w	(a7)+,point(a6)
		move.w	d2,d0
		bra	chcase
********************************
*  downcase-word
********************************
x_downcase_word:
		lea	tolower(pc),a1
		bra	chcase_word
********************************
*  upcase-region
********************************
x_upcase_region:
		lea	toupper(pc),a1
chcase_region:
		move.w	mark(a6),d0
		bmi	x_error

		move.w	point(a6),d2
		cmp.w	d0,d2
		bls	chcase_region_forward

		move.w	d0,point(a6)
		movea.l	line_top(a6),a0
		lea	(a0,d0.w),a0
		sub.w	d0,d2
		move.w	d2,d0
		bsr	backward_cursor_x
		move.w	d2,d0
		bra	chcase

chcase_region_forward:
		sub.w	d2,d0
		movem.l	d0/d2,-(a7)
		bsr	chcase_sub
		movem.l	(a7)+,d0/d2
		move.w	d2,point(a6)
		movea.l	line_top(a6),a0
		lea	(a0,d2.w),a0
		bsr	backward_cursor_x
		bra	getline_x_1
********************************
*  downcase-region
********************************
x_downcase_region:
		lea	tolower(pc),a1
		bra	chcase_region
********************************
*  transpose-chars
********************************
x_transpose_chars:
		move.w	point(a6),d0
		cmp.w	nbytes(a6),d0
		blo	x_transpose_chars_1

		bsr	move_letter_backward
x_transpose_chars_1:
		move.w	point(a6),d0
		beq	x_error

		bsr	x_size_forward
		move.w	d2,d4
		bsr	move_letter_backward
		bsr	transpose
		bra	getline_x_1
********************************
*  transpose-words
********************************
x_transpose_words:
		move.w	point(a6),d4
		bsr	move_word_forward
		bsr	move_word_backward
		move.w	point(a6),d0
		bne	x_transpose_word_ok

		move.w	d4,point(a6)
		move.w	d4,d0
		movea.l	line_top(a6),a0
		bsr	forward_cursor_x
		bra	x_error

x_transpose_word_ok:
		move.w	d2,d4				*  D4.W : �E�̒P��̃o�C�g��
		bsr	move_word_backward
		move.w	d2,d5				*  D5.W : ���̒P��{�X�y�[�X�̃o�C�g��
		move.l	d3,d6				*  D6.L : ���̒P��{�X�y�[�X�̕�����
		move.w	point(a6),-(a7)
		bsr	forward_word			*  D2.W : ���̒P��̃o�C�g��
		move.w	(a7),point(a6)
		exg	d2,d5
		bsr	transpose
		sub.w	d2,point(a6)
		move.l	d6,d0
		bsr	backward_cursor
		move.w	d2,d4
		sub.w	d5,d4
		move.w	d5,d2
		bsr	transpose
		bra	getline_x_1
********************************
transpose:
		movea.l	line_top(a6),a0
		adda.w	point(a6),a0			*  ������
		lea	(a0,d2.w),a1
		lea	(a1,d4.w),a2
		bsr	rotate
		move.w	d2,d0
		add.w	d4,d0
		bsr	write_chars
		move.w	mark(a6),d3
		bmi	transpose_done

		sub.w	point(a6),d3
		blo	transpose_done

		sub.w	d2,d3
		blo	transpose_mark_forward

		sub.w	d4,d3
		bhs	transpose_done

		sub.w	d2,mark(a6)
		bra	transpose_done

transpose_mark_forward:
		add.w	d4,mark(a6)
transpose_done:
		add.w	d0,point(a6)
		rts
********************************
*  up-history
********************************
x_up_history:
		movea.l	line_top(a6),a0
		moveq	#0,d0
		move.w	point(a6),d0

		movea.l	x_histptr(a6),a1
		btst.b	#0,x_histflag(a6)
		beq	x_up_history_1

		cmpa.l	#0,a1
		beq	x_up_history_2

		movea.l	HIST_PREV(a1),a1
x_up_history_1:
		moveq	#0,d2
		bsr	search_up_history
		bne	history_found
x_up_history_2:
		btst.b	#1,x_histflag(a6)
		beq	search_history_fail

		movea.l	history_bot(a5),a1
		moveq	#0,d2
		bsr	search_up_history
search_history_done:
		bne	history_found
search_history_fail:
		bset.b	#1,x_histflag(a6)
		bra	x_error

history_found:
		move.l	a1,x_histptr(a6)
		move.b	#1,x_histflag(a6)

		bsr	delete_line
		move.w	#-1,mark(a6)

		movea.l	line_top(a6),a0
		move.w	HIST_NWORDS(a1),d2		*  D2.W : ���̃C�x���g�̒P�ꐔ
		subq.w	#1,d2
		bcs	copy_history_done

		lea	HIST_BODY(a1),a1		*  A1 : �����̒P����т̐擪
		bra	copy_history_start

copy_history_loop:
		subq.w	#1,d1
		bcs	copy_history_over

		move.b	#' ',(a0)+
		addq.w	#1,nbytes(a6)
copy_history_start:
copy_history_dup_word_loop:
		moveq	#0,d0
		move.b	(a1)+,d0
		beq	copy_history_continue

		bsr	issjis
		bne	copy_history_word_1

		lsl.w	#8,d0
		move.b	(a1)+,d0
		beq	copy_history_continue
copy_history_word_1:
		cmp.w	histchar1(a5),d0
		bne	copy_history_not_histchar

		move.b	(a1),d0
		bsr	is_histchar_canceller
		beq	copy_history_dup_histchar

		subq.w	#1,d1
		bcs	copy_history_over

		move.b	#'\',(a0)+
		addq.w	#1,nbytes(a6)
copy_history_dup_histchar:
		move.w	histchar1(a5),d0
		bra	copy_history_dup_1

copy_history_not_histchar:
		cmp.w	#'\',d0
		beq	copy_history_dup_escape
copy_history_dup_1:
		cmp.w	#$100,d0
		blo	copy_history_dup_1_1
copy_history_dup_1_2:
		subq.w	#1,d1
		bcs	copy_history_over

		move.w	d0,-(a7)
		lsr.w	#8,d0
		move.b	d0,(a0)+
		move.w	(a7)+,d0
		addq.w	#1,nbytes(a6)
copy_history_dup_1_1:
		subq.w	#1,d1
		bcs	copy_history_over

		move.b	d0,(a0)+
		addq.w	#1,nbytes(a6)
		bra	copy_history_dup_word_loop

copy_history_dup_escape:
		subq.w	#1,d1
		bcs	copy_history_over

		move.b	d0,(a0)+
		addq.w	#1,nbytes(a6)

		move.b	(a1)+,d0
		beq	copy_history_continue

		bsr	issjis
		bne	copy_history_dup_1_1

		lsl.w	#8,d0
		move.b	(a1)+,d0
		bne	copy_history_dup_1_2
copy_history_continue:
		dbra	d2,copy_history_loop
copy_history_done:
		move.w	nbytes(a6),point(a6)
		cmp.w	point(a6),d3
		bhi	copy_history_draw

		move.w	d3,point(a6)
copy_history_draw:
		bsr	redraw
		bra	getline_x_2

copy_history_over:
		addq.w	#1,d1
		bsr	beep
		bra	copy_history_done
********************************
*  down-history
********************************
x_down_history:
		movea.l	line_top(a6),a0
		moveq	#0,d0
		move.w	point(a6),d0

		movea.l	x_histptr(a6),a1
		btst.b	#0,x_histflag(a6)
		beq	x_down_history_1

		cmpa.l	#0,a1
		beq	x_down_history_2

		movea.l	HIST_NEXT(a1),a1
x_down_history_1:
		moveq	#0,d2
		bsr	search_down_history
		bne	history_found
x_down_history_2:
		btst.b	#1,x_histflag(a6)
		beq	search_history_fail

		movea.l	history_top(a5),a1
		moveq	#0,d2
		bsr	search_down_history
		bra	search_history_done
********************************
FLAGBIT_LIST   = 0	*  �⊮������̑}���͍s�킸�C�⊮���̕\�����s��
FLAGBIT_FILE   = 1	*  ������̈ʒu�ɂ�炸�t�@�C�����Ƃ��ĕ⊮����
FLAGBIT_CMD    = 2	*  ������̈ʒu�ɂ�炸�R�}���h���Ƃ��ĕ⊮����
FLAGBIT_VAR    = 3	*  $�Ŏn�܂��Ă��Ȃ��Ƃ���ɕϐ����Ƃ��ĕ⊮����
FLAGBIT_NOSVAR = 4	*  �ϐ����⊮���ɃV�F���ϐ����f�t�H���g�̌��Ƃ���
FLAGBIT_NOENV  = 5	*  �ϐ����⊮���Ɋ��ϐ����f�t�H���g�̌��Ƃ���

FLAGX_COMPL      = 0
FLAGX_COMPL_CMD  = (1<<FLAGBIT_CMD)
FLAGX_COMPL_FILE = (1<<FLAGBIT_FILE)
FLAGX_COMPL_VAR  = (1<<FLAGBIT_VAR)
FLAGX_COMPL_SVAR = (1<<FLAGBIT_VAR)|(1<<FLAGBIT_NOENV)
FLAGX_COMPL_ENV  = (1<<FLAGBIT_VAR)|(1<<FLAGBIT_NOSVAR)

FLAGX_LIST       = (1<<FLAGBIT_LIST)
FLAGX_LIST_CMD   = (1<<FLAGBIT_LIST)|(1<<FLAGBIT_CMD)
FLAGX_LIST_FILE  = (1<<FLAGBIT_LIST)|(1<<FLAGBIT_FILE)
FLAGX_LIST_VAR   = (1<<FLAGBIT_LIST)|(1<<FLAGBIT_VAR)
FLAGX_LIST_SVAR  = (1<<FLAGBIT_LIST)|(1<<FLAGBIT_VAR)|(1<<FLAGBIT_NOENV)
FLAGX_LIST_ENV   = (1<<FLAGBIT_LIST)|(1<<FLAGBIT_VAR)|(1<<FLAGBIT_NOSVAR)

********************************
*  list-environment-variable
********************************
x_list_environment_variable:
		moveq	#FLAGX_LIST_ENV,d7
		bra	x_filec_or_list
********************************
*  list-shell-variable
********************************
x_list_shell_variable:
		moveq	#FLAGX_LIST_SVAR,d7
		bra	x_filec_or_list
********************************
*  list-variable
********************************
x_list_variable:
		moveq	#FLAGX_LIST_VAR,d7
		bra	x_filec_or_list
********************************
*  list-command
********************************
x_list_command:
		moveq	#FLAGX_LIST_CMD,d7
		bra	x_filec_or_list
********************************
*  list-file
********************************
x_list_file:
		moveq	#FLAGX_LIST_FILE,d7
		bra	x_filec_or_list
********************************
*  list
********************************
x_list:
		moveq	#FLAGX_LIST,d7
		bra	x_filec_or_list
********************************
*  complete-environment-variable
********************************
x_complete_environment_variable:
		moveq	#FLAGX_COMPL_ENV,d7
		bra	x_filec_or_list
********************************
*  complete-shell-variable
********************************
x_complete_shell_variable:
		moveq	#FLAGX_COMPL_SVAR,d7
		bra	x_filec_or_list
********************************
*  complete-variable
********************************
x_complete_variable:
		moveq	#FLAGX_COMPL_VAR,d7
		bra	x_filec_or_list
********************************
*  complete-command
********************************
x_complete_command:
		moveq	#FLAGX_COMPL_CMD,d7
		bra	x_filec_or_list
********************************
*  complete-file
********************************
x_complete_file:
		moveq	#FLAGX_COMPL_FILE,d7
		bra	x_filec_or_list
********************************
*  complete
********************************
x_complete:
		moveq	#FLAGX_COMPL,d7

filec_statbuf = -STATBUFSIZE
filec_fignore = filec_statbuf-4
filec_command_ptr = filec_fignore-4
filec_files_builtin_ptr = filec_command_ptr-4
filec_buffer_ptr = filec_files_builtin_ptr-4
filec_command_path_count = filec_buffer_ptr-2
filec_buffer_free = filec_command_path_count-2
filec_patlen = filec_buffer_free-4
filec_dirlen = filec_patlen-4
filec_maxlen = filec_dirlen-4
filec_minlen = filec_maxlen-4
filec_minlen_precious = filec_minlen-4
filec_numentry = filec_minlen_precious-2
filec_numprecious = filec_numentry-2
filec_files_mode = filec_numprecious-2
filec_flag = filec_files_mode-1
filec_command = filec_flag-1
filec_suffix = filec_command-1
filec_exact_suffix = filec_suffix-1
filec_pad = filec_exact_suffix-0

x_filec_or_list:
		link	a4,#filec_pad
		move.b	d7,filec_flag(a4)
		*
		*  �Ώۂ̒P������o��
		*
		move.w	point(a6),d6
		movea.l	line_top(a6),a2
		move.b	#1,filec_command(a4)
filec_find_word_loop1:
		subq.w	#1,d6
		bcs	filec_find_word_loop1_break

		move.b	(a2)+,d0
		beq	filec_find_word_loop1

		bsr	isspace
		beq	filec_find_word_loop1

		subq.l	#1,a2
filec_find_word_loop1_break:
		movea.l	a2,a1
		addq.w	#1,d6
filec_find_word_loop2:
		subq.w	#1,d6
		bcs	filec_find_word_done

		moveq	#0,d0
		move.b	(a2)+,d0
		beq	filec_find_word_loop2_break

		bsr	issjis
		beq	filec_find_word_sjis

		lea	filec_separators,a0
		bsr	jstrchr
		beq	filec_find_word_loop2

		cmpa.l	#x_command_separators,a0
		blo	filec_find_word_loop2_break

		move.b	#2,filec_command(a4)
		bra	filec_find_word_loop1

filec_find_word_loop2_break:
		clr.b	filec_command(a4)
		bra	filec_find_word_loop1

filec_find_word_sjis:
		subq.w	#1,d6
		bcs	filec_find_word_done

		addq.l	#1,a2
		bra	filec_find_word_loop2

filec_find_word_done:
		moveq	#0,d0
		move.w	point(a6),d0
		add.l	line_top(a6),d0
		sub.l	a1,d0
		cmp.l	#MAXWORDLEN,d0
		bhi	filec_error

		lea	tmpword1,a0
		bsr	memmovi
		clr.b	(a0)

		clr.w	filec_numentry(a4)
		clr.w	filec_numprecious(a4)
		clr.l	filec_maxlen(a4)
		move.l	#-1,filec_minlen(a4)
		move.l	#-1,filec_minlen_precious(a4)
		lea	tmpargs,a0
		move.l	a0,filec_buffer_ptr(a4)
		move.w	#MAXWORDLISTSIZE,filec_buffer_free(a4)
		clr.b	filec_exact_suffix(a4)
		moveq	#0,d0
		btst.b	#FLAGBIT_LIST,filec_flag(a4)
		bne	filec_no_fignore

		lea	word_fignore,a0
		bsr	find_shellvar
filec_no_fignore:
		move.l	d0,filec_fignore(a4)
		*
		*  �ϐ������H
		*  ���[�U�����H
		*  �R�}���h���^�t�@�C�������H
		*
		lea	tmpword1,a0
		btst.b	#FLAGBIT_VAR,filec_flag(a4)
		bne	complete_varname_start

		moveq	#'$',d0
		bsr	jstrchr
		bne	complete_varname

		lea	tmpword1,a0
		bsr	builtin_dir_match
		beq	filec_not_builtin

		cmpi.b	#'/',(a0,d0.l)
		bne	filec_not_builtin

		movea.l	a0,a1
		lea	tmpword2,a0
		bsr	strcpy
		bra	filec_file_0

filec_not_builtin:
		cmpi.b	#'~',(a0)
		bne	filec_file

		moveq	#'/',d0
		bsr	jstrchr
		beq	complete_username
****************
filec_file:
	*
	*  �t�@�C������������
	*
		*
		*  ~ ��W�J�c
		*
		lea	tmpword1,a0
		lea	tmpword2,a1
		moveq	#0,d2
		move.l	d1,-(a7)
		move.w	#MAXWORDLEN+1,d1
		bsr	expand_tilde
		move.l	(a7)+,d1
		tst.l	d0
		bmi	filec_find_done
		*
		*  �t�@�C��������������
		*
		lea	tmpword2,a0
		bsr	contains_dos_wildcard		*  Human68k �̃��C���h�J�[�h���܂��
		bne	filec_find_done			*  ����Ȃ�Ζ���

		moveq	#'\',d0				*  \ ��
		bsr	jstrchr				*  �܂��
		bne	filec_find_done			*  ����Ȃ�Ζ���

		lea	tmpword2,a0
		bsr	test_directory
		bne	filec_find_done
filec_file_0:
		lea	tmpword2,a0
		bsr	headtail			*  A1 : �t�@�C�����̃A�h���X
							*  D0.L : �h���C�u�{�f�B���N�g���̒���
		btst.b	#FLAGBIT_FILE,filec_flag(a4)
		bne	filec_file_file

		tst.b	filec_command(a4)
		bne	filec_file_command

		btst.b	#FLAGBIT_CMD,filec_flag(a4)
		beq	filec_just_real_file

		move.b	#2,filec_command(a4)
filec_file_command:
		tst.l	d0
		bne	filec_file_command_only_file

		bsr	strlen
		tst.l	d0
		bne	filec_file_start

		tst.b	flag_nonullcommandc(a5)
		bne	filec_error

		bra	filec_file_start

filec_file_command_only_file:
		move.b	#5,filec_command(a4)
		bra	filec_just_real_file

filec_file_file:
		clr.b	filec_command(a4)
filec_just_real_file:
		cmp.l	#MAXHEAD,d0
		bhi	filec_find_done

		move.l	d0,filec_dirlen(a4)
		move.w	#MODEVAL_FILEDIR,filec_files_mode(a4)

		move.l	a1,-(a7)
		movea.l	a0,a1
		lea	tmpword1,a0
		bsr	memmovi
		lea	dos_allfile,a1
		bsr	strcpy
		movea.l	(a7)+,a1
filec_file_start:
		movea.l	a1,a0
		bsr	strlen
		move.l	d0,filec_patlen(a4)
		bsr	filec_file_sub
		bne	filec_error
		bra	filec_find_done
****************
complete_username:
		bsr	open_passwd
		bmi	filec_find_done

		move.l	d0,tmpfd(a5)
		move.w	d0,d2				*  D2.W : passwd �t�@�C���E�n���h��

		lea	tmpword1+1,a0
		bsr	strlen
		move.l	d0,filec_patlen(a4)
		move.b	#'/',filec_suffix(a4)

pwd_buf = -(((PW_SIZE+1)+1)>>1<<1)

		link	a6,#pwd_buf
complete_username_loop:
		move.w	d2,d0
		lea	pwd_buf(a6),a0
		bsr	fgetpwent
		bne	complete_username_done0

		lea	PW_NAME(a0),a0
		lea	tmpword1+1,a1
		move.l	filec_patlen(a4),d0
		bsr	memcmp
		bne	complete_username_loop

		moveq	#' ',d0
		bsr	filec_enter
		bne	complete_username_done		*  D0.L == 1 .. error

		bra	complete_username_loop

complete_username_done0:
		moveq	#-1,d0
complete_username_done:
		unlk	a6
		bsr	close_tmpfd
		tst.l	d0
		bpl	filec_error

		bra	filec_find_done
****************
complete_varname:
		addq.l	#1,a0
		cmpi.b	#'@',(a0)
		beq	complete_shellvar

		cmpi.b	#'%',(a0)
		bne	complete_varname_2
complete_environ:
		bclr.b	#FLAGBIT_NOENV,filec_flag(a4)
		bset.b	#FLAGBIT_NOSVAR,filec_flag(a4)
		bra	complete_varname_1

complete_shellvar:
		bclr.b	#FLAGBIT_NOSVAR,filec_flag(a4)
		bset.b	#FLAGBIT_NOENV,filec_flag(a4)
complete_varname_1:
		addq.l	#1,a0
complete_varname_2:
		cmpi.b	#'{',(a0)
		bne	complete_varname_start

		addq.l	#1,a0
complete_varname_start:
		bsr	strlen
		move.l	d0,filec_patlen(a4)
		move.b	#$ff,filec_suffix(a4)		*  ������ addsuffix ���Ȃ����Ƃ�����
		movea.l	a0,a1				*  A1 : �������̐擪�A�h���X
		btst.b	#FLAGBIT_NOSVAR,filec_flag(a4)
		bne	do_complete_varname_skip_shellvar

		movea.l	shellvar_top(a5),a2
		bsr	do_complete_varname_sub
		bne	filec_error
do_complete_varname_skip_shellvar:
		btst.b	#FLAGBIT_NOENV,filec_flag(a4)
		bne	do_complete_varname_skip_environ

		movea.l	env_top(a5),a2
		bsr	do_complete_varname_sub
		bne	filec_error
do_complete_varname_skip_environ:
		bra	filec_find_done
****************
filec_find_done:
		btst.b	#FLAGBIT_LIST,filec_flag(a4)
		bne	filec_list			*  ���X�g�\����

		tst.w	filec_numentry(a4)
		beq	filec_nomatch

		tst.w	filec_numprecious(a4)
		bne	filec_numprecious_ok

		move.w	filec_numentry(a4),d0
		move.w	d0,filec_numprecious(a4)
		move.l	filec_minlen(a4),d0
		move.l	d0,filec_minlen_precious(a4)
filec_numprecious_ok:
		*
		*  �ŏ��̞B���łȂ��������m�肷��
		*
		move.l	d1,-(a7)
		lea	tmpargs,a0
		move.w	filec_numprecious(a4),d0
		move.l	filec_patlen(a4),d1
		move.b	flag_cifilec(a5),d2
		bsr	common_spell
		move.l	filec_minlen_precious(a4),d1
		sub.l	filec_patlen(a4),d1
		bsr	minmaxul			*  D0.L : ���ʕ����̒���
		move.l	(a7)+,d1
		*
		*  ����������}������
		*
		movea.l	a0,a1
		adda.l	filec_patlen(a4),a1
		move.l	d0,d2
		bsr	open_columns
		bcs	filec_error

		move.l	d2,d0
		move.l	a0,-(a7)
		bsr	memmovi
		movea.l	(a7)+,a0
		bsr	post_insert_job

		lea	tmpargs,a0
		move.w	filec_numprecious(a4),d0
		bsr	is_all_same_word
		beq	filec_match

		tst.b	filec_exact_suffix(a4)
		beq	filec_ambiguous

		*  not unique exact match
		*  set matchbeep=notuniq �ł���Ƃ��ɂ̂݃x����炷

		bsr	find_matchbeep
		beq	filec_notunique_nobeep
		bpl	filec_match

		lea	word_notunique,a1
		bsr	strcmp
		bne	filec_notunique_nobeep

		bsr	beep
filec_notunique_nobeep:
		move.b	filec_exact_suffix(a4),d0
		move.b	d0,filec_suffix(a4)
filec_match:
		btst.b	#7,filec_suffix(a4)
		bne	filec_done

		lea	word_addsuffix,a0		*  �V�F���ϐ� addsuffix ��
		bsr	find_shellvar			*  �Z�b�g�����
		beq	filec_done			*  ���Ȃ���΂����܂�

		tst.l	d2				*  1�������}�����Ȃ������Ȃ��
		beq	filec_addsuffix			*  �T�t�B�b�N�X��ǉ�����

		bsr	get_var_value			*  $@addsuffix[1] == exact �łȂ����
		beq	filec_addsuffix			*  �T�t�B�b�N�X��ǉ�����

		lea	word_exact,a1
		bsr	strcmp
		beq	filec_done
filec_addsuffix:
		moveq	#1,d2
		bsr	open_columns
		bcs	filec_error

		move.b	filec_suffix(a4),(a0)
		bsr	post_insert_job
		bra	filec_done


filec_nomatch:
		bsr	find_matchbeep
		beq	filec_beep
		bpl	filec_done

		lea	word_nomatch,a1
		bsr	strcmp
		beq	filec_beep

		lea	word_ambiguous,a1
		bsr	strcmp
		beq	filec_beep

		lea	word_notunique,a1
		bsr	strcmp
		bne	filec_done
filec_beep:
filec_error:
		bsr	beep
filec_done:
		unlk	a4
		bra	getline_x_1


filec_ambiguous:
		bsr	find_matchbeep
		beq	filec_ambiguous_beep
		bpl	filec_ambiguous_nobeep

		lea	word_ambiguous,a1
		bsr	strcmp
		beq	filec_ambiguous_beep

		lea	word_notunique,a1
		bsr	strcmp
		bne	filec_ambiguous_nobeep
filec_ambiguous_beep:
		bsr	beep
filec_ambiguous_nobeep:
		tst.l	d2
		bne	filec_done

		tst.b	flag_autolist(a5)
		beq	filec_done
filec_list:
	*
	*  ���X�g�\��
	*
		move.w	filec_numentry(a4),d6
		beq	filec_list_done

		lea	tmpargs,a0
		move.w	d6,d0
		bsr	sort_wordlist
		bsr	uniq_wordlist
		move.w	d0,d6
		addq.l	#2,filec_maxlen(a4)
		*
		*  79(�s�̌���-1)��1���ڂ̌����Ŋ����āA1�s������̍��ڐ����b�肷��
		*
		moveq	#1,d2
		move.l	filec_maxlen(a4),d0
		moveq	#79,d3
		cmp.l	d0,d3
		blo	filec_list_width_ok

		move.l	d3,d2
		divu	d0,d2				*  D2.W : 79 / ���� = 1�s�̍��ڐ�(�b��)
filec_list_width_ok:
		*
		*  ���s�ɂȂ邩�����߂�
		*
		moveq	#0,d3
		move.w	d6,d3
		divu	d2,d3				*  D3.W : �G���g���� / 1�s�̍��ڐ� = �s��
		swap	d3
		move.w	d3,d4
		swap	d3
		*
		*  �]�肪�Ȃ���΂n�j
		*
		tst.w	d4
		beq	filec_list_height_ok
		*
		*  �]�肪���� --- �s���͂����1�s����
		*
		addq.w	#1,d3
		*
		*  1�s�����Ȃ����̂ŁA1�s�̍��ڐ����v�Z������
		*
		moveq	#0,d2
		move.w	d6,d2
		divu	d3,d2
		swap	d2
		move.w	d2,d4
		swap	d2
		tst.w	d4
		beq	filec_list_height_ok
		*
		*  �]�肪���� --- 1�s�̍��ڐ��͂����1���ڑ���
		*                 �]��(D4.W)��1���ڑ����s���ł���
		*
		addq.w	#1,d2
filec_list_height_ok:
		lea	tmpargs,a0
		movea.l	a0,a1				*  A1:�ŏ��̍s�̐擪����
		bsr	move_cursor_to_eol
filec_list_loop1:
		bsr	put_newline
		movea.l	a1,a0
		bsr	strfor1
		exg	a0,a1				*  A0:���̍s�̐擪����  A1:���s�̐擪����
		move.w	d2,d5
filec_list_loop2:
		movem.l	d1-d4/a1,-(a7)
		moveq	#1,d1				*  ���l��
		moveq	#' ',d2				*  �󔒂�pad
		move.l	filec_maxlen(a4),d3		*  �ŏ��t�B�[���h��
		moveq	#-1,d4				*  �ő�o�͕������F$FFFFFFFF
		lea	putc(pc),a1
		bsr	printfs
		movem.l	(a7)+,d1-d4/a1

		subq.w	#1,d6
		beq	filec_list_done

		subq.w	#1,d5
		beq	filec_list_loop2_break

		move.w	d3,d0
		bsr	strforn
		bra	filec_list_loop2

filec_list_loop2_break:
		tst.w	d4
		beq	filec_list_loop1

		subq.w	#1,d4
		bne	filec_list_loop1

		subq.w	#1,d2
		bra	filec_list_loop1

filec_list_done:
		unlk	a4
		bsr	put_newline
		bra	x_redraw_1
****************
filec_enter:
		movem.l	d1-d5/a0-a2,-(a7)
		addq.w	#1,filec_numentry(a4)
		bcs	filec_enter_error

		move.b	d0,d5				*  D5.B : ���X�g�\���ɉ�����T�t�B�b�N�X
		bsr	strlen
		cmp.l	#MAXWORDLEN,d0
		bhi	filec_enter_error

		sub.w	d0,filec_buffer_free(a4)
		bcs	filec_enter_error

		subq.w	#2,filec_buffer_free(a4)
		bcs	filec_enter_error

		movea.l	a0,a2				*  A2 : �P��̐擪�A�h���X
		move.l	d0,d2				*  D2 : �P��̒���
		cmp.l	filec_maxlen(a4),d2
		bls	filec_entry_1

		move.l	d2,filec_maxlen(a4)
filec_entry_1:
		cmp.l	filec_minlen(a4),d2
		bhs	filec_entry_2

		move.l	d2,filec_minlen(a4)
filec_entry_2:
		*
		*  fignore �Ɋ܂܂�Ă��邩�ǂ����𒲂ׂ�
		*
		move.l	filec_fignore(a4),d0
		beq	filec_enter_ignored

		bsr	get_var_value
		move.w	d0,d4				*  D4.W : fignore �̗v�f��
		bra	check_fignore_start

check_fignore_loop:
		bsr	strlen
		move.l	d0,d3				*  D3.L : $fignore[i] �̒���
		move.l	d2,d0				*  �P��̒���(D2)��
		sub.l	d3,d0				*  $fignore[i] �̒���(D3)���
		blo	check_fignore_continue		*  �Z��

		lea	(a2,d0.l),a1
		move.l	d3,d0
		move.b	flag_cifilec(a5),d1
		bsr	memxcmp				*  �P�c����v���邩�H
		beq	filec_enter_ignored
check_fignore_continue:
		bsr	strfor1
check_fignore_start:
		dbra	d4,check_fignore_loop
not_ignore:
		addq.w	#1,filec_numprecious(a4)
		cmp.l	filec_minlen_precious(a4),d2
		bhs	filec_entry_3

		move.l	d2,filec_minlen_precious(a4)
filec_entry_3:
		move.l	filec_buffer_ptr(a4),a1
		lea	tmpargs,a0
		move.l	a1,d0
		sub.l	a0,d0
		movea.l	a1,a0
		adda.l	d2,a0
		addq.l	#2,a0
		bsr	memmovd
		lea	tmpargs,a0
		bra	filec_add_entry

filec_enter_ignored:
		movea.l	filec_buffer_ptr(a4),a0
filec_add_entry:
		*
		*  �o�^����
		*
		move.l	d2,d0
		movea.l	a2,a1
		bsr	memmovi
		move.b	d5,(a0)+
		clr.b	(a0)
		add.l	d2,filec_buffer_ptr(a4)
		addq.l	#2,filec_buffer_ptr(a4)

		tst.b	flag_recexact(a5)
		beq	filec_enter_success

		move.l	filec_patlen(a4),d0
		tst.b	(a2,d0.l)
		bne	filec_enter_success

		move.b	filec_suffix(a4),d0
		move.b	d0,filec_exact_suffix(a4)
filec_enter_success:
		moveq	#0,d0
filec_enter_return:
		movem.l	(a7)+,d1-d5/a0-a2
		rts

filec_enter_error:
		moveq	#1,d0
		bra	filec_enter_return
****************
find_matchbeep:
		lea	word_matchbeep,a0
		bsr	find_shellvar
		beq	find_matchbeep_return		*  D0.L == 0

		bsr	get_var_value
		beq	find_matchbeep_1

		moveq	#-1,d0				*  D0.L == -1
find_matchbeep_return:
		rts

find_matchbeep_1:
		moveq	#1,d0				*  D0.L == 1
		rts
****************
do_complete_varname_sub:
		cmpa.l	#0,a2
		beq	do_complete_varname_sub_done

		lea	var_body(a2),a0
		move.l	var_next(a2),a2
		move.l	filec_patlen(a4),d0
		bsr	memcmp
		bne	do_complete_varname_sub

		moveq	#' ',d0
		bsr	filec_enter
		bne	do_complete_varname_sub_return

		bra	do_complete_varname_sub

do_complete_varname_sub_done:
		moveq	#0,d0
do_complete_varname_sub_return:
		rts
****************
filec_file_sub:
		bsr	filec_files
filec_file_loop:
		bmi	filec_file_sub_done

		move.w	d0,d2				*  D2 : mode
		btst	#8,d2
		bne	filec_file_ok_1

		cmpi.b	#'.',(a0)
		bne	filec_file_ok_1

		tst.b	1(a0)
		beq	filec_file_next			*  "." �͏��O

		cmpi.b	#'.',1(a0)
		bne	filec_file_ok_1

		tst.b	2(a0)
		beq	filec_file_next			*  ".." �͏��O
filec_file_ok_1:
		movem.l	d1,-(a7)
		sf	d1
		btst	#8,d2
		bne	filec_file_compare

		move.b	flag_cifilec(a5),d1
filec_file_compare:
		move.l	filec_patlen(a4),d0
		bsr	memxcmp
		movem.l	(a7)+,d1
		bne	filec_file_next

		moveq	#'/',d0
		btst	#MODEBIT_DIR,d2			*  directory?
		bne	filec_file_matched

		bsr	filec_file_check_command
		bne	filec_file_next

		moveq	#' ',d0
filec_file_matched:
		move.b	d0,filec_suffix(a4)
		bsr	filec_enter
		bne	filec_file_sub_return
filec_file_next:
		bsr	filec_nfiles
		bra	filec_file_loop

filec_file_sub_done:
		moveq	#0,d0
filec_file_sub_return:
		rts
****************
filec_file_check_command:
		tst.b	flag_recunexec(a5)
		bne	filec_file_check_command_ok

		cmpi.b	#4,filec_command(a4)
		blo	filec_file_check_command_ok

		tst.l	filec_files_builtin_ptr(a4)
		bne	filec_file_check_command_ok

		move.l	a0,-(a7)
		bsr	check_executable_suffix
		movea.l	(a7)+,a0
		cmp.l	#2,d0
		blo	filec_file_check_script

		cmp.l	#5,d0
		bls	filec_file_check_command_ok
filec_file_check_script:
path_buf = -(((MAXPATH+1)+1)>>1<<1)
		link	a6,#path_buf
		movem.l	a0-a1,-(a7)
		lea	path_buf(a6),a0
		lea	tmpword1,a1
		move.l	filec_dirlen(a4),d0
		bsr	memmovi
		lea	filec_statbuf+ST_NAME(a4),a1
		bsr	strcpy
		movem.l	(a7)+,a0-a1
		move.w	#0,-(a7)
		pea	path_buf(a6)
		DOS	_OPEN
		addq.l	#6,a7
		unlk	a6
		tst.l	d0
		bmi	filec_file_check_command_fail

		movem.l	d1,-(a7)
		move.w	d0,-(a7)
		bsr	check_executable_script
		seq	d1
		DOS	_CLOSE
		addq.l	#2,a7
		tst.b	d1
		movem.l	(a7)+,d1
		beq	filec_file_check_command_fail
filec_file_check_command_ok:
		moveq	#0,d0
		rts

filec_file_check_command_fail:
		moveq	#-1,d0
		rts
****************
filec_files:
		cmpi.b	#1,filec_command(a4)
		beq	filec_nfiles_statement_first

		cmpi.b	#2,filec_command(a4)
		beq	filec_nfiles_alias_first
filec_files_normal:
		lea	tmpword1,a0
		bsr	builtin_dir_match
		beq	filec_files_not_builtin

		cmpi.b	#'/',(a0,d0.l)
		beq	filec_files_builtin

		cmpi.b	#'\',(a0,d0.l)
		bne	filec_files_not_builtin
filec_files_builtin:
		lea	builtin_table,a0
		move.l	a0,filec_files_builtin_ptr(a4)
		bra	filec_nfiles_normal

filec_files_not_builtin:
		clr.l	filec_files_builtin_ptr(a4)
		move.w	filec_files_mode(a4),-(a7)
		move.l	a0,-(a7)
		pea	filec_statbuf(a4)
		DOS	_FILES
		lea	10(a7),a7
filec_files_normal_done:
		tst.l	d0
		bmi	filec_files_return

		lea	filec_statbuf+ST_NAME(a4),a0
		moveq	#0,d0
		move.b	filec_statbuf+ST_MODE(a4),d0
filec_files_return:
		tst.l	d0
		rts
****************
filec_nfiles:
		cmpi.b	#1,filec_command(a4)
		beq	filec_nfiles_statement

		cmpi.b	#2,filec_command(a4)
		beq	filec_nfiles_alias

		cmpi.b	#3,filec_command(a4)
		beq	filec_nfiles_function

		bsr	filec_nfiles_normal
		bpl	filec_files_return

		cmpi.b	#4,filec_command(a4)
		bne	filec_files_return

		bra	filec_files_command_file_next
****************
filec_nfiles_normal:
		move.l	filec_files_builtin_ptr(a4),d0
		bne	filec_nfiles_builtin

		pea	filec_statbuf(a4)
		DOS	_NFILES
		addq.l	#4,a7
		bra	filec_files_normal_done
****************
filec_nfiles_builtin:
		movea.l	d0,a0
		move.l	(a0),d0
		beq	filec_files_nomore

		lea	10(a0),a0
		move.l	a0,filec_files_builtin_ptr(a4)
filec_files_builtin_set_return:
		movea.l	d0,a0
filec_files_builtin_return:
		move.l	#$100,d0
		rts
****************
filec_nfiles_statement_first:
		lea	statement_table,a0
		move.l	a0,filec_command_ptr(a4)
filec_nfiles_statement:
		move.l	filec_command_ptr(a4),a0
		move.l	(a0),d0
		beq	filec_nfiles_statement_nomore

		lea	10(a0),a0
		move.l	a0,filec_command_ptr(a4)
		bra	filec_files_builtin_set_return

filec_nfiles_statement_nomore:
		addq.b	#1,filec_command(a4)
filec_nfiles_alias_first:
		tst.b	flag_noalias(a5)
		bne	filec_nfiles_alias_nomore

		move.l	alias_top(a5),filec_command_ptr(a4)
filec_nfiles_alias:
		move.l	filec_command_ptr(a4),d0
		beq	filec_nfiles_alias_nomore

		movea.l	d0,a0
		move.l	var_next(a0),filec_command_ptr(a4)
		lea	var_body(a0),a0
		bra	filec_files_builtin_return

filec_nfiles_alias_nomore:
		addq.b	#1,filec_command(a4)
		move.l	function_bot(a5),filec_command_ptr(a4)
filec_nfiles_function:
		move.l	filec_command_ptr(a4),d0
		beq	filec_files_function_nomore

		movea.l	d0,a0
		move.l	FUNC_PREV(a0),filec_command_ptr(a4)
		lea	FUNC_NAME(a0),a0
		bra	filec_files_builtin_return

filec_files_function_nomore:
		addq.b	#1,filec_command(a4)
		lea	word_path,a0
		bsr	find_shellvar
		beq	filec_files_nomore

		bsr	get_var_value
		move.l	a0,filec_command_ptr(a4)
		move.w	d0,filec_command_path_count(a4)
filec_files_command_file_next:
		subq.w	#1,filec_command_path_count(a4)
		bcs	filec_files_nomore

		lea	tmpword1,a0
		movem.l	a1-a3,-(a7)
		lea	dos_allfile,a2
		movea.l	filec_command_ptr(a4),a1
		bsr	cat_pathname
		move.l	a1,filec_command_ptr(a4)
		movem.l	(a7)+,a1-a3
		tst.l	d0
		bmi	filec_files_command_file_next

		bsr	drvchkp
		bmi	filec_files_command_file_next

		move.l	a1,-(a7)
		bsr	headtail
		movea.l	(a7)+,a1
		cmp.l	#MAXHEAD,d0
		bhi	filec_files_command_file_next

		move.l	d0,filec_dirlen(a4)

		cmpi.b	#'.',(a0)
		bne	filec_files_command_file_2

		cmpi.b	#'/',1(a0)
		beq	filec_files_command_file_3

		cmpi.b	#'\',1(a0)
		beq	filec_files_command_file_3
filec_files_command_file_2:
		move.w	#MODEVAL_FILE,filec_files_mode(a4)
		bra	filec_files_command_file_4

filec_files_command_file_3:
		move.w	#MODEVAL_FILEDIR,filec_files_mode(a4)
filec_files_command_file_4:
		bsr	filec_files_normal
		tst.l	d0
		bmi	filec_files_command_file_next

		rts
****************
filec_files_nomore:
		moveq	#-1,d0
		rts
*****************************************************************
getline_x_getletter:
		bsr	getline_x_getc
		bmi	getline_x_getletter_return

		bsr	issjis
		bne	getline_x_getletter_1

		move.b	d0,d2
		lsl.w	#8,d2
		bsr	getline_x_getc
		bmi	getline_x_getletter_return

		or.w	d2,d0
getline_x_getletter_1:
		cmp.l	d0,d0
getline_x_getletter_return:
getline_x_getc_return:
		rts
*****************************************************************
getline_x_getc:
		tst.l	macro_ptr(a6)
		beq	getline_x_getc_tty

		move.l	a0,-(a7)
		movea.l	macro_ptr(a6),a0
		moveq	#0,d0
		move.b	(a0)+,d0
		move.l	a0,macro_ptr(a6)
		movea.l	(a7)+,a0
		tst.l	d0
		bne	getline_x_getc_return

		clr.l	macro_ptr(a6)
getline_x_getc_tty:
		move.w	input_handle(a6),d0
		bra	fgetc
*****************************************************************
x_size_forward:
		movem.l	d0/a0,-(a7)
		movea.l	line_top(a6),a0
		move.b	(a0,d0.w),d0
		moveq	#1,d2
		moveq	#4,d3
		cmp.b	#HT,d0
		beq	x_size_forward_return

		moveq	#2,d3
		bsr	iscntrl
		beq	x_size_forward_return

		moveq	#1,d3
		bsr	issjis
		bne	x_size_forward_return

		moveq	#2,d2
		cmp.b	#$80,d0
		beq	x_size_forward_return

		cmp.b	#$f0,d0
		bhs	x_size_forward_return

		moveq	#2,d3
x_size_forward_return:
		movem.l	(a7)+,d0/a0
		rts
*****************************************************************
x_size_backward:
		movem.l	d0-d1/a0,-(a7)
		move.w	d0,d1
		movea.l	line_top(a6),a0
		lea	(a0,d1.w),a0
		move.b	-1(a0),d0
		moveq	#1,d2
		moveq	#4,d3
		cmp.b	#HT,d0
		beq	x_size_backward_return

		moveq	#2,d3
		bsr	iscntrl
		beq	x_size_backward_return

		moveq	#1,d3
		cmp.w	#2,d1
		blo	x_size_backward_return

		move.b	-2(a0),d0
		bsr	issjis
		bne	x_size_backward_return

		move.w	d1,d0
		subq.w	#1,d0
		bsr	getline_isnsjisp
		beq	x_size_backward_return

		moveq	#2,d2
		cmp.b	#$80,d0
		beq	x_size_backward_return

		cmp.b	#$f0,d0
		bhs	x_size_backward_return

		moveq	#2,d3
x_size_backward_return:
		movem.l	(a7)+,d0-d1/a0
		rts
****************
getline_isnsjisp:
		movem.l	d1/a0,-(a7)
		movea.l	line_top(a6),a0
		move.w	d0,d1
getline_isnsjisp_loop:
		move.b	(a0)+,d0
		bsr	issjis
		bne	getline_isnsjisp_continue

		subq.w	#1,d1
		beq	getline_isnsjisp_break

		addq.l	#1,a0
getline_isnsjisp_continue:
		subq.w	#1,d1
		bne	getline_isnsjisp_loop

		moveq	#0,d0
getline_isnsjisp_break:
		movem.l	(a7)+,d1/a0
		tst.b	d0
		rts
*****************************************************************
region_width:
		movem.l	d1-d3/a0,-(a7)
		moveq	#0,d2
		move.w	d0,d1
		beq	region_width_return
region_width_loop:
		move.b	(a0)+,d0
		subq.w	#1,d1
		moveq	#4,d3
		cmp.b	#HT,d0
		beq	region_width_1

		moveq	#2,d3
		bsr	iscntrl
		beq	region_width_1

		moveq	#1,d3
		bsr	issjis
		bne	region_width_1

		cmp.b	#$80,d0
		beq	region_width_2

		cmp.b	#$f0,d0
		bhs	region_width_2

		moveq	#2,d3
region_width_2:
		tst.w	d1
		beq	region_width_1

		addq.l	#1,a0
		subq.w	#1,d1
region_width_1:
		add.l	d3,d2
		tst.w	d1
		bne	region_width_loop
region_width_return:
		move.l	d2,d0
		movem.l	(a7)+,d1-d3/a0
		rts
*****************************************************************
* backward_cursor_x - �w��̃t�B�[���h�̕������J�[�\�������Ɉړ�����
*
* CALL
*      A0     �t�B�[���h�̐擪�A�h���X
*      D0.W   �t�B�[���h�̒����i�o�C�g�j
*
* RETURN
*      D0.L   �t�B�[���h�̕�
*****************************************************************
*****************************************************************
* backward_cursor - �J�[�\�������Ɉړ�����
*
* CALL
*      D0.L   �ړ���
*
* RETURN
*      none
*****************************************************************
backward_cursor_x:
		bsr	region_width
backward_cursor:
		move.l	a0,-(a7)
		lea	t_bs,a0
		bsr	puts_ntimes
		movea.l	(a7)+,a0
		rts
*****************************************************************
* forward_cursor_x - �w��̃t�B�[���h�̕������J�[�\�����E�Ɉړ�����
*
* CALL
*      A0     �t�B�[���h�̐擪�A�h���X
*      D0.W   �t�B�[���h�̒����i�o�C�g�j
*
* RETURN
*      D0.L   �t�B�[���h�̕�
*****************************************************************
*****************************************************************
* forward_cursor - �J�[�\�����E�Ɉړ�����
*
* CALL
*      D0.L   �ړ���
*
* RETURN
*      none
*****************************************************************
forward_cursor_x:
		bsr	region_width
forward_cursor:
		move.l	a0,-(a7)
		lea	t_fs,a0
		bsr	puts_ntimes
		movea.l	(a7)+,a0
		rts
*****************************************************************
* backward_letter - �|�C���^��1�����߂��D�J�[�\���͈ړ����Ȃ�
*
* CALL
*      none
*
* RETURN
*      D0.L   �j��
*      D2.W   �ړ��o�C�g��
*      D3.L   �J�[�\���ړ���
*****************************************************************
backward_letter:
		moveq	#0,d2
		moveq	#0,d3
		move.w	point(a6),d0
		beq	backward_letter_done

		bsr	x_size_backward
		sub.w	d2,point(a6)
backward_letter_done:
		rts
*****************************************************************
* forward_letter - �|�C���^��1�����i�߂�D�J�[�\���͈ړ����Ȃ�
*
* CALL
*      none
*
* RETURN
*      D0.L   �j��
*      D2.W   �ړ��o�C�g��
*      D3.L   �J�[�\���ړ���
*****************************************************************
forward_letter:
		moveq	#0,d2
		moveq	#0,d3
		move.w	point(a6),d0
		cmp.w	nbytes(a6),d0
		beq	forward_letter_done

		bsr	x_size_forward
		add.w	d2,point(a6)
forward_letter_done:
		rts
*****************************************************************
* backward_word - �|�C���^��1��߂��D�J�[�\���͈ړ����Ȃ�
*
* CALL
*      none
*
* RETURN
*      D0.L   �j��
*      D2.W   �ړ��o�C�g��
*      D3.L   �J�[�\���ړ���
*****************************************************************
backward_word:
		movem.l	d0/d4-d6/a0,-(a7)
		moveq	#0,d4
		moveq	#0,d5
backward_word_1:
		tst.w	point(a6)
		beq	backward_word_done

		bsr	backward_letter
		add.w	d2,d4
		add.l	d3,d5

		bsr	is_point_space
		beq	backward_word_1

		bsr	is_special_character
		move.b	(a0),d6
backward_word_3:
		tst.w	point(a6)
		beq	backward_word_done

		bsr	backward_letter
		add.w	d2,d4
		add.l	d3,d5

		bsr	is_point_space
		beq	backward_word_5

		tst.b	d6
		beq	backward_word_4

		cmp.b	d6,d0
		beq	backward_word_3
		bra	backward_word_5

backward_word_4:
		bsr	is_special_character
		beq	backward_word_3
backward_word_5:
		bsr	forward_letter
		sub.w	d2,d4
		sub.l	d3,d5
backward_word_done:
		move.w	d4,d2
		move.l	d5,d3
		movem.l	(a7)+,d0/d4-d6/a0
		rts
*****************************************************************
* forward_word - �|�C���^��1��i�߂�D�J�[�\���͈ړ����Ȃ�
*
* CALL
*      none
*
* RETURN
*      D0.L   �j��
*      D2.W   �ړ��o�C�g��
*      D3.L   �J�[�\���ړ���
*****************************************************************
forward_word:
		movem.l	d0/d4-d6/a0,-(a7)
		moveq	#0,d4
		moveq	#0,d5
forward_word_1:
		move.w	point(a6),d0
		cmp.w	nbytes(a6),d0
		beq	forward_word_done

		bsr	is_dot_space
		bne	forward_word_2

		bsr	forward_letter
		add.w	d2,d4
		add.l	d3,d5
		bra	forward_word_1

forward_word_2:
		bsr	is_special_character
		move.b	(a0),d6
forward_word_3:
		bsr	forward_letter
		add.w	d2,d4
		add.l	d3,d5
		move.w	point(a6),d0
		cmp.w	nbytes(a6),d0
		beq	forward_word_done

		bsr	is_dot_space
		beq	forward_word_done

		tst.b	d6
		beq	forward_word_4

		cmp.b	d6,d0
		beq	forward_word_3
		bra	forward_word_done

forward_word_4:
		bsr	is_special_character
		beq	forward_word_3
forward_word_done:
		move.w	d4,d2
		move.l	d5,d3
		movem.l	(a7)+,d0/d4-d6/a0
		rts
*****************************************************************
is_point_space:
		move.w	point(a6),d0
is_dot_space:
		movea.l	line_top(a6),a0
		move.b	(a0,d0.w),d0
		bra	isspace
*****************************************************************
is_special_character:
		and.w	#$ff,d0
		lea	x_special_characters,a0
		bra	jstrchr
*****************************************************************
* move_letter_backward - �|�C���^��1�����߂��A�J�[�\�������Ɉړ�����
* move_word_backward - �|�C���^��1��߂��A�J�[�\�������Ɉړ�����
*
* CALL
*      none
*
* RETURN
*      D0.L   �J�[�\���ړ���
*      D2.W   �ړ��o�C�g��
*      D3.L   �J�[�\���ړ���
*****************************************************************
move_letter_backward:
		bsr	backward_letter
		bra	backward_cursor_d3

move_word_backward:
		bsr	backward_word
backward_cursor_d3:
		move.l	d3,d0
		bra	backward_cursor
*****************************************************************
* move_letter_forward - �|�C���^��1�����i�߁A�J�[�\�����E�Ɉړ�����
* move_word_forward - �|�C���^��1��i�߁A�J�[�\�����E�Ɉړ�����
*
* CALL
*      none
*
* RETURN
*      D0.L   �J�[�\���ړ���
*      D2.W   �ړ��o�C�g��
*      D3.L   �J�[�\���ړ���
*****************************************************************
move_letter_forward:
		bsr	forward_letter
		bra	forward_cursor_d3

move_word_forward:
		bsr	forward_word
forward_cursor_d3:
		move.l	d3,d0
		bra	forward_cursor
*****************************************************************
moveto_bol:
		movea.l	line_top(a6),a0
		move.w	point(a6),d0
		bsr	backward_cursor_x
		clr.w	point(a6)
		rts
*****************************************************************
move_cursor_to_eol:
		movem.l	d0/a0,-(a7)
		movea.l	line_top(a6),a0
		adda.w	point(a6),a0			*  ������
		move.w	nbytes(a6),d0
		sub.w	point(a6),d0
		bsr	forward_cursor_x
		movem.l	(a7)+,d0/a0
		rts
*****************************************************************
erase_line:
		movem.l	d0/a0-a1,-(a7)
		movea.l	line_top(a6),a0
		move.w	point(a6),d0
		lea	(a0,d0.w),a1			*  A1 : �J�[�\���ʒu
		bsr	backward_cursor_x
		move.l	d0,-(a7)			*  �s�̐擪����J�[�\���ʒu�܂ł̕�
		movea.l	a1,a0
		move.w	nbytes(a6),d0
		sub.w	point(a6),d0
		bsr	region_width			*  �J�[�\���ʒu����s���܂ł̕�
		add.l	(a7)+,d0			*  D0.L : �s�S�̂̕�
		bsr	put_spaces
		bsr	backward_cursor
		movem.l	(a7)+,d0/a0-a1
		rts
*****************************************************************
delete_line:
		bsr	erase_line
		add.w	nbytes(a6),d1
		clr.w	nbytes(a6)
		clr.w	point(a6)
		clr.w	mark(a6)
		rts
*****************************************************************
* open_columns
*
* CALL
*      D2.W   �}���o�C�g��
*****************************************************************
open_columns:
		cmp.w	d2,d1
		blo	open_columns_return

		sub.w	d2,d1
		movem.l	d0/a1,-(a7)
		movea.l	line_top(a6),a0
		moveq	#0,d0
		move.w	nbytes(a6),d0
		adda.l	d0,a0				*  A0 : �s��
		sub.w	point(a6),d0			*  D0.W : �J�[�\���ȍ~�̃o�C�g��
		movea.l	a0,a1
		lea	(a0,d2.w),a0
		bsr	memmovd
		movem.l	(a7)+,d0/a1
		suba.w	d2,a0				*  ������
		cmp.w	d0,d0
open_columns_return:
		rts
*****************************************************************
* post_insert_job
*
* CALL
*      D2.W   �}���o�C�g��
*****************************************************************
post_insert_job:
		movem.l	d0/a0,-(a7)
		move.w	d2,d0
		bsr	write_chars
		lea	(a0,d2.w),a0
		move.w	nbytes(a6),d0
		sub.w	point(a6),d0
		bsr	write_chars
		bsr	backward_cursor_x
		move.w	mark(a6),d0
		bmi	post_insert_1

		cmp.w	point(a6),d0
		blo	post_insert_1

		add.w	d2,mark(a6)
post_insert_1:
		add.w	d2,nbytes(a6)
		add.w	d2,point(a6)
		movem.l	(a7)+,d0/a0
		rts
*****************************************************************
* copy_region_to_buffer
*
* CALL
*      D0.B     bit0 : ��0�Ȃ�Ύ��s�����Ƃ��ɐq�˂�
*               bit1 : 0:���ɒǉ�, 1:�擪�ɒǉ�
*      D2.W     �R�s�[����̈�̒����i�o�C�g���j
*      D4.W     �R�s�[����̈�̐擪�I�t�Z�b�g
*
* RETURN
*      D0.L     ���������Ȃ� 0�C���s�����Ȃ� 1
*      CCR      TST.L D0
*****************************************************************
copy_region_to_buffer:
		movem.l	d1/d3/a0-a1,-(a7)
		move.b	d0,d1
		lea	linecutbuf(a5),a0
		tst.b	killing(a6)
		bne	copy_region_to_buffer_1

		clr.b	(a0)
copy_region_to_buffer_1:
		bsr	strlen
		move.l	d0,d3
		add.w	d2,d0
		cmp.w	#MAXLINELEN,d0
		bhi	cannot_copy_region_to_buffer

		clr.b	(a0,d0.w)
		btst	#1,d1
		bne	copy_region_to_buffer_2

		bsr	strbot
		bra	copy_region_to_buffer_3

copy_region_to_buffer_2:
		lea	(a0,d0.w),a0
		movea.l	a0,a1
		suba.w	d2,a1				*  ������
		move.l	d3,d0
		bsr	memmovd
		lea	linecutbuf(a5),a0
copy_region_to_buffer_3:
		movea.l	line_top(a6),a1
		lea	(a1,d4.w),a1
		moveq	#0,d0
		move.w	d2,d0
		bsr	memmovi
		st	killing(a6)
copy_region_to_buffer_success:
		moveq	#0,d0
copy_region_to_buffer_return:
		movem.l	(a7)+,d1/d3/a0-a1
		rts

cannot_copy_region_to_buffer:
		bsr	beep
		moveq	#1,d0
		bra	copy_region_to_buffer_return
*****************************************************************
* delete_region
*
* CALL
*      D2.W     �폜����̈�̒����i�o�C�g���j
*      D3.L     �폜����̈�̕�
*      D4.W     �폜����̈�̐擪�I�t�Z�b�g
*
* RETURN
*      none.
*****************************************************************
delete_region:
		movem.l	d0/a0-a1,-(a7)
		tst.w	d2
		beq	delete_region_done

		movea.l	line_top(a6),a0
		lea	(a0,d4.w),a0
		lea	(a0,d2.w),a1
		moveq	#0,d0
		move.w	nbytes(a6),d0
		sub.w	d4,d0
		sub.w	d2,d0
		move.l	a0,-(a7)
		bsr	memmovi
		movea.l	(a7)+,a0
		bsr	write_chars
		bsr	region_width
		exg	d0,d3
		bsr	put_spaces
		exg	d0,d3
		add.l	d3,d0
		bsr	backward_cursor

		sub.w	d2,nbytes(a6)
		add.w	d2,d1
		move.w	mark(a6),d0
		bmi	delete_region_done

		sub.w	d4,d0
		blo	delete_region_done

		cmp.w	d2,d0
		blo	delete_region_mark_missed

		sub.w	d2,mark(a6)
		bra	delete_region_done

delete_region_mark_missed:
		move.w	d4,mark(a6)
delete_region_done:
		movem.l	(a7)+,d0/a0-a1
		rts
*****************************************************************
redraw_with_prompt:
		move.l	a1,-(a7)
		movea.l	put_prompt_ptr(a6),a1
		bsr	put_prompt
		movea.l	(a7)+,a1
redraw:
		movem.l	d0/d2/a0,-(a7)
		movea.l	line_top(a6),a0
		move.w	nbytes(a6),d0
		bsr	write_chars
		move.w	point(a6),d2
		lea	(a0,d2.w),a0
		move.w	nbytes(a6),d0
		sub.w	d2,d0
		bsr	backward_cursor_x
		movem.l	(a7)+,d0/d2/a0
		rts
*****************************************************************
puts_ntimes:
		move.l	d0,-(a7)
		beq	puts_nitems_done
puts_ntimes_loop:
		bsr	puts
		subq.l	#1,d0
		bne	puts_ntimes_loop
puts_nitems_done:
		move.l	(a7)+,d0
		rts
*****************************************************************
put_spaces:
		movem.l	d0-d1,-(a7)
		move.l	d0,d1
		beq	put_spaces_done

		moveq	#' ',d0
put_spaces_loop:
		bsr	putc
		subq.l	#1,d1
		bne	put_spaces_loop
put_spaces_done:
		movem.l	(a7)+,d0-d1
		rts
*****************************************************************
write_chars:
		movem.l	d0-d1/a0,-(a7)
		move.w	d0,d1
		bra	write_chars_continue

write_chars_loop:
		move.b	(a0)+,d0
		cmp.b	#HT,d0
		beq	write_chars_tab

		bsr	cputc
		bra	write_chars_continue

write_chars_tab:
		moveq	#4,d0
		bsr	put_spaces
write_chars_continue:
		dbra	d1,write_chars_loop

		movem.l	(a7)+,d0-d1/a0
		rts
*****************************************************************
eol_newline:
		bsr	move_cursor_to_eol
		bra	put_newline
*****************************************************************
beep:
		tst.b	flag_nobeep(a5)
		bne	beep_done

		move.l	a0,-(a7)
		lea	t_bell,a0
		bsr	puts
		movea.l	(a7)+,a0
beep_done:
		rts
*****************************************************************
put_prompt:
		cmpa.l	#0,a1
		beq	put_prompt_done

		jsr	(a1)
put_prompt_done:
		rts
*****************************************************************
*  $prompt �̏����t���o�͕ϊ�����L��
*
*	�L��	���	�Ӗ�
*	%	s	���� '%'
*	!	d	����ԍ�
*	/	s	�J�����g�E�f�B���N�g���̊��S�p�X�i#�t���O��t�����~�ł̗��L�j
*	?	d	�V�F���ϐ� status �̒l
*	R	s	�p�[�T�̏��			# ������
*	y	d	�N�i���x���w�肳��C���ꂪ2�ȉ��Ȃ牺2���̂݁j
*	m	d	��
*	d	d	��
*	H	d	24���Ԑ��̎��i#�t���O��t�����12���Ԑ��j
*	M	d	��
*	S	d	�b
*	w	s	�j���̉p�ꖼ�i#�t���O��t����Ɠ��{�ꖼ�j
*	h	s	���̉p�ꖼ
*	a	s	�ߑO�Ȃ�� a�C�ߌ�Ȃ�� p�D�i#�t���O��t����ƌߑO�^�ߌ�j
*****************************************************************
.xdef put_prompt_1

put_prompt_1:
		movem.l	d0-d7/a0-a3,-(a7)
		lea	word_prompt2,a0
		tst.b	funcdef_status(a5)
		bne	put_prompt_2

		tst.b	switch_status(a5)
		bne	put_prompt_2

		tst.b	if_status(a5)
		bne	put_prompt_2

		tst.b	loop_status(a5)
		bmi	put_prompt_2

		lea	word_prompt,a0
put_prompt_2:
.if 0
		movem.l	d0-d7/a0-a4,-(a7)
		tst.b	in_prompt(a5)
		bne	no_prompt_function

		lea	word_prompt,a0
		lea	function_root(a5),a2
		bsr	find_function
		beq	no_prompt_function

		movea.l	d0,a1				*  A1 : �֐��̃w�b�_�̐擪�A�h���X
		moveq	#0,d0
		st	in_prompt(a5)
		bsr	source_function			*  �֐������s����
no_prompt_function:
		sf	in_prompt(a5)
		movem.l	(a7)+,d0-d7/a0-a4
.endif
.if 0
		movem.l	d0-d7/a0-a4,-(a7)
		tst.b	in_prompt(a5)
		bne	no_prompt_alias

		lea	word_prompt,a1
		movea.l	alias_top(a5),a0
		bsr	findvar				*  �ʖ���T��
		beq	no_prompt_alias

		bsr	get_var_value
		st	in_prompt(a5)
		bsr	cmd_eval
no_prompt_alias:
		sf	in_prompt(a5)
		movem.l	(a7)+,d0-d7/a0-a4
.endif
		bsr	find_shellvar
		beq	prompt_done

		bsr	get_var_value
		beq	prompt_done

		movea.l	a0,a1
		lea	tmpword1,a0
		bsr	strcpy
		bsr	compile_esch
		move.w	d0,d7
		movea.l	a0,a3
prompt_loop:
		subq.w	#1,d7
		bcs	prompt_done

		move.b	(a3)+,d0
		cmp.b	#'%',d0
		bne	prompt_normal_letter

		tst.w	d7
		beq	prompt_normal_char

		sf	d0				*  �ŏ��t�B�[���h���C���x�Ɂe*�f�`���Ȃ�
		bsr	preparse_fmtout
		bne	prompt_done

		cmp.b	#'%',d0
		beq	prompt_percent

		cmp.b	#'!',d0
		beq	prompt_eventno

		cmp.b	#'/',d0
		beq	prompt_cwd

		cmp.b	#'?',d0
		beq	prompt_status

		cmp.b	#'R',d0
		beq	prompt_request

		cmp.b	#'y',d0
		beq	prompt_year

		cmp.b	#'m',d0
		beq	prompt_month_of_year

		cmp.b	#'d',d0
		beq	prompt_day_of_month

		cmp.b	#'H',d0
		beq	prompt_hour

		cmp.b	#'M',d0
		beq	prompt_minute

		cmp.b	#'S',d0
		beq	prompt_second

		cmp.b	#'w',d0
		beq	prompt_week_word

		cmp.b	#'h',d0
		beq	prompt_month_word

		cmp.b	#'a',d0
		beq	prompt_ampm

		bra	prompt_loop

prompt_normal_letter:
		bsr	issjis
		bne	prompt_normal_char

		bsr	putc
		subq.w	#1,d7
		bcs	prompt_done

		move.b	(a3)+,d0
prompt_normal_char:
		bsr	putc
		bra	prompt_loop

prompt_done:
		movem.l	(a7)+,d0-d7/a0-a3
		rts
****************
*  %% : %
****************
prompt_percent:
		lea	word_percent,a0
prompt_string:
		bsr	prompt_string_sub
		bra	prompt_loop

prompt_string_sub:
		lea	putc(pc),a1
		tst.b	d5
		bne	prompt_string_precision_ok

		moveq	#-1,d4
prompt_string_precision_ok:
		bra	printfs
****************
*  %R : request
****************
prompt_request:
.if 0
		move.l	prompt_request_word(a5),a0
.else
		lea	word_sorry,a0
.endif
		bra	prompt_string
****************
*  %? : current status
****************
prompt_status:
		lea	word_status,a0
		movem.l	d1,-(a7)
		bsr	svartol
		exg	d0,d1
		cmp.l	#5,d1
		movem.l	(a7)+,d1
		beq	prompt_digit

		lea	msg_no_status,a0
		bra	prompt_string
****************
*  %! : current event number of history
****************
prompt_eventno:
		move.l	current_eventno(a5),d0
prompt_digit:
		lea	itoa(pc),a0
		lea	putc(pc),a1
		suba.l	a2,a2
		tst.b	d5
		bne	prompt_digit_precision_ok

		moveq	#1,d4
prompt_digit_precision_ok:
		bsr	printfi
		bra	prompt_loop
****************
*  %/ : current working directory
****************
cwdbuf = -(((MAXPATH+1)+1)>>1<<1)

prompt_cwd:
		link	a6,#cwdbuf
		lea	cwdbuf(a6),a0
		move.b	d6,d0
		bsr	getcwdx
		bsr	prompt_string_sub
		unlk	a6
		bra	prompt_loop
****************
*  %y : year
****************
prompt_year:
		DOS	_GETDATE
		lsr.l	#8,d0
		lsr.l	#1,d0
		and.l	#%1111111,d0
		add.l	#1980,d0
		tst.b	d5
		beq	prompt_digit

		cmp.l	#2,d4
		bhi	prompt_digit

		move.l	d1,-(a7)
		moveq	#100,d1
		bsr	divul
		move.l	d1,d0
		move.l	(a7)+,d1
		bra	prompt_digit
****************
*  %m : month of year
****************
prompt_month_of_year:
		DOS	_GETDATE
		lsr.l	#5,d0
		and.l	#%1111,d0
		bra	prompt_digit
****************
*  %h : month word
****************
prompt_month_word:
		DOS	_GETDATE
		lsr.l	#5,d0
		and.l	#%1111,d0
		subq.l	#1,d0
		lea	month_word_table,a0
prompt_name_in_table:
		bsr	strforn
		bra	prompt_string
****************
*  %d : day of month
****************
prompt_day_of_month:
		DOS	_GETDATE
		and.l	#%11111,d0
		bra	prompt_digit
****************
*  %a : week word
****************
prompt_week_word:
		DOS	_GETDATE
		swap	d0
		and.w	#%111,d0
		lea	english_week,a0
		tst.b	d6
		beq	prompt_name_in_table

		lea	japanese_week,a0
		bra	prompt_name_in_table
****************
*  %r : a(.m.)/p(.m.)
****************
prompt_ampm:
		DOS	_GETTIM2
		lsr.l	#8,d0
		lsr.l	#8,d0
		and.l	#%11111,d0
		cmp.b	#12,d0				*  Tricky!
		slo	d0				*    d0.l = d0.l < 12 ? 0 : 1;
		addq.b	#1,d0				*  (0:AM, 1:PM)
		lea	english_ampm,a0
		tst.b	d6
		beq	prompt_name_in_table

		lea	japanese_ampm,a0
		bra	prompt_name_in_table
****************
*  %H : hour
****************
prompt_hour:
		DOS	_GETTIM2
		lsr.l	#8,d0
		lsr.l	#8,d0
		and.l	#%11111,d0
		tst.b	d6
		beq	prompt_digit

		cmp.b	#12,d0
		bls	prompt_digit

		sub.b	#12,d0
		bra	prompt_digit
****************
*  %M : minute
****************
prompt_minute:
		DOS	_GETTIM2
		lsr.l	#8,d0
		and.l	#%111111,d0
		bra	prompt_digit
****************
*  %S : second
****************
prompt_second:
		DOS	_GETTIM2
		and.l	#%111111,d0
		bra	prompt_digit
*****************************************************************
* test_directory - �p�X���̃f�B���N�g�������݂��邩�ǂ����𒲂ׂ�
*
* CALL
*      A0     �p�X��
*
* RETURN
*      D0.L   ���݂���Ȃ��0
*      CCR    TST.L D0
*
* NOTE
*      / �݂̂�������A\ �͋����Ȃ�
*      flag_cifilec(B) ������
****************************************************************
statbuf = -STATBUFSIZE
searchnamebuf = statbuf-(((MAXPATH+1)+1)>>1<<1)

test_directory:
		link	a6,#searchnamebuf
		movem.l	d1-d2/a0-a3,-(a7)
		lea	searchnamebuf(a6),a2
		moveq	#0,d2
get_firstdir_restart:
		movea.l	a0,a3
		move.b	(a0)+,d0
		beq	get_firstdir_done

		cmp.b	#'/',d0
		beq	get_firstdir_root

		tst.w	d2
		bne	get_firstdir_done

		bsr	issjis
		beq	get_firstdir_done

		move.b	d0,d1
		move.b	(a0)+,d0
		beq	get_firstdir_done

		cmp.b	#':',d0
		bne	get_firstdir_done

		move.b	d1,(a2)+
		move.b	d0,(a2)+
		moveq	#1,d2
		bra	get_firstdir_restart

get_firstdir_root:
		move.b	d0,(a2)+
		movea.l	a0,a3
get_firstdir_done:
		clr.b	(a2)
		lea	searchnamebuf(a6),a0
		bsr	drvchkp				*  �h���C�u���͗L����
		bmi	test_directory_return		*  ���� .. false
test_directory_loop:
		*
		*  A2 : �������o�b�t�@�̃P�c
		*  A3 : ���ݒ��ڂ��Ă���G�������g�̐擪
		*
		movea.l	a3,a0				*  ���ݒ��ڂ��Ă���G�������g�̌���
		moveq	#'/',d0				*  / ��
		bsr	jstrchr				*  ���邩�H
		beq	test_directory_true		*  ���� .. true

		move.l	a0,d2
		sub.l	a3,d2				*  D2.L : �G�������g�̒���
		move.w	#MODEVAL_DIR,-(a7)		*  �f�B���N�g���݂̂�����
		pea	searchnamebuf(a6)
		pea	statbuf(a6)
		movea.l	a2,a0
		lea	dos_allfile,a1
		bsr	strcpy
		DOS	_FILES
		lea	10(a7),a7
test_directory_find_loop:
		tst.l	d0
		bmi	test_directory_return		*  �G���g�������� .. false

		lea	statbuf+ST_NAME(a6),a0
		movea.l	a3,a1
		move.l	d2,d0
		move.b	flag_cifilec(a5),d1
		bsr	memxcmp
		beq	test_directory_found

		pea	statbuf(a6)
		DOS	_NFILES
		addq.l	#4,a7
		bra	test_directory_find_loop

test_directory_found:
		move.l	d2,d0
		addq.l	#1,d0
		exg	a1,a3
		exg	a0,a2
		bsr	memmovi
		exg	a0,a2
		exg	a1,a3
		clr.b	(a2)
		bra	test_directory_loop

test_directory_true:
		moveq	#0,d0
test_directory_return:
		movem.l	(a7)+,d1-d2/a0-a3
		unlk	a6
		tst.l	d0
		rts
*****************************************************************
.data

.xdef word_separators

.even
key_function_jump_table:
		dc.l	x_self_insert
		dc.l	x_error
		dc.l	x_macro
		dc.l	x_prefix_1
		dc.l	x_prefix_2
		dc.l	x_abort
		dc.l	x_eof
		dc.l	x_accept_line
		dc.l	x_quoted_insert
		dc.l	x_redraw
		dc.l	x_clear_and_redraw
		dc.l	x_set_mark
		dc.l	x_exg_point_and_mark
		dc.l	x_search_character
		dc.l	x_bol
		dc.l	x_eol
		dc.l	x_backward_char
		dc.l	x_forward_char
		dc.l	x_backward_word
		dc.l	x_forward_word
		dc.l	x_del_back_char
		dc.l	x_del_for_char
		dc.l	x_kill_back_word
		dc.l	x_kill_for_word
		dc.l	x_kill_bol
		dc.l	x_kill_eol
		dc.l	x_kill_whole_line
		dc.l	x_kill_region
		dc.l	x_copy_region
		dc.l	x_yank
		dc.l	x_upcase_char
		dc.l	x_downcase_char
		dc.l	x_upcase_word
		dc.l	x_downcase_word
		dc.l	x_upcase_region
		dc.l	x_downcase_region
		dc.l	x_transpose_chars
		dc.l	x_transpose_words
		dc.l	x_up_history
		dc.l	x_down_history
		dc.l	x_complete
		dc.l	x_complete_command
		dc.l	x_complete_file
		dc.l	x_complete_variable
		dc.l	x_complete_environment_variable
		dc.l	x_complete_shell_variable
		dc.l	x_list
		dc.l	x_list_command
		dc.l	x_list_file
		dc.l	x_list_variable
		dc.l	x_list_environment_variable
		dc.l	x_list_shell_variable
		dc.l	x_list_or_eof
		dc.l	x_del_for_char_or_list
		dc.l	x_del_for_char_or_list_or_eof
		dc.l	x_copy_prev_word

word_fignore:		dc.b	'fignore',0
word_matchbeep:		dc.b	'matchbeep',0
word_ambiguous:		dc.b	'ambiguous',0
word_notunique:		dc.b	'notunique',0
word_addsuffix:		dc.b	'addsuffix',0

filec_separators:	dc.b	'"',"'",'`^'
word_separators:	dc.b	' ',HT,LF,VT,FS,CR
x_special_characters:	dc.b	'<>)'
x_command_separators:	dc.b	'(;&|',0

month_word_table:
		dc.b	'January',0
		dc.b	'February',0
		dc.b	'March',0
		dc.b	'April',0
		dc.b	'May',0
		dc.b	'June',0
		dc.b	'July',0
		dc.b	'August',0
		dc.b	'September',0
		dc.b	'October',0
		dc.b	'November',0
		dc.b	'December',0
		dc.b	0
		dc.b	0
		dc.b	0

english_week:
		dc.b	'Sunday',0
		dc.b	'Monday',0
		dc.b	'Tuesday',0
		dc.b	'Wednesday',0
		dc.b	'Thursday',0
		dc.b	'Friday',0
		dc.b	'Saturday',0
		dc.b	0

japanese_week:
		dc.b	'��',0
		dc.b	'��',0
		dc.b	'��',0
		dc.b	'��',0
		dc.b	'��',0
		dc.b	'��',0
		dc.b	'�y',0
		dc.b	0

english_ampm:
		dc.b	'a',0
		dc.b	'p',0

japanese_ampm:
		dc.b	'�ߑO',0
		dc.b	'�ߌ�',0

t_bs:		dc.b	BS,0				*  �mtermcap�n
t_fs:		dc.b	FS,0				*  �mtermcap�n
t_clear:	dc.b	ESC,'[2J',0			*  �mtermcap�n
t_bell:		dc.b	BL,0				*  �mtermcap�n

.if 0
msg_reverse_i_search:	dc.b	'reverse-'
msg_i_search:		dc.b	'i-search: ',0
msg_i_search_colon:	dc.b	' : ',0
.endif

msg_no_status:	dc.b	'(status is unset)',0
word_sorry:	dc.b	'(%R is not available yet)',0
word_percent:	dc.b	'%',0

.end
