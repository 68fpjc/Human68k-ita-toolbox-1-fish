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
.xref set_var
.xref find_var
.xref print_var
.xref pre_perror
.xref no_space_for
.xref word_alias
.xref word_unalias

.xref tmpargs

.xref alias

.text

****************************************************************
.xdef print_alias_value

print_alias_value:
		movem.l	d0/a0-a1,-(a7)
		addq.l	#2,a0
		move.w	(a0)+,d0
		bsr	strfor1
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
		movea.l	alias(a5),a0
		bsr	set_var
		bne	no_space
		bra	return_0
****************
print_one_alias:
		movea.l	a0,a1
		movea.l	alias(a5),a0
		bsr	find_var
		beq	return_0

		bsr	print_alias_value
		bsr	put_newline
		bra	return_0
****************
print_all_alias:
		movea.l	alias(a5),a0
		bsr	print_var
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
****************
no_space:
		lea	msg_alias_space,a0
		bra	no_space_for
****************************************************************
.data

msg_alias_space:	dc.b	'�ʖ��u���b�N',0
msg_danger:		dc.b	'���̖��O��ʖ��Ƃ���̂͊댯�ł�',0

.end
