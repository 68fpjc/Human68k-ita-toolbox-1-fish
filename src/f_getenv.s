* f_getenv.s
* Itagaki Fumihiko 18-Aug-91  Create.

.include ../src/var.h

.xref strcmp
.xref strfor1

.xref env_top

.text

****************************************************************
* fish_getenv - FISH �̊��ϐ����X�g���疼�O�ŕϐ���T��
*
* CALL
*      A0     ��������ϐ����̐擪�A�h���X
*
* RETURN
*      A0     �ϐ������������I�ɑO���Ɉʒu����Ō�̕ϐ��̃A�h���X
*             ���邢�� 0
*
*      D0.L   ���������ϐ��̃A�h���X�D
*             ������Ȃ���� 0�D
*
*      CCR    TST.L D0
*****************************************************************
.xdef fish_getenv

fish_getenv:
		movem.l	a1-a3,-(a7)
		movea.l	env_top(a5),a2
		suba.l	a3,a3
loop:
		cmpa.l	#0,a2
		beq	done

		lea	var_body(a2),a1
		bsr	strcmp
		beq	done

		movea.l	a2,a3
		movea.l	var_next(a3),a2
		bra	loop

done:
		movea.l	a3,a0
		move.l	a2,d0
		movem.l	(a7)+,a1-a3
		rts

.end
