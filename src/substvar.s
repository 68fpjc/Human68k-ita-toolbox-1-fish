* substvar.s
* Itagaki Fumihiko 10-Oct-90  Create.

.include limits.h
.include ../src/fish.h
.include ../src/source.h
.include ../src/modify.h

.xref isdigit
.xref isspace2
.xref issjis
.xref strlen
.xref strchr
.xref strforn
.xref copy_wordlist
.xref atou
.xref utoa
.xref skip_varname
.xref fish_getenv
.xref find_shellvar
.xref get_var_value
.xref modify
.xref getline_stdin
.xref xmallocp
.xref xfree
.xref eputs
.xref enputs
.xref irandom
.xref free_tmpgetlinebuf
.xref too_many_words
.xref too_long_word
.xref too_long_line
.xref cannot_because_no_memory
.xref undefined
.xref word_argv
.xref word_status
.xref msg_bad_subscript
.xref msg_syntax_error
.xref msg_subscript_out_of_range
.xref dummy

.xref tmpline
.xref pid
.xref myname
.xref irandom_struct
.xref not_execute
.xref current_source
.xref tmpgetlinebufp
.xref var_line_eof
.xref in_getline_x

.text

****************************************************************
.xdef allocate_tmpgetlinebuf

allocate_tmpgetlinebuf:
			lea	tmpgetlinebufp(a5),a0
			move.l	#MAXLINELEN+1,d0
			bra	xmallocp
****************************************************************
* D5 : 0 : 何もしない
*      1 : 単語カウンタを進める
****************************************************************
.xdef dup1
.xdef dup1_1
.xdef dup1_2
.xdef dup1_3

dup1:
		tst.b	d5
		beq	dup1_1

		addq.w	#1,d4			* ++argc
		cmp.w	d3,d4			* D3 : 展開語数の限度
		bhi	dup1_too_many_words

		move.w	#MAXWORDLEN,d2		* 単語の長さの限度を更新
		moveq	#0,d5			* 「新たな語とする」フラグをクリア
dup1_1:
		subq.w	#1,d2
		bcs	dup1_too_long_word
dup1_2:
		subq.w	#1,d1
		bcs	dup1_buffer_over
dup1_3:
		move.b	d0,(a1)+
		and.l	#$ff,d0
		rts

inc_wordc_fail:
		addq.l	#4,a7
		rts

dup1_too_many_words:
		moveq	#-1,d0
		rts

dup1_buffer_over:
		moveq	#-2,d0
		rts

dup1_too_long_word:
		moveq	#-3,d0
		rts
****************************************************************
.xdef dup1_with_escaping

dup1_with_escaping:
		move.l	d0,-(a7)
		moveq	#'\',d0
		bsr	dup1
		bmi	dup1_with_escaping_return

		move.l	(a7)+,d0
		bra	dup1
****************************************************************
.xdef dup1_with_escaping_in_quote

dup1_with_escaping_in_quote:
		move.l	d0,-(a7)
		moveq	#'"',d0
		bsr	dup1
		bmi	dup1_with_escaping_return

		moveq	#'\',d0
		bsr	dup1
		bmi	dup1_with_escaping_return

		move.l	(a7),d0
		bsr	dup1
		bmi	dup1_with_escaping_return

		moveq	#'"',d0
		bsr	dup1
		bmi	dup1_with_escaping_return

		move.l	(a7),d0
		and.l	#$ff,d0
dup1_with_escaping_return:
		addq.l	#4,a7
		tst.l	d0
		rts
****************************************************************
terminate_word:
		tst.b	d5
		bne	terminate_word_1

		moveq	#0,d0
		moveq	#1,d2
		bsr	dup1
		bmi	terminate_word_return
terminate_word_1:
		moveq	#1,d5
terminate_word_return:
		rts
