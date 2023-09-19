*************************************************
*						*
*   malloc Ext version Ver 0.10			*
*   Copyright 1991 by �d����(T.Kawamoto)	*
*						*
*************************************************
*						*
*   file name : enlarge.s			*
*   author    : T.Kawamoto			*
*   date      : 91/9/28				*
*   functions : allocate_lake			*
*             : enlarge_lake			*
*   history   : 91/9/16	now coding		*
*             : 91/9/21	debugging has finished	*
*   ver 0.01  : 91/9/22	lake_top(a5)		*
*             : 91/9/23	large size support	*
*   ver 0.02  : 91/9/28	rename file name	*
*             : 	from lake to enlarge	*
*   ver 0.10  : 92/3/18	make enlarging only	*
*             : 	2 bytes fatal error	*
*   ver 0.11  : 92/3/24	new lake adds the end	*
*             : 	of the lakes list	*
*   ver 0.11  : 92/3/24	new alloc least size	*
*             : 	of area whom user needs	*
*						*
*************************************************
*
	include	defines.inc
*
	.text
*
	.xref	is_previous_free
*
	.xdef	allocate_lake
	.xdef	enlarge_lake
*
allocate_lake:
*
* input
*  d1	�o�C�g�T�C�Y
*  a5	pointer to local BSS
* destroy
*  d0	OS �Ŕj�󂳂��
*  d2	���[�N���W�X�^
*  d7	���[�N���W�X�^
*  a1	���[�N�|�C���^
*  a2	���[�N�|�C���^
*  a4	pointer to lake head
*  a6	���[�N�|�C���^
*
	move.l	#lake_buffer_head+2+2,d2
	add.l	d1,d2
	move.l	d2,-(sp)
	dc.w	$ff48		* MALLOC
	addq.l	#4,sp
	tst.l	d0
	bmi	alloc_error
	move.l	d0,a4
	move.l	d2,lake_size(a4)
	move.l	#0,next_lake_ptr(a4)
	lea	next_pool_offset-2(a4,d2.l),a2	* last dummy ��
	move.w	#0,(a2)			*         �ݒ�
	move.w	#free_pool_buffer_head,head_pool+next_pool_offset(a4)
	move.w	#free_pool_buffer_head,head_pool+next_free_offset(a4)
	lea	lake_buffer_head(a4),a6
	move.l	a2,d0			* lake buffer head �� last dummy �Ԃ�
	sub.l	a6,d0			* �I�t�Z�b�g���v�Z
	move.w	d0,next_pool_offset(a6)	* last free pool �̍Đݒ�
	move.w	d0,next_free_offset(a6)	*
	lea	lake_top-next_lake_ptr(a5),a6
alloc_end_loop:
	move.l	next_lake_ptr(a6),d0
	beq	alloc_end_end
	move.l	d0,a6
	bra	alloc_end_loop
*
alloc_end_end:
	move.l	a4,next_lake_ptr(a6)
	bsr	enlarge_lake
	moveq	#0,d0
alloc_error:
	rts
*
*
enlarge_lake:
*
* input
*  d1	�o�C�g�T�C�Y
*  a4	pointer to lake head
*  a5	pointer to local BSS
* output
*  d0	�G���[�R�[�h
* destroy
*  d2	new length
*  d7	���[�N���W�X�^
*  a1	���[�N�|�C���^
*  a2	���[�N�|�C���^
*  a6	pointer to last free pool
*
	tst.w	head_pool+next_pool_offset(a4)
	beq	no_more_error	* large size �̏ꍇ�́A�G���[
	move.l	lake_size(a4),d2
	cmp.l	#$00008000,d2
	beq	no_more_error	* �ő� lake �T�C�Y�����ς��������ꍇ
	lea	next_pool_offset-2(a4,d2.l),a6	* last dummy
	bsr	is_previous_free
	bne	set_skip	* last dummy pool �̒��O�� free �Ȃ�A
	move.l	a2,a6		* �������ŏI�A�h���X�ia6�j
set_skip:
*
* new length ���Z�o
*
	add.l	#$00001000,d2
	and.l	#$0000f000,d2
	cmp.l	#$00008000,d2
	bcs	size_skip
	move.l	#$00008000,d2
size_skip:
	move.l	d2,-(sp)	* �܂��A�Z�o�T�C�Y�Ɋg�債�Ă݂�
	move.l	a4,-(sp)
	dc.w	$ff4a		* SETBLOCK
	addq.l	#8,sp
	tst.l	d0
	bpl	enlarge_ok
	move.l	d0,d2		* �g��Ɏ��s�����ꍇ�͏o����͈͂Ŋg�傷��
	andi.l	#$ff000000,d0
	cmpi.l	#$82000000,d0	* �S�R�g��s�Ȃ�G���[
	beq	no_more_error	*   lake �T�C�Y������ȏ㑝���Ȃ��ꍇ
*
* OS ���Ԃ��Ă����͈͂Ń��g���C
*
	and.l	#$00ffffff,d2
	move.l	lake_size(a4),d0
	addq.l	#2,d0		* 2 bytes �����]�v�Ɋm�ۏo���Ȃ��ꍇ��
	cmp.l	d2,d0		* �v���I�G���[ 92/3/18 (Thanks �_)
	bcc	no_more_error
	move.l	d2,-(sp)
	move.l	a4,-(sp)
	dc.w	$ff4a		* SETBLOCK
	addq.l	#8,sp
	tst.l	d0
	bmi	no_more_error	*  �v���I�G���[
enlarge_ok:
*
* �g��ɐ��������̂� lake ���Đݒ�
*
*  a4	pointer to lake head
*  a6	pointer to last free pool
*
	move.l	d2,lake_size(a4)	* lake size ���Đݒ�
	lea	next_pool_offset-2(a4,d2.l),a2	* last dummy ��
	move.w	#0,(a2)			*         �Đݒ�
	move.l	a2,d0			* last free pool �� last dummy �Ԃ�
	sub.l	a6,d0			* �I�t�Z�b�g���v�Z
	move.w	d0,next_pool_offset(a6)	* last free pool �̍Đݒ�
	move.w	d0,next_free_offset(a6)	*
	moveq.l	#0,d0			* ����I��
	rts
*
no_more_error:
	moveq.l	#-1,d0
	rts
*
	.end
