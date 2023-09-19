* fgetpwnam.s
* Itagaki Fumihiko 17-Aug-91  Create.

.include limits.h
.include pwd.h

.xref strcmp
.xref fgetpwent

.text

*****************************************************************
* fgetpwnam - �p�X���[�h�E�t�@�C�����烆�[�U���ŃG���g������������
*
* CALL
*      D0.W   �p�X���[�h�E�t�@�C���̃t�@�C���E�n���h���i�s�̐擪���w���Ă��邱�Ɓj
*      A0     pwd�\���̂̐擪�A�h���X
*      A1     �s�ǂݍ��݃o�b�t�@�̐擪�A�h���X
*      D1.L   �s�ǂݍ��݃o�b�t�@�̗e��
*      A2     �������閼�O�̐擪�A�h���X(NUL�I�[�͕s�v)
*
* RETURN
*      D0.L   ���������Ȃ�� 0
*      CCR    TST.L D0
*****************************************************************
.xdef fgetpwnam

fgetpwnam:
		movem.l	d2/a0/a3,-(a7)
		move.w	d0,d2				*  D2.W : �t�@�C���E�n���h��
		movea.l	a0,a3				*  A3 : pwd�\����
fgetpwnam_loop:
		move.w	d2,d0
		movea.l	a3,a0
		jsr	fgetpwent
		bne	fgetpwnam_done

		movea.l	PW_NAME(a3),a0
		exg	a1,a2
		jsr	strcmp
		exg	a1,a2
		bne	fgetpwnam_loop
fgetpwnam_done:
		movem.l	(a7)+,d2/a0/a3
		rts

.end
