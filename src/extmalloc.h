		.offset	0
*
pool_head:			* �e pool �̐擪
next_pool_offset:		* ���� pool �ւ̃I�t�Z�b�g
		ds.w	1	* �K�� 2 �̔{���ł���
				* 0 �Ȃ�I����\�킷 dummy pool
				* 2 �� broken pool�A���݂͈�ؐ������Ȃ�
pool_buffer_head:		* 4 �ȏ�� used pool �� free pool
				*   ���̋�ʂ͕ʂ̃`�F�C���� free �������q��
				*   ���̃��X�g�ɂȂ���� used �� pool_buffer_head
				*   ���� next_pool_offset - 2 bytes �g�p��
next_free_offset:		* free �� next_free_offset �Ń`�F�C������
		ds.w	1	* �K�� 2 �̔{���ł���
				* 0 �Ȃ玟�� free pool ��������������
free_pool_buffer_head:
*
		.offset	0
*
lake_head:			* �e lake �̐擪
lake_size:			* lake �̃T�C�Y
		ds.l	1	*
next_lake_ptr:			* ���� pool �ւ̃|�C���^
		ds.l	1	* 0 �Ȃ玟�� pool �͖���
head_pool:			* next_free_offset ���i�[����ׂ� free pool
		ds.b	free_pool_buffer_head
				* next_pool_offset �ɂ͒��x free_pool_buffer_head ��
				* next_free_offset �ɂ� free pool ��
				* �̃I�t�Z�b�g������
lake_buffer_head:		* ����������ۂ� pool �̃`�F�C��������
				* ��ԍŌ�ɂ� dummy pool ������
