* tfopen.s
* Itagaki Fumihiko 23-Feb-91  Create.

.include doscall.h

.xref drvchkp

.text

*****************************************************************
* tfopen - �t�@�C�����I�[�v������
*
* CALL
*      A0     �I�[�v������t�@�C���̃p�X��
*      D0.W   �I�[�v���E���[�h
*
* RETURN
*      D0.L   ��: �G���[�E�R�[�h
*             ��: ���ʃ��[�h���A�I�[�v�������t�@�C���̃t�@�C���E�n���h��������
*
*      CCR    TST.L D0
*
* NOTE
*      �I�[�v������O�Ƀh���C�u���ǂݍ��݉\���ǂ�����������
*      �i���C�g�v���e�N�g�͌������Ȃ��j
*****************************************************************
.xdef tfopen

tfopen:
		move.w	d0,-(a7)
		move.l	a0,-(a7)
		bclr	#31,d0
		and.b	#15,d0
		beq	tfopen_1

		bset	#31,d0
tfopen_1:
		jsr	drvchkp
		bmi	return

		DOS	_OPEN
return:
		addq.l	#6,a7
		tst.l	d0
		rts

.end