****************************************************************
* expand_var - 変数置換をする
*
* CALL
*      A0     変数置換を指す
*      A1     格納するバッファの先頭アドレス
*      D1.W   バッファの容量
*      D2.W   最初の単語の長さの限度
*      D3.W   展開語数の限度
*      D4.W   現在までに展開した単語の数
*      D5.B   「新たな語とする」フラグ
*      D7.B   0 : 値の単語並びをさらに空白で分ける。  \  '  "  `  を  \\  \'  \"  \`  とする。
*             1 : 値の単語並びを１つの単語にまとめる。  "  `  を  "\""  "\`"  とする。
*             2 : 値の単語並びを１つの単語にまとめる。エスケープはしない。
*
* RETURN
*      D0.L   成功ならば 0
*             負数ならばエラー
*                  -1  展開語数が限度を超えた
*                  -2  バッファの容量を超えた
*                  -3  単語の長さが規定を超えた
*                  -4  その他のエラー．メッセージが表示される．
*                           変数が未定義
*                           文法が誤り
*                           添字が範囲外
*                           添字の値がオーバーフロー
*
*      A0     終端の次の位置
*      A1     バッファの次の格納位置
*      D1.W   下位ワードは残りバッファ容量
*      D2.W   現在の単語の残り容量
*      D4.W   展開した単語の数だけインクリメントされる
*      D5.B   状態に従って変化している
*      CCR    TST.L D0
*
*      上記のうち .W の上位ワードは保証されない
*      エラーの場合、上記のうち D0.L と CCR 以外の値は保証されない
*****************************************************************
MAXCHAR_INDEX = 10+1+10

indexbuf = -(((MAXCHAR_INDEX+1)+1)>>1<<1)
allocated_by_modify = indexbuf-4
source_pointer = allocated_by_modify-4
word_from = source_pointer-4		*  展開する最初の単語番号
word_to = word_from-4			*  展開する最後の単語番号（-1:最後の単語まで）
modifier_pointer = word_to-4
modify_status = modifier_pointer-1
quote_word = modify_status-1
eval_option = quote_word-1		*  $@  $%  フラグ
braceflag = eval_option-1		*  {}  フラグ
sharp_question= braceflag-1		*  $#  $?  フラグ
special = sharp_question-1		*  $$  $<  $,  $0  フラグ
digit = special-1			*  $i  フラグ
mode = digit-1
not_expand = mode-1
pad = not_expand-1			*  偶数に合わせる

expand_var:
		link	a6,#pad
		move.b	d7,mode(a6)
		movem.l	d6-d7/a2-a4,-(a7)
		clr.l	allocated_by_modify(a6)
		sf	quote_word(a6)
		move.l	#1,word_from(a6)	* 展開する最初の単語の番号
		move.l	#-1,word_to(a6)		* 展開する最後の単語の番号  -1:最後の単語
		cmpi.b	#'@',(a0)
		beq	expand_var_eval_option

		cmpi.b	#'%',(a0)
		beq	expand_var_eval_option

		clr.b	eval_option(a6)
		bra	expand_var_check_open_brace

expand_var_eval_option:
		move.b	(a0)+,eval_option(a6)
expand_var_check_open_brace:
		clr.b	braceflag(a6)
		cmpi.b	#'{',(a0)
		bne	expand_var_no_brace

		move.b	(a0)+,braceflag(a6)
expand_var_no_brace:
		sf	not_expand(a6)
		clr.b	sharp_question(a6)
		clr.b	special(a6)
		sf	digit(a6)
		cmpi.b	#'#',(a0)				*   $[%@]#...
		beq	expand_var_sharp_question

		cmpi.b	#'?',(a0)				*   $[%@]?...
		bne	expand_var_no_sharp_question
expand_var_sharp_question:
		move.b	(a0)+,sharp_question(a6)
