*************************************************
*						*
*   malloc Ext version Ver 0.14			*
*   Copyright 1991 by �d����(T.Kawamoto)	*
*						*
*************************************************
*						*
*   file name : alloc.s				*
*   author    : T.Kawamoto			*
*   date      : 92/4/15				*
*   functions : allocate_memory_reg_saved	*
*             : allocate_memory			*
*   history   : 91/9/16	now coding		*
*             : 91/9/21	debugging has finished	*
*   ver 0.01  : 91/9/22	added D2 saving		*
*             : 91/9/22	lake_top(a5)		*
*             : 91/9/23	large size support	*
*   ver 0.12  : 92/4/15	omitted MALLOC		*
*   ver 0.15  : 92/11/2	shrink bug fix		*
*						*
*************************************************
*
	include	defines.inc
*
	.text
*
	.xref	enlarge_lake
	.xref	allocate_lake
	.xref	allocate_large_memory
*
	.xdef	allocate_memory_reg_saved
	.xdef	allocate_memory
*
	dc.b	"Ext malloc library << lake >> Ver 0.16 for fish, ksh, zsh, and dis",0
	.even
*
*
allocate_memory_reg_saved:
*
* input
*  d0	�K�v�ȃo�C�g�T�C�Y
*  a5	pointer to local BSS
* output
*  d0	�A�h���X or -1
*
	movem.l	d1-d5/d7/a0-a2/a4/a6,-(sp)
	bsr	allocate_memory
	movem.l	(sp)+,d1-d5/d7/a0-a2/a4/a6
	rts
