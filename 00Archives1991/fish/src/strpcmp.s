* strpcmp.s
* Itagaki Fumihiko 02-Sep-90  Create.

.xref issjis
.xref toupper
.xref scanchar2
.xref enputs

.text

****************************************************************
scanchar2c:
		bsr	scanchar2
		beq	scanchar2c_return

		tst.b	d2
		beq	scanchar2c_return

		cmp.w	#$100,d0
		bsr	toupper
scanchar2c_return:
		tst.b	d0
		rts
****************************************************************
* strpcmp - compare string and pattern
*
* CALL
*      A0     points string (contsins no escape or quoting character)
*      A1     points pattern string (may be contains \)
*      D0.B   0: case dependent  otherwise: case independent
*
* RETURN
*      D0.L   0 if matches, 1 if not match, -1 if error
*      CCR    TST.L D0
*****************************************************************
*
* (A1) �̃��^�V�[�P���X :
*	?		�C�ӂ�1�����Ƀ}�b�`����
*	*		0�����ȏ�̔C�ӂ̒Ԃ�Ƀ}�b�`����
*	[list]		list���̔C�ӂ�1�����Ƀ}�b�`����
*	[^list]		list�Ɋ܂܂�Ȃ��C�ӂ�1�����Ƀ}�b�`����
*
* list �̃��^�V�[�P���X :
*	-		���O�̕������傫������̕�����菬�������ׂĂ̕����W��
*
*  ���ׂĂ̏ꍇ�ɂ����� 1�̃V�t�gJIS�R�[�h������ 1�̕����Ƃ��Ĉ�����
*  �ǂ̃V�t�gJIS�R�[�h�������A�ǂ� ANK�������傫��
*
*  ���� \ �͑����������G�X�P�[�v����
*  �G�X�P�[�v����Ă��Ȃ� [ �܂��� [^ �̒���ł� - �� ] �͓��ʂȈӖ��������Ȃ�
*  ���ʂȈӖ������� - �ɑ��� - �� ] �͓��ʂȈӖ��������Ȃ�
*
*  �b�V�F���Ƃ܂����������ł͂Ȃ��̂ŗv����
*
*  * �̐������ċA���邩��C�����邱��
*
*****************************************************************
.xdef strpcmp

strpcmp:
		movem.l	d1-d6/a0-a1,-(a7)
		move.b	d0,d2			* D2.B : case independent �t���O
ismatch_loop:
		move.b	(a1)+,d0
		beq	ismatch_tail

		cmp.b	#'*',d0
		beq	ismatch_asterisk

		cmp.b	#'?',d0
		beq	ismatch_question

		cmp.b	#'[',d0
		beq	ismatch_list

		cmp.b	#'\',d0
		bne	ismatch_char

		move.b	(a1)+,d0
		beq	ismatch_tail
****************
ismatch_char:
		move.b	(a0)+,d1
		bsr	issjis
		beq	ismatch_sjis

		tst.b	d2
		beq	ismatch_char_comp

		exg	d0,d1
		bsr	toupper
		exg	d0,d1
		bsr	toupper
ismatch_char_comp:
		cmp.b	d1,d0
		bne	ismatch_false

		bra	ismatch_loop
****************
ismatch_sjis:
		cmp.b	d1,d0
		bne	ismatch_false

		move.b	(a1)+,d0
		beq	ismatch_tail

		cmp.b	(a0)+,d0
		bne	ismatch_false

		bra	ismatch_loop
****************
ismatch_list:
		bsr	scanchar2c
		beq	ismatch_false

		move.w	d0,d1

		moveq	#0,d3			* D3.B : �u�}�b�`�����v�t���O
		moveq	#0,d4			* D4.B : ^ �t���O
		moveq	#0,d5			* D5.B : 0:�ŏ�  -1:-�̎�  1:�����̎�
		cmpi.b	#'^',(a1)
		bne	ismatch_list_loop

		moveq	#1,d4
		addq.l	#1,a1
ismatch_list_loop:
		moveq	#0,d0
		move.b	(a1)+,d0
		beq	ismatch_list_missing_blaket

		tst.b	d5
		beq	ismatch_list_no_special
		bmi	ismatch_list_no_special

		cmp.b	#'-',d0
		bne	ismatch_list_not_minus

		moveq	#-1,d5
		bra	ismatch_list_loop

ismatch_list_not_minus:
		cmp.b	#']',d0
		beq	ismatch_list_done_scan
ismatch_list_no_special:
		cmp.b	#'\',d0
		bne	ismatch_list_char

		move.b	(a1)+,d0
		beq	ismatch_list_missing_blaket
ismatch_list_char:
		subq.l	#1,a1
		exg	a0,a1
		bsr	scanchar2c
		exg	a0,a1
		beq	ismatch_list_missing_blaket

		cmp.w	d0,d1				* ������������Ɣ�r
		beq	ismatch_list_matched

		tst.b	d5				* �e-�f�̎��Ȃ�΁c
		bpl	ismatch_list_not_matched_yet

		cmp.w	d6,d1				* lower �Ɣ�r
		blo	ismatch_list_not_matched_yet

		cmp.w	d0,d1				* upper�i������������j�Ɣ�r
		bhi	ismatch_list_not_matched_yet
ismatch_list_matched:
		moveq	#1,d3
ismatch_list_not_matched_yet:
		move.w	d0,d6
		moveq	#1,d5
		bra	ismatch_list_loop

ismatch_list_done_scan:
		eor.b	d4,d3
		bra	ismatch_question_1
****************
ismatch_question:
		bsr	scanchar2
ismatch_question_1:
		beq	ismatch_false

		bra	ismatch_loop
****************
ismatch_asterisk:
		move.b	(a1)+,d0
		cmp.b	#'*',d0
		beq	ismatch_asterisk

		cmp.b	#'?',d0
		bne	ismatch_asterisk_2

		bsr	scanchar2
		beq	ismatch_false

		bra	ismatch_asterisk

ismatch_asterisk_2:
		subq.l	#1,a1
ismatch_aster_loop2:
		move.b	d2,d0
		bsr	strpcmp
		bmi	ismatch_return
		beq	ismatch_return

		bsr	scanchar2
		beq	ismatch_false
		bra	ismatch_aster_loop2
****************
ismatch_tail:
		tst.b	(a0)
		bne	ismatch_false

		moveq	#0,d0
		bra	ismatch_return
ismatch_false:
		moveq	#1,d0
ismatch_return:
		movem.l	(a7)+,d1-d6/a0-a1
		rts

ismatch_list_missing_blaket:
		lea	msg_missing_blaket,a0
		bsr	enputs
		moveq	#-1,d0
		bra	ismatch_return
****************************************************************
.data

msg_missing_blaket:	dc.b	'] ������܂���',0

.end
