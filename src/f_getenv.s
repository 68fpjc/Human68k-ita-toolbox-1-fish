* f_getenv.s
* Itagaki Fumihiko 18-Aug-91  Create.

.xref getenv

.xref envwork

.text

****************************************************************
* fish_getenv - FISH �̊��ϐ��u���b�N���疼�O�ŕϐ���T��
*
* CALL
*      A0     ��������ϐ����̐擪�A�h���X
*
* RETURN
*      A0     ���������Ȃ�Ί��u���b�N�̕ϐ����̐擪���w��
*      D0.L   ���������Ȃ�Βl�̕�����̐擪�A�h���X���w��
*             ������Ȃ���� 0
*      CCR    TST.L D0
*****************************************************************
.xdef fish_getenv

fish_getenv:
		move.l	a3,-(a7)
		movea.l	envwork(a5),a3
		bsr	getenv
		movea.l	(a7)+,a3
		rts

.end
