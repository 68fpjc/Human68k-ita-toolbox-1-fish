* remove.s
* Itagaki Fumihiko 23-Feb-91  Create.

.include doscall.h

.text
*****************************************************************
* remove - �t�@�C�����폜����
*
* CALL
*      A0     �폜����t�@�C���̃p�X�����w��
*
* RETRUN
*      D0.L   �G���[�E�R�[�h
*      CCR    TST.L D0
*
* NOTE
*      �h���C�u�̌����͍s��Ȃ�
*****************************************************************
.xdef remove

remove:
		move.l	a0,-(a7)
		DOS	_DELETE
		addq.l	#4,a7
		tst.l	d0
		rts

.end
