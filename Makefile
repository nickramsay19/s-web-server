CC := gcc
CCFLAGS := 
AS := as
ASFLAGS := 

all: bin/main

debug: bin/debug

bin/debug: build/debug.o build/web.o
	@mkdir -p bin
	@#ld -o $@ $^
	$(CC) $(CCFLAGS) -o $@ $^

bin/main: build/crt0.o build/main.o build/web.o
	@mkdir -p bin
	ld -o $@ $^

build/%.o: src/%.c
	@mkdir -p build
	$(CC) $(CCFLAGS) -o $@ -c $^

build/%.o: src/%.s
	@mkdir -p build
	$(AS) -o $@ $^

#build/main.o: src/main.c
#	@mkdir -p build
#	$(CC) $(CCFLAGS) -o $@ -c $^

#build/web.o: src/web.s
#	@mkdir -p build
#	$(AS) -o $@ $^

.PHONY: clean
clean:
	@rm -f bin/main bin/debug
	@rm -f build/*.o
	rm -fd bin
	rm -fd build

