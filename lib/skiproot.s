* skiproot.s
* Itagaki Fumihiko 27-Mar-93  Create.

.text

****************************************************************
* skiproot - �p�X���̐擪�� ?:[/\\] ���X�L�b�v����
*
* CALL
*      A0     �p�X���̐擪�A�h���X
*
* RETURN
*      A0     ?:[/\\] ���X�L�b�v�����A�h���X
*      D0.B   (A0)
*      CCR    TST.B (A0)
*****************************************************************
.xdef skip_root

skip_root:
		tst.b	(a0)
		beq	return

		cmpi.b	#':',1(a0)
		bne	drive_ok

		addq.l	#2,a0
drive_ok:
		cmpi.b	#'/',(a0)
		beq	do_skip_root

		cmpi.b	#'\',(a0)
		bne	return
do_skip_root:
		addq.l	#1,a0
return:
		move.b	(a0),d0
		rts

.end
