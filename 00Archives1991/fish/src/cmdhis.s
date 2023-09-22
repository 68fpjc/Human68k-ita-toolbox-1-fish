* cmdhis.s
* This contains built-in command 'history'.
*
* Itagaki Fumihiko 23-Dec-90  Create.

.text

****************************************************************
*  Name
*       history - print history list
*
*  Synopsis
*       history [-hr] [�s��]
*
*       -h   �s�ԍ������ŏo�͂���
*       -r   �t���ɏo�͂���
****************************************************************

itoawork  = -12

.xdef cmd_history

cmd_history:
		link	a6,#itoawork
		moveq	#0,d4		* D4 : -h : hide line #
		moveq	#0,d5		* D5 : -r : reverse
sw_lp:
		tst.w	d0
		beq	his_n

		cmpi.b	#'-',(a0)
		bne	his_n

		subq.w	#1,d0
		addq.l	#1,a0
sw_lp1:
		move.b	(a0)+,d1
		beq	sw_lp

		cmp.b	#'h',d1
		beq	his_h

		cmp.b	#'r',d1
		bne	his_bad_arg
his_r:
		moveq	#1,d5
		bra	sw_lp1

his_h:
		moveq	#1,d4
		bra	sw_lp1

his_n:
		cmp.w	#1,d0			* ������
		bhi	his_too_many_args	* �Q�ȏ゠��΃G���[
		blo	history_default		* �P��������� $history[1] ���Q�Ƃ���

		bsr	atou			* ���l���X�L��������
		tst.b	(a0)			* �ŏ��̔񐔎���NUL�łȂ����
		bne	his_bad_arg		* �G���[

		tst.l	d0
		bmi	his_bad_arg		* �G���[
		bne	history_all		* �I�[�o�[�t���[�D�D�S�s��\��

		bra	history_check_n

history_default:
		lea	word_history,a0
		bsr	svartol
		bmi	history_all		* �I�[�o�[�t���[�D�D�D�S�s��\��

		cmp.l	#1,d0
		bls	history_done		* $history[1] �͒�`����Ă��Ȃ�

		cmp.l	#4,d0
		beq	history_check_n

		bsr	badly_formed_number
		bra	history_return

history_check_n:
		move.l	d1,d0
		cmp.l	his_nlines_now,d0	* ���݂̍s���ȉ��Ȃ��
		bls	history_start		* �n�j
history_all:
		move.l	his_nlines_now,d0	* D0�Ɍ��݂̍s�����Z�b�g
history_start:
		tst.l	d0
		beq	history_done

		move.l	his_toplineno,d1	* D1�ɂ�
		add.l	his_nlines_now,d1	*   �ŏI�s�̍s�ԍ��{�P���Z�b�g
		movea.l	hiswork,a0
		add.l	his_end,a0		* A0�ɂ͌��݂̗����̖��[�̃A�h���X�̐擪����̃I�t�Z�b�g���Z�b�g
		tst.w	d5			* �t�����H
		bne	history_reverse

		* ����

		sub.l	d0,d1			* D1�ɕ\������擪�̍s�̍s�ԍ������߂�
		bsr	backup_history
prhist_for_loop:
		tst.w	(a0)			* ���̍s�̃o�C�g��
		beq	history_done		* 0�Ȃ炨���܂�

		bsr	prhist_1line		* ���̍s��\������
		adda.w	(a0),a0			* �|�C���^�����̍s�Ɉړ��@�i�������j
		addq.l	#1,d1			* �s�ԍ����C���N�������g
		bra	prhist_for_loop		* �J��Ԃ�

		* �t��
history_reverse:
prhist_rev_loop:
		suba.w	-2(a0),a0		* �|�C���^��O�̍s�Ɉړ��@�i�������j
		subq.l	#1,d1			* �s�ԍ����f�N�������g
		bsr	prhist_1line		* ���̍s��\������
		subq.l	#1,d0
		bne	prhist_rev_loop		* �\���s�����J��Ԃ�
history_done:
		moveq	#0,d0
history_return:
		unlk	a6
		rts

his_too_many_args:
		bsr	too_many_args
		bra	history_usage

his_bad_arg:
		bsr	bad_arg
history_usage:
		lea	msg_usage,a0
		bsr	usage
		bra	history_return
****************************************************************
prhist_1line:
		movem.l	d0-d3/a1,-(a7)
		move.l	a0,-(a7)		* �A�h���X��Ҕ�
		tst.w	d4			* �s�ԍ���\�����Ȃ��Ȃ��
		bne	prhist_1line_1		* �s�ԍ��\�����X�L�b�v

		move.l	d1,d0			* �s�ԍ���
		moveq	#6,d2			* ���Ȃ��Ƃ��U��
		moveq	#0,d3			* '0'���ߖ�����
		lea	puts(pc),a1
		bsr	printu			* �\������
		bsr	put_tab			* �^�u��\������
prhist_1line_1:
		addq.l	#2,a0
		move.w	(a0)+,d1		* ���̍s�̌ꐔ��D1�ɃZ�b�g
		beq	prhist_1line_done	* �O�Ȃ炨���܂�

		subq.w	#1,d1
		bra	prhist_1line_start
prhist_1line_loop:
		bsr	put_space		* �󔒂�\������
		bsr	for1str			* ���̌�
prhist_1line_start:
		bsr	cputs			* ���\������
		dbra	d1,prhist_1line_loop
prhist_1line_done:
		move.l	(a7)+,a0		* �A�h���X��߂�
		bsr	put_newline		* ���s����
		movem.l	(a7)+,d0-d3/a1
		rts

	if	0
*****************************************************************
* gethist - get history line address
*
* CALL
*      D0       line no.
*
* RETURN
*      D0.L	0 if found, otherwise 1
*      A0.L     address of the line
*
gethist:
		movea.l	hiswork,a0		* �����̐擪�s�̃A�h���X��
		addq.l	#4,a0			* A0�ɃZ�b�g
		sub.l	his_toplineno,d0	* �擪�̍s�ԍ�������
		blo	return_1		* ��������Ⴏ��΃G���[

		bsr	forward_var		* D0�s�i�߂�
		beq	return_1		* �s�������Ȃ�΃G���[

		moveq	#0,d0
		rts

return_1:
		moveq	#1,d0
		rts

	endif

.data

msg_usage:	dc.b	'[ -h ] [ -r ] [ <�C�x���g��> ]',0

.end
