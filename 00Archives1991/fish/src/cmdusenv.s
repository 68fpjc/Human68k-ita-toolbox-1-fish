* cmdusenv.s
* This contains built-in command 'unsetenv'.
*
* Itagaki Fumihiko 16-Jul-90  Create.

.text

****************************************************************
*  Name
*       unsetenv - unset environment
*
*  Synopsis
*       unsetenv name ...
****************************************************************
.xdef	cmd_unsetenv

cmd_unsetenv:
		move.w	d0,d1
		subq.w	#1,d1
		blo	too_few_args

		movea.l	envwork,a1
unset_loop:
		movea.l	a0,a2
		bsr	for1str
		exg	a0,a2
		bsr	strip_quotes
		exg	a0,a1
		bsr	unsetenv
		exg	a0,a1
		movea.l	a2,a0
		dbra	d1,unset_loop

		moveq	#0,d0
		rts
*****************************************************************
* unsetenv - ���ϐ����폜����
*
* CALL
*      A0     ���ϐ��̈�̐擪�A�h���X
*      A1     �폜����ϐ����p�^�[�����w��
*
* RETURN
*      none
*****************************************************************
unsetenv:
		movem.l	d0/a0-a1,-(a7)
		bsr	getenv			* ���ϐ� name ��T��
		beq	unsetenv_done		* ������Ή������Ȃ�

		movea.l	a0,a1
		bsr	for1str
		exg	a0,a1
		bsr	str_blk_copy		* ���݂̊��̗v�f���폜����
unsetenv_done:
		movem.l	(a7)+,d0/a0-a1
		rts

.end
