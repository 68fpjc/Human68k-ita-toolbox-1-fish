* fgetc.s
* Itagaki Fumihiko 23-Feb-91  Create.

.include doscall.h

*****************************************************************
* fgetc - �t�@�C������1�����ǂݎ��
*
* CALL
*      D0.W   �t�@�C���E�n���h��
*
* RETURN
*      D0.L   ��: �G���[�E�R�[�h
*             ��: ���ʃo�C�g�͓ǂݎ��������
*
*      CCR    TST.L D0
*****************************************************************
.xdef fgetc

fgetc:
		move.w	d0,-(a7)
		DOS	_FGETC
		addq.l	#2,a7
		tst.l	d0
		rts

.end
