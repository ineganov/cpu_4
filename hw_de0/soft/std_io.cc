#include "std_io.h"
#include "ioaddr.h"

extern "C" void delay(int);

//--------------------------------------------------------------------//
void usleep(int useconds)
{ delay(useconds*10);
  return; }
//--------------------------------------------------------------------//
void print_str(const char * str)
{ int free_space = 31 - (0xFF & *UTX_S);

  for(int i = 0; i < free_space; ++i)
  { if(str[i]) *UTX_D = str[i];
    else return; }

  //we can choose to just wait 
  //usleep(1000000);
  //or wait for a specific condition, say if the buffer is half-full:
  while((0xFF & *UTX_S) > 15) {}

  print_str(str + free_space); }
//--------------------------------------------------------------------//
int getch()
{  while(1)
   { if(*URX_S < 0) return *URX_D; } }
//--------------------------------------------------------------------//
void print_hex32(int a)
{ char symbols[10];
  symbols[8] = ' ';
  symbols[9] = '\0';

  for(int i = 0; i < 8; ++i)
  { unsigned char c = ((a >> 28) & 0xF);
    if (c < 10) c += '0';
    else    c += 'A' - 10;
    symbols[i] = c;
    a <<= 4;
  }   
  print_str(symbols);
  return; }
//--------------------------------------------------------------------//
void print_hex16(int a)
{ char symbols[6];
  symbols[4] = ' ';
  symbols[5] = '\0';

  for(int i = 0; i < 4; ++i)
  { unsigned char c = ((a >> 12) & 0xF);
    if (c < 10) c += '0';
    else    c += 'A' - 10;
    symbols[i] = c;
    a <<= 4;
  }   
  print_str(symbols);
  return; }
//--------------------------------------------------------------------//
/* UART READ:

  int num_ch = 0;
  char buf[128];
  while(1)
  { int char_count = 0xFFFF & (*UART_RX >> 16);
    for(int i = 0; i < char_count; i++)
    { int ch = 0xFF & *UART_RX;
      *UART_RX = 0;
      
      //*DEV_UART_TX = ch; 
      buf[num_ch] = ch;
      num_ch++;
      if(num_ch >= 32) 
      { num_ch = 0;
        for(int j = 0; j < 32; j++) 
        { *UART_TX = buf[j];
          usleep(100000); }
        print_str("\n"); }
        
    }
    usleep(10000); } */
//--------------------------------------------------------------------//
