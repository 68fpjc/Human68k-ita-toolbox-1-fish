* b_alias.s
* This contains built-in command 'alias'.
*
* Itagaki Fumihiko 05-Sep-90  Create.

.xref strfor1
.xref cputs
.xref enputs1
.xref put_newline
.xref echo
.xref strip_quotes
.xref expand_wordlist
.xref strcmp
.xref setvar
.xref findvar
.xref printvar
.xref get_var_value
.xref pre_perror
.xref insufficient_memory
.xref word_alias
.xref word_unalias

.xref tmpargs

.xref alias_top

.text

****************************************************************
.xdef print_alias_value

print_alias_value:
		movem.l	d0/a0-a1,-(a7)
		bsr	get_var_value
		lea	cputs(pc),a1
		bsr	echo
		movem.l	(a7)+,d0/a0-a1
		rts
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
		move.w	d0,d1			* D1.W : �����̐�
		beq	print_all_alias		* �����������Ȃ�ʖ��̃��X�g��\��

		movea.l	a0,a2
		bsr	strfor1
		exg	a0,a2			* A0 : name   A2 : wordlist
		bsr	strip_quotes
		subq.w	#1,d1
		beq	print_one_alias		* ������ 1�Ȃ炻�̕ʖ��̓��e��\��

		lea	word_alias,a1
		bsr	strcmp
		beq	danger

		lea	word_unalias,a1
		bsr	strcmp
		beq	danger

		movea.l	a2,a1			* A1 : wordlist
		movea.l	a0,a2			* A2 : name
		lea	tmpargs,a0
		move.w	d1,d0
		bsr	expand_wordlist
		bmi	return

		movea.l	a2,a1			* A1 : name
		movea.l	a0,a2			* A2 : tmpargs
		lea	alias_top(a5),a0
		bsr	setvar
		beq	insufficient_memory
		bra	return_0
****************
print_one_alias:
		movea.l	a0,a1
		movea.l	alias_top(a5),a0
		bsr	findvar
		beq	return_0

		bsr	print_alias_value
		bsr	put_newline
		bra	return_0
****************
print_all_alias:
		movea.l	alias_top(a5),a0
		bsr	printvar
return_0:
		moveq	#0,d0
return:
		rts
****************
danger:
		movea.l	a1,a0
		bsr	pre_perror
		lea	msg_danger,a0
		bra	enputs1
****************************************************************
.data

msg_danger:		dc.b	'���̖��O��ʖ��Ƃ���̂͊댯�ł�',0

.end
