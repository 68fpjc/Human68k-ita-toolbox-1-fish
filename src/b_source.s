* b_source.s
* This contains built-in command source.
*
* Itagaki Fumihiko 16-Aug-90  Create.

.include ../src/fish.h

.xref OpenLoadRun_source
.xref tfopen
.xref close_tmpfd
.xref getline
.xref getline_file
.xref make_wordlist
.xref enter_history
.xref perror1
.xref usage
.xref too_few_args
.xref too_many_args
.xref bad_arg
.xref verbose

.xref tmpargs
.xref line
.xref tmpfd

.xref exitflag

.text

****************************************************************
*  Name
*       source - run shell script on current shell
*
*  Synopsis
*       source [-h] file
****************************************************************
.xdef cmd_source
.xdef read_source

cmd_source:
		moveq	#0,d1			* -h : Do not execute. Just enter to history.
decode_opt_loop1:
		tst.w	d0
		beq	decode_opt_done

		cmpi.b	#'-',(a0)
		bne	decode_opt_done

		tst.b	1(a0)
		beq	decode_opt_done

		subq.w	#1,d0
		addq.l	#1,a0
		move.b	(a0)+,d7
decode_opt_loop2:
		cmp.b	#'h',d7
		bne	cmd_source_bad_arg

		moveq	#1,d1
decode_opt_nextch:
		move.b	(a0)+,d7
		bne	decode_opt_loop2
		bra	decode_opt_loop1

decode_opt_done:
		cmp.w	#1,d0
		blo	cmd_source_too_few_args
		bhi	cmd_source_too_many_args

		tst.b	d1
		bne	just_read_source

		bsr	OpenLoadRun_source		***!! 再帰 !!***
		clr.b	exitflag(a5)
		bra	cmd_source_success

just_read_source:
		cmpi.b	#'-',(a0)
		bne	just_read_source_file

		tst.b	1(a0)
		bne	just_read_source_file

		moveq	#0,d0				*  stdin
		bra	read_source

just_read_source_file:
		moveq	#0,d0
		bsr	tfopen
		bmi	perror1
read_source:
		move.l	d0,tmpfd(a5)
		move.w	d0,d7
read_source_loop:
		lea	line(a5),a0
		move.w	#MAXLINELEN,d1
		moveq	#1,d2
		suba.l	a1,a1
		lea	getline_file(pc),a2
		bsr	getline
		bmi	read_source_done
		bne	read_source_continue

		lea	line(a5),a0
		lea	tmpargs,a1
		move.w	#MAXWORDLISTSIZE,d1
		bsr	make_wordlist
		bmi	read_source_continue

		lea	tmpargs,a0
		bsr	verbose
		bsr	enter_history
read_source_continue:
		bra	read_source_loop

read_source_done:
		bsr	close_tmpfd
cmd_source_success:
		moveq	#0,d0
		rts


cmd_source_too_few_args:
		bsr	too_few_args
		bra	cmd_source_usage

cmd_source_too_many_args:
		bsr	too_many_args
		bra	cmd_source_usage

cmd_source_bad_arg:
		bsr	bad_arg
cmd_source_usage:
		lea	msg_usage,a0
		bra	usage
****************************************************************
.data

msg_usage:	dc.b	'[ -h ] { - | <ファイル名> }',0

.end
