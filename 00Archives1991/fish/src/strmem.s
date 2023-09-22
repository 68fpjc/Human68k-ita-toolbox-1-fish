* strmem.s
* Itagaki Fumihiko 16-Jul-90  Create.

.text

****************************************************************
* strmem - �����񂩂炠��p�^�[����T���o��
*
* CALL
*      A0     ��������w���|�C���^
*      A1     �����p�^�[���̐擪�A�h���X
*      D0.L   �����p�^�[���̃o�C�g��
*      D1.B   0 �ȊO�Ȃ�΁AANK�p�����̑啶���Ə���������ʂ��Ȃ�
*
* RETURN
*      D0.L   ���������A�h���X�D������Ȃ����0
*      CCR    TST.L D0
*
* DESCRIPTION
*      �����񒆂̃V�t�g�i�h�r�������l�����Ă���
*****************************************************************
.xdef strmem

strmem:
		movem.l	d2-d3/a0/a2,-(a7)
		move.l	d0,d2		* D2.L : �ƍ��p�^�[���̒���
		beq	strmem_found	* 0 �Ȃ�Ε�����̐擪��Ԃ�

		bsr	strlen
		move.l	d0,d3		* ������̒�������
		sub.l	d2,d3		* �ƍ��p�^�[���̒���������
		bcs	strmem_fail	* �ƍ��p�^�[����蕶���񂪒Z���Ȃ猩����킯�͂Ȃ�
strmem_loop:
		move.l	d2,d0
		bsr	memxcmp
		beq	strmem_found

		subq.l	#1,d3
		bcs	strmem_fail

		move.b	(a0)+,d0
		bsr	issjis
		bne	strmem_loop

		subq.l	#1,d3
		bcs	strmem_fail

		addq.l	#1,a0
		bra	strmem_loop

strmem_fail:
		suba.l	a0,a0
strmem_found:
		move.l	a0,d0
strmem_return:
		movem.l	(a7)+,d2-d3/a0/a2
		rts

.end
