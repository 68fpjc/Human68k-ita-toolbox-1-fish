* f_setenv.s
* Itagaki Fumihiko 18-Aug-91  Create.

.xref setenv
.xref no_space_for

.xref envwork

.text

*****************************************************************
* setenv - FISH �̊��ϐ����Z�b�g����
*
* CALL
*      A0       �ϐ����̐擪�A�h���X
*      A1       �l�̕�����̐擪�A�h���X
*
* RETURN
*      D0.L	�����Ȃ� 0 ��Ԃ��D�e�ʂ�����Ȃ���� �G���[�E
*               ���b�Z�[�W��\������ 1 ��Ԃ��D
*      CCR      TST.L D0
*****************************************************************
.xdef fish_setenv

fish_setenv:
		movem.l	a0/a3,-(a7)
		movea.l	envwork(a5),a3
		bsr	setenv
		beq	fish_setenv_return

		lea	msg_environment,a0
		bsr	no_space_for
fish_setenv_return:
		movem.l	(a7)+,a0/a3
		rts
****************************************************************
.data

msg_environment:	dc.b	'��',0

.end
