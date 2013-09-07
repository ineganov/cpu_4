#include "ioaddr.h"
#include "std_io.h"

extern "C" int main();
extern "C" void delay( int );
extern "C" void interrupt(int, int, int *);

inline void _break() { asm( "break" ); }

const char l_a[] = {0x77, 0x0C, 0x7F, 0x0C, 0x77};
const char l_b[] = {0x3E, 0x41, 0x41, 0x41, 0x3E};
const char l_c[] = {0x7F, 0x01, 0x01, 0x01, 0x7F};
const char l_d[] = {0x7E, 0x09, 0x09, 0x09, 0x7E};

const char l_e[] = {0x00, 0x00, 0x00, 0x00, 0x00};

const char l_ss[] = {0x3E, 0x41, 0x41, 0x41, 0x41};
const char l_ch[] = {0x0F, 0x10, 0x10, 0x10, 0x7F};
const char l_aa[] = {0x7E, 0x09, 0x09, 0x09, 0x7E};
const char l_tt[] = {0x01, 0x01, 0x7F, 0x01, 0x01};
const char l_ii[] = {0x7F, 0x48, 0x48, 0x48, 0x30};
const char l_ee[] = {0x7F, 0x49, 0x49, 0x49, 0x41};

const char digits[] = { 0x3E, 0x41, 0x41, 0x41, 0x3E, 0x00, 0x00, 0x00,     // 0
                        0x00, 0x00, 0x02, 0x7F, 0x00, 0x00, 0x00, 0x00,     // 1
                        0x31, 0x49, 0x49, 0x49, 0x46, 0x00, 0x00, 0x00,     // 2
                        0x49, 0x49, 0x49, 0x49, 0x3E, 0x00, 0x00, 0x00,     // 3
                        0x0F, 0x08, 0x08, 0x08, 0x7F, 0x00, 0x00, 0x00,     // 4
                        0x46, 0x49, 0x49, 0x49, 0x31, 0x00, 0x00, 0x00,     // 5
                        0x3E, 0x49, 0x49, 0x49, 0x30, 0x00, 0x00, 0x00,     // 6
                        0x01, 0x41, 0x21, 0x11, 0x0F, 0x00, 0x00, 0x00,     // 7
                        0x36, 0x49, 0x49, 0x49, 0x36, 0x00, 0x00, 0x00,     // 8
                        0x06, 0x49, 0x49, 0x49, 0x3E, 0x00, 0x00, 0x00  };  // 9

//---------------------------------------------------------------------------------//
void interrupt(int epc, int cause, int * state)
{  print_str("Hello from an interrupt\n");

   cause = 0x1F & (cause >> 2);
   print_str("EPC:   "); print_hex32(epc);   print_str("\n");
   print_str("Cause: "); print_hex32(cause); print_str("\n\n");

   print_str("at: "); print_hex32( state[28] ); print_str("\n");
   print_str("v0: "); print_hex32( state[27] ); print_str("\n");
   print_str("v1: "); print_hex32( state[26] ); print_str("\n");
   print_str("a0: "); print_hex32( state[25] ); print_str("\n");
   print_str("a1: "); print_hex32( state[24] ); print_str("\n");
   print_str("a2: "); print_hex32( state[23] ); print_str("\n");
   print_str("a3: "); print_hex32( state[22] ); print_str("\n");
   print_str("t0: "); print_hex32( state[21] ); print_str("\n");
   print_str("t1: "); print_hex32( state[20] ); print_str("\n");
   print_str("t2: "); print_hex32( state[19] ); print_str("\n");
   print_str("t3: "); print_hex32( state[18] ); print_str("\n");
   print_str("t4: "); print_hex32( state[17] ); print_str("\n");
   print_str("t5: "); print_hex32( state[16] ); print_str("\n");
   print_str("t6: "); print_hex32( state[15] ); print_str("\n");
   print_str("t7: "); print_hex32( state[14] ); print_str("\n");
   print_str("s0: "); print_hex32( state[13] ); print_str("\n");
   print_str("s1: "); print_hex32( state[12] ); print_str("\n");
   print_str("s2: "); print_hex32( state[11] ); print_str("\n");
   print_str("s3: "); print_hex32( state[10] ); print_str("\n");
   print_str("s4: "); print_hex32( state[9]  ); print_str("\n");
   print_str("s5: "); print_hex32( state[8]  ); print_str("\n");
   print_str("s6: "); print_hex32( state[7]  ); print_str("\n");
   print_str("s7: "); print_hex32( state[6]  ); print_str("\n");
   print_str("t8: "); print_hex32( state[5]  ); print_str("\n");
   print_str("t9: "); print_hex32( state[4]  ); print_str("\n");
   print_str("gp: "); print_hex32( state[3]  ); print_str("\n");
   print_str("sp: "); print_hex32( state[2]  ); print_str("\n");
   print_str("fp: "); print_hex32( state[1]  ); print_str("\n");
   print_str("ra: "); print_hex32( state[0]  ); print_str("\n");

   if(cause == 9) state[30] += 4; //If it was a break, increment EPC

   getch();
   *INT_BTN = 0;
   return; }
//---------------------------------------------------------------------------------//
void wait()
{  asm("nop; nop; nop; nop;");
   return; }
//---------------------------------------------------------------------------------//
void hp_init()
{  *HP_CTRL = HP_RESET;
   usleep(10);
   *HP_CTRL = 0;
   usleep(10);

   *HP_CTRL = HP_RS; wait();
   *HP_CTRL = HP_RS | HP_CE;
   *HP_SREG = 0x6C;
//  *HP_SREG = 0x7F;
   while(*HP_SREG) {}
   *HP_CTRL = 0;
   return;  }
//---------------------------------------------------------------------------------//
void hp_letter(const char * l)
{  *HP_CTRL = HP_CE;
   for(int i = 0; i < 5; ++i)
   {   *HP_SREG = l[i];
      while(*HP_SREG) {} }
   *HP_CTRL = 0;
   usleep(1);
   return;  }
//---------------------------------------------------------------------------------//
void hp_int(unsigned int a)
{  /*int dd[4];

   for(int i = 0; i < 4; ++i)
   {   dd[i] = a % 10; a /= 10; }

   for(int i = 0; i < 4; ++i)
      hp_letter(&digits[8*dd[3 - i]]);
   
   */
   int z = a % 10; a /= 10;
   int y = a % 10;

   hp_letter(&digits[8*y]);
   hp_letter(&digits[8*z]);
   

   return;  }
//---------------------------------------------------------------------------------//
int main()
{  *LEDS = 0x00;

   hp_init();
  
   hp_int(1234);

   for(int i = 0; i < 4; ++i)
   {  usleep(7000000);
      hp_letter(l_e); }


   usleep(700000);
   hp_letter(l_ss);
   usleep(700000);
   hp_letter(l_ch);
   usleep(700000);
   hp_letter(l_aa);
   usleep(700000);
   hp_letter(l_ss);
   usleep(700000);
   hp_letter(l_tt);
   usleep(700000);
   hp_letter(l_ii);
   usleep(700000);
   hp_letter(l_ee);


   while(1) {};

   return 0; }
