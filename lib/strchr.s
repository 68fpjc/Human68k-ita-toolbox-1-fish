* strchr.s
* Itagaki Fumihiko 24-Aug-91  Create.

.text

****************************************************************
* strchr - �����񂩂�ANK������T���o��
*
* CALL
*      A0     ������̐擪�A�h���X
*      D0.B   ���������iANK�j
*
* RETURN
*      A0     �ŏ��Ɍ��������������ʒu���w��
*             ����������������Ȃ������ꍇ�ɂ́C�Ō��NUL�������w��
*
*      CCR    TST.B (A0)
*
* NOTE
*      �V�t�gJIS�R�[�h�͍l�����Ă��Ȃ�
*****************************************************************
.xdef strchr

strchr:
		move.l	d1,-(a7)
strchr_loop:
		move.b	(a0)+,d1
		beq	strchr_done

		cmp.b	d0,d1
		bne	strchr_loop
strchr_done:
		move.l	(a7)+,d1
		tst.b	-(a0)
		rts

.end
