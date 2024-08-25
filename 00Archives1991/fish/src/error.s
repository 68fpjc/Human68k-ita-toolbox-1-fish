* error.s
* Itagaki Fumihiko 11-Jul-90  Create.

* This contains error print (and process if any) routines.

.include chrcode.h

.xref eputc
.xref eputs
.xref ecputs
.xref enputs
.xref strip_quotes
.xref msg_ambiguous
.xref command_name

.text

.xdef usage
usage:
		move.l	a0,-(a7)
		lea	msg_usage,a0
		bsr	eputs
		tst.l	command_name
		beq	usage_1

		movea.l	command_name,a0
		bsr	ecputs
		move.b	#' ',d0
		bsr	eputc
usage_1:
		movea.l	(a7)+,a0
		bra	enputs1

.xdef command_error
.xdef enputs1

command_error:
		bsr	perror_command_name
enputs1:
		bsr	enputs
		moveq	#1,d0
		rts

.xdef syntax_error
syntax_error:
		move.l	a0,-(a7)
		lea	msg_syntax_error,a0
command_error_return:
		bsr	command_error
error_return_0:
		movea.l	(a7)+,a0
		rts

.xdef badly_formed_number
badly_formed_number:
		lea	msg_badly_formed_number,a0
		bra	command_error

.xdef bad_arg
bad_arg:
		move.l	a0,-(a7)
		lea	msg_bad_arg,a0
		bra	command_error_return

.xdef too_many_args
too_many_args:
		lea	msg_too_many_args,a0
		bra	command_error

.xdef too_few_args
too_few_args:
		lea	msg_too_few_args,a0
		bra	command_error

.xdef subscript_out_of_range
subscript_out_of_range:
		move.l	a0,-(a7)
		lea	msg_subscript_out_of_range,a0
		bra	command_error_return

.xdef bad_subscript
bad_subscript:
		move.l	a0,-(a7)
		lea	msg_bad_subscript,a0
		bra	command_error_return

.xdef no_close_brace
no_close_brace:
		lea	msg_no_close_brace,a0
		bra	enputs1

.xdef too_long_line
too_long_line:
		move.l	a0,-(a7)
		lea	msg_too_long_line,a0
		bra	command_error_return

.xdef too_long_word
too_long_word:
		lea	msg_too_long_word,a0
		bra	command_error

.xdef too_many_words
too_many_words:
		move.l	a0,-(a7)
		lea	msg_too_many_words,a0
		bra	command_error_return

.xdef undefined
undefined:
		bsr	pre_perror
		lea	msg_undefined,a0
		bra	enputs1

.xdef ambiguous
ambiguous:
		bsr	strip_quotes
		bsr	pre_perror
		lea	msg_ambiguous,a0
		bra	enputs1

.xdef no_match
no_match:
		lea	msg_no_match,a0
		bra	enputs1

.xdef cannot_because_no_memory
cannot_because_no_memory:
		move.l	a0,-(a7)
		lea	msg_bacause_of_no_memory,a0
		bsr	eputs
		movea.l	(a7)+,a0
		bra	enputs1

.xdef perror_command_name
perror_command_name:
		tst.l	command_name
		beq	perror_command_name_done

		move.l	a0,-(a7)
		movea.l	command_name,a0
		bsr	pre_perror
		movea.l	(a7)+,a0
perror_command_name_done:
		rts

.xdef pre_perror
pre_perror:
		move.l	a0,-(a7)
		bsr	ecputs
		lea	msg_colon_blank,a0
		bsr	eputs
		movea.l	(a7)+,a0
		rts

.xdef perror
perror:
		movem.l	d0/a0,-(a7)
		bsr	pre_perror
		not.l	d0		* -1 -> 0, -2 -> 1, ...
		cmp.l	#25,d0
		bls	perror_2

		cmp.l	#256,d0
		blo	perror_1

		sub.l	#256,d0
		cmp.l	#4,d0
		bhi	perror_1

		lea	perror_table_2,a0
		bra	perror_3

perror_1:
		moveq	#25,d0
perror_2:
		lea	perror_table,a0
perror_3:
		lsl.l	#2,d0
		movea.l	(a0,d0),a0
		bsr	enputs
		movem.l	(a7)+,d0/a0
		tst.l	d0
		rts

.data

