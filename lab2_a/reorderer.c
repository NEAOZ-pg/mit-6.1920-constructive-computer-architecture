#include "stdlib.h"
#include "stdio.h"

#define bitset(byte,nbit)   ((byte) |=  (1<<(nbit)))
#define bitclear(byte,nbit) ((byte) &= ~(1<<(nbit)))
#define bitcheck(byte,nbit) ((byte) &   (1<<(nbit)))

int set = 0;

unsigned char emitRequest(unsigned char x) {
    if (bitcheck(set, x)) {
        printf("ERROR the completion buffer reused a nonrecycled token\n"); fflush(stdout);
	exit(1);
    }
    bitset(set,x);
    return 0;
}

unsigned int response(){
    int idx = -1;
    for (int i = 0; i < 1024; i++) {
        int nidx = rand() % 8;
        if (bitcheck(set,nidx)) {
            // printf("Found idx %d", nidx);
            idx = nidx;
            break;
        };
    }
    if (idx == -1) { return idx; }
    bitclear(set, idx);
    return idx;
}