expand_var_no_sharp_question:
		movea.l	a0,a2					*  A2 : top of name
		bsr	skip_varname				*  A0 : bottom of name
		cmpa.l	a2,a0
		bne	expand_var_get_varname_ok

		tst.b	eval_option(a6)
		bne	expand_var_syntax_error

		move.b	(a0)+,d0
		cmp.b	#'*',d0
		beq	expand_var_argv_x			*  $*

		cmp.b	#'$',d0
		beq	expand_var_special_1			*  $$

		cmp.b	#',',d0
		beq	expand_var_special_1			*  $,

		cmp.b	#'<',d0
		beq	expand_var_special_2			*  $<

		subq.l	#1,a0
		bsr	isdigit
		beq	expand_var_digit

		cmpi.b	#'#',sharp_question(a6)
		beq	expand_var_argv

		cmpi.b	#'?',sharp_question(a6)
		bne	expand_var_syntax_error

		*  $?
		clr.b	sharp_question(a6)
		lea	word_status,a2
		lea	dummy,a3
		bra	expand_var_start

expand_var_digit:
		st	digit(a6)
		move.l	d1,-(a7)
		bsr	atou
		move.l	d1,d0
		move.l	(a7)+,d1
		move.l	d0,word_from(a6)
		move.l	d0,word_to(a6)
		beq	expand_var_0
		*  $i
expand_var_argv_x:
		tst.b	sharp_question(a6)
		bne	expand_var_syntax_error
expand_var_argv:
		lea	word_argv,a2
		lea	dummy,a3
		bra	expand_var_start

expand_var_0:
		*  $0
		moveq	#'0',d0
		bra	expand_var_special_2

expand_var_special_1:
		tst.b	sharp_question(a6)
		bne	expand_var_syntax_error
expand_var_special_2:
		cmpi.b	#'#',sharp_question(a6)
		beq	expand_var_syntax_error

		move.b	d0,special(a6)
		bra	expand_var_start

expand_var_get_varname_ok:
		movea.l	a0,a3					* A3 : bottom of name
		tst.b	sharp_question(a6)
		bne	expand_var_start

		tst.b	special(a6)
		bne	expand_var_start

		cmpi.b	#'[',(a0)
		bne	expand_var_start

		addq.l	#1,a0

		movem.l	d1/a1,-(a7)
		lea	indexbuf(a6),a1
		move.w	#MAXCHAR_INDEX,d1
		moveq	#']',d0
		bsr	subst_var_2			***!! 再帰 !!***
		movem.l	(a7)+,d1/a1
		cmp.l	#-4,d0
		beq	expand_var_return

		tst.l	d0
		bmi	expand_var_subscript_too_long

		cmpi.b	#']',-1(a0)
		bne	expand_var_subscript_error

		move.l	#1,word_from(a6)
		move.l	#-1,word_to(a6)
		tst.b	not_execute(a5)
		bne	expand_var_start

		lea	indexbuf(a6),a4
		move.b	(a4)+,d0
		cmp.b	#'*',d0
		beq	selecter_fixed

		cmp.b	#'-',d0
		beq	get_selecter_2
		*
		*  selecter1 を読み取る
		*
		move.l	d1,-(a7)
		move.l	#-2,word_from(a6)			*  -2 : overflow
		subq.l	#1,a4
		exg	a0,a4
		bsr	atou
		exg	a0,a4
		bmi	expand_var_subscript_error
		bne	selecter_1_ok

		tst.l	d1
		bmi	selecter_1_ok

		move.l	d1,word_from(a6)
selecter_1_ok:
		move.l	(a7)+,d1
****************
		move.b	(a4)+,d0
		cmp.b	#'*',d0
		beq	selecter_fixed

		cmp.b	#'-',d0
		beq	get_selecter_2

		subq.l	#1,a4
		move.l	word_from(a6),word_to(a6)
		bra	selecter_fixed

get_selecter_2:
		*
		*  （もしあれば）selecter2 を読み取る
		*
		move.l	d1,-(a7)
		exg	a0,a4
		bsr	atou
		exg	a0,a4
		bmi	selecter_2_ok

		move.l	#-2,word_to(a6)				*  -2 : overflow
		tst.l	d0
		bne	selecter_2_ok

		tst.l	d1
		bmi	selecter_2_ok

		move.l	d1,word_to(a6)
