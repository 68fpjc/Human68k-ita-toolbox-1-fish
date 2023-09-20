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
.xref current_source


.text

****************************************************************
.xdef usage

put_command_name:
		movea.l	command_name(a5),a0
		bsr	ecputs
put_space:
		moveq	#' ',d0
		bra	eputc

usage:
		move.l	a0,-(a7)
		lea	msg_usage,a0
		bsr	eputs
		tst.l	command_name(a5)
		beq	usage_1

		bsr	put_command_name
usage_1:
		movea.l	(a7)+,a0
		bra	enputs1
****************************************************************
.xdef command_error
.xdef enputs1

command_error:
		bsr	perror_command_name
enputs1:
		bsr	enputs
		moveq	#1,d0
		rts
****************************************************************
.xdef too_deep_statement_nest

too_deep_statement_nest:
		bsr	eputs
		lea	msg_too_deep_statement_nest,a0
		bra	enputs1
****************************************************************
.xdef syntax_error

syntax_error:
		move.l	a0,-(a7)
		lea	msg_syntax_error,a0
command_error_return:
		bsr	command_error
		movea.l	(a7)+,a0
		rts
****************************************************************
.xdef expression_syntax_error

expression_syntax_error:
		move.l	a0,-(a7)
		lea	msg_bad_expression_syntax,a0
		bra	command_error_return
****************************************************************
.xdef subscript_out_of_range

subscript_out_of_range:
		move.l	a0,-(a7)
		lea	msg_subscript_out_of_range,a0
		bra	command_error_return
****************************************************************
.xdef bad_subscript

bad_subscript:
		move.l	a0,-(a7)
		lea	msg_bad_subscript,a0
		bra	command_error_return
****************************************************************
.xdef bad_arg

bad_arg:
		move.l	a0,-(a7)
		lea	msg_bad_arg,a0
		bra	command_error_return
****************************************************************
.xdef too_long_line

too_long_line:
		lea	msg_too_long_line,a0
		bra	command_error
****************************************************************
.xdef too_long_word

too_long_word:
		lea	msg_too_long_word,a0
		bra	command_error
****************************************************************
.xdef too_many_words

too_many_words:
		lea	msg_too_many_words,a0
		bra	command_error
****************************************************************
.xdef too_many_args

too_many_args:
		lea	msg_too_many_args,a0
		bra	command_error
****************************************************************
.xdef too_few_args

too_few_args:
		lea	msg_too_few_args,a0
		bra	command_error
****************************************************************
.xdef badly_formed_number

badly_formed_number:
		lea	msg_badly_formed_number,a0
		bra	command_error
****************************************************************
.xdef too_large_number

too_large_number:
		lea	msg_too_large_number,a0
		bra	command_error
****************************************************************
.xdef dstack_not_deep

dstack_not_deep:
		lea	msg_dstack_not_deep,a0
		bra	command_error
****************************************************************
.xdef no_close_brace

no_close_brace:
		lea	msg_no_close_brace,a0
		bra	enputs1
****************************************************************
.xdef undefined

undefined:
		bsr	pre_perror
		lea	msg_undefined,a0
		bra	enputs1
****************************************************************
.xdef ambiguous

ambiguous:
		bsr	strip_quotes
		bsr	pre_perror
		lea	msg_ambiguous,a0
		bra	enputs1
****************************************************************
.xdef no_match

no_match:
		lea	msg_no_match,a0
		bra	enputs1
****************************************************************
.xdef insufficient_memory

insufficient_memory:
		lea	msg_insufficient_memory,a0
		bra	enputs1
****************************************************************
.xdef cannot_because_no_memory

because_no_memory:
		lea	msg_bacause_of_no_memory,a0
		bra	eputs

cannot_because_no_memory:
		move.l	a0,-(a7)
		bsr	because_no_memory
		movea.l	(a7)+,a0
		bra	enputs1
****************************************************************
.xdef cannot_run_command_because_no_memory

cannot_run_command_because_no_memory:
		tst.l	command_name(a5)
		beq	insufficient_memory

		bsr	because_no_memory
		bsr	put_space
		bsr	put_command_name
		lea	msg_cannot_run,a0
		bra	enputs1
****************************************************************
.xdef perror_command_name

perror_command_name:
		tst.l	command_name(a5)
		beq	perror_command_name_done

		move.l	a0,-(a7)
		movea.l	command_name(a5),a0
		bsr	pre_perror
		movea.l	(a7)+,a0
perror_command_name_done:
		rts
****************************************************************
.xdef pre_perror

pre_perror:
		move.l	a0,-(a7)
		bsr	ecputs
		lea	msg_colon_blank,a0
		bsr	eputs
		movea.l	(a7)+,a0
		rts
