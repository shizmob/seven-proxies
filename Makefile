CROSS_COMPILE =
CC = gcc
CC := $(CROSS_COMPILE)$(CC)
CFLAGS = $(EXTRACFLAGS)
CPPFLAGS = $(EXTRACPPFLAGS)
LDFLAGS = -Wl,--enable-stdcall-fixup $(EXTRALDFLAGS)
OBJDUMP = objdump
OBJDUMP := $(CROSS_COMPILE)$(OBJDUMP)

EXTRASYMS = DllMain
ORIGPREFIX =
ORIGSUFFIX = -orig


.SUFFIXES:
.SECONDARY:
.PHONY: help clean

help:
	@echo "targets:"
	@echo "  clean     -- clean build output"
	@echo "  *.c       -- make template file for *.dll"
	@echo "  *.dll     -- build proxy DLL for $(ORIGPREFIX)*$(ORIGSUFFIX).dll from *.c"

clean:
	rm -f *.def *.o $$(ls -1 *.dll | grep -v -- '^$(ORIGPREFIX).*$(ORIGSUFFIX).dll$$')

%.dll: %.o %.def
	$(CC) $(LDFLAGS) -shared $^ -o $@

%.def: $(ORIGPREFIX)%$(ORIGSUFFIX).dll
	OBJDUMP="$(OBJDUMP)" ./.gen-def.sh -r $< $< $(EXTRASYMS) > $@

%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

%.c: .template
	cp $< $@
