* strazbot.s
* Itagaki Fumihiko 16-Jul-90  Create.

.xref strfor1

.text

****************************************************************
* strazbot - NUL������ŏI�[���ꂽ��������т̖����A�h���X�𓾂�
*
* CALL
*      A0     ��������т̐擪�A�h���X
*
* RETURN
*      A0     �I�[�� NUL������̃A�h���X
****************************************************************
.xdef strazbot

strazbot:
strazbot_loop:
		tst.b	(a0)
		beq	strazbot_done

		jsr	strfor1
		bra	strazbot_loop

strazbot_done:
		rts

.end
