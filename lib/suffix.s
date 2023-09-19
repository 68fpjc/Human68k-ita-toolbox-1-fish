* suffix.s
* Itagaki Fumihiko 14-Aug-90  Create.

.xref strbot

****************************************************************
* suffix - �t�@�C�����̊g���q���̃A�h���X
*
* CALL
*      A0     �t�@�C�����̐擪�A�h���X
*
* RETURN
*      A0     �g���q���̃A�h���X�i�e.�f�̈ʒu�D�e.�f��������΍Ō�� NUL ���w���j
*      CCR    TST.B (A0)
*
* NOTE
*      �e/�f��e\�f�̓`�F�b�N���Ȃ��D�K�v�Ȃ�headtail���Ă�ł���ĂԂ̂��悢
*****************************************************************
.xdef suffix

suffix:
		movem.l	d0/a1-a2,-(a7)
		movea.l	a0,a2
		jsr	strbot
		movea.l	a0,a1
search_suffix:
		cmpa.l	a2,a1
		beq	suffix_return

		cmpi.b	#'.',-(a1)
		bne	search_suffix

		movea.l	a1,a0
suffix_return:
		movem.l	(a7)+,d0/a1-a2
		tst.b	(a0)
		rts

.end
