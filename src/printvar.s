* printvar.s
* Itagaki Fumihiko 24-Sep-90  Create.

.xref strfor1
.xref putc
.xref cputs
.xref put_tab
.xref put_newline
.xref echo

.text

****************************************************************
* print_var - �ϐ��̒l��\������
*
* CALL
*      A0     �ϐ��̒l�̐擪�A�h���X
*      D0.W   �ϐ��̗v�f��
*
* RETURN
*      ����
****************************************************************
.xdef print_var_value

print_var_value:
		movem.l	d0-d2/a1,-(a7)
		move.w	d0,d2
		cmp.w	#1,d2
		beq	print_var_value_start

		move.b	#'(',d0			* ( ��
		bsr	putc			* �\������
print_var_value_start:
		move.w	d2,d0
		lea	cputs(pc),a1
		bsr	echo

		cmp.w	#1,d2
		beq	print_var_value_done

		move.b	#')',d0			* ) ��
		bsr	putc			* �\������
print_var_value_done:
		movem.l	(a7)+,d0-d2/a1
		rts
****************************************************************
* print_var - �ϐ���\������
*
* CALL
*      A0     �ϐ��̈�̐擪�A�h���X
*
* RETURN
*      ����
****************************************************************
.xdef print_var

print_var:
		movem.l	d0/a0-a1,-(a7)
		addq.l	#8,a0
loop:
		moveq	#0,d0
		move.w	(a0),d0			* ���̕ϐ�����߂�o�C�g��
		beq	done			* 0�Ȃ炨���܂�

		movea.l	a0,a1			* A1��
		adda.w	d0,a1			* ���̕ϐ��̃A�h���X���Z�b�g�@�i�������j
		addq.l	#2,a0
		move.w	(a0)+,d0		* D0.W : ���̕ϐ��̗v�f��
		bsr	cputs			* �ϐ�����\������
		bsr	put_tab			* �����^�u��\������
		bsr	strfor1
		bsr	print_var_value		* �ϐ��̒l��\������
		bsr	put_newline		* ���s����
		movea.l	a1,a0			* ���̕ϐ��̃A�h���X
		bra	loop			* �J��Ԃ�

done:
		movem.l	(a7)+,d0/a0-a1
		rts

.end
