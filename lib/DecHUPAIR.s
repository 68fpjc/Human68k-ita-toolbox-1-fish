*****************************************************************
*  DecHUPAIR.s
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
*  ���̃��W���[���Ɋ܂܂�Ă��� �T�u���[�`�� DecodeHUPAIR �́C
*  HUPAIR �ɏ]���ăR�}���h���C����ɃG���R�[�h���ꂽ��������
*  ���f�R�[�h������̂ł��D
*
*  �ȉ��ɗ�������܂��D
*
*		.TEXT
*
*	start:				*  start : ���s�J�n�A�h���X
*		bra.s	start1		*  2 Byte
*		dc.b	'#HUPAIR',0	*  ���s�J�n�A�h���X+2 �ɂ��̃f�[�^��u�����Ƃɂ��C
*					*  HUPAIR�K���R�}���h�ł��邱�Ƃ�e�v���Z�X�Ɏ����D
*	start1:
*		movea.l	a0,a5		*  A5 := �v���O�����̃������Ǘ��|�C���^�̃A�h���X
*		lea	stack_bottom,a7
*		movea.l	a7,a1		*  A1 := �������т��i�[����G���A�̐擪�A�h���X
*		lea	1(a2),a0	*  A0 := �R�}���h���C���̕�����̐擪�A�h���X
*		bsr	strlen		*  D0.L �� A0 ������������̒��������߁C
*		add.l	a1,d0		*    �i�[�G���A�̗e�ʂ�
*		cmp.l	8(a5),d0	*    �`�F�b�N����D
*		bhs	insufficient_memory
*
*		bsr	DecodeHUPAIR	*  �f�R�[�h����D
*
*		*  �����ŁCD0.W �͈����̐��DA1 �������G���A�ɂ́CD0.W �������������C
*		*  �P��̈����i$00�ŏI�[���ꂽ������j�����Ԗ�������ł���D
*
*		*  ���Ƃ��΁C������ 1�s�� 1���\������ɂ́C
*
*		move.w	d0,d1
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
*		dbra	d1,print_args_loop
*			.
*			.
*			.
*
*		.BSS
*		.ds.b	STACKSIZE
*		.EVEN
*	stack_bottom:
*
*		.END	start
*
*****************************************************************
* DecodeHUPAIR - HUPAIR�ɏ]���ăR�}���h���C�����f�R�[�h���C����
*                ���т𓾂�
*
* CALL
*      A0     HUPAIR�ɏ]���ăG���R�[�h���ꂽ�����̐擪�A�h���X
*             �i�R�}���h�E���C���̐擪�A�h���X + 1�j
*
*      A1     �f�R�[�h�����������т��������ރG���A�̐擪�A�h���X
*
* RETURN
*      D0.W   �����̐��i�������j
*      CCR    TST.W D0
*
* STACK
*      16 Bytes
*
* DESCRIPTION
*      A0���W�X�^���w���A�h���X����n�܂镶����isource�j��
*      HUPAIR �ɏ]���ăf�R�[�h���Ĉ������т𓾁CA1���W�X�^���w��
*      �A�h���X����n�܂�G���A�idestination�j�Ɋi�[����D
*
*      destination �ɂ́C�߂�lD0.W�������������C�P��̈���
*      �i$00�ŏI�[���ꂽ������j�����ԂɌ��Ԗ������ԁD
*
*      destination �ɂ� source �̒��������̗e�ʂ��K�v�ł���D
*
* AUTHOR
*      �_ �j�F
*
* REVISION
*      12 Mar. 1991   �_ �j�F         �쐬
*      07 Oct. 1991   �_ �j�F         source��destination�𕪗�
*****************************************************************

	.TEXT

	.XDEF	DecodeHUPAIR

DecodeHUPAIR:
		movem.l	d1-d2/a0-a1,-(a7)
		clr.w	d0
		moveq	#0,d2
global_loop:
skip_loop:
		move.b	(a0)+,d1
		cmp.b	#' ',d1
		beq	skip_loop

		tst.b	d1
		beq	done

		addq.w	#1,d0
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
		movem.l	(a7)+,d1-d2/a0-a1
		tst.w	d0
		rts
*****************************************************************

	.END
