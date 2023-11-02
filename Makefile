OUT = bootsec.bin
AS = nasm
FLAGS = -o $@

$(OUT): bootsec.s
	$(AS) $(FLAGS) $<

clean:
	rm -f $(OUT)
