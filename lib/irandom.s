* irandom.s  -  �����̈�l����

*
*  Itagaki Fumihiko   26 Mar 1989
*

*
*  Description
*
*          �{�p�b�P�[�W�́C�^������(pseudo random numbers)�𔭐�������̂�
*  ����D�����ɂ͂��낢��Ȏ�ނ����邪�C�Ȃ��ł���Ԋ�{�I�Ȃ��͈̂�l��
*  �z�̗����C���Ȃ킿��l�����ł���D����́C�^����ꂽ�͈͂̂����C�ǂ̒l
*  ���Ƃ�m�����������D
*
*          �{�p�b�P�[�W�̊֐� _irandom �́C�Ăяo���x�� 0�ȏ� 32768������
*  �����̈�l������Ԃ��D
*
*      �֐� _irandom �̃A���S���Y����
*
*                   X[n] = (X[n-55] - X[n-24]) mod m
*
*  �Ƃ����u�����Z�@�v(subtractive method)�ł��邪�C���ۂɂ� m �� 2�̗ݏ��
*  ���� 32768 ��I�сC
*
*     �@              X[n] = X[n-55] XOR X[n-24]
*
*  �Ƃ��Ă���D�܂�C55��O�ɔ������������� 24��O�ɔ������������Ƃ̔r��
*  �I�_���a�����߂�D�ŉ��ʃr�b�g (X[n] mod 2) �̎����͐��m��
*  (2 pow 55) - 1 �ł���C���ꂪ X[n] �̎����̉����ɂȂ�D
*
*          �֐� _irandom �͊m���Ɉ�l�����𔭐����C���̗����̕��z��
*  �����͂Ȃ��D�������Ȃ���C�������闐���ɖ��炩�ȋK�������F�߂��邩��
*  �m��Ȃ��D�����ł�������ǂ����̂��֐� irandom �ł���D�֐� irandom �́C
*  �֐� _irandom �𗘗p���Ȃ���K������������x��������������Ԃ��D������
*  �����闐���ɋK�����������Ă��\��Ȃ��Ȃ�Ί֐� _irandom ���g�p���Ă���
*  ���킯�����C�֐� irandom �̃I�[�o�[�w�b�h�͂����͂��Ȃ̂ŁC�ǂ̂悤�ȏ�
*  ���ɂ��֐� irandom ���g�p����̂��ǂ����낤�D
*
*          �v���O�������ŗ����̏����ς������ꍇ�ɂ́C0�ȏ� 1�����̎�����
*  ��l�����𔭐�����֐� random �𗘗p����
*
*�@ �@                    (int)trunc(random() * m)
*
*  �̂悤�ɂ��邩�C���̃p�b�P�[�W�̊֐� irandom �𗘗p����
*
*                          (irandom() * m) >> 15
*
*  �̂悤�ɂ���D�O�҂̕��������傫���ݒ肷�邱�Ƃ��ł��邪�C�������Z��
*  �����Ȃ��v�Z�@�ł͌�҂̕������x�̓_�ł����ƗL���ł���D
*
*          �֐� irandom ����� _irandom ���g�p����ɂ́C�ŏ��Ɉ�񂾂�����
*  ���̎葱�� init_irandom(seed,poolsize) �����s���Ă����D������ seed �͗�
*  ���́u��v�� 0�ȏ� 32768�����̐����Ƃ���D���� seed �̒l�ɂ���ė�����
*  �n�񂪈قȂ邱�ƂɂȂ�Dpoolsize �͊֐� irandom ���g�p����z��
*  irandom_pool �̗e��(�v�f��)�������D
*
*          �{�p�b�P�[�W�𗘗p����ɂ́C�{�p�b�P�[�W�̑���
*
*                  .BSS
*                  irandom_index:       ds.b    1
*                  irandom_position:    ds.b    1
*                  irandom_poolsize:    ds.b    1
*                  irandom_table:       ds.w    55
*                  irandom_pool:        ds.w    (irandom_poolsize)
*
*  ���K�v�ł���D
*

.xref irandom_index
.xref irandom_position
.xref irandom_poolsize
.xref irandom_table
.xref irandom_pool

.text

****************************************************************
* randomize
*
* CALL
*      none
*
* RETURN
*      none
****************************************************************
randomize:
		movem.l	d0-d1/a0,-(a7)
		lea	irandom_table,a0
		moveq	#23,d1
randomize_loop1:
		move.w	31*2(a0),d0
		eor.w	d0,(a0)+
		dbra	d1,randomize_loop1

		moveq	#30,d1
randomize_loop2:
		move.w	-24*2(a0),d0
		eor.w	d0,(a0)+
		dbra	d1,randomize_loop2

		movem.l	(a7)+,d0-d1/a0
		rts
****************************************************************
* _irandom - �ȒP�ȋ^����l��������
*
* CALL
*      none
*
* RETURN
*      D0.L   �ȒP�ȋ^����l�������� (0..32767)
****************************************************************
.xdef _irandom

_irandom:
		move.l	a0,-(a7)
		moveq	#0,d0
		move.b	irandom_index,d0
		addq.b	#1*2,d0
		cmp.b	#55*2,d0
		blo	_irandom_1

		bsr	randomize
		moveq	#0,d0
_irandom_1:
		move.b	d0,irandom_index
		lea	irandom_table,a0
		move.w	(a0,d0.l),d0
		movea.l	(a7)+,a0
		rts
****************************************************************
* irandom - ���ǔŋ^����l��������
*
* CALL
*      none
*
* RETURN
*      D0.L   ���ǔŋ^����l�������� (0..32767)
****************************************************************
.xdef irandom

irandom:
		movem.l	d1-d2/a0,-(a7)
		moveq	#0,d2
		move.b	irandom_position,d2
		lea	irandom_pool,a0
		move.w	(a0,d2.w),d2
		moveq	#0,d1
		move.b	irandom_poolsize,d1
		mulu	d1,d2
		clr.w	d2
		swap	d2
		lsl.w	#1,d2
		move.b	d2,irandom_position
		move.w	(a0,d2.w),d1
		bsr	_irandom
		move.w	d0,(a0,d2.w)
		moveq	#0,d0
		move.w	d1,d0
		movem.l	(a7)+,d1-d2/a0
		rts
****************************************************************
* init_irandom - ���ǔŋ^����l��������������������
*
* CALL
*      D0.W   (signed) seed (�����̎�) (0..32767)
*      D1.B   (signed) poolsize (1..63)
*
* RETURN
*      none
*
* NOTE
*      D0.W �� MSB �� CLR ����D
*
*      D1.B �� 1 ���� 63 �͈̔͂ɖ����ꍇ�ɂ� 1 ���� 63 �͈̔͂�
*      �N���b�s���O����D
****************************************************************
.xdef init_irandom

init_irandom:
		movem.l	d0-d4/a0,-(a7)
*
		moveq	#1,d2
		cmp.b	d2,d1
		blt	init_irandom_1

		moveq	#63,d2
		cmp.b	d2,d1
		ble	init_irandom_2
init_irandom_1:
		move.b	d2,d1
init_irandom_2:
		move.b	d1,irandom_poolsize
*
		bclr	#15,d0
		lea	irandom_table,a0
		move.w	d0,54*2(a0)
		moveq	#1,d1
		moveq	#1,d2
init_irandom_loop1:
		moveq	#21,d3
		mulu	d2,d3
		divu	#55,d3
		swap	d3
		lsl.w	#1,d3
		move.w	d1,(a0,d3.w)
		move.w	d1,d4
		sub.w	d0,d1
		neg.w	d1
		bclr	#15,d1
		move.w	d4,d0
		addq.w	#1,d2
		cmp.w	#55,d2
		blo	init_irandom_loop1
*
		bsr	randomize
		bsr	randomize
		bsr	randomize
		move.b	#54*2,irandom_index
*
		lea	irandom_pool,a0
		moveq	#0,d1
		move.b	irandom_poolsize,d1
		subq.w	#1,d1
init_irandom_loop2:
		bsr	_irandom
		move.w	d0,(a0)+
		dbra	d1,init_irandom_loop2
*
		move.b	irandom_poolsize,d0
		subq.b	#1,d0
		lsl.b	#1,d0
		move.b	d0,irandom_position
*
		movem.l	(a7)+,d0-d4/a0
		rts

.end
