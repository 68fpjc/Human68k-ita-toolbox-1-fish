* irandom.s  -  �����̈�l����

*
*  Itagaki Fumihiko   Mar 26 1989
*

*
*    �{�p�b�P�[�W�́C�^������(pseudorandom numbers)�𔭐�������̂ł���D
*  �����ɂ͂��낢��Ȏ�ނ����邪�C�Ȃ��ł���Ԋ�{�I�Ȃ��͈̂�l���z�̗����C
*  ���Ȃ킿��l�����ł���D����́C�^����ꂽ�͈͂̂����C�ǂ̒l���Ƃ�m������
*  �����D
*
*    �{�p�b�P�[�W�̊֐� _irandom �́C�Ăяo���x�� 0�ȏ� 32768�����̐����̈�l
*  ������Ԃ��D
*    �ŏ��Ɉ�񂾂��������̎葱�� init_irandom(seed) �����s���Ă����D������
*  seed �͗����́u��v�� 0�ȏ� 32768�����̐����Ƃ���D����seed�̒l�ɂ���ė�
*  ���̌n�񂪈قȂ邱�ƂɂȂ�D
*
*  �֐� _irandom �̃A���S���Y����
*�@�@�@�@X[n] = (X[n-55] - X[n-24]) mod m
*  �Ƃ����u�����Z�@�v(subtractive method)�ł��邪�C���ۂɂ� m �� 2�̗ݏ�ł�
*  �� 32768 ��I�сC
*�@�@�@�@X[n] = X[n-55]�@XOR�@X[n-24]
*  �Ƃ��Ă���D�܂�C55��O�ɔ������������� 24��O�ɔ������������Ƃ̔r���I
*  �_���a�����߂�D
*    �ŉ��ʃr�b�g (X[n] mod 2) �̎����͐��m�� (2 pow 55) - 1 �ł���C���ꂪ
*  X[n] �̎����̉����ɂȂ�D
*
*    �֐� _irandom �͊m���Ɉ�l�����𔭐����C���̗����̕��z�͈����͂Ȃ��D
*  �������Ȃ���C�������闐���ɖ��炩�ȋK�������F�߂��邩���m��Ȃ��D������
*  ��������ǂ����̂��֐� irandom �ł���D�֐� irandom �́C�֐� _irandom ��
*  �p���Ȃ���K������������x��������������Ԃ��D�����������闐���ɋK��������
*  ���Ă��\��Ȃ��Ȃ�Ί֐� _irandom ���g�p���Ă��ǂ��킯�����C�֐�irandom�̃I
*  �[�o�[�w�b�h�͂����͂��Ȃ̂ŁC�ǂ̂悤�ȏꍇ�ɂ��֐� irandom ���g�p����̂�
*  �ǂ����낤�D
*
*    �v���O�������ŗ����̏����ς������ꍇ�ɂ́C0�ȏ� 1�����̎����̈�l������
*  ��������֐� random �𗘗p����
*�@�@�@�@trunc(random() * m)
*  �̂悤�ɂ��邩�C���̃p�b�P�[�W�̊֐� irandom �𗘗p����
*�@�@�@�@(irandom() * m) >> 15
*  �̂悤�ɂ���D�O�҂̕��������傫���ݒ肷�邱�Ƃ��ł��邪�C�������Z������
*  �Ȃ��v�Z�@�ł͌�҂̕������x�̓_�ł����ƗL���ł���D
*

.include random.h

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
		lea	random_table,a0
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
		move.b	random_index,d0
		addq.b	#1*2,d0
		cmp.b	#55*2,d0
		blo	_irandom_1

		bsr	randomize
		moveq	#0,d0
_irandom_1:
		move.b	d0,random_index
		lea	random_table,a0
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
		move.b	random_position,d2
		lea	random_pool,a0
		move.w	(a0,d2.w),d2
		mulu	#POOLSIZE*2,d2
		clr.w	d2
		swap	d2
		lsl.w	#1,d2
		move.b	d2,random_position
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
*      D0.W   �����̎� (0..32767)
*
* RETURN
*      none
****************************************************************
.xdef init_irandom

init_irandom:
		movem.l	d0-d4/a0,-(a7)
		lea	random_table,a0
		move.w	d0,54*2(a0)
		moveq	#1,d1
		moveq	#1,d2
init_random_loop1:
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
		blo	init_random_loop1

		bsr	randomize
		bsr	randomize
		bsr	randomize
		move.b	#54*2,random_index

		lea	random_pool,a0
		moveq	#POOLSIZE-1,d1
init_random_loop2:
		bsr	_irandom
		move.w	d0,(a0)+
		dbra	d1,init_random_loop2

		move.b	#(POOLSIZE-1)*2,random_position
		movem.l	(a7)+,d0-d4/a0
		rts

.end
