CC=gcc
LIBS=-lm
CFLAGS=-std=c11 -pedantic -Wall 
FILES=raytrace.c

.PHONY: all

all: raytrace

raytrace: $(FILES) ; $(CC) -o $@ $(CFLAGS) $(FILES) $(LIBS)


cuda: ray_cuda.cu ; nvcc -o ray_cuda ray_cuda.cu


.PHONY: clean

clean: ; rm raytrace
