* skipsl.s
* Itagaki Fumihiko 27-Mar-93  Create.

.text

****************************************************************
* skip_slashes - / �� \ ���X�L�b�v����
*
* CALL
*      A0     ������
*
* RETURN
*      A0     �ŏ��� / �ł� \ �ł��Ȃ��ʒu
*      D0.B   �ŏ��� / �ł� \ �ł��Ȃ�����
*      CCR    TST.B D0
*****************************************************************
.xdef skip_slashes

skip_slashes:
		move.b	(a0)+,d0
		cmp.b	#'/',d0
		beq	skip_slashes

		cmp.b	#'\',d0
		beq	skip_slashes

		tst.b	-(a0)
		rts

.end
