* strfor1.s
* Itagaki Fumihiko 18-Aug-91  Create.

****************************************************************
* strfor1 - �������1�X�L�b�v����
*
* CALL
*      A0     ������̐擪�A�h���X
*
* RETURN
*      A0     1�X�L�b�v�����A�h���X
*****************************************************************
.xdef strfor1

strfor1:
		tst.b	(a0)+
		bne	strfor1

		rts

.end
