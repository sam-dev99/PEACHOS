#ifndef IO_H
#define IO_H

//input
unsigned char insb(unsigned short port);
unsigned short insw(unsigned short port);

//output 1 byte to the port
void outb(unsigned short port, unsigned char val);

//output 2 byte to the port
void outw(unsigned short port, unsigned short val);


#endif