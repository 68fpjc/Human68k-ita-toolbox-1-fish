.include doscall.h

.text

start:
		bra	start1
		dc.b	'#HUPAIR',0
start1:
		lea	4(a3),a0		* ����
		bsr	find_env_bottom		*   �����{�P��A0��
		move.l	a3,d0			* ����
		add.l	(a3),d0			*   ��{�P��D0��
		sub.l	a0,d0			* �󂫗e�ʂ�
		bcs	setenv_return		* �Ȃ�

		cmp.l	#12,d0			* D1�o�C�g��
		blo	setenv_return		* �Ȃ�

		moveq	#11,d0
		lea	testdata(pc),a1
		subq.l	#1,a0			* A0�͊��̖���
setenv_loop:
		move.b	(a1)+,(a0)+
		dbra	d0,setenv_loop
setenv_return:
		DOS	_EXIT
****************************************************************
find_env_bottom:
find_env_bottom_loop:
		tst.b	(a0)+
		beq	find_env_bottom_done
find_env_bottom_loop2:
		tst.b	(a0)+
		bne	find_env_bottom_loop2

		bra	find_env_bottom_loop

find_env_bottom_done:
		rts
****************************************************************
.data

testdata:	dc.b	'ITA=baddest',0

.end start
