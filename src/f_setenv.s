* f_setenv.s
* Itagaki Fumihiko 18-Aug-91  Create.

.include ../src/var.h

.xref strlen
.xref xmalloc
.xref allocvar
.xref entervar
.xref fish_getenv
.xref insufficient_memory

.xref env_top

.text

*****************************************************************
* fish_setenv - FISH �̊��ϐ����Z�b�g����
*
* CALL
*      A0     �ϐ����̐擪�A�h���X
*      A1     �l�̕�����̐擪�A�h���X
*
* RETURN
*      D0.L   �Z�b�g�����ϐ��̐擪�A�h���X�D
*             ������������������Ȃ����߃Z�b�g�ł��Ȃ������Ȃ�� 0�D
*      CCR    TST.L D0
*
* NOTE
*      �Z�b�g����l�̌���т̃A�h���X���ϐ��̌��݂̒l��
*      �ꕔ�ʂł���Ƃ��ɂ��A���������삷��B
*****************************************************************
.xdef fish_setenv

fish_setenv:
		movem.l	d1-d2/a0-a4,-(a7)
		moveq	#1,d1				*  D1.W : �P�ꐔ = 1
		movea.l	a1,a2				*  A2 : �l
		movea.l	a0,a1				*  A1 : �ϐ���
		bsr	allocvar			*  A3 : �V�ϐ��̃A�h���X
		beq	fish_setenv_no_space

		movea.l	a1,a0
		bsr	fish_getenv
		lea	env_top(a5),a4
		bsr	entervar
return:
		movem.l	(a7)+,d1-d2/a0-a4
		rts


fish_setenv_no_space:
		bsr	insufficient_memory
		moveq	#0,d0
		bra	return

.end