****************************************************************
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
		cmp.l	#5,d0
		bhi	perror_1

		lea	perror_table_2,a0
		bra	perror_3

perror_1:
		moveq	#25,d0
perror_2:
		lea	perror_table,a0
perror_3:
		lsl.l	#2,d0
		movea.l	(a0,d0.l),a0
		bsr	enputs
		movem.l	(a7)+,d0/a0
		tst.l	d0
		rts
****************************************************************
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
	dc.l	msg_write_protected	* 261 (-262)

.xdef msg_usage
.xdef msg_too_long
.xdef msg_colon_blank
.xdef msg_syntax_error
.xdef msg_badly_formed_number
.xdef msg_too_large_number
.xdef msg_bad_subscript
.xdef msg_subscript_out_of_range
.xdef msg_too_few_args
.xdef msg_too_many_args
.xdef msg_too_long_word

msg_usage:			dc.b	'�g�p�@'
msg_colon_blank:		dc.b	': ',0
msg_bad_subscript:		dc.b	'�Y����'
msg_syntax_error:		dc.b	'�\�������ł�',0
msg_bad_expression_syntax:	dc.b	'��������Ă��܂�',0
msg_badly_formed_number:	dc.b	'���l�̋L�@������������܂���',0
msg_too_large_number:		dc.b	'���l���傫�߂��܂�',0
msg_subscript_out_of_range:	dc.b	'�Y�����͈͊O�ł�',0
msg_undefined:			dc.b	'���̕ϐ��͒�`����Ă��܂���',0
msg_too_long_line:		dc.b	'�s��'
msg_too_long:			dc.b	'���߂��܂�',0
msg_too_long_word:		dc.b	'�P�ꂪ���߂��܂�',0
msg_too_many_words:		dc.b	'�P�ꐔ�����߂��܂�',0
msg_too_deep_statement_nest:	dc.b	' �̓���q���[�߂��܂�',0
msg_bad_arg:			dc.b	'����������������܂���',0
msg_too_many_args:		dc.b	'���������߂��܂�',0
msg_too_few_args:		dc.b	'����������܂���',0
msg_no_close_brace:		dc.b	'} ������܂���',0
msg_no_match:			dc.b	'�}�b�`����t�@�C����f�B���N�g��������܂���',0
msg_dstack_not_deep:		dc.b	'�f�B���N�g���E�X�^�b�N�͂���Ȃɐ[������܂���',0
msg_bacause_of_no_memory:	dc.b	'�������s���̂���',0
msg_insufficient_memory:	dc.b	'������������܂���',0
msg_cannot_run:			dc.b	'�����s�ł��܂���',0
msg_err:			dc.b	'error',0
msg_nofile:			dc.b	'���̂悤�ȃt�@�C���͂���܂���',0
msg_nodir:			dc.b	'���̂悤�ȃf�B���N�g���͂���܂���',0
msg_toomany_openfiles:		dc.b	'�t�@�C��������ȏ�I�[�v���ł��܂���',0
msg_is_dir_or_vol:		dc.b	'�f�B���N�g�����{�����[���E���x���ł�',0
msg_bad_filename:		dc.b	'�t�@�C�����������ł�',0
msg_bad_drive:			dc.b	'�h���C�u�̎w�肪�����ł�',0
msg_current:			dc.b	'�J�����g�E�f�B���N�g���ł��̂ō폜�ł��܂���',0
msg_write_disabled:		dc.b	'�������݂�������Ă��܂���',0
msg_directory_exists:		dc.b	'���łɑ��݂��Ă��܂�',0
msg_not_empty:			dc.b	'��łȂ��̂ō폜�ł��܂���',0
msg_directory_full:		dc.b	'�f�B���N�g�������t�̂��ߍ쐬�ł��܂���',0
msg_disk_full:			dc.b	'�f�B�X�N�����t�̂��ߍ쐬�ł��܂���',0
msg_bad_drivename:		dc.b	'�h���C�u���������ł�',0
msg_no_drive:			dc.b	'�h���C�u������܂���',0
msg_no_media_in_drive:		dc.b	'�h���C�u�Ƀ��f�B�A���Z�b�g����Ă��܂���',0
msg_media_set_miss:		dc.b	'�h���C�u�Ƀ��f�B�A���������Z�b�g����Ă��܂���',0
msg_drive_not_ready:		dc.b	'�h���C�u�̏������ł��Ă��܂���',0
msg_write_protected:		dc.b	'���f�B�A���v���e�N�g����Ă��܂�',0
****************************************************************
.end
