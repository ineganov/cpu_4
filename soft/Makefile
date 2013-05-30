all:
	mips-as -mips32 main.S -o main.o
	mips-ld main.o --section-start .text=0x00000000 -o main
	mips-objdump -S -C -Dz --section=.text main > program-listing.txt
	cat program-listing.txt | grep -P "^\s*[\d|abcdef]+:" | cut -f 2 > program.txt
