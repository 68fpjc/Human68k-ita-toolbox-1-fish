REQUIRED_OSVER	equ	$200			*  2.00�ȍ~

EXTMALLOC	equ	1			*  0 = DOS MALLOC,  1 = Ext�� MALLOC

STACKSIZE	equ	4096			*  �X�^�b�N�̑傫��
MINENVSIZE	equ	256			*  �ŏ����T�C�Y

DSTACKSIZE	equ	512			*  �f�B���N�g���E�X�^�b�N�̑傫��
ALIASSIZE	equ	2048			*  �ʖ���Ԃ̑傫��
SHELLVARSIZE	equ	2048			*  �V�F���ϐ���Ԃ̑傫��
KMACROSIZE	equ	1024			*  �L�[�E�}�N����Ԃ̑傫��

MAXWORDLISTSIZE	equ	4096			*  MAXWORDLEN+1�ȏ� (32767-14)/2=16376�ȉ�  UNIX��10240
MAXLINELEN	equ	MAXWORDLISTSIZE		*  ��������ƍs�ƈ������тƂ̈ꎞ�̈�����p�ł���킯
MAXWORDS	equ	MAXWORDLISTSIZE/2	*  32766�ȉ�  csh�� 10240/6
MAXWORDLEN	equ	1024			*  12�ȏ� MAXPATH�ȏ� 32766�ȉ� MAXWORDLISTSIZE-1�ȉ�  csh��1024
MAXSEARCHLEN	equ	31			*  ��������������̗L���擪�������i�܂��͍ő啶�����j
MAXSUBSTLEN	equ	63			*  ����u��������̍ő啶����
MAXALIASLOOP	equ	20			*  �ʖ����[�v�̍ő��  0�ȏ�65535�ȉ�  csh��20
MAXIFLEVEL	equ	65535			*  if �̃l�X�g�̍Ő[���x��  0�ȏ�65535�ȉ�  csh�͖������H
MAXLOOPLEVEL	equ	31			*  while/foreach �̃l�X�g�̍ő��  0�ȏ�65535�ȉ�  csh�͖������H
MAXSWITCHLEVEL	equ	65535			*  switch �̃l�X�g�̍Ő[  0�ȏ�65535�ȉ�  csh�͖������H
MAXLABELLEN	equ	31			*  goto/onintr���x���̗L���擪������
MAXFUNCNAMELEN	equ	31			*  �֐����̍ő咷

RND_POOLSIZE	equ	61			*  �����v�[���T�C�Y
