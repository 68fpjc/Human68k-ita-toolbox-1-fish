* isfullpath.s
* Itagaki Fumihiko 26-Aug-91  Create.

.text

*****************************************************************
* isfullpath - �p�X�����h���C�u�����܂ރt���p�X���ł��邩
*              �ǂ�������������
*
* CALL
*      A0     �p�X���̐擪�A�h���X
*
* RETURN
*      CCR    �t���p�X���Ȃ�� EQ
*****************************************************************
.xdef isfullpath

isfullpath:
		tst.b	(a0)
		beq	isnot

		cmpi.b	#':',1(a0)
		bne	return

		cmpi.b	#'/',2(a0)
		beq	return

		cmpi.b	#'\',2(a0)
return:
		rts

isnot:
		cmpi.b	#1,(a0)
		rts

.end
