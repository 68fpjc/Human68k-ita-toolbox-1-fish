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
*	start:					*  start : ���s�J�n�A�h���X
*			bra.s	start1		*  2Byte
*			dc.b	'#HUPAIR',0	*  ���s�J�n�A�h���X+2 �ɂ��̃f�[�^��
*						*  �u���āCHUPAIR�K���R�}���h�ł���
*						*  ���Ƃ�e�v���Z�X�Ɏ����D
*	start1:
*			lea	stack(a6),a7
*			lea	1(a2),a0	*  A0 : �R�}���h���C���̕�����̃A�h���X
*			bsr	DecodeHUPAIR	*  �f�R�[�h����
*
*			*  �����ŁCA0 �͈������т̐擪�A�h���X�C
*			*  D0.W �͈����̐��ł���DA0 ����̃A�h
*			*  ���X�ɂ́C$00 �ŏI�[���ꂽ������
*			*  �i1�̈����j�� D0.W �������������C
*			*  ���Ԗ��������Ă���D
*
*			*  ���Ƃ��΁C������ 1�s�� 1���\������ɂ́C
*
*			move.w	d0,d1
*			bra	print_args_continue
*
*	print_args_loop:
*			*
*			*  ������ 1�\������
*			*
*			move.l	a0,-(a7)
*			DOS	_PRINT
*			addq.l	#4,a7
*			move.w	#$0d,-(a7)
*			DOS	_PUTCHAR
*			move.w	#$0a,(a7)
*			DOS	_PUTCHAR
*			addq.l	#2,a7
*			*
*			*  �|�C���^�����̈����ɐi�߂�
*			*
*	skip_1_arg:
*			tst.b	(a0)+
*			bne	skip_1_arg
*			*
*			*  �����̐������J��Ԃ�
*			*
*	print_args_continue:
*			dbra	d1,print_args_loop
*				.
*				.
*				.
*		.END	start
*
*****************************************************************
* DecodeHUPAIR - �R�}���h���C���� HUPAIR �ɏ]���ăf�R�[�h����
*                �������т𓾂�
*
* CALL
*      A0     �������т� HUPAIR �ɏ]���ăG���R�[�h����Ă���
*             ������̐擪�A�h���X
*             �i�R�}���h�E���C���̐擪�A�h���X�{�P�j
*
* RETURN
*      A0     �f�R�[�h���ꂽ�������т̐擪�A�h���X
*      D0.W   �����̐��i�������j
*      CCR    TST.W D0
*
* STACK
*      16 Bytes
*
* DESCRIPTION
*      A0���W�X�^���w���A�h���X����n�܂� $00�R�[�h�ŏI�[����
*      �Ă��镶����� HUPAIR �ɏ]���ăf�R�[�h���Ĉ������т�
*      ��D�����œ�����������т̍\���́C$00�R�[�h�ŏI�[��
*      �ꂽ������i�����j�����ԂɌ��Ԗ�������ł�����̂ł���D
*
*      ���^�[������ A0���W�X�^�͈������т̐擪�A�h���X���w��
*      �Ă���ł��邪�C����͌Ăяo������ A0���W�X�^�̒l�Ɠ�
*      ���ł���D���Ȃ킿�C���̕�����͎�����D
*
* AUTHOR
*      �_ �j�F
*
* REVISION
*      12 Mar. 1991   �_ �j�F         �쐬
*****************************************************************

	.TEXT

	.XDEF	DecodeHUPAIR

DecodeHUPAIR:
		movem.l	d1-d2/a0-a1,-(a7)
		clr.w	d0
		movea.l	a0,a1
		moveq	#0,d2
global_loop:
skip_loop:
		move.b	(a1)+,d1
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
		move.b	d1,(a0)+
		beq	done
dup_continue:
		move.b	(a1)+,d1
		bra	dup_loop

terminate:
		clr.b	(a0)+
		bra	global_loop

done:
		movem.l	(a7)+,d1-d2/a0-a1
		tst.w	d0
		rts
*****************************************************************

	.END
