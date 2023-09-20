* b_time.s
* This contains built-in command 'time', 'noabort' and 'cmd'.
*
* Itagaki Fumihiko 22-Dec-90  Create.

.include chrcode.h

.xref strfor1
.xref memmovi
.xref isopt
.xref copy_wordlist
.xref report_time
.xref alloc_new_argbuf
.xref free_current_argbuf
.xref DoSimpleCommand_recurse_2
.xref cannot_run_command_because_no_memory
.xref too_few_args
.xref bad_arg
.xref usage

.xref shell_timer_high
.xref shell_timer_low
.xref argc
.xref simple_args

.text

****************************************************************
*  Name
*       time - report timer
*
*  Synopsis
*       time time [command]
****************************************************************
.xdef cmd_time

cmd_time:
		move.l	shell_timer_high(a5),d3
		move.l	shell_timer_low(a5),d2
		tst.w	d0
		bne	cmd_time_recurse

		jmp	report_time			*  0 �ŋA��

cmd_time_recurse:
		moveq	#1,d1
recurse2:
		movea.l	a0,a1
recurse3:
		jsr	DoSimpleCommand_recurse_2	*** �ċA ***
		moveq	#0,d0
		rts
****************************************************************
*  Name
*       noabort
*
*  Synopsis
*       noabort command
****************************************************************
.xdef cmd_noabort

cmd_noabort:
		tst.w	d0
		beq	cmd_noabort_too_few_args

		moveq	#2,d1
		bra	recurse2

cmd_noabort_too_few_args:
		bsr	too_few_args
		lea	msg_noabort_usage,a0
		bra	usage
****************************************************************
*  Name
*       cmd
*
*  Synopsis
*       cmd [-a|-f|-i[<str>]] [-dert] [--] command
****************************************************************
.xdef cmd_cmd

cmd_cmd:
		move.b	#$80,d1
		moveq	#0,d3
cmd_cmd_parse_option_loop1:
		bsr	isopt
		bne	cmd_cmd_parse_option_done
cmd_cmd_parse_option_loop2:
		move.b	(a0)+,d2
		beq	cmd_cmd_parse_option_loop1

		moveq	#5,d4
		cmp.b	#'d',d2
		beq	cmd_cmd_set_option

		moveq	#6,d4
		cmp.b	#'e',d2
		beq	cmd_cmd_set_option

		moveq	#2,d4
		cmp.b	#'r',d2
		beq	cmd_cmd_set_option

		moveq	#0,d4
		cmp.b	#'t',d2
		beq	cmd_cmd_set_option

		cmp.b	#'a',d2
		beq	cmd_cmd_option_a

		cmp.b	#'f',d2
		beq	cmd_cmd_option_f

		cmp.b	#'i',d2
		beq	cmd_cmd_option_i

		bsr	bad_arg
		bra	cmd_cmd_usage

cmd_cmd_option_a:	*  abort
		bset	#3,d1
		bset	#4,d1
		moveq	#0,d3
		bra	cmd_cmd_parse_option_loop2

cmd_cmd_option_f:	*  force
		bset	#3,d1
		bclr	#4,d1
		moveq	#0,d3
		bra	cmd_cmd_parse_option_loop2

cmd_cmd_option_i:	*  indirect
		bclr	#3,d1
		bset	#4,d1
		move.l	a0,d3
		bsr	strfor1
		bra	cmd_cmd_parse_option_loop1

cmd_cmd_set_option:
		bset	d4,d1
		bra	cmd_cmd_parse_option_loop2

cmd_cmd_parse_option_done:
		tst.w	d0
		beq	cmd_cmd_too_few_args

		tst.l	d3
		beq	recurse2

		move.w	d0,d7
		move.b	d1,d6
		movea.l	a0,a3

		movea.l	d3,a0
		moveq	#1,d0
		bsr	alloc_new_argbuf
		beq	cannot_run_command_because_no_memory

		move.l	a0,-(a7)
		move.l	d1,d0
		jsr	memmovi
		movea.l	(a7)+,a2

		move.w	d7,d0
		move.b	d6,d1
		movea.l	a3,a1
		bsr	recurse3
		jmp	free_current_argbuf

cmd_cmd_too_few_args:
		bsr	too_few_args
cmd_cmd_usage:
		lea	msg_cmd_usage,a0
		bra	usage

.data

msg_noabort_usage:
	dc.b	'<�R�}���h��> [<�������X�g>]',0

msg_cmd_usage:
	dc.b	'[-a|-f|-i[<������>]] [-rdet] [--] <�R�}���h��> [<�������X�g>]',CR,LF
	dc.b	'     -a             unset hugearg �̏ꍇ�Ɠ���',CR,LF
	dc.b	'     -f             set hugearg=force �̏ꍇ�Ɠ���',CR,LF
	dc.b	'     -i[<������>]   set hugearg=(indirect <������>) �̏ꍇ�Ɠ���',CR,LF
	dc.b	'     -r             �������X�g��HUPAIR�G���R�[�h���Ȃ�',CR,LF
	dc.b	'     -d             ��ƃf�B���N�g���̕ύX���󂯓����',CR,LF
	dc.b	'     -e             ���ϐ��̕ύX���󂯓����',CR,LF
	dc.b	'     -t[<N>]        �R�}���h����������Ԃ�񍐂���',CR,LF,0

.end
