.PHONY: clean

all: ammc.exe ammc-opencl.exe

clean:
	rm -rf *~ *.c ammc *.exe

%.exe: %.fut
	futhark-c -o $@ $<

%-opencl.exe: %.fut
	futhark-opencl -o $@ $<

.PHONY: sync
sync:
	futhark-pkg sync

.PHONY: sync
realclean: clean
	rm -rf lib
