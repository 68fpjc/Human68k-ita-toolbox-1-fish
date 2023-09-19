* ifthen.s
* This contains if/else if/else/endif statement.
*
* Itagaki Fumihiko 13-Aug-90  Create.

.include ../src/fish.h

.xref strcmp
.xref strfor1
.xref skip_paren
.xref copy_wordlist
.xref expression
.xref subst_var_wordlist
.xref do_line
.xref too_deep_statement_nest
.xref expression_syntax_error
.xref syntax_error
.xref command_error
.xref word_if

.xref if_status
.xref if_level
.xref tmpargs

.text

****************************************************************
* test_statement_paren - �X�e�[�g�����g�� ( ) ���`�F�b�N����
*
* CALL
*      A0       �P�����
*      D0.W     �P�ꐔ
*
* RETURN
*      A0       ( �̎��̒P����w��
*      A1       ) �̎��̒P����w��
*      D0.W     ( ) �̒��̒P�ꐔ
*      D1.W     A1�ȍ~�̒P�ꐔ
*      CCR      �G���[�Ȃ�� NZ
****************************************************************
.xdef test_statement_paren

test_statement_paren:
		cmp.w	#3,d0
		blo	test_statement_paren_error

		cmpi.b	#'(',(a0)
		bne	test_statement_paren_error

		tst.b	1(a0)
		bne	test_statement_paren_error

		move.w	d0,d1
		movea.l	a0,a1
		bsr	skip_paren
		beq	test_statement_paren_error

		bsr	strfor1
		exg	a0,a1				*  A1 : ) �̎��̒P��
		subq.w	#1,d0
		exg	d0,d1				*  D1 : A1 �ȍ~�̒P�ꐔ

		sub.w	d1,d0
		subq.w	#2,d0				*  D0 : ()�̒��̒P�ꐔ
		beq	test_statement_paren_error

		bsr	strfor1				*  A0 : ( �̎��̒P��
		cmp.w	d0,d0
		rts

test_statement_paren_error:
		moveq	#1,d0
		rts
****************************************************************
*   1.  if (expression) statement
*
*   2.  if (expression) then
*           statement(s)
*       [ else if (expression) then
*           statement(s) ]
*               .
*               .
*               .
*       [ else
*           statement(s) ]
*       endif
****************************************************************
.xdef state_if

state_if:
		movea.l	a1,a3
		bsr	test_statement_paren		*  �߂�l�FA0/D0/A1/D1
		bne	syntax_error

		move.w	d1,d2				*  D2.W : ( ) �ɑ����P�ꐔ
		beq	empty_if

		movea.l	a1,a2				*  A2 : ( ) �ɑ����P����w��
		movea.l	a0,a1				*  A1 : ( �̎��̒P����w��

		tst.b	if_status(a5)			*  ����
		bne	state_if_1			*  FALSE��Ԃł���

		lea	tmpargs,a0
		bsr	subst_var_wordlist
		bmi	syntax_error

		move.w	d0,d7
		bsr	expression
		bne	return				*  D0.L == 1

		tst.w	d7
		bne	expression_syntax_error
state_if_1:
		move.w	d2,d7				*  D7.W : ( ) �ɑ����P�ꐔ
		movea.l	a2,a0				*  A0 : ( ) �ɑ����P����w��
		lea	word_then,a1
		bsr	strcmp
		beq	state_if_then
		*
		*  then �͖���
		*
		tst.b	if_status(a5)			*  ����
		bne	state_if_recurse		*  FALSE��Ԃł���

		tst.l	d1				*  ���̒l��
		bne	state_if_recurse		*    �^
		bra	success				*    �U

state_if_then:
		*
		*  then ������
		*
		subq.w	#1,d7				*  then �̌��
		bne	syntax_error			*  �܂��P�ꂪ����Ȃ�G���[

		tst.b	if_status(a5)			*  ����
		bne	state_if_inc_level		*  FALSE��Ԃł���

		clr.w	if_level(a5)
		tst.l	d1
		seq	if_status(a5)			*  if_status := ����0 ? -1 : 0
state_if_recurse:
		move.w	d7,d0
		movea.l	a3,a1
recurse:
		tst.w	d0
		beq	success

		exg	a0,a1
		bsr	copy_wordlist
		addq.l	#4,a7			**  �߂�A�h���X���̂Ă� **
		bra	do_line			**!! �ċA !!**


state_if_inc_level:
		lea	word_if,a0
		cmpi.w	#MAXIFLEVEL,if_level(a5)
		beq	too_deep_statement_nest

		addq.w	#1,if_level(a5)
success:
		moveq	#0,d0
return:
		rts


empty_if:
		lea	msg_empty_if,a0
		bra	command_error
****************************************************************
.xdef state_else

state_else:
		tst.w	if_level(a5)
		bne	success

		tst.b	if_status(a5)
		bpl	set_if_status_1

		clr.b	if_status(a5)
		bra	recurse

set_if_status_1:
		move.b	#1,if_status(a5)
		bra	success
****************************************************************
.xdef state_endif

state_endif:
		tst.w	if_level(a5)
		beq	clear_if_status

		subq.w	#1,if_level(a5)
		bra	success

clear_if_status:
		clr.b	if_status(a5)
		bra	success
****************************************************************
.data

word_then:		dc.b	'then',0
msg_empty_if:		dc.b	'then �܂��̓R�}���h������܂���',0

.end
