* b_alias.s
* This contains built-in command 'alias'.
*
* Itagaki Fumihiko 05-Sep-90  Create.

.xref strfor1
.xref enputs1
.xref put_newline
.xref strip_quotes
.xref expand_wordlist
.xref strcmp
.xref findvar
.xref setvar
.xref printvar
.xref print_var_value
.xref pre_perror
.xref insufficient_memory
.xref word_alias
.xref word_unalias

.xref alias_top
.xref completion_top
.xref tmpargs

.text

****************************************************************
cmd_alias_sub_1:
		move.w	d0,d1
		beq	printvar			*  D0.L==0, ZF==1

		movea.l	a0,a2
		bsr	strfor1
		exg	a0,a2				*  A0 : name   A2 : list
		bsr	strip_quotes
		subq.w	#1,d1
		bne	return				*  ZF==0
print_one:
		movea.l	a0,a1
		movea.l	(a3),a0
		bsr	findvar
		beq	return_0

		bsr	print_var_value
		bsr	put_newline
return_0:
		moveq	#0,d0				*  D0.L==0, ZF==1
return:
		rts
****************************************************************
cmd_alias_sub_2:
		movea.l	a2,a1				*  A1 : list
		movea.l	a0,a2				*  A2 : name
		movea.l	tmpargs(a5),a0			*  A0 : for store expanded list
		move.w	d1,d0
		bsr	expand_wordlist
		bmi	return

		movea.l	a2,a1				*  A1 : name
		movea.l	a0,a2				*  A2 : expanded list
		movea.l	a3,a0				*  A0 : varptr
		bsr	setvar
		beq	insufficient_memory
		bra	return_0
****************************************************************
*  Name
*       alias - �ʖ��̕\���ƒ�`
*
*  Synopsis
*       alias
*            ��`����Ă��邷�ׂĂ̕ʖ��Ƃ����̒�`��\������
*
*       alias pattern
*            pattern �Ɉ�v���� �ʖ��̓��e��\������
*
*       alias name wordlist
*            wordlist �̕ʖ��Ƃ��� name ���`����
****************************************************************
.xdef cmd_alias

cmd_alias:
		lea	alias_top(a5),a3
		bsr	cmd_alias_sub_1
		beq	return				*  D0.L == 0

		lea	word_alias,a1
		bsr	strcmp
		beq	danger

		lea	word_unalias,a1
		bsr	strcmp
		beq	danger

		bra	cmd_alias_sub_2
****************
danger:
		movea.l	a1,a0
		bsr	pre_perror
		lea	msg_danger,a0
		bra	enputs1
****************************************************************
*  Name
*       complete - �⊮���̕\���ƒ�`
*
*  Synopsis
*       complete
*            ��`����Ă��邷�ׂĂ̕⊮���Ƃ����̒�`��\������
*
*       complete pattern
*            pattern �Ɉ�v����⊮���̓��e��\������
*
*       complete name expression
*            �⊮�� name �� expression �Ƃ��Ē�`����
****************************************************************
.xdef cmd_complete

cmd_complete:
		lea	completion_top(a5),a3
		bsr	cmd_alias_sub_1
		beq	return				*  D0.L == 0

		bra	cmd_alias_sub_2
****************************************************************
.data

msg_danger:		dc.b	'���̖��O��ʖ��Ƃ���̂͊댯�ł�',0

.end
