* fgetpwnam.s
* Itagaki Fumihiko 17-Aug-91  Create.

.include limits.h
.include pwd.h

.xref memcmp
.xref fgetpwent

.text

*****************************************************************
* fgetpwnam - �p�X���[�h�E�t�@�C�����烆�[�U���ŃG���g������������
*
* CALL
*      D0.W   �p�X���[�h�E�t�@�C���̃t�@�C���E�n���h��
*             �i�s�̐擪���w���Ă��邱�Ɓj
*
*      A0     �i�[�o�b�t�@�iPW_SIZE�o�C�g�j�̐擪�A�h���X
*
*      A1     �������閼�O�̐擪�A�h���X
*
*      D1.L   �������閼�O�̒���
*
* RETURN
*      D0.L   ���������Ȃ�� 0
*      CCR    TST.L D0
*****************************************************************
.xdef fgetpwnam

fgetpwnam:
		movem.l	d2/a0-a2,-(a7)
		move.w	d0,d2				*  D2.W : �t�@�C���E�n���h��
		moveq	#-1,d0
		cmp.l	#PW_NAME_SIZE,d1
		bhi	fgetpwnam_done

		movea.l	a0,a2				*  A2 : �i�[�\����
fgetpwnam_loop:
		move.w	d2,d0
		movea.l	a2,a0
		jsr	fgetpwent
		bne	fgetpwnam_done

		lea	PW_NAME(a2),a0
		tst.b	(a0,d1.l)
		bne	fgetpwnam_loop

		move.l	d1,d0
		jsr	memcmp
		bne	fgetpwnam_loop
fgetpwnam_done:
		movem.l	(a7)+,d2/a0-a2
		rts

.end