selecter_2_ok:
		move.l	(a7)+,d1
****************
selecter_fixed:
		tst.b	(a4)
		bne	expand_var_subscript_error
****************
expand_var_start:
		move.l	a0,source_pointer(a6)
		tst.b	not_execute(a5)
		bne	expand_var_start_var

		cmpi.b	#'0',special(a6)
		bne	not_0
		* {
			movea.l	myname(a5),a0
			move.l	current_source(a5),d0
			beq	arg0_1

			movea.l	d0,a0
			lea	SOURCE_HEADER_SIZE(a0),a0
arg0_1:
			cmpi.b	#'?',sharp_question(a6)
			beq	is_defined_arg0

			cmpa.l	#0,a0
			bne	expand_var_1word

			lea	msg_no_file_for_0,a0
			bra	expand_var_syntax_error_2

is_defined_arg0:
			cmpa.l	#0,a0
			sne	d0
			bra	do_expand_bool
		* }
not_0:
		cmpi.b	#'<',special(a6)
		bne	not_gets
		* {
			cmpi.b	#'?',sharp_question(a6)
			beq	do_expand_line_is_eof

			bsr	allocate_tmpgetlinebuf
			beq	cannot_getline

			movea.l	d0,a0
			move.w	#MAXLINELEN,d1
			movem.l	d4/a1,-(a7)
			suba.l	a1,a1
			moveq	#0,d4
			bsr	getline_stdin
			movem.l	(a7)+,d4/a1
			smi	var_line_eof(a5)
			neg.l	d0
			bmi	expand_var_buffer_over

			movea.l	tmpgetlinebufp(a5),a0
			st	quote_word(a6)
			bra	expand_var_1word

do_expand_line_is_eof:
			tst.b	var_line_eof(a5)
			seq	d0
			bra	do_expand_bool
		* }
not_gets:
		cmpi.b	#'$',special(a6)
		bne	not_pid
		* {
			move.l	pid(a5),d0
			bra	expand_var_utoa
		* }
not_pid:
		cmpi.b	#',',special(a6)
		bne	not_random
		* {
			lea	irandom_struct(a5),a0
			bsr	irandom
			bra	expand_var_utoa
		* }
not_random:
		movea.l	a2,a0
		move.b	(a3),d7
		clr.b	(a3)
		cmpi.b	#'%',eval_option(a6)
		beq	try_env

		move.l	a0,-(a7)
		bsr	find_shellvar
		movea.l	(a7)+,a0
		bne	eval_var_found

		cmpi.b	#'@',eval_option(a6)
		beq	eval_var_undefined
try_env:
		move.l	a0,-(a7)
		bsr	fish_getenv
		movea.l	(a7)+,a0
		beq	eval_var_undefined
eval_var_found:
		bsr	get_var_value
		bra	eval_var_done

eval_var_undefined:
		moveq	#-1,d0
eval_var_done:
		move.b	d7,(a3)
		cmpi.b	#'?',sharp_question(a6)
		bne	expand_not_question

		tst.l	d0
		spl	d0
do_expand_bool:
		lea	indexbuf(a6),a0
		move.b	#'1',(a0)
		clr.b	1(a0)
		tst.b	d0
		bne	expand_var_1word

		move.b	#'0',(a0)
		bra	expand_var_1word

expand_not_question:
		tst.l	d0
		bpl	var_found
		* {
			tst.b	digit(a6)
			bne	expand_var_null

			tst.b	in_getline_x(a5)
			bne	expand_var_undefined_1

			move.b	(a3),d7
			clr.b	(a3)
			movea.l	a2,a0
			bsr	undefined
			move.b	d7,(a3)
expand_var_undefined_1:
			bra	expand_var_misc_error_return
		* }
