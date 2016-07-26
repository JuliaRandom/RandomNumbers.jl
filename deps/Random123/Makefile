ifeq ($(OS), Windows_NT)
	CC = gcc
	SLIB = dll
else
	UNAME := $(shell uname)
	ifeq ($(UNAME), Darwin)
		CC = gcc
		SLIB = dylib
	else
		CC = cc
		SLIB = so
	endif
endif
CFLAGS = -std=c99 -shared -fPIC -O3 -maes


OBJ = 	aesni.c

all:
	$(CC) $(CFLAGS) $(OBJ) -o librandom123.$(SLIB)

clean:
	rm *.$(SLIB)
