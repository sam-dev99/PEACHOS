#ifndef HEAP_H
#define HEAP_H
#include "config.h"
#include <stdint.h>
#include <stddef.h>

#define HEAP_BLOCK_TABLE_ENTRY_TAKEN 0X01
#define HEAP_BLOCK_TABLE_ENTRY_FREE 0X00

#define HEAP_BLOCK_HAS_NEXT 0b10000000
#define HEAP_BLOCK_IS_FIRST  0b01000000

//8 bits in the entry table as its own type
typedef unsigned char HEAP_BLOCK_TABLE_ENTRY;


struct heap_table{
    //pointer to the entries table
    HEAP_BLOCK_TABLE_ENTRY* entries;
    //total pf all the entries that we have
    size_t total;
};

struct heap{
    struct heap_table* table;
    //start address of the heap;
    void* saddr;
};

int heap_create(struct heap* heap, void* ptr, void* end, struct heap_table* table);
void* heap_malloc(struct heap* heap, size_t size);
void heap_free(struct heap* heap,void* ptr);


#endif