var_found:
		tst.b	sharp_question(a6)
		beq	expand_not_sharp
		* {
expand_var_utoa:
			lea	indexbuf(a6),a0
			bsr	utoa
expand_var_1word:
			moveq	#0,d7
			bra	expand_var_start_var
		*}
expand_not_sharp:
		cmpi.l	#-1,word_to(a6)
		bne	index2_fixed

		move.l	d0,word_to(a6)
index2_fixed:
		cmp.l	word_to(a6),d0
		bhs	range_ok

		tst.b	digit(a6)
		bne	expand_var_null
out_of_range:
		lea	msg_subscript_out_of_range,a2
		bra	expand_var_syntax_error_1

range_ok:
		move.l	word_to(a6),d0
		beq	expand_var_null

		cmp.l	word_from(a6),d0
		blo	expand_var_null

		move.l	word_from(a6),d0
		beq	out_of_range

		subq.w	#1,d0					* D0.W : 最初に跳ばす単語数
		bsr	strforn
		move.l	word_to(a6),d7
		sub.l	word_from(a6),d7			* D7.W : 取り出す単語数-1
		bra	expand_var_start_var

expand_var_null:
		st	not_expand(a6)
		lea	str_nul,a0
****************
*  展開を開始する
expand_var_start_var:
		addq.w	#1,d7
		exg	d1,d7
		moveq	#0,d0
		move.l	a1,-(a7)
		movea.l	source_pointer(a6),a1
		bsr	modify
		move.l	a1,source_pointer(a6)
		movea.l	(a7)+,a1
		exg	d1,d7
		move.b	d0,modify_status(a6)
		btst	#MODIFYSTATBIT_MALLOC,d0
		beq	expand_var_not_alloced

		move.l	a0,allocated_by_modify(a6)
expand_var_not_alloced:
		btst	#MODIFYSTATBIT_NOMEM,d0
		bne	expand_var_misc_error_return

		btst	#MODIFYSTATBIT_ERROR,d0
		bne	expand_var_misc_error_return

		btst	#MODIFYSTATBIT_OVFLO,d0
		bne	expand_var_buffer_over

		tst.b	braceflag(a6)
		beq	brace_ok

		movea.l	source_pointer(a6),a4
		cmpi.b	#'}',(a4)+
		bne	expand_var_syntax_error

		move.l	a4,source_pointer(a6)
brace_ok:
		tst.b	not_expand(a6)
		bne	expand_var_done

		tst.b	quote_word(a6)
		beq	expand_var_loop1

		bset.b	#MODIFYSTATBIT_Q,modify_status(a6)
****************
*  展開単語毎のループ
expand_var_loop1:
		bsr	strlen
		bne	expand_var_loop2

		addq.l	#1,a0
		subq.w	#1,d7
		beq	expand_var_done

		bra	expand_var_loop1
****************
expand_var_loop2:
		moveq	#0,d0
		move.b	(a0)+,d0
		beq	expand_var_continue

		cmpi.b	#2,mode(a6)				*  mode == 2 では
		beq	expand_var_dup1				*  空白を保存する

		tst.b	mode(a6)				*  mode == 1 では
		bne	expand_var_dup1_mode1			*  空白を保存する

		btst.b	#MODIFYSTATBIT_Q,modify_status(a6)	*  :q では
		bne	expand_var_dup1_mode0			*  空白を保存する

		bsr	isspace2				*  空白文字でなければ
		bne	expand_var_dup1_mode0			*  コピーを続ける

		bsr	terminate_word
		bmi	expand_var_return

		bra	expand_var_loop2

