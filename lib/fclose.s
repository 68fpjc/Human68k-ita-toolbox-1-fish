* fclose.s
* Itagaki Fumihiko 18-Aug-91  Create.

.include doscall.h

*****************************************************************
* fclose - �t�@�C�����N���[�Y����
*
* CALL
*      D0.W   �t�@�C���E�n���h��
*
* RETURN
*      D0.L   OS �̃G���[�E�R�[�h
*      CCR    TST.L D0
*****************************************************************
.xdef fclose

fclose:
		move.w	d0,-(a7)
		DOS	_CLOSE
		addq.l	#2,a7
		tst.l	d0
		rts

.end
