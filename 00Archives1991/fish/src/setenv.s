* setenv.s
* Itagaki Fumihiko 16-Jul-90  Create.

.xref strlen
.xref stpcpy
.xref strmove
.xref memmove_dec
.xref for1str
.xref str_blk_copy
.xref getenv
.xref command_error

.xref envwork

.text

*****************************************************************
* setenv - set environment
*
* CALL
*      A0       name
*      A1       value
*
* RETURN
*      D0.L	�����Ȃ� 0  �e�ʂ�����Ȃ���� 1
*      CCR      TST.L D0
*****************************************************************
.xdef setenv

setenv:
		movem.l	d1/a0-a4,-(a7)
		movea.l	envwork,a3
		movea.l	a1,a2
		movea.l	a0,a1
		movea.l	a3,a0
		bsr	getenv			* name ��T��
		bne	change_value		* ������� change_value

		movea.l	a1,a0			* name��
		bsr	strlen			*   ����
		move.l	d0,d1			*   �{
		movea.l	a2,a0			*   value��
		bsr	strlen			*   ����
		add.l	d0,d1			*   �{
		addq.l	#2,d1			*   �Q�i'='��NUL�̕��j��D1�ɃZ�b�g

		lea	4(a3),a0		* ����
		bsr	find_env_bottom		*   �����{�P��A0��
		move.l	a3,d0			* ����
		add.l	(a3),d0			*   ��{�P��D0��
		sub.l	a0,d0			* �󂫗e�ʂ�
		bcs	setenv_full		* �Ȃ�

		cmp.l	d1,d0			* D1�o�C�g��
		blo	setenv_full		* �Ȃ�

		subq.l	#1,a0			* A0�͊��̖���
		bsr	stpcpy			* ���O���R�s�[
		move.b	#'=',(a0)+		* = �łȂ���
		movea.l	a2,a1			* �l��
		bsr	strmove			* �R�s�[
		clr.b	(a0)			* ���̏I���̃}�[�N���Z�b�g
		bra	setenv_success		* �I���

change_value:
		move.l	a0,d2			* d2 := �����̊��̖��O�̃|�C���^
		movea.l	d0,a4			* A4 := ���݂̒l���w���|�C���^
		movea.l	a2,a0			* �V���Ȓl��
		bsr	strlen			* ����
		move.l	d0,d1			* ����
		movea.l	a4,a0			* ���݂̒l��
		bsr	strlen			* ������
		sub.l	d0,d1			* ����
		beq	setenv_just_change_value	* �����������Ȃ�Ώ���������̂�
		blo	setenv_change_and_trunc		* �]�T������Ώ�����������ɐ؂�l�߂�

		* D1�o�C�g����Ȃ�
		movea.l	d2,a0			* ���̌��݂�
		bsr	find_env_bottom		*   �����{�P��A0�ɃZ�b�g
		move.l	a3,d0			* ����
		add.l	(a3),d0			*   ��{�P
		sub.l	a0,d0			* �󂫗e�ʂ�
		bcs	setenv_full		* �Ȃ�

		cmp.l	d1,d0			* D1�o�C�g��
		blo	setenv_full		* �Ȃ�

		movea.l	a0,a1			* ���̌��݂̖����{�P��A1�i�\�[�X�j��
		movea.l	d2,a0			* ���݂̊��̗v�f��
		bsr	for1str			*   ���̗v�f�̃A�h���X��A0��
		move.l	a1,d0			* ���̌��݂̖����{�P����
		sub.l	a0,d0			* A0�������΁A�]������T�C�Y
		movea.l	a1,a0			* �\�[�X
		adda.l	d1,a0			*   �{D1���f�X�e�B�l�[�V����
		bsr	memmove_dec		* ����u���b�N�]��
setenv_just_change_value:
		bsr	setenv_change_value	* �l������������
		bra	setenv_success		* �I���

setenv_change_and_trunc:
		movea.l	d2,a0			* ���݂̊��̗v�f��
		bsr	for1str			*   ���̗v�f�̃A�h���X��
		move.l	a0,-(a7)		*   �Z�[�u
		bsr	setenv_change_value	* �l������������
		move.l	(a7)+,a1		* ���̗v�f�̃A�h���X
		bsr	str_blk_copy		* �؂�l�߂�
setenv_success:
		moveq	#0,d0
setenv_return:
		movem.l	(a7)+,d1/a0-a4
		rts

setenv_full:
		lea	msg_full(pc),a0
		bsr	command_error
		bra	setenv_return
****************************************************************
setenv_change_value:
		movea.l	a4,a0
		movea.l	a2,a1
		bra	strmove
****************************************************************
find_env_bottom:
find_env_bottom_loop:
		tst.b	(a0)+
		beq	find_env_bottom_done

		bsr	for1str
		bra	find_env_bottom_loop

find_env_bottom_done:
		rts
****************************************************************
.data

msg_full:	dc.b	'���̗e�ʂ�����܂���',0

.end
