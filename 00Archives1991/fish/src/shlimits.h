MAXWORDLEN	equ	512		*  12�ȏ� MAXPATH�ȏ� 32767�ȉ�  csh��1024
MAXWORDLISTSIZE	equ	4096		*  MAXWORDLEN�ȏ� (32767-6)/2=16380�ȉ�  UNIX��10240
MAXLINELEN	equ	MAXWORDLISTSIZE	*  ��������ƍs�ƈ������тƂ̈ꎞ�̈�����p�ł���킯
MAXWORDS	equ	1024		*  32766�ȉ�
MAXSEARCHLEN	equ	31		*  ��������������̍ő咷
MAXSUBSTLEN	equ	63		*  ����u��������̍ő咷
MAXALIASLOOP	equ	20		*  �ʖ����[�v�̍Ő[  0�ȏ�65535�ȉ�  csh��20
