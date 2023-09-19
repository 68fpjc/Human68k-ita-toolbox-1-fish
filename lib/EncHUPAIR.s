*****************************************************************
*  EncHUPAIR.s
*
*  Copyright(C)1991 by Itagaki Fumihiko
*
*  �{���W���[���́C��L�̔Ō��\�����܂ޑS�̂���؉��ς��Ȃ���
*  �Ƃ������ɁC�g�p�C�g�ݍ��݁C�����C���J�C�Ĕz�z���邱�Ƃ��C
*  ���ꂪ�����Ȃ�ړI�ł����Ă��F�߂܂��B����������҂͖@�̒�
*  �߂�ق��͖{���W���[���ɂ��Ĉ�ؕۏ؂��܂���B�{���W���[
*  ���͌���̂܂ܖ��ۏ؂ɂĒ񋟂���C�{���W���[���ɂ����郊�X
*  �N�͂��ׂĎg�p�҂����畉�����̂Ƃ��܂��B����҂́C�{���W���[
*  �����g�p���C���邢�͎g�p�ł��Ȃ��������Ƃɂ�钼�ړI���邢
*  �͊ԐړI�ȑ��Q�╴���ɂ��Ĉ�؊֒m�����C�{���W���[���Ɍ�
*  �ׁC�s�s���C��肪�����Ă�������C������`���𕉂��܂���B
*****************************************************************
*
*  ���̃��W���[���Ɋ܂܂�Ă��� 2�̃T�u���[�`��
*  EncodeHUPAIR �� SetHUPAIR �́CHUPAIR �ɏ]���Ĉ������т��R
*  �}���h���C����ɃG���R�[�h������̂ł��D
*
*  �ȉ��ɗ�������܂��D
*
*		* A0 �ɃR�}���h���C���̐擪�A�h���X���CD0.W ��
*		* �R�}���h���C���̗e�ʁi�o�C�g���j���Z�b�g����D
*
*		lea	cmdline,a0
*		move.w	#CMDLINE_SIZE,d0
*
*		* A1 �ɃG���R�[�h�������������т̐擪�A�h���X���C
*		* D1.W �ɂ��̒P�ꐔ���Z�b�g���āCEncodeHUPAIR
*		���Ăяo���D
*
*		lea	wordlist_1,a1
*		move.w	nwords_1,d1
*		bsr	EncodeHUPAIR
*		bmi	too_long	*  �����Ԃ�����G���[
*
*		* ���̑���͘A�����ČJ��Ԃ��s�����Ƃ��ł���D
*		* �܂�C�G���R�[�h�������������т͕����̗̈�
*		* �ɕ�������Ă��Ă��ǂ��D
*
*		lea	wordlist_2,a1
*		move.w	nwords_2,d1
*		bsr	EncodeHUPAIR
*		bmi	too_long
*			.
*			.
*			.
*
*		* EncodeHUPAIR �̌J��Ԃ����I������C�Ō��
*		* SetHUPAIR ���Ăяo���ăR�}���h���C����������
*		* ����D
*
*		lea	cmdline,a1
*		move.w	#CMDLINE_SIZE,d1
*		bsr	SetHUPAIR
*		bmi	too_long	*  �����Ԃ�����G���[
*
*		* �����ŁCD0.W �̓R�}���h���C���̕�����̒����C
*		* D1.W �͎��ۂɃR�}���h���C���� 1�o�C�g�ڂɃZ�b
*		* �g�����l�ł���D�R�}���h���C���̕�����255
*		* �o�C�g�𒴂������Ƃ����m����ɂ́C
*
*		cmp.w	#255,d0
*		bhi	huge_arg
*
*		* ���邢��
*
*		cmp.w	d1,d0
*		bne	huge_arg
*
*		* �Ƃ���Ηǂ��D
*
*
*	.DATA
*	.EVEN
*	nwords_1:	dc.w	2
*	wordlist_1:	dc.b	'arg1',0
*			dc.b	'arg2',0
*
*	.EVEN
*	nwords_2:	dc.w	3
*	wordlist_2:	dc.b	'arg3',0
*			dc.b	'arg4',0
*			dc.b	'arg5',0
*
*	hupair_
*
*	.BSS
*			ds.b	8		*  �����ɂ� 'HUPAIR>',0 ���������܂��D
*	cmdline:	ds.b	CMDLINE_SIZE
*
*****************************************************************
* EncodeHUPAIR - �������т� HUPAIR �ɏ]���ăo�b�t�@�ɃG���R�[�h����
*
* CALL
*      A0     �o�b�t�@�̃A�h���X
*
*      D0.W   �o�b�t�@�̗e�ʁi�o�C�g���j
*
*      A1     �G���R�[�h�����������
*
*      D1.W   �G���R�[�h��������̐��i�������j
*
* RETURN
*      A0     ������ EncodeHUPAIR �܂��� SetHUPAIR ���Ăяo���ۂ�
*             �n���ׂ� A0 �̒l�D
*             �i�o�b�t�@�̏������݃|�C���^�j
*
*      D0.L   �����Ȃ�΁C���ʃ��[�h�͑����� EncodeHUPAIR �܂���
*             SetHUPAIR �� �Ăяo���ۂ� �n���ׂ� D0.W �̒l�D
*             �i�o�b�t�@�̎c��e�ʁj
*             �����Ȃ�Ηe�ʕs���������D
*
*      CCR    TST.L D0
*
* STACK
*      20 Bytes
*
* DESCRIPTION
*      $00 �ŏI�[���ꂽ�����񂪌��Ԗ�������ł���s�������сt
*      ���G���R�[�h���ăo�b�t�@�ɏ������ށD�������ސ擪�ʒu��
*      �Ăяo������ A0���W�X�^�Ŏw�肵�C���̈ʒu����̗e�ʂ�
*      D0.W���W�X�^�Ŏ����D���^�[������ A0���W�X�^�� D0.W���W
*      �X�^�̒l�́C������ EncodeHUPAIR �܂��� SetHUPAIR ����
*      �ԍۂɎg�p�����D
*      ���^�[������ D0.L���W�X�^�̒l�������ɂȂ��Ă���Ȃ�΁C
*      ����̓o�b�t�@�̗e�ʂ��s���������Ƃ������Ă���D
*
* NOTE
*      �G���R�[�h��������̐��� 0 �łȂ���΁C�ŏ��ɋ󔒁i$20�j
*      �� 1�����u�����D
*
* AUTHOR
*      �_ �j�F
*
* REVISION
*      12 Mar. 1991   �_ �j�F         �쐬
*       2 Nov. 1991   �_ �j�F         �N�I�[�g�͈͂��Œ��Ƃ���
*****************************************************************

	.TEXT
	.XDEF	EncodeHUPAIR

EncodeHUPAIR:
		movem.l	d1-d3/a1-a2,-(a7)
		moveq	#0,d2
		move.w	d0,d2			*  D2.L : �o�b�t�@�̎c��e��
encode_continue:
		dbra	d1,encode_loop
encode_return:
		move.l	d2,d0
		movem.l	(a7)+,d1-d3/a1-a2
		rts

encode_loop:
		subq.l	#1,d2
		bcs	encode_return

		move.b	#' ',(a0)+		*  �P�����̃X�y�[�X��u���āA�����P�����؂�

		move.b	(a1),d0			*  �P�ꂪ��Ȃ�
		beq	begin_quote		*  �N�I�[�g����
encode_one_loop:
		*  ��ǂ݂��ăN�I�[�g���ׂ�������T��
		movea.l	a1,a2
		sf	d3			*  D3.B : �󔒕��������������Ƃ��o����t���O
prescan:
		move.b	(a2)+,d0
		beq	prescan_done		*  �� ��ǂݏI��

		cmp.b	#'"',d0			*  " ����������
		beq	begin_quote		*  ' �ŃN�I�[�g���J�n����

		cmp.b	#"'",d0			*  ' ����������
		beq	begin_quote		*  " �ŃN�I�[�g���J�n����

		cmp.b	#' ',d0
		beq	found_white_space	*  �� �󔒕�����������

		cmp.b	#$09,d0
		blo	prescan

		cmp.b	#$0d,d0
		bhi	prescan
found_white_space:
	*  �󔒕�����������
		st	d3			*  �󔒕��������������Ƃ��o���Ă�����
		bra	prescan			*  ��ǂ݂𑱂���

prescan_done:
	*  ��ǂݏI��
		tst.b	d3			*  �󔒕������������Ȃ��
		bne	begin_quote		*  " �ŃN�I�[�g���J�n����

	*  �����N�I�[�g���ׂ������͖����̂ŁA�P��̎c�����C�ɃR�s�[����B
		subq.l	#1,a2
		move.l	a2,d0
		sub.l	a1,d0			*  D0.L : �R�s�[����o�C�g��
		sub.l	d0,d2
		bcs	encode_return
dup_loop:
		move.b	(a1)+,d0
		beq	encode_continue

		move.b	d0,(a0)+
		bra	dup_loop

begin_quote:
	*  D0.B �� " �Ȃ�� ' �ŁA�����łȂ���� " �ŃN�I�[�g���J�n����
		moveq	#'"',d3
		cmp.b	d0,d3
		bne	insert_quote_char

		moveq	#"'",d3
insert_quote_char:
		move.b	d3,d0
		bra	quoted_insert

quoted_loop:
		move.b	(a1),d0
		beq	close_quote		*  �P��̏I���Ȃ�N�I�[�g�����

		cmp.b	d3,d0			*  �N�I�[�g����������ꂽ�Ȃ�
		beq	close_quote		*  �N�I�[�g����U����

		addq.l	#1,a1
quoted_insert:
		subq.l	#1,d2
		bcs	encode_return

		move.b	d0,(a0)+
		bra	quoted_loop

close_quote:
		subq.l	#1,d2
		bcs	encode_return

		move.b	d3,(a0)+
		bra	encode_one_loop
*****************************************************************
* SetHUPAIR - �R�}���h���C������������
*
* CALL
*      A0     �Ō�� EncodeHUPAIR �Ăяo����� A0 �̒l
*             �i�o�b�t�@�̏������݃|�C���^�j
*
*      D0.W   �Ō�� EncodeHUPAIR �Ăяo����� D0.W �̒l
*             �i�o�b�t�@�̎c��e�ʁj
*
*      A1     �ŏ��� EncodeHUPAIR �Ăяo�����ɓn���� A0 �̒l
*             �i�R�}���h���C���̐擪�A�h���X�j
*
*      D1.W   �ŏ��� EncodeHUPAIR �Ăяo�����ɓn���� D0.W �̒l
*             �i�R�}���h���C���̑S�e�ʁj
*
* RETURN
*      D0.L   �����Ȃ�΁C���ʃ��[�h�̓R�}���h���C���̕������
*             �����i�o�C�g���j�D
*             �����Ȃ�Ηe�ʕs���������D
*
*      D1.W   �R�}���h���C���� 1�o�C�g�ڂɃZ�b�g�����C�������
*             �����D������ D0.L �������̂Ƃ��ɂ͕s��D
*
*      CCR    TST.L D0
*
* STACK
*      0 Bytes
*
* DESCRIPTION
*      EncodeHUPAIR �̌J��Ԃ����I������ɌĂяo���ăR�}���h
*      ���C����������������̂ł���D
*
*      A1���W�X�^�ŗ^������R�}���h���C���̑O�ɂ�8�o�C�g��
*      �]�����Ȃ���΂Ȃ�Ȃ��D����8�o�C�g�̗]���ɂ� 'HUPAIR>',0
*      ���������܂��D
*
* AUTHOR
*      �_ �j�F
*
* REVISION
*      11 Aug. 1991   �_ �j�F         �쐬
*      24 Nov. 1991   �_ �j�F         'HUPAIR>',0 ���Z�b�g
*****************************************************************

	.TEXT
	.XDEF	SetHUPAIR

SetHUPAIR:
		tst.w	d0
		beq	set_over

		sub.w	d0,d1
		moveq	#0,d0
		move.w	d1,d0
		beq	set_noarg

		clr.b	(a0)
		subq.w	#1,d0
		move.w	#255,d1
		cmp.w	d1,d0
		bhi	set_length

		move.w	d0,d1
		bra	set_length

set_noarg:
		clr.b	1(a1)
set_length:
		move.b	d1,(a1)
		subq.l	#8,a1
		move.b	#'#',(a1)+
		move.b	#'H',(a1)+
		move.b	#'U',(a1)+
		move.b	#'P',(a1)+
		move.b	#'A',(a1)+
		move.b	#'I',(a1)+
		move.b	#'R',(a1)+
		clr.b	(a1)+
		tst.l	d0
		rts

set_over:
		moveq	#-1,d0
		rts
*****************************************************************

	.END
