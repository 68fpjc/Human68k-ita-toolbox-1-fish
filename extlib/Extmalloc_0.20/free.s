*************************************************
*						*
*   malloc Ext version Ver 0.10			*
*   Copyright 1991 by �d����(T.Kawamoto)	*
*						*
*************************************************
*						*
*   file name : free.s				*
*   author    : T.Kawamoto			*
*   date      : 92/4/15				*
*   functions : free_memory_reg_saved		*
*             : free_memory			*
*             : free_all_memory_reg_saved	*
*             : free_all_memory			*
*   history   : 91/9/16	now coding		*
*             : 91/9/21	debugging has finished	*
*   ver 0.01  : 91/9/22	lake_top(a5)		*
*             : 91/9/23	large size support	*
*   ver 0.02  : 91/9/28	shrink support		*
*   ver 0.03  : 91/10/2	add free_all_memory	*
*   ver 0.12  : 92/4/15	omitted MALLOC		*
*						*
*************************************************
*
	include	defines.inc
*
	.text
*
	.xref	is_previous_free
	.xref	free_lake
	.xref	shrink_lake
*
	.xdef	free_memory_reg_saved
	.xdef	free_memory
	.xdef	MFREEALL
	.xdef	free_all_memory_reg_saved
	.xdef	free_all_memory
*
free_memory_reg_saved:
*
* input
*  d0	�A�h���X
*  a5	pointer to local BSS
* output
*  d0	�G���[�R�[�h
*
	movem.l	d7/a1/a2/a4/a6,-(sp)
	bsr	free_memory
	movem.l	(sp)+,d7/a1/a2/a4/a6
	rts
*
free_memory:
*
* input
*  d0	�A�h���X
*  a5	pointer to local BSS
* output
*  d0	�G���[�R�[�h
* destroy
*  d7	���[�N���W�X�^
*  a1	���[�N�|�C���^
*  a2	���[�N�|�C���^
*  a4	lake head �ւ̃|�C���^
*  a6	pool head �ւ̃|�C���^
*
	subq.l	#2,d0
	move.l	lake_top(a5),d7
	bra	lake_entry
lake_loop:
	move.l	next_lake_ptr(a4),d7
lake_entry:
	beq	no_pool			* lake ���Ȃ��Ȃ���
	move.l	d7,a4			* lake head �ւ̃|�C���^
	add.l	#head_pool,d7
	cmp.l	d0,d7
	beq	free_lake		* large size �̊J��
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
* �J�������� pool �̈ʒu����������
*
*  a6	�J�������� pool �ւ̃|�C���^
*
* ���O�� free pool ���ǂ������`�F�b�N
*
	bsr	is_previous_free
	beq	together_previous
*
* ���O�� free pool �łȂ��ꍇ
*
*  a6	�J�������� pool �ւ̃|�C���^
*  a2	���O�� free pool �ւ̃|�C���^
*
	move.l	a6,d0
	sub.l	a2,d0			* �ӂ��̊Ԋu
	move.w	next_free_offset(a2),d7	* next_free_offset ��񕪂���
	move.w	d0,next_free_offset(a2)	* ���O�̂ق���
	sub.w	d0,d7
	move.w	d7,next_free_offset(a6)	* �J���������ق��ɑ��
	bra	together_if_following_is_free
*
* ���O�� free pool �̏ꍇ
*
*  a6	�J�������� pool �ւ̃|�C���^
*  a2	���O�� free pool �ւ̃|�C���^
*
together_previous:
	move.w	next_pool_offset(a6),d7	* �ӂ���
	add.w	d7,next_pool_offset(a2)	* �܂Ƃ߂�
	move.l	a2,a6			* ���܂�
*
together_if_following_is_free:
*
* ���x�́A���オ free pool ���ǂ������`�F�b�N
*
	move.w	next_pool_offset(a6),d7
	cmp.w	next_free_offset(a6),d7
	bne	together_following_skip
*
* ���オ free pool �̏ꍇ
*
*  a6	�J�������� pool �ւ̃|�C���^
*  a2	����� free pool �ւ̃|�C���^
*
	lea	(a6,d7.w),a2
	move.w	next_pool_offset(a2),d7	* �ӂ���
	beq	together_following_skip
	add.w	d7,next_pool_offset(a6)	* �܂Ƃ߂�
	move.w	next_free_offset(a2),d7	* ���܂���
	add.w	d7,next_free_offset(a6)	* �ЂƂ�
together_following_skip:
	bra	shrink_lake
	moveq.l	#0,d0
	rts
*
no_pool:
*
* �Ō�܂ŃT�[�`�I��
*
*   �Ȃ������̂ŃG���[�I��
*
	moveq.l	#-1,d0
	rts
*
MFREEALL:
free_all_memory_reg_saved:
*
* input
*  a5	pointer to local BSS
* output
*  d0	�G���[�R�[�h
*
	movem.l	d7/a1/a4/a6,-(sp)
	bsr	free_all_memory
	movem.l	(sp)+,d7/a1/a4/a6
	rts
*
free_all_memory:
*
* input
*  a5	pointer to local BSS
* output
*  d0	�G���[�R�[�h
* destroy
*  d7	���[�N���W�X�^
*  a1	���[�N�|�C���^
*  a4	lake head �ւ̃|�C���^
*  a6	���[�N�|�C���^
*
	subq.l	#2,d0
	move.l	lake_top(a5),d7
	bra	lake_all_entry
lake_all_loop:
	move.l	next_lake_ptr(a6),d7
lake_all_entry:
	beq	no_all_pool		* lake ���Ȃ��Ȃ���
	move.l	d7,a6			* lake head �ւ̃|�C���^
	move.l	a6,a4
	bsr	free_lake
	bra	lake_all_loop
*
no_all_pool:
*
* �Ō�܂� free ����
*
	moveq.l	#0,d0
	rts
*
	.end