expand_var_dup1_mode0:
		move.l	a0,-(a7)
		lea	characters_to_be_escaped_1,a0		*  { ~ = * ? [ \ ' ` "
		btst.b	#MODIFYSTATBIT_Q,modify_status(a6)
		bne	expand_var_dup_character_check

		btst.b	#MODIFYSTATBIT_X,modify_status(a6)
		bne	expand_var_dup_character_check

		lea	characters_to_be_escaped_4,a0		*  \ ' ` "
		bra	expand_var_dup_character_check

expand_var_dup1_mode1:
		move.l	a0,-(a7)
		lea	characters_to_be_escaped_5,a0		*  ` "
expand_var_dup_character_check:
		bsr	strchr					*  いずれもシフトJIS文字は含んでいない
		movea.l	(a7)+,a0
		beq	expand_var_dup1

		tst.b	mode(a6)
		beq	expand_var_dup_with_escaping

		bsr	dup1_with_escaping_in_quote
		bra	expand_var_dup1_1

expand_var_dup_with_escaping:
		bsr	dup1_with_escaping
		bra	expand_var_dup1_1

expand_var_dup1:
		bsr	dup1
expand_var_dup1_1:
		bmi	expand_var_return

		bsr	issjis
		bne	expand_var_loop2

		move.b	(a0)+,d0
		beq	expand_var_continue

		bsr	dup1
		bmi	expand_var_return

		bra	expand_var_loop2
****************
expand_var_continue:
		subq.w	#1,d7
		beq	expand_var_done

		tst.b	mode(a6)
		bne	expand_var_continue_1

		bsr	terminate_word
		bra	expand_var_continue_2

expand_var_continue_1:
		moveq	#' ',d0
		bsr	dup1
expand_var_continue_2:
		bmi	expand_var_return

		bra	expand_var_loop1
****************
expand_var_done:
		movea.l	source_pointer(a6),a0
		moveq	#0,d0
expand_var_return:
		movem.l	d0/a0,-(a7)
		move.l	allocated_by_modify(a6),d0
		bsr	xfree
		bsr	free_tmpgetlinebuf
		movem.l	(a7)+,d0/a0
		movem.l	(a7)+,d6-d7/a2-a4
		unlk	a6
		tst.l	d0
		rts
********************************
expand_var_buffer_over:
		moveq	#-2,d0
		bra	expand_var_return
****************
cannot_getline:
		tst.b	in_getline_x(a5)
		bne	cannot_getline_1

		lea	msg_cannot_getline,a0
		bsr	cannot_because_no_memory
cannot_getline_1:
		bra	expand_var_misc_error_return
****************
expand_var_subscript_too_long:
		lea	msg_subscript_too_long,a2
		bra	expand_var_syntax_error_1
****************
expand_var_subscript_error:
		lea	msg_bad_subscript,a2
		bra	expand_var_syntax_error_1
****************
expand_var_syntax_error:
		lea	msg_syntax_error,a2
****************
expand_var_syntax_error_1:
		tst.b	in_getline_x(a5)
		bne	expand_var_syntax_error_2

		lea	msg_subst,a0
		bsr	eputs
		movea.l	a2,a0
expand_var_syntax_error_2:
		tst.b	in_getline_x(a5)
		bne	expand_var_syntax_error_3

		bsr	enputs
expand_var_syntax_error_3:
expand_var_misc_error_return:
		moveq	#-4,d0
		bra	expand_var_return
****************************************************************
* subst_var - １語について変数置換をする
*             ""の中では置換するが、''および``の中では置換しない
*             \$.. や ..$ は置換せず、そのまま
*
* CALL
*      A0     ソースとなる単語の先頭アドレス
*      A1     格納するバッファの先頭アドレス
*      D0.W   展開語数の限度
*      D1.W   バッファの容量
*
* RETURN
*      A0     ソースの終端の次の位置
*             ただしエラーのときには保証されない
*
*      A1     バッファの次の格納位置
*             ただしエラーのときには保証されない
*
*      D0.L   正数ならば成功．下位ワードは展開語数．
*             負数ならばエラー．
*                  -1  展開語数が限度を超えた
*                  -2  バッファの容量を超えた
*                  -3  単語の長さが規定を超えた
*                  -4  その他のエラー．メッセージが表示される．
*                           変数が未定義
*                           文法が誤り
*                           添字が範囲外
*                           添字の値がオーバーフロー
*
*      D1.L   下位ワードは残りバッファ容量
*             ただしエラーのときには保証されない
*             上位ワードは破壊
*
*      CCR    TST.L D0
*****************************************************************
.xdef subst_var

subst_var:
		movem.l	d2-d7,-(a7)
		move.w	#MAXWORDLEN,d2			* D2.W : 展開中の単語の長さの限度
		move.w	d0,d3				* D3.W : 展開語数の限度
		moveq	#0,d4				* D4.W : 展開後の単語数カウンタ
		moveq	#1,d5				* D5.B : 新たな語を開始する
		moveq	#0,d6				* D6.B : " フラグ
subst_var_loop:
		move.b	(a0)+,d0
		beq	subst_var_done

		bsr	issjis
		beq	subst_var_dup2

		tst.b	d6
		beq	subst_var_not_in_quote

		cmp.b	d6,d0
		beq	subst_var_quote

		cmp.b	#'"',d6
		bne	subst_var_dup1

		cmp.b	#'`',d0
		beq	subst_var_backquote_in_doublequote

		tst.b	d7
		bne	subst_var_dup1

		bra	subst_var_check_doller

subst_var_backquote_in_doublequote:
		not.b	d7
		bra	subst_var_dup1

subst_var_quote:
		eor.b	d0,d6
		moveq	#0,d7
		bra	subst_var_dup1

subst_var_not_in_quote:
		cmp.b	#'\',d0
		beq	subst_var_escape

		cmp.b	#'"',d0
		beq	subst_var_quote

		cmp.b	#"'",d0
		beq	subst_var_quote

		cmp.b	#'`',d0
		beq	subst_var_quote
subst_var_check_doller:
		cmp.b	#'$',d0
		bne	subst_var_dup1

		move.b	(a0),d0
		beq	subst_var_dup_doller

		bsr	isspace2
		beq	subst_var_dup_doller

		movem.l	d7,-(a7)
		move.b	d6,d7
		beq	subst_var_do_expand

		moveq	#1,d7
subst_var_do_expand:
		bsr	expand_var
		movem.l	(a7)+,d7
		bmi	subst_var_return

		bra	subst_var_loop

subst_var_dup_doller:
		moveq	#'$',d0
		bra	subst_var_dup1

subst_var_escape:
		bsr	dup1
		bmi	subst_var_return

		move.b	(a0)+,d0
		beq	subst_var_done

		bsr	issjis
		bne	subst_var_dup1
subst_var_dup2:
		bsr	dup1
		bmi	subst_var_return

		move.b	(a0)+,d0
		beq	subst_var_done
subst_var_dup1:
		bsr	dup1
		bmi	subst_var_return

		bra	subst_var_loop

subst_var_done:
		bsr	terminate_word
		bmi	subst_var_return

		move.w	d4,d0
subst_var_return:
		movem.l	(a7)+,d2-d7
		tst.l	d0
		rts
****************************************************************
* subst_var_2 - １文字列について変数置換をする
*               \$.. は $..、..$ は ..$ とするが、それ以外は置換する
*               " ' ` は特別な意味を持たない
*               単語は保存し、単語並びは空白で区切る
*
* CALL
*      A0     ソースとなる文字列の先頭アドレス
*      A1     格納するバッファの先頭アドレス
*      D0.B   NULの他の終端文字
*      D1.W   バッファの容量（最後のNULは含まない）
*
* RETURN
*      A0     ソースの終端の次の位置
*             ただしエラーのときには保証されない
*
*      D0.L   0ならば成功
*             負数ならばエラー．
*                  -2  バッファの容量を超えた
*                  -4  その他のエラー．メッセージが表示される．
*                           変数が未定義
*                           文法が誤り
*                           添字が範囲外
*                           添字の値がオーバーフロー
*
*      CCR    TST.L D0
*****************************************************************
.xdef subst_var_2

subst_var_2:
		movem.l	d1-d2/d5-d7/a1,-(a7)
		move.b	d0,d6
		move.w	d1,d2
		addq.w	#1,d2
		moveq	#0,d5
		moveq	#2,d7
subst_var_2_loop:
		move.b	(a0)+,d0
		beq	subst_var_2_done

		bsr	issjis
		beq	subst_var_2_dup2

		cmp.b	d6,d0
		beq	subst_var_2_done

		cmp.b	#'\',d0
		beq	subst_var_2_escape

		cmp.b	#'$',d0
		bne	subst_var_2_dup1

		move.b	(a0),d0
		beq	subst_var_2_dup_doller

		cmp.b	d6,d0
		beq	subst_var_2_dup_doller

		bsr	isspace2
		beq	subst_var_2_dup_doller

		bsr	expand_var
		bmi	subst_var_2_return

		bra	subst_var_2_loop

subst_var_2_dup_doller:
		moveq	#'$',d0
		bra	subst_var_2_dup1

subst_var_2_escape:
		move.b	(a0)+,d0
		cmp.b	#'$',d0
		beq	subst_var_2_dup1

		moveq	#'\',d0
		bsr	dup1
		bmi	subst_var_2_return

		move.b	-1(a0),d0
		beq	subst_var_2_done

		bsr	issjis
		bne	subst_var_2_dup1
subst_var_2_dup2:
		bsr	dup1
		bmi	subst_var_2_return

		move.b	(a0)+,d0
		beq	subst_var_2_done

		cmp.b	d6,d0
		beq	subst_var_2_done
subst_var_2_dup1:
		bsr	dup1
		bmi	subst_var_2_return

		bra	subst_var_2_loop

subst_var_2_done:
		clr.b	(a1)
		moveq	#0,d0
subst_var_2_return:
		movem.l	(a7)+,d1-d2/d5-d7/a1
		tst.l	d0
		rts
****************************************************************
* subst_var_wordlist - 単語並びの各単語について変数置換をする
*
* CALL
*      A0     格納領域の先頭．引数並びと重なっていても良い．
*      A1     引数並びの先頭
*      D0.W   語数
*
* RETURN
*      (tmpline)   破壊される
*
*      D0.L   正数ならば成功．下位ワードは展開後の語数
*             負数ならばエラー
*
*      (A0)   破壊
*
*      CCR    TST.L D0
****************************************************************
.xdef subst_var_wordlist

subst_var_wordlist:
		movem.l	d1-d3/a0-a1,-(a7)
		move.w	#MAXWORDLISTSIZE,d1	* D1 : 最大文字数
		move.w	d0,d2			* D2 : 引数カウンタ
		moveq	#0,d3			* D3 : 展開後の語数
		move.l	a0,-(a7)
		lea	tmpline(a5),a0		* 一時領域に
		bsr	copy_wordlist		* 引数並びを一旦コピーしてこれをソースとする
		movea.l	(a7)+,a1
		bra	subst_wordlist_continue

subst_wordlist_loop:
		move.w	#MAXWORDS,d0
		sub.w	d3,d0
		bsr	subst_var
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
****************************************************************
.data

.xdef characters_to_be_escaped_3

msg_subst:			dc.b	'変数置換の',0
msg_subscript_too_long:		dc.b	'添字が長過ぎます',0
msg_no_file_for_0:		dc.b	'$0 に対する名前はありません',0
msg_cannot_getline:		dc.b	' $< を処理できません',0

characters_to_be_escaped_1:	dc.b	'{'
characters_to_be_escaped_2:	dc.b	'~='
characters_to_be_escaped_3:	dc.b	'*?['
characters_to_be_escaped_4:	dc.b	"\'"
characters_to_be_escaped_5:	dc.b	'`"'
str_nul:			dc.b	0

.end
