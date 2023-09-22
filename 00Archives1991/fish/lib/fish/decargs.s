****************************************************************
* DecodeFishArgs - �R�}���h���C�����f�R�[�h���Ĉ������т𓾂�
*
* CALL
*      A0     �R�}���h�E���C���̐擪�A�h���X�{�P
*
* RETURN
*      A0     �������т̐擪�A�h���X
*      D0.W   �����̐�
*      CCR    �j��
*
* DESCRIPTION
*      A0 ���w���A�h���X����n�܂� $00 �ŏI�[����Ă��镶�����
*      fish�d�l�Ɋ�Â��ăf�R�[�h���Ĉ������т𓾂�B�������т�
*      $00 �ŏI�[���ꂽ�������A���ԂɌ��Ԗ�������ł�����̂ł�
*      ��B
*
*      �Ԃ� A0 �͈������т̐擪�A�h���X�ł��邪�A����͌Ăяo��
*      ���Ɠ����ł���B���Ȃ킿�A���̕�����͎�����B
*
*      �Ԃ� D0.W �͈����̐��ł���B
*
* AUTHOR
*      �_ �j�F
*
* REVISION
*      12 Mar. 1991   �_ �j�F         �쐬
****************************************************************

	.TEXT

	.XDEF	DecodeFishArgs

DecodeFishArgs:
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
		rts

	.END
