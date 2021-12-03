CC=gcc
CFLAGS=-g -Wall -std=c99 -fopenmp -pthread
LDFLAGS=-fopenmp -lm

proj4: main.o stat.o proj4.o
	rm -f proj4.out
	$(CC) $(CFLAGS) main.o stat.o proj4.o -o proj4.out $(LDFLAGS)

main.o: main.c proj4.h
	$(CC) -g -c -o $@ $<

proj4.o: proj4.c proj4.h
	$(CC) -g -c -o $@ $< -lm -fopenmp -pthread
stat.o: stat.c proj4.h
	$(CC) -g -c -o $@ $< -mavx -mfma

clear:
	rm -f *.o
	rm -f proj4.out
