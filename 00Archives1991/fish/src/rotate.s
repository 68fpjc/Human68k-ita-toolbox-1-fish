* rotate.s
* Itagaki Fumihiko 16-Jul-90  Create.

.text

****************************************************************
* rotate - �z������񂷂�
*
* CALL
*      A0     ���񂳂���z��̐擪�A�h���X
*      A1     �����擪�ƂȂ�v�f�̃A�h���X
*      A2     ���񂳂���z��̍ŏI�A�h���X�{�P
*
* RETURN
*      �Ȃ�
*****************************************************************
.xdef rotate

rotate:
		bsr	reverse			* �O���𔽓]����
		exg	a0,a1
		exg	a1,a2
		bsr	reverse			* �㔼�𔽓]����
		exg	a0,a2
		bsr	reverse			* �S�̂𔽓]����
						* ����őO���ƌ㔼������ւ��̂��I
		exg	a1,a2
		rts

.end
