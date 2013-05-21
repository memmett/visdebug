visdebug
========

Simple in-situ visualisation/debugging routines for F90.  See
memmett.blogspot.com for a brief description.

To compile zmq.c, you need the ZMQ library.  If you have Ananconda
installed, you have everything you need already:

CFLAGS  += -I$HOME/anaconda/include
LDFLAGS += -I$HOME/anaconda/lib -lzmq

In the example code posted here, the 'dsend' subroutine in debug.f90
uses BoxLib.



