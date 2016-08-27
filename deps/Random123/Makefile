ifeq ($(OS), Windows_NT)
	CC = g++
	SLIB = dll
else
	UNAME := $(shell uname)
	ifeq ($(UNAME), Darwin)
		CC = g++
		SLIB = dylib
	else
		CC = g++
		SLIB = so
	endif
endif

CFLAGS = -shared -fPIC -O3 -maes

OBJ = 	aesni.cpp ars.cpp

all:
	$(CC) $(CFLAGS) $(OBJ) -o librandom123.$(SLIB)

clean:
	rm *.$(SLIB)
