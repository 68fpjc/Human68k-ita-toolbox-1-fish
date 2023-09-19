* setenv.s
* Itagaki Fumihiko 16-Jul-90  Create.

.xref strlen
.xref stpcpy
.xref strmove
.xref memmovd
.xref strfor1
.xref strazcpy
.xref strazbot
.xref getenv

.text

*****************************************************************
* setenv - ���ϐ����Z�b�g����
*
* CALL
*      A0       �ϐ����̐擪�A�h���X
*      A1       �l�̕�����̐擪�A�h���X
*      A3       ���u���b�N�̐擪�A�h���X
*
* RETURN
*      D0.L	�����Ȃ� 0  �e�ʂ�����Ȃ���� 1
*      CCR      TST.L D0
*****************************************************************
.xdef setenv

setenv:
		movem.l	d1-d2/a0-a2/a4,-(a7)
		cmpa.l	#-1,a3
		beq	nospace

		movea.l	a1,a2			*  A2 : value
		movea.l	a0,a1			*  A1 : name
		jsr	getenv			*  name ��T��
		bne	setenv_change_value	*  ������� change_value

		movea.l	a1,a0			*  name��
		jsr	strlen			*    ����
		move.l	d0,d1			*    �{
		movea.l	a2,a0			*    value��
		jsr	strlen			*    ����
		add.l	d0,d1			*    �{
		addq.l	#2,d1			*    �Q�i'='��NUL�̕��j��D1�ɃZ�b�g

		lea	4(a3),a0		*  ����
		bsr	find_env_bottom		*    �����{�P��A0��
		move.l	a3,d0			*  ����
		add.l	(a3),d0			*    ��{�P��D0��
		sub.l	a0,d0			*  �󂫗e�ʂ�
		bcs	nospace			*  �Ȃ�

		cmp.l	d1,d0			*  D1�o�C�g��
		blo	nospace			*  �Ȃ�

		subq.l	#1,a0			*  A0�͊��̖���
		jsr	stpcpy			*  ���O���R�s�[
		move.b	#'=',(a0)+		*  = �łȂ���
		movea.l	a2,a1			*  �l��
		jsr	strmove			*  �R�s�[
		clr.b	(a0)			*  ���̏I���̃}�[�N���Z�b�g
		bra	success			*  �I���

setenv_change_value:
		move.l	a0,d2			*  D2 := �����̊��̖��O�̃|�C���^
		movea.l	d0,a4			*  A4 := ���݂̒l���w���|�C���^
		movea.l	a2,a0			*  �V���Ȓl��
		jsr	strlen			*  ����
		move.l	d0,d1			*  ����
		movea.l	a4,a0			*  ���݂̒l��
		jsr	strlen			*  ������
		sub.l	d0,d1			*  ����
		beq	just_change_value	*  �����������Ȃ�Ώ���������̂�
		blo	setenv_change_and_trunc	*  �]�T������Ώ�����������ɐ؂�l�߂�

		* D1�o�C�g����Ȃ�
		movea.l	d2,a0			*  ���̌��݂�
		bsr	find_env_bottom		*    �����{�P��A0�ɃZ�b�g
		move.l	a3,d0			*  ����
		add.l	(a3),d0			*    ��{�P
		sub.l	a0,d0			*  �󂫗e�ʂ�
		bcs	nospace			*  �Ȃ�

		cmp.l	d1,d0			*  D1�o�C�g��
		blo	nospace			*  �Ȃ�

		movea.l	a0,a1			*  ���̌��݂̖����{�P��A1�i�\�[�X�j��
		movea.l	d2,a0			*  ���݂̊��̗v�f��
		jsr	strfor1			*    ���̗v�f�̃A�h���X��A0��
		move.l	a1,d0			*  ���̌��݂̖����{�P����
		sub.l	a0,d0			*  A0�������΁A�]������T�C�Y
		movea.l	a1,a0			*  �\�[�X
		adda.l	d1,a0			*    �{D1���f�X�e�B�l�[�V����
		jsr	memmovd			*  ����u���b�N�]��
just_change_value:
		bsr	change_value		*  �l������������
		bra	success			*  �I���

setenv_change_and_trunc:
		movea.l	d2,a0			*  ���݂̊��̗v�f��
		jsr	strfor1			*    ���̗v�f�̃A�h���X��
		move.l	a0,-(a7)		*    �Z�[�u
		bsr	change_value		*  �l������������
		move.l	(a7)+,a1		*  ���̗v�f�̃A�h���X
		jsr	strazcpy		*  �؂�l�߂�
success:
		moveq	#0,d0
return:
		movem.l	(a7)+,d1-d2/a0-a2/a4
		rts

nospace:
		moveq	#1,d0
		bra	return
****************************************************************
change_value:
		movea.l	a4,a0
		movea.l	a2,a1
		jmp	strmove
****************************************************************
find_env_bottom:
		jsr	strazbot
		addq.l	#1,a0
		rts
****************************************************************

.end
