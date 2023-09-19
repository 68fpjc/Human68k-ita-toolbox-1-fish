	.INCLUDE doscall.h

	.XREF DecodeHUPAIR


STACKSIZE	EQU	512

CR	EQU	$0d
LF	EQU	$0a


	.TEXT

start:						*  ���s�J�n�A�h���X
		bra	start1			*  2 Byte
hupair_id:	dc.b	'#HUPAIR',0		*  ���̃v���O������HUPAIR�����ł��邱�Ƃ�����
start1:
		lea	stack_bottom,a7
		movea.l	a0,a5			*  A5 := �v���O�����̃������Ǘ��|�C���^
	*
	*  �R�}���h���C���� HUPAIR encoded �ł��邩�ǂ����𒲂ׂ�
	*
		lea	-8(a2),a0		*  A0 := �R�}���h���C���̐擪�A�h���X-8
		lea	hupair_id(pc),a1	*  A1 := HUPAIR ID �̃A�h���X
		moveq	#7,d0
check_loop:
		cmpm.b	(a0)+,(a1)+
		dbne	d0,check_loop

		lea	msg_hupair_encoded,a0
		beq	check_done

		lea	msg_not_hupair_encoded,a0
check_done:
		move.l	a0,-(a7)
		DOS	_PRINT
		addq.l	#4,a7
	*
	*  HUPAIR decode ���s��
	*
		movea.l	a7,a1			*  A1 := �������т��i�[����G���A�̐擪�A�h���X
		lea	1(a2),a0		*  A0 := �R�}���h���C���̕�����̐擪�A�h���X
		bsr	strlen			*  D0.L �� A0 ������������̒��������߁C
		add.l	a1,d0			*    �i�[�G���A�̗e�ʂ�
		cmp.l	8(a5),d0		*    �`�F�b�N����D
		bhs	insufficient_memory

		bsr	DecodeHUPAIR		*  �f�R�[�h����D

		*  �����ŁCD0.W �͈����̐��DA1 �������G���A�ɂ́CD0.W �������������C
		*  �P��̈����i$00�ŏI�[���ꂽ������j�����Ԗ�������ł���D
	*
	*  �������\������
	*
		move.w	d0,d1			*  D1.w : �����̐�
		bra	print_start

loop1:
		moveq	#'>',d0
		bsr	putc
loop2:
		clr.w	d0
		move.b	(a1)+,d0
		beq	continue

		bsr	putc
		bra	loop2

continue:
		moveq	#'<',d0
		bsr	putc
		moveq	#CR,d0
		bsr	putc
		moveq	#LF,d0
		bsr	putc
print_start:
		dbra	d1,loop1
	*
	*  �I��
	*
		clr.w	-(a7)
		DOS	_EXIT2
*
*  �u������������܂���v�ƕ\�����ďI������
*
insufficient_memory:
		pea	msg_insufficient_memory
		DOS	_PRINT
		addq.l	#4,a7
		move.w	#1,-(a7)
		DOS	_EXIT2
**
**  �T�u���[�`�� putc - ���� D0.W ���o�͂���
**
putc:
		move.w	d0,-(a7)
		DOS	_PUTCHAR
		addq.l	#2,a7
		rts
**
**  �T�u���[�`�� strlen - ������ A0 �̒����� D0.L �ɓ���
**
strlen:
		move.l	a0,-(a7)
		move.l	a0,d0
loop:
		tst.b	(a0)+
		bne	loop

		subq.l	#1,a0
		sub.l	a0,d0
		neg.l	d0
		movea.l	(a7)+,a0
		rts


	.DATA

msg_insufficient_memory:
		dc.b	'argtest: ������������܂���',CR,LF,0

msg_hupair_encoded:
		dc.b	'�R�}���h���C���͊ԈႢ�Ȃ� HUPAIR encoded �ł�',CR,LF,0

msg_not_hupair_encoded:
		dc.b	'�R�}���h���C���� HUPAIR encoded �ł͂Ȃ������m��܂���',CR,LF,0


	.BSS

		ds.b	STACKSIZE
stack_bottom:


	.END start
