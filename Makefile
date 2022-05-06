CROSS_COMPILE =
CC = gcc
CC := $(CROSS_COMPILE)$(CC)
CXX = g++
CXX := $(CROSS_COMPILE)$(CXX)
LDFLAGS = -Wl,--enable-stdcall-fixup
OBJDUMP = objdump
OBJDUMP := $(CROSS_COMPILE)$(OBJDUMP)
EXTRASYMS = DllMain


.SUFFIXES:
.SECONDARY:
.PHONY: help clean

help:
	@echo "targets:"
	@echo "  clean     -- clean build output"
	@echo "  *.c       -- make template file for *.dll"
	@echo "  *.dll     -- build proxy DLL for *-orig.dll from *.c"

clean:
	rm -f *.def *.o $$(ls -1 *.dll | grep -v -- '-orig.dll$$')

%.dll: %.o %.def
	$(CC) $(LDFLAGS) -shared $^ -o $@

%.def: %-orig.dll
	OBJDUMP="$(OBJDUMP)" ./.gen-def.sh -r $< $< $(EXTRASYMS) > $@

%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

%.c: .template
	cp $< $@