*
allocate_memory:
*
* input
*  d0	�K�v�ȃo�C�g�T�C�Y
*  a5	pointer to local BSS
* output
*  d0	�A�h���X or -1
* destroy
*  d1	�o�C�g�T�C�Y
*  d2	���[�N���W�X�^
*  d7	���[�N���W�X�^
*  a1	���[�N�|�C���^
*
* ���݃T�[�`���̂���
*  d0.w	�K�v�ȃo�C�g�T�C�Y
*  a4	lake head �ւ̃|�C���^
*  a6	free pool �ւ̃|�C���^
*  a2	���O�� free pool �ւ̃|�C���^
*  a1	����� free pool �ւ̃|�C���^
*
* free pool �̒��ŕK�v�ŏ����̃T�C�Y��������
*  d5.w	�T�C�Y
*  d3	lake head �ւ̃|�C���^
*  d4	free pool �ւ̃|�C���^
*  a0	���O�� free head �ւ̃|�C���^
*
	move.l	d0,d1
	addq.l	#1,d1		* �o�C�g�T�C�Y��
	andi.l	#$fffffffe,d1	* �����ɐ���������
	cmpi.l	#$00004000,d1
	bcc	allocate_large_memory
allocate_memory_retry:
	moveq.l	#-1,d5		* �K�v�ŏ����̃T�C�Y
	moveq.l	#0,d4		* �K�v�ŏ����ւ̃|�C���^
	move.l	lake_top(a5),d7
	bra	lake_entry
lake_loop:
	move.l	next_lake_ptr(a4),d7
lake_entry:
	beq	lake_end	* lake ���Ȃ��Ȃ���
	move.l	d7,a4		* lake head �ւ̃|�C���^
	tst.w	head_pool+next_pool_offset(a4)
	beq	lake_loop	* large size �̏ꍇ�́A�X�L�b�v
	lea	head_pool(a4),a6
pool_loop:
	move.l	a6,a2		* free �̃|�C���^���Z�[�u
	move.w	next_free_offset(a6),d7
	lea	(a6,d7.w),a6
	move.w	next_pool_offset(a6),d7
	beq	lake_loop	* pool ���Ȃ��Ȃ���
	subi.w	#2,d7		* pool �̃T�C�Y�v�Z
	cmp.w	d7,d1
	beq	just_fit_found	* ���x�K�v�T�C�Y�ƈ�v�Ȃ璼���Ɋm�ۂ�
	bcc	pool_loop	* �K�v�T�C�Y�ɖ����Ȃ�
	subi.w	#2,d7		* pool �̃T�C�Y�v�Z
	cmp.w	d7,d1
	beq	just_fit_found	* ���x�K�v�T�C�Y�{�Q�ł������Ɋm�ۂ�
	cmp.w	d7,d5
	bcs	pool_loop	* ���܂ł݂��������̂��傫���ꍇ�̓X�L�b�v
	move.w	d7,d5		* �K�v�Œ�����A��菬�������̂��݂������̂�
	move.l	a4,d3		* d5,a0,d3,d4 �ɃZ�[�u
	move.l	a6,d4
	move.l	a2,a0
	bra	pool_loop
*
lake_end:			* �Ō�܂ŃT�[�`�I��
	move.l	a0,a2
	move.l	d3,a4
	move.l	d4,a6
	move.l	a6,d7
	bne	larger_found	* �K�v�ŏ���������΂���Ŋm��
*
generate_lake_and_retry:
*
* ������Ȃ������̂ŁA�V���� lake ���m��
*  ���܂�p�ɂɂ͋N����Ȃ������Ȃ̂ŁA
*   ���g���C�Ƃ������ʂɂ���ăo�O��}����
*
* �܂��́A������ lake �̊g�������݂�
*
*  d7	offset work registers,
*  a4	lake head �ւ̃|�C���^
*  a5	pointer to local BSS
*
	move.l	lake_top(a5),d7
enlarge_loop:
	beq	enlarge_end
	move.l	d7,a4
	bsr	enlarge_lake
	bpl	allocate_memory_retry	* ���g���C�i���܂�N����Ȃ��j
	move.l	next_lake_ptr(a4),d7
	bra	enlarge_loop
*
* �g�����o���Ȃ���ΐV���� lake ���m�ۂ���
*
enlarge_end:
	bsr	allocate_lake
	bpl	allocate_memory_retry	* ���g���C�i���܂�N����Ȃ��j
allocation_error:
	moveq.l	#-1,d0
	rts			* allocation error
*
just_fit_found:
*
* ���x�̃T�C�Y����������
*  a6	free pool �ւ̃|�C���^
*  a2	���O�� free pool �ւ̃|�C���^
*  d7	���[�N���W�X�^
*
	move.w	next_free_offset(a6),d7
	add.w	d7,next_free_offset(a2)
	lea.l	pool_buffer_head(a6),a6
	move.l	a6,d0
	rts
*
larger_found:
*
* �T�C�Y�̑傫���̂���������
*
*  d1.w	�K�v�ȃo�C�g�T�C�Y
*  a6	pool head �ւ̃|�C���^
*  a2	���O�� free pool �ւ̃|�C���^
*  a1	����� free pool �ւ̃|�C���^
*  d7	���[�N���W�X�^
*
	lea.l	pool_buffer_head(a6),a1
	move.l	a1,d0		* �Ԃ�l��\�ߎZ�o
	addi.w	#2,d1		* �m�ۃT�C�Y�́A�{�Q
	move.w	next_free_offset(a6),d7
	lea	(a6,d7.w),a1	* ���� free pool �̃|�C���^
	move.w	next_pool_offset(a6),d7
	move.w	d1,next_pool_offset(a6)
	lea	(a6,d1.w),a6	* �c��� free pool head ���쐬
	sub.w	d1,d7		* �c��� pool size
	move.w	d7,next_pool_offset(a6)
	move.l	a6,d7		* ���O�� free pool �Ɩ{ free pool
	sub.l	a2,d7		* �̍����v�Z
	move.w	d7,next_free_offset(a2)
	move.l	a1,d7		* �{ free pool �ƒ���� free pool
	sub.l	a6,d7		* �̍����v�Z
	move.w	d7,next_free_offset(a6)
	rts
*
	.end
