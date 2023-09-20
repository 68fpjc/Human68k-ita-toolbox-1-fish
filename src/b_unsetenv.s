* b_unsetenv.s
* This contains built-in command 'unsetenv'.
*
* Itagaki Fumihiko 16-Jul-90  Create.

.include ../src/var.h

.xref strfor1
.xref free
.xref strip_quotes
.xref fish_getenv
.xref too_few_args

.xref env_top

.text

****************************************************************
*  Name
*       unsetenv - unset environment
*
*  Synopsis
*       unsetenv name ...
****************************************************************
.xdef cmd_unsetenv

cmd_unsetenv:
		subq.w	#1,d0
		blo	too_few_args
unset_loop:
		movea.l	a0,a1
		jsr	strfor1
		exg	a0,a1				*  A0:���݂̒P��CA1:���̒P��
		bsr	strip_quotes
		bsr	fish_unsetenv
		movea.l	a1,a0
		dbra	d0,unset_loop

		moveq	#0,d0
		rts
*****************************************************************
* fish_unsetenv - FISH �̊��ϐ����폜����
*
* CALL
*      A0     �폜����ϐ������w��
*
* RETURN
*      none
*****************************************************************
fish_unsetenv:
		movem.l	d0/a0-a1,-(a7)
		bsr	fish_getenv		* ���ϐ� name ��T��
		beq	unsetenv_done		* ������Ή������Ȃ�

		movea.l	d0,a1
		movea.l	var_next(a1),a1
		cmpa.l	#0,a0
		beq	fish_unsetenv_top

		move.l	a1,var_next(a0)
		bra	fish_unsetenv_free

fish_unsetenv_top:
		move.l	a1,env_top(a5)
fish_unsetenv_free:
		bsr	free
unsetenv_done:
		movem.l	(a7)+,d0/a0-a1
		rts

.end