.even
perror_table:
	dc.l	msg_err			*   0 ( -1)
	dc.l	msg_nofile		*   1 ( -2)
	dc.l	msg_nodir		*   2 ( -3)
	dc.l	msg_toomany_openfiles	*   3 ( -4)
	dc.l	msg_is_dir_or_vol	*   4 ( -5)
	dc.l	msg_err			*   5 ( -6)
	dc.l	msg_err			*   6 ( -7)
	dc.l	msg_err			*   7 ( -8)
	dc.l	msg_err			*   8 ( -9)
	dc.l	msg_err			*   9 (-10)
	dc.l	msg_err			*  10 (-11)
	dc.l	msg_err			*  11 (-12)
	dc.l	msg_bad_filename	*  12 (-13)
	dc.l	msg_err			*  13 (-14)
	dc.l	msg_bad_drive		*  14 (-15)
	dc.l	msg_current		*  15 (-16)
	dc.l	msg_err			*  16 (-17)
	dc.l	msg_err			*  17 (-18)
	dc.l	msg_write_disabled	*  18 (-19)
	dc.l	msg_directory_exists	*  19 (-20)
	dc.l	msg_not_empty		*  20 (-21)
	dc.l	msg_err			*  21 (-22)
	dc.l	msg_disk_full		*  22 (-23)
	dc.l	msg_directory_full	*  23 (-24)
	dc.l	msg_err			*  24 (-25)
	dc.l	msg_err			*  25 (-26)
.even
perror_table_2:
	dc.l	msg_bad_drivename	* 256 (-257)
	dc.l	msg_no_drive		* 257 (-258)
	dc.l	msg_no_media_in_drive	* 258 (-259)
	dc.l	msg_media_set_miss	* 259 (-260)
	dc.l	msg_drive_not_ready	* 260 (-261)

.xdef msg_too_long
.xdef msg_colon_blank
.xdef msg_syntax_error
.xdef msg_too_large_number
.xdef msg_bad_subscript
.xdef msg_subscript_out_of_range

msg_usage:			dc.b	'使用法'
msg_colon_blank:		dc.b	': ',0
msg_bad_subscript:		dc.b	'添字の'
msg_syntax_error:		dc.b	'構文が誤りです',0
msg_badly_formed_number:	dc.b	'数値の記法が正しくありません',0
msg_too_large_number:		dc.b	'数値が大き過ぎます',0
msg_subscript_out_of_range:	dc.b	'添字が範囲外です',0
msg_undefined:			dc.b	'この変数は定義されていません',0
msg_too_long_line:		dc.b	'行が'
msg_too_long:			dc.b	'長過ぎます',0
msg_too_long_word:		dc.b	'単語が長過ぎます',0
msg_too_many_words:		dc.b	'単語数が多過ぎます',0
msg_bad_arg:			dc.b	'引数が正しくありません',0
msg_too_many_args:		dc.b	'引数が多過ぎます',0
msg_too_few_args:		dc.b	'引数が足りません',0
msg_no_close_brace:		dc.b	'} がありません',0
msg_no_match:			dc.b	'マッチするファイルやディレクトリーがありません',0
msg_bacause_of_no_memory:	dc.b	'メモリーが足りないため',0
msg_err:			dc.b	'error',0
msg_nofile:			dc.b	'このようなファイルはありません',0
msg_nodir:			dc.b	'このようなディレクトリーはありません',0
msg_toomany_openfiles:		dc.b	'ファイルをこれ以上オープンできません',0
msg_is_dir_or_vol:		dc.b	'ディレクトリーかボリューム・ラベルです',0
msg_bad_filename:		dc.b	'無効なファイル名です',0
msg_bad_drive:			dc.b	'ドライブの指定が無効です',0
msg_current:			dc.b	'カレント・ディレクトリーですので削除できません',0
msg_write_disabled:		dc.b	'書き込みが許可されていません',0
msg_directory_exists:		dc.b	'既に存在しています',0
msg_not_empty:			dc.b	'空でないので削除できません',0
msg_directory_full:		dc.b	'ディレクトリーが満杯のため作成できません',0
msg_disk_full:			dc.b	'ディスクが満杯のため作成できません',0
msg_bad_drivename:		dc.b	'無効なドライブ名です',0
msg_no_drive:			dc.b	'ドライブがありません',0
msg_no_media_in_drive:		dc.b	'ドライブにメディアがセットされていません',0
msg_media_set_miss:		dc.b	'ドライブにメディアが正しくセットされていません',0
msg_drive_not_ready:		dc.b	'ドライブの準備ができていません',0

.end
