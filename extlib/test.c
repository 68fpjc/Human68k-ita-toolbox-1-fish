static int offset = 0;
static char *buf[100];

main()
{
  int offset, bytes, ret;
  char ch;

  while (1)
    {
      printf("a(lloc),r(ealloc),f(ree),d(ump) ");
      do
	scanf("%c", &ch);
      while (ch == '\n');
      switch (ch)
	{
	case 'a':
	case 'A':
	  for (offset = 0; offset < 100; offset++)
	    if (buf[offset] == 0)
	      break;
	  if (offset == 100)
	    {
	      printf("����ȏ�m�ۂ͏o���܂���B\n");
	      continue;
	    }
	  printf("���o�C�g�m�ۂ��܂����H ");
	  scanf("%d", &bytes);
	  ret = malloc(bytes);
	  printf("���^�[���R�[�h %8X\n", ret);
	  if (ret > 0)
	    buf[offset] = ret;
	  break;

	case 'r':
	case 'R':
	  printf("���Ԃ����T�C�Y���܂����H ");
	  scanf("%d", &offset);
	  printf("���o�C�g�m�ۂ��܂����H ");
	  scanf("%d", &bytes);
	  if (0 <= offset && offset < 100 && buf[offset])
	    {
	      ret = realloc(buf[offset], bytes);
	      printf("���^�[���R�[�h %8X\n", ret);
	      if (ret > 0)
		buf[offset] = ret;
	    }
	  break;

	case 'f':
	case 'F':
	  printf("���Ԃ��J�����܂����H ");
	  scanf("%d", &offset);
	  if (0 <= offset && offset < 100 && buf[offset])
	    printf("���^�[���R�[�h %8X\n", free(buf[offset]));
	  buf[offset] = 0;
	  break;

	case 'd':
	case 'D':
	  for (offset = 0; offset < 100; offset++)
	    if (buf[offset])
	      printf("%2d %8X\n", offset, buf[offset]);
	  debug_mdump();
	  break;
	}
    }
}
