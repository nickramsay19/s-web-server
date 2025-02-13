CC := gcc
CCFLAGS := -ansi
AS := as
ASFLAGS := 

all: bin/main

bin/main: build/main.o build/web.o
	@mkdir -p bin
	@#ld -o $@ $^
	$(CC) $(CCFLAGS) -o $@ $^

build/main.o: src/main.c
	@mkdir -p build
	$(CC) $(CCFLAGS) -o $@ -c $^

build/web.o: src/web.s
	@mkdir -p build
	$(AS) -o $@ $^

.PHONY: clean
clean:
	@rm -f bin/main
	@rm -f build/main.o
	@rm -f build/web.o
	rm -fd bin
	rm -fd build

