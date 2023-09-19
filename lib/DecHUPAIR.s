*  Revision 2 : 24 Jan 1993   �R�����g�C��

*****************************************************************
*  DecHUPAIR.s
*
*  Copyright(C)1991-93 by Itagaki Fumihiko
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


*  ���̃��W���[���Ɋ܂܂�Ă��� �T�u���[�`�� DecodeHUPAIR �́C
*  HUPAIR �ɏ]���ăR�}���h���C����ɃG���R�[�h���ꂽ�������
*  �f�R�[�h������̂ł��D
*
*  �ȉ��ɗ�������܂��D
*
*		.text
*
*	start:				*  start : ���s�J�n�A�h���X
*		bra.s	start1		*  2 Byte
*		dc.b	'#HUPAIR',0	*  ���s�J�n�A�h���X+2 �ɂ��̃f�[�^��u�����Ƃɂ��C
*					*  HUPAIR�K���R�}���h�ł��邱�Ƃ��������Ƃ��ł���D
*	start1:
*		lea	stack_bottom,a7
*
*	*  ������i�[�̈���m�ۂ���
*
*		movea.l	a0,a5		*  A5 := �v���O�����̃������Ǘ��|�C���^�̃A�h���X
*		movea.l	a7,a1		*  A1 := ��������i�[����̈�̐擪�A�h���X
*		lea	1(a2),a0	*  A0 := �R�}���h���C���̕�����̐擪�A�h���X
*		bsr	strlen		*  D0.L �� A0 ������������̒����i$00 �̒��O�܂ł̃o
*					*  �C�g���j�����߁C
*		add.l	a1,d0		*    �i�[�G���A�̗e�ʂ�
*		bcs	insufficient_memory
*		cmp.l	8(a5),d0	*    �`�F�b�N����D
*		bhs	insufficient_memory
*
*			*  ���̗�ł́C�v���Z�X�N�����ɍő僁�����E�u���b�N�����蓖�Ă��Ă�
*			*  �邱�Ƃ𗘗p���āC���̒��Ɉ����i�[�̈�������Ă���D��U�������E�u
*			*  ���b�N�� setblock�Ő؂�l�߂Ă��� malloc ����̂��ǂ����낤�D
*
*		*  �����ŁC
*		*       A0 : �R�}���h���C���̕�����̐擪�A�h���X
*		*       A1 : ��������i�[����̈�̐擪�A�h���X
*
*	*  �R�}���h���C�����f�R�[�h���Ĉ�����𓾂�
*
*		bsr	DecodeHUPAIR
*
*		*  �����ŁCD0.L �͈����̐��DA1 ���w���̈�ɂ́CD0.L �������������C�P��̈���
*		*  �i$00�ŏI�[���ꂽ������j�����Ԗ�������ł���D
*
*	*  ���Ƃ��΁C������ 1�s�� 1���\������ɂ́C
*
*		move.l	d0,d1
*		bra	print_args_continue
*
*	print_args_loop:
*		*
*		*  ������ 1�\������
*		*
*		move.l	a1,-(a7)
*		DOS	_PRINT
*		addq.l	#4,a7
*		move.w	#$0d,-(a7)
*		DOS	_PUTCHAR
*		move.w	#$0a,(a7)
*		DOS	_PUTCHAR
*		addq.l	#2,a7
*		*
*		*  �|�C���^�����̈����ɐi�߂�
*		*
*	skip_1_arg:
*		tst.b	(a1)+
*		bne	skip_1_arg
*		*
*		*  �����̐������J��Ԃ�
*		*
*	print_args_continue:
*               subq.l	#1,d1
*		bcc	print_args_loop
*			.
*			.
*			.
*
*		.bss
*		.ds.b	STACKSIZE
*		.even
*	stack_bottom:
*
*		.END	start



*****************************************************************
* DecodeHUPAIR - HUPAIR�ɏ]���ăR�}���h���C�����f�R�[�h���C����
*                ��𓾂�
*
* CALL
*      A0     HUPAIR�ɏ]���ăG���R�[�h���ꂽ�����̐擪�A�h���X
*             �i�R�}���h���C���̐擪�A�h���X + 1�j
*
*      A1     �f�R�[�h������������������ރG���A�̐擪�A�h���X
*
* RETURN
*      A0     �R�}���h���C���̕�����̍Ō�� $00 �̎��̃A�h���X
*      D0.L   �����̐��i�������j
*      CCR    TST.L D0
*
* STACK
*      12 Bytes
*
* DESCRIPTION
*      A0���W�X�^���w���A�h���X����n�܂镶����isource�j��
*      HUPAIR �ɏ]���ăf�R�[�h���Ĉ�����𓾁CA1���W�X�^���w��
*      �A�h���X����n�܂�G���A�idestination�j�Ɋi�[����D
*
*      destination �ɂ́C�߂�lD0.L�������������C�P��̈���
*      �i$00�ŏI�[���ꂽ������j�����ԂɌ��Ԗ������ԁD
*
*      destination �ɂ͍ő� source �̒��������̗e�ʂ��K�v�ł���D
*
*      �����R�}���h���C���̐擪-8�����8�o�C�g�� '#HUPAIR',0
*      �ł���Ȃ�΁C���^�[������ A0 ���w���Ă���A�h���X�ɂ�
*      arg0 ������D���������̃T�u���[�`���ł� '#HUPAIR',0 ��
*      �`�F�b�N���Ȃ��D
*
* AUTHOR
*      �_ �j�F
*
* REVISION
*      12 Mar. 1991   �_ �j�F         �쐬
*       7 Oct. 1991   �_ �j�F         source��destination�𕪗�
*       3 Jan. 1992   �_ �j�F         A0��߂�u�Ƃ��ĉ�����
*                                       �߂�u D0.W �� D0.L �ɕύX
*****************************************************************

	.text

	.xdef	DecodeHUPAIR

DecodeHUPAIR:
		movem.l	d1-d2/a1,-(a7)
		moveq	#0,d0
		moveq	#0,d2
global_loop:
skip_loop:
		move.b	(a0)+,d1
		cmp.b	#' ',d1
		beq	skip_loop

		tst.b	d1
		beq	done

		addq.l	#1,d0				*  �I�[�o�[�t���[�͗L�蓾�Ȃ�
dup_loop:
		tst.b	d2
		beq	not_in_quote

		cmp.b	d2,d1
		bne	dup_one
quote:
		eor.b	d1,d2
		bra	dup_continue

not_in_quote:
		cmp.b	#'"',d1
		beq	quote

		cmp.b	#"'",d1
		beq	quote

		cmp.b	#' ',d1
		beq	terminate
dup_one:
		move.b	d1,(a1)+
		beq	done
dup_continue:
		move.b	(a0)+,d1
		bra	dup_loop

terminate:
		clr.b	(a1)+
		bra	global_loop

done:
		movem.l	(a7)+,d1-d2/a1
		tst.l	d0
		rts
*****************************************************************

	.end
