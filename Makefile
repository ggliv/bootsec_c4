OUT = connect_four.bin
AS = nasm
FLAGS = -o $@

$(OUT): connect_four.asm
	$(AS) $(FLAGS) $<

clean:
	rm -f $(OUT)
