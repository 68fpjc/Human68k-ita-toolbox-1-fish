* cmdsenv.s
* This contains built-in command 'setenv'.
*
* Itagaki Fumihiko 16-Jul-90  Create.

.text

****************************************************************
*  Name
*       setenv - set environment
*
*  Synopsis
*       setenv
*       setenv name
*       setenv name word
****************************************************************
.xdef	cmd_setenv

cmd_setenv:
		tst.w	d0			* �������Ȃ����
		beq	printenv		* ���ϐ���\������

		lea	str_nul,a1
		cmp.w	#2,d0
		blo	cmd_setenv_set
		bhi	too_many_args		* �G���[

		movea.l	a0,a2			* A2 : �ϐ���
		bsr	for1str
		movea.l	a0,a1			* A1 : �l
		move.l	a1,-(a7)
		lea	tmpargs,a0		* tmpargs ��
		moveq	#1,d0
		bsr	expand_wordlist		* �l��u���W�J����
		movea.l	(a7)+,a1
		bmi	return_1

		cmp.w	#1,d0
		bhi	setenv_ambiguous

		movea.l	a0,a1			* A1 : �u���W�J���ꂽ�l
		movea.l	a2,a0			* A0 : �ϐ���
cmd_setenv_set:
		bsr	strip_quotes
		bra	setenv

printenv:
		movea.l	envwork,a0
		addq.l	#4,a0
printenv_loop:
		tst.b	(a0)			* �ŏ��̕�����NUL�Ȃ��
		beq	return_0		* �I���

		bsr	nputs
		bsr	for1str
		bra	printenv_loop

setenv_ambiguous:
		movea.l	a1,a0
		bra	ambiguous

return_0:
		moveq	#0,d0
		rts

return_1:
		moveq	#1,d0
		rts

.end
