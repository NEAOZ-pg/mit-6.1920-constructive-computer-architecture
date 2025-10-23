#include "src/defines.h"
.section ".text.init"
    .globl sort
    .globl kth_smallest
    .globl violation

/*

QUICKSORT & PARTITION

C implementation (for reference)

int partition(int* p, int start, int end) {
    int x = p[end]; // select pivot
    int j, tmp, i = start - 1;
    for (j = start; j < end; j++) {
        if (p[j] <= x) {
            i++;
            tmp = p[i];
            p[i] = p[j];
            p[j] = tmp;
        }
    }
    tmp = p[i + 1];
    p[i + 1] = p[end];
    p[end] = tmp;
    return i + 1;
}

void quicksort(int* p, int start, int end) {
    if (start < end) {
        int q = partition(p, start, end);
        quicksort(p, start, q - 1);
        quicksort(p, q + 1, end);
    }
}

Python implementation (for reference)

def partition(p, start, end):
    x = p[end]
    i = (start - 1)
    for j in range(start, end):
        if p[j] <= x:
            i = i + 1
            tmp = p[i]
            p[i] = p[j]
            p[j] = tmp

    tmp = p[i + 1]
    p[i + 1] = p[end]
    p[end] = tmp
    return i + 1

def quicksort(p, start, end):
    if start < end:
        q = partition(p, start, end)
        quicksort(p, start, q - 1)
        quicksort(p, q + 1, end)

*/

//  QUICKSORT (should call "partition")
//
//  Inputs:
//  a0 = p (address of array)
//  a1 = start
//  a2 = end

sort:
  bge a1, a2, end // if start >= end --> end
  addi sp, sp, -16
  sw a0, 0(sp)  // save p
  sw a1, 4(sp) // save start
  sw a2, 8(sp) // save end
  sw ra, 12(sp) // save ra
  call partition
  mv a3, a0
  lw a0, 0(sp)
  lw a1, 4(sp)
  lw a2, 8(sp)
  lw ra, 12(sp)
  addi sp, sp, 16
  addi sp, sp, -20
  sw a0, 0(sp)
  sw a1, 4(sp)
  sw a2, 8(sp)
  sw a3, 12(sp)
  sw ra, 16(sp)
  addi a4, a3, -1
  mv a2, a4
  call sort
  lw a0, 0(sp)
  lw a1, 4(sp)
  lw a2, 8(sp)    
  lw a3, 12(sp) 
  addi a4, a3, 1
  mv a1, a4
  call sort
  lw a0, 0(sp)
  lw a1, 4(sp)
  lw a2, 8(sp)    
  lw a3, 12(sp) 
  lw ra, 16(sp)
  addi sp, sp, 20
  end:
  ret


// PARTITION
//
// Inputs:           
// a0 = starting address of the array
// a1 = index of the starting element
// a2 = index of the ending element

partition:
  slli a3, a2, 2
  add a3, a3, a0
  lw a3, 0(a3)
  mv a4, a1 // j = start
  addi a6, a1, -1
  for:
    bge a4, a2, done
    slli t0, a4, 2
    add t0, a0, t0
    lw a7, 0(t0)
    if:
      bgt a7, a3, else
      addi a6, a6, 1
      slli t1, a6, 2
      add t1, a0, t1
      lw a5, 0(t1)
      sw a5, 0(t0)
      sw a7, 0(t1)
    else:
    addi a4, a4, 1
    blt a4, a2, for
  done:
    addi a6, a6, 1
    slli a5, a6, 2
    add a5, a0, a5
    lw a4, 0(a5)
    slli a3, a2, 2
    add a3, a0, a3
    lw a7, 0(a3)
    sw a7, 0(a5)
    sw a4, 0(a3)
    mv a0, a6
    ret



/*

Kth SMALLEST

Python implementation (for reference)

# array is the sorted array from sort
# gets index k from the user and prints array[k]
# returns nothing

def kth_smallest(array):
    x = input("enter the index to print\n")
    print array[x]
    return

*/

//  Input:  a0 = address of sorted array
kth_smallest:
  li t0, 0x40004000
  lw a1, 0(t0)
  slli a1, a1, 2
  add a1, a1, a0
  lw a2, 0(a1)
  li t0, 0x40000004
  sw a2, 0(t0) 
  ret
