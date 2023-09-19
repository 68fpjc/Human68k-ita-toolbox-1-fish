* findvar.s
* Itagaki Fumihiko 24-Sep-90  Create.

.xref strcmp

.xref shellvar

.text

****************************************************************
* find_var - �ϐ��i�V�F���ϐ��C�ʖ��j��T��
*
* CALL
*      A0     �ϐ��̈�̐擪�A�h���X
*      A1     �T���ϐ������w��
*
* RETURN
*      A0     ���������ꍇ�F���������ϐ��̐擪�A�h���X
*             ������Ȃ������ꍇ�F�ϐ������������I�Ɍ���ł���ŏ��̕ϐ��̐擪�A�h���X
*                                   ���邢�͏I�[�̃A�h���X
*
*      D0.L   ������� A0 �Ɠ����l
*             ������Ȃ���� 0
*
*      CCR    TST.L D0
****************************************************************
.xdef find_var

find_var:
		addq.l	#8,a0
loop:
		tst.w	(a0)			* ���̕ϐ�����߂�o�C�g��
		beq	not_found		* 0�Ȃ炨���܂�

		addq.l	#4,a0
		bsr	strcmp
		beq	match
		bhi	over

		subq.l	#4,a0
		adda.w	(a0),a0			* ���̕ϐ��̃A�h���X���Z�b�g�@�i�������j
		bra	loop			* �J��Ԃ�

match:
		subq.l	#4,a0
		move.l	a0,d0
		rts

over:
		subq.l	#4,a0
not_found:
		moveq	#0,d0
		rts
****************************************************************
* find_shellvar - �V�F���ϐ���T��
*
* CALL
*      A0     �T���ϐ������w��
*
* RETURN
*      A0     ���������ꍇ�F���������ϐ��̐擪�A�h���X
*             ������Ȃ������ꍇ�F�ϐ������������I�Ɍ���ł���ŏ��̕ϐ��̐擪�A�h���X
*                                   ���邢�͏I�[�̃A�h���X
*
*      D0.L   ������� A0 �Ɠ����l
*             ������Ȃ���� 0
*
*      CCR    TST.L D0
****************************************************************
.xdef find_shellvar

find_shellvar:
		move.l	a1,-(a7)
		movea.l	a0,a1
		movea.l	shellvar(a5),a0
		bsr	find_var
		movea.l	(a7)+,a1
		rts
****************************************************************
.end
