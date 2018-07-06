.PHONY: clean

all: ammc.exe ammc-opencl.exe

clean:
	rm -rf *~ *.c ammc *.exe

%.exe: %.fut
	futhark-c -o $@ $<

%-opencl.exe: %.fut
	futhark-opencl -o $@ $<
