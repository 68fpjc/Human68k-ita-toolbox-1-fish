* scanch2.s
* Itagaki Fumihiko 23-Sep-90  Create.

.xref issjis

.text

****************************************************************
* scanchar2 - ���������當����1�������o��
*
* CALL
*      A0     �A�h���X
*
* RETRUN
*      D0.L   ���o��������
*             ��ʃ��[�h�͏��0
*             �����ANK�ł͏�ʃo�C�g��0
*             ��ʃo�C�g����0�Ȃ�΃V�t�gJIS�R�[�h�ł���
*
*      A0     ���̃A�h���X
*
*      CCR    TST.B D0
****************************************************************
.xdef scanchar2

scanchar2:
		moveq	#0,d0
		move.b	(a0)+,d0
		bsr	issjis
		bne	done

		lsl.w	#8,d0
		move.b	(a0)+,d0
done:
		tst.b	d0
		rts

.end
