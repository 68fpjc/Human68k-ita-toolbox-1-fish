* reverse.s
* Itagaki Fumihiko 16-Jul-90  Create.

.text

****************************************************************
* reverse - �����z��𔽓]����
*
* CALL
*      A0     ���]������z��̐擪�A�h���X
*      A1     ���]������z��̍ŏI�A�h���X�{�P
*
* RETURN
*      �Ȃ�
*****************************************************************
.xdef reverse

reverse:
		movem.l	d0/a0-a1,-(a7)
loop:
		cmpa.l	a0,a1
		bls	done

		move.b	-(a1),d0
		move.b	(a0),(a1)
		move.b	d0,(a0)+
		bra	loop

done:
		movem.l	(a7)+,d0/a0-a1
		rts

.end
