AS = HAS060
ASFLAGS = -m 68000
AR = oar

OBJECTS = alloc.o realloc.o large.o free.o enlarge.o shrink.o previous.o dump.o \
		Calloc.o Crealloc.o Cfree.o Cmdump.o

.PHONY : all clean

all : Extmalloc.a

clean :
	-rm -f $(OBJECTS) Extmalloc.a

$(OBJECTS) : %.o : %.s defines.inc
	$(AS) $(ASFLAGS) $<

Extmalloc.a : $(OBJECTS)
	$(AR) $@ $?
