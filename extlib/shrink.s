*************************************************
*						*
*   malloc Ext version				*
*   Copyright 1991 by �d����(T.Kawamoto)	*
*						*
*************************************************
*						*
*   file name : shrink.s			*
*   author    : T.Kawamoto			*
*   date      : 91/9/28				*
*   functions : free_lake			*
*             : shrink_lake			*
*   history   : 				*
*   ver 0.01  : 91/9/23	large size support	*
*   ver 0.02  : 91/9/28	shrink support		*
*             : 	rename file name	*
*             : 	from freelake to shrink	*
*   ver 0.15  : 92/11/2	shrink bug fix		*
*						*
*************************************************
*
	include	defines.inc
*
	.text
*
	.xref	is_previous_free
*
	.xdef	free_lake
	.xdef	shrink_lake
*
*
free_lake:
* input
*  a5	pointer to local BSS
*  a4	lake head �ւ̃|�C���^
* output
*  d0	�G���[�R�[�h
* destroy
*  d7	���[�N���W�X�^
*  a1	���[�N�|�C���^
*  a4	lake head �ւ̃|�C���^
*
	move.l	a4,d0
	move.l	lake_top(a5),a4	* lake head �ւ̃|�C���^
	cmp.l	a4,d0
	bne	lake_loop
	move.l	next_lake_ptr(a4),lake_top(a5)
	bra	free_to_OS
*
lake_loop:
	move.l	a4,a1
	move.l	next_lake_ptr(a4),d7
	beq	no_lake_error	* lake ���Ȃ��Ȃ���
	move.l	d7,a4		* lake head �ւ̃|�C���^
	cmp.l	a4,d0
	bne	lake_loop
	move.l	next_lake_ptr(a4),next_lake_ptr(a1)
free_to_OS:
	move.l	a4,-(sp)
	dc.w	$ff49		* MFREE
	addq.l	#4,sp
	tst.l	d0
	bmi	no_lake_error
	rts
*
no_lake_error:
	moveq.l	#-1,d0
	rts
*
*
shrink_lake:
* input
*  a5	pointer to local BSS
*  a4	lake head �ւ̃|�C���^
* output
*  d0	�G���[�R�[�h
* destroy
*  d7	���[�N���W�X�^
*  a1	���[�N�|�C���^
*  a2	pointer to previous pool head
*  a6	pointer to pool head
*  a4	lake head �ւ̃|�C���^
*
	move.l	lake_size(a4),d7
	lea	-2(a4,d7.l),a6		* �Ō�� dummy pool �ւ̃|�C���^
	bsr	is_previous_free	* ���O�� free �H
	bne	shrink_lake_do_nothing	* �łȂ���Βꂳ�炢���Ȃ�
	lea	lake_buffer_head(a4),a1	* pool �̈�Ԑ擪�A�h���X
	cmp.l	a1,a2			* ���O����Ԑ擪�Ȃ�
	beq	free_lake		* �S�����炤
	move.l	a6,d7
	sub.l	a2,d7
	cmp.l	#$00001000,d7		* free �̃T�C�Y�� �S�jbytes
	bcs	shrink_lake_do_nothing	* �����Ȃ�ꂳ�炢���Ȃ�
	move.w	#0,next_pool_offset(a2)	* �Ō�� free pool �� dummy �ɂ��Ă��܂�
	move.l	lake_size(a4),d0
	sub.l	d7,d0
	move.l	d0,lake_size(a4)	* lake ���k��
	move.l	d0,-(sp)
	move.l	a4,-(sp)
	dc.w	$ff4a			* SETBLOCK
	addq.l	#8,sp
	tst.l	d0
	bpl	shrink_lake_ok
shrink_lake_fail:
	moveq.l	#-1,d0
	rts
*
shrink_lake_ok:
shrink_lake_do_nothing:
	moveq.l	#0,d0
	rts
*
	.end
