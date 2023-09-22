* passwd.s
* Itagaki Fumihiko 23-Feb-91  Create.
*
* This contains password file controll routines.

.xref fopen
.xref fgetc
.xref fseek_nextline
.xref fmemcmp

.text

*****************************************************************
* open_passwd - �p�X���[�h�E�t�@�C�����I�[�v������
*
* CALL
*      none
*
* RETURN
*      D0.L   ���Ȃ�Ύ��s�ŁA�c�n�r�̃G���[�E�R�[�h
*             �����Ȃ��Ή��ʃ��[�h���I�[�v�������p�X���[�h�E�t�@�C���̃t�@�C���E�n���h��
*****************************************************************
.xdef open_passwd

open_passwd:
		move.l	a0,-(a7)
		lea	pathname_passwd,a0
		moveq	#0,d0
		bsr	fopen
		movea.l	(a7)+,a0
		rts
*****************************************************************
* findpwent - �p�X���[�h�E�t�@�C�����烆�[�U�[�̃G���g����T��
*
* CALL
*      D0.W   �p�X���[�h�E�t�@�C���̃t�@�C���E�n���h��
*      A0     �������[�U�[��
*      D1.L   A0 �̒����i�o�C�g���j
*
* RETURN
*      D0.L   ���F�G���[�E�R�[�h�C��F��������
*      CCR    TST.L D0
*****************************************************************
.xdef findpwent

findpwent:
		move.w	d2,-(a7)
		move.w	d0,d2
findpwent_loop:
		move.w	d2,d0
		bsr	fmemcmp
		bne	findpwent_next

		move.w	d2,d0
		bsr	fgetc
		bmi	findpwent_return

		cmp.b	#';',d0
		beq	findpwent_found
findpwent_next:
		move.w	d2,d0
		bsr	fseek_nextline
		bpl	findpwent_loop
findpwent_return:
		move.w	(a7)+,d2
		tst.l	d0
		rts

findpwent_found:
		moveq	#0,d0
		bra	findpwent_return
*****************************************************************
.data

pathname_passwd:	dc.b	'A:/etc/passwd',0

.end
