* b_which.s
* This contains built-in command 'which'.
*
* Itagaki Fumihiko 16-Feb-91  Create.

.include chrcode.h
.include limits.h

.xref strfor1
.xref strlen
.xref strcpy
.xref puts
.xref nputs
.xref cputs
.xref put_space
.xref put_newline
.xref search_command
.xref headtail
.xref find_var
.xref find_shellvar
.xref find_function
.xref list_1_function
.xref print_alias_value
.xref print_var_value
.xref usage
.xref too_few_args
.xref word_path
.xref msg_too_long

.xref alias
.xref function_root

.text

****************************************************************
print_name_is:
		bsr	cputs
		move.l	a0,-(a7)
		lea	msg_is,a0
		bsr	puts
		movea.l	(a7)+,a0
		rts
****************************************************************
*  Name
*       which - �R�}���h�̎��̂�\������
*
*  Synopsis
*       which [ -o | -O ] command ...
****************************************************************
.xdef cmd_which

command_name = -(((MAXPATH+1)+1)>>1<<1)

cmd_which:
		move.w	d0,d1
		beq	which_too_few_args

		cmpi.b	#'-',(a0)
		bne	no_option

		move.b	1(a0),d0
		beq	no_option

		tst.b	2(a0)
		bne	no_option

		moveq	#%111,d2			*  no { function, alias, builtin }
		cmp.b	#'O',d0
		beq	start0

		moveq	#%110,d2			*  no { function, alias }
		cmp.b	#'o',d0
		beq	start0
no_option:
		moveq	#0,d2
		bra	start

start0:
		bsr	strfor1
		subq.w	#1,d1
start:
		subq.w	#1,d1
		bcs	which_too_few_args

		link	a6,#command_name
loop:
		movea.l	a0,a1
	*
	*  �֐�
	*
		btst	#2,d2
		bne	not_function

		lea	function_root(a5),a2
		bsr	find_function
		beq	not_function

		move.l	d0,-(a7)
		bsr	print_name_is
		lea	msg_is_function,a0
		bsr	nputs
		movea.l	(a7)+,a0
		bsr	list_1_function
		bra	continue

not_function:
	*
	*  �ʖ�
	*
		btst	#1,d2
		bne	not_alias

		movea.l	alias(a5),a0
		bsr	find_var
		beq	not_alias

		exg	a0,a1
		bsr	print_name_is
		bsr	put_space
		exg	a0,a1
		bsr	print_alias_value
		lea	msg_is_aliased,a0
		bra	puts_and_continue

not_alias:
	*
	*  path ����
	*
		movea.l	a1,a0
		bsr	strlen
		cmp.w	#MAXPATH,d0
		bhi	too_long_command_name

		lea	command_name(a6),a0
		bsr	strcpy
		btst	#0,d2
		sne	d0
		bsr	search_command
		cmp.l	#-1,d0
		beq	not_found

		btst	#31,d0
		beq	puts_and_continue

		bsr	print_name_is
		lea	msg_is_builtin,a0
		bra	puts_and_continue

not_found:
		bsr	print_name_is
		move.l	a1,-(a7)
		bsr	headtail
		cmpa.l	a0,a1
		movea.l	(a7)+,a1
		lea	msg_not_found,a0
		bne	puts_and_continue

		bsr	put_space
		lea	word_path,a0
		bsr	find_shellvar
		beq	put_pathlist

		addq.l	#2,a0
		move.w	(a0)+,d0			* D0.W : $path �̗v�f��
		bsr	strfor1				* A0 : $path[1] �̃A�h���X
put_pathlist:
		bsr	print_var_value
		lea	msg_not_found_in,a0
		bra	puts_and_continue

too_long_command_name:
		bsr	print_name_is
		lea	msg_too_long,a0
puts_and_continue:
		bsr	cputs
		bsr	put_newline
continue:
		movea.l	a1,a0
		bsr	strfor1
		dbra	d1,loop

		moveq	#0,d0
		unlk	a6
		rts

which_too_few_args:
		bsr	too_few_args
		lea	msg_usage,a0
		bra	usage

.data

msg_usage:		dc.b	'[ -o | -O ] <�R�}���h��> ...',CR,LF
			dc.b	'    -o   �ʖ������O����',CR,LF
			dc.b	'    -O   �ʖ��Ƒg�ݍ��݃R�}���h�����O����',0
msg_is:			dc.b	' ��',0
msg_is_function:	dc.b	'�֐��ł�',0
msg_is_aliased:		dc.b	' �̕ʖ��ł�',0
msg_is_builtin:		dc.b	' FISH �̑g�ݍ��݃R�}���h�ł�',0
msg_not_found_in:	dc.b	' �̒���'
msg_not_found:		dc.b	'����܂���',0

.end
