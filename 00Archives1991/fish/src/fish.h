STACKSIZE	equ	4096-240	*  �X�^�b�N�̑傫��

DSTACKSIZE	equ	1024		*  �f�B���N�g���E�X�^�b�N�̃f�t�H���g�̑傫��
SHELLVARSIZE	equ	1024		*  �V�F���ϐ���Ԃ̃f�t�H���g�̑傫��
ALIASSIZE	equ	512		*  �ʖ���Ԃ̃f�t�H���g�̑傫��

MAXWORDLEN	equ	512		*  12�ȏ� MAXPATH�ȏ� 32767�ȉ�  csh��1024
MAXWORDLISTSIZE	equ	4096		*  MAXWORDLEN�ȏ� (32767-6)/2=16380�ȉ�  UNIX��10240
MAXLINELEN	equ	MAXWORDLISTSIZE	*  ��������ƍs�ƈ������тƂ̈ꎞ�̈�����p�ł���킯
MAXWORDS	equ	1024		*  32766�ȉ�
MAXSEARCHLEN	equ	31		*  ��������������̍ő咷
MAXSUBSTLEN	equ	63		*  ����u��������̍ő咷
MAXALIASLOOP	equ	20		*  �ʖ����[�v�̍Ő[  0�ȏ�65535�ȉ�  csh��20

MAXFILES = 1400				* maximum file directory entry
DIRWORK = (MAXFILES+1)*32		* maximum file directory work size
FNAMELEN = 18				* maximum file name length
EXTLEN = 3				* maximum file extension length
NAMEBUF = 24				* file name work size
DOSVER2 = $100*1+74			* os version 2.00 number
DOSVER3 = $100*2+50			* os version 3.00 number
