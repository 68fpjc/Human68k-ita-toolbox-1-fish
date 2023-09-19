* printi.s
* Itagaki Fumihiko 21-Apr-91  Create.

.xref printfs

.text

****************************************************************
* printfi - �����O�E���[�h�l�������ɏ]���ďo�͂���
*
* CALL
*      D0.L   �l
*
*      D1.L   ���Ȃ��Ƃ��o�͂��镶�����i�o�C�g���j
*
*      D2.L   bit 0 : 0=�E�l��  1=���l��
*             bit 1 : 1= D1.L�̕������i�o�C�g���j�𒴂��ďo�͂��Ȃ�
*
*      D3.B   �E�l�߂̂Ƃ��A�����̌��Ԃ𖄂߂镶���R�[�h
*
*      A0     �l�𕶎���ɕϊ�����T�u�E���[�`���̃G���g���[�E�A�h���X
*             �i���̃T�u�E���[�`���ɑ΂��A�l��D0.L�ɁA
*               34B�̃o�b�t�@�̐擪�A�h���X��A0�ɗ^���ČĂяo���j
*
*      A1     �����̏o�͂��s�Ȃ��T�u�E���[�`���̃G���g���[�E�A�h���X
*             �i���̃T�u�E���[�`���ɑ΂��A�����R�[�h��D0.B�ɗ^���ČĂяo���j
*
* RETURN
*      D0.L   �o�͂���������
*****************************************************************
.xdef printfi

printfi:
		movem.l	d1/a0/a2,-(a7)
		movea.l	a0,a2
		link	a6,#-34			* ������o�b�t�@���m�ۂ���
		lea	-34(a6),a0		* A0 : ������o�b�t�@�̐擪�A�h���X
		movem.l	d1-d7/a0-a6,-(a7)
		jsr	(a2)			* �l�𕶎���ɕϊ�
		movem.l	(a7)+,d1-d7/a0-a6
		btst	#0,d2
		bne	do_printfs

		cmp.b	#'0',d3
		bne	do_printfs

		cmpi.b	#'-',(a0)
		beq	with_sign

		cmpi.b	#'+',(a0)
		beq	with_sign
do_printfs:
		jsr	printfs
		bra	done

with_sign:
		tst.l	d1
		bne	with_sign_1

		btst	#1,d2
		bne	done
with_sign_1:
		move.b	(a0)+,d0
		jsr	(a1)
		subq.l	#1,d1
		jsr	printfs
		addq.l	#1,d0
done:
		unlk	a6
		movem.l	(a7)+,d1/a0/a2
		rts

.end
