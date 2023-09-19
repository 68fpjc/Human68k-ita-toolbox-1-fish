* f_getenv.s
* Itagaki Fumihiko 18-Aug-91  Create.

.include ../src/var.h

.xref strcmp
.xref strfor1

.xref envtop

.text

****************************************************************
* fish_getenv - FISH �̊��ϐ����X�g���疼�O�ŕϐ���T��
*
* CALL
*      A0     ��������ϐ����̐擪�A�h���X
*
* RETURN
*      D0.L   ���������ϐ��̃w�b�_�̐擪�A�h���X�D
*             ������Ȃ���� 0�D
*      CCR    TST.L D0
*****************************************************************
.xdef fish_getenv

fish_getenv:
		movem.l	a1-a2,-(a7)
		movea.l	envtop(a5),a2
loop:
		cmpa.l	#0,a2
		beq	done

		lea	var_body(a2),a1
		bsr	strcmp
		beq	done

		movea.l	var_next(a2),a2
		bra	loop

done:
		move.l	a2,d0
		movem.l	(a7)+,a1-a2
		rts

.end
