*************************************************
*						*
*   malloc Ext version				*
*   Copyright 1991 by �d����(T.Kawamoto)	*
*						*
*************************************************
*						*
*   file name : alloc.s				*
*   author    : T.Kawamoto			*
*   date      : 92/4/15				*
*   functions : realloc_memory_reg_saved	*
*             : realloc_memory			*
*   history   : 92/5/17	now coding		*
*   ver 0.14  : 92/5/17	add _realloc		*
*   ver 0.16  : 93/5/1	fixed error when	*
*             :		copying 1-2 bytes area	*
*						*
*************************************************
*
	include	defines.inc
*
	.text
*
	.xref	allocate_memory
	.xref	free_memory
*
	.xdef	realloc_memory_reg_saved
	.xdef	realloc_memory
*
realloc_memory_reg_saved:
*
* input
*  d0	�A�h���X
*  d1	���A���b�N�T�C�Y
*  a5	pointer to local BSS
* output
*  d0	�A�h���X or -1
*
	movem.l	d1-d7/a1-a4/a6,-(sp)
	bsr	realloc_memory
	movem.l	(sp)+,d1-d7/a1-a4/a6
	rts
*
realloc_memory:
*
* input
*  d0	�A�h���X
*  d1	���A���b�N�T�C�Y
*  a5	pointer to local BSS
* output
*  d0	�A�h���X or -1
* destroy
*  d2	���[�N���W�X�^
*  d3	���[�N���W�X�^
*  d4	���[�N���W�X�^
*  d5	���[�N���W�X�^
*  d6	�I���W�i���T�C�Y
*  d7	���[�N���W�X�^
*  a1	���[�N�|�C���^
*  a2	���[�N�|�C���^
*  a3	�I���W�i���A�h���X
*  a4	lake head �ւ̃|�C���^
*  a6	pool head �ւ̃|�C���^
*
	subq.l	#2,d0			* �������� free ������ size �̌v�Z
	move.l	lake_top(a5),d7
	bra	lake_entry
lake_loop:
	move.l	next_lake_ptr(a4),d7
lake_entry:
	beq	no_pool			* lake ���Ȃ��Ȃ���
	move.l	d7,a4			* lake head �ւ̃|�C���^
	add.l	#head_pool,d7
	cmp.l	d0,d7
	beq	realloc_lake		* large size �̃��A���b�N
	tst.w	head_pool+next_pool_offset(a4)
	beq	lake_loop		* large size �̏ꍇ�́A�X�L�b�v
	cmp.l	d0,a4			* d0 pointer �� lake �͈͓̔��ɂ��邩�ǂ����H
	bcc	lake_loop		* �Ȃ��i���̂P�j
	move.l	lake_size(a4),d7
	add.l	a4,d7
	cmp.l	d7,d0
	bcc	lake_loop		* �Ȃ��i���̂Q�j
	lea	head_pool(a4),a6	* �͈͓��Ȃ̂ŏڂ��� pool ���T�[�`
pool_loop:
	move.w	next_pool_offset(a6),d7
	beq	no_pool			* pool ���Ȃ��Ȃ���
	lea	(a6,d7.w),a6
	cmp.l	a6,d0
	bne	pool_loop		* ���� pool ���ǂ����H
*
* ���A���b�N������ pool �̈ʒu����������
*
*  a6	�I���W�i���� pool �ւ̃|�C���^
*  d1	���A���b�N������ size
*
	clr.l	d6
	move.w	next_pool_offset(a6),d6
	subq.l	#2,d6
	lea	2(a6),a3
	bra	realloc_memory_body
*
* ���A���b�N������ lake �̈ʒu����������
*
*  a4	�I���W�i���� lake �ւ̃|�C���^
*  d1	���A���b�N������ size
*
realloc_lake:
	move.l	lake_size(a4),d6
	sub.l	#head_pool+pool_buffer_head,d6
	lea	head_pool+pool_buffer_head(a4),a3
realloc_memory_body:
*
* ���A���b�N�̎���
*
*  a3	�I���W�i���̗̈�ւ̃|�C���^
*  d6	�I���W�i�� size
*  d1	���A���b�N������ size
*
	move.l	d1,d0
	cmp.l	d6,d1
	bcc	min_size_skip
	move.l	d1,d6
min_size_skip:
	bsr	allocate_memory
	tst.l	d0
	bmi	no_pool
*
*  a3	�I���W�i���̗̈�ւ̃|�C���^
*  d6	�I���W�i�� size �ƃ��A���b�N������ size �̂�����������
*  d0	���A���b�N�������̈�ւ̃|�C���^
*
	move.l	a3,a1
	move.l	d0,a2
	move.l	a2,a3
	move.l	a1,d0
	btst.l	#1,d6			* �n�[�t���[�h�P�ʂ̃T
	beq	half_skip		* �C�Y�Ŋ�ł���Ȃ�
	move.w	(a1)+,(a2)+		* �����ɒ������Ă���
half_skip:
	asr.l	#2,d6			* �����O���[�h�P�ʃT�C�Y
	tst.l	d6			* 0 �o�C�g�Ȃ�
	beq	move_skip		* �X�L�b�v    93/5/1
	subq.l	#1,d6
move_loop:
	move.l	(a1)+,(a2)+
	dbra	d6,move_loop
	clr.w	d6
	subq.l	#1,d6
	bcc	move_loop
move_skip:
	bsr	free_memory
	tst.l	d0
	bmi	no_pool
	move.l	a3,d0
	rts
*
no_pool:
*
* �Ō�܂ŃT�[�`�I��
*
*   �Ȃ������̂ŃG���[�I��
*
no_memory:
*
* ������������Ȃ��̂ŃG���[�I��
*
	moveq.l	#-1,d0
	rts
*
	.end
