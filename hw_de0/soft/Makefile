CCOPTS =  -O2 -G0 -c -nostartfiles -fstack-usage -Wstack-usage=1024 -std=c++11 
CCOPTS += -fno-strict-aliasing -fno-exceptions -fno-rtti
#CCOPTS += -flto -fdata-sections -ffunction-sections -fno-threadsafe-statics

#LDOPTS = -O2 -nostdlib -nostartfiles -flto -fwhole-program


all:
	mips-as -mips32 -o startup.o startup.S
	mipsgcc $(CCOPTS) -o main.o main.cc
	mipsgcc $(CCOPTS) -o std_io.o std_io.cc
	mips-ld -o main -T ld.script startup.o main.o std_io.o 
	mips-objdump -S -C -Dz --section=.text main > program-listing.txt
	cat program-listing.txt | grep -P "^\s*[\d|abcdef]+:" | cut -f 2 > program.txt

clean:   
	rm '*.o'
	rm main
	rm program_objdump.txt
	rm program.txt
