CC = gcc
CFLAGS = -Wall -m64

all: main.o juliaset.o
	$(CC) $(CFLAGS) -o result main.o juliaset.o `allegro-config --shared`

juliaset.o: juliaset.s
	nasm -f elf64 -o juliaset.o juliaset.s

main.o: main.c juliaset.h
	$(CC) $(CFLAGS) -c -o main.o main.c

clean:
	rm -f *.o

