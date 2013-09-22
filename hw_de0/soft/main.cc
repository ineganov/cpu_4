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

const char digits[] = { 0x3E, 0x51, 0x49, 0x45, 0x3E,  0,0,0,
                        0x00, 0x42, 0x7F, 0x40, 0x00,  0,0,0,
                        0x42, 0x61, 0x51, 0x49, 0x46,  0,0,0,
                        0x21, 0x41, 0x45, 0x4B, 0x31,  0,0,0,
                        0x18, 0x14, 0x12, 0x7F, 0x10,  0,0,0,
                        0x27, 0x45, 0x45, 0x45, 0x39,  0,0,0,
                        0x3C, 0x4A, 0x49, 0x49, 0x30,  0,0,0,
                        0x01, 0x71, 0x09, 0x05, 0x03,  0,0,0,
                        0x36, 0x49, 0x49, 0x49, 0x36,  0,0,0,
                        0x06, 0x49, 0x49, 0x29, 0x1E,  0,0,0  };


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
   *HP_SREG = 0x7F;
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
void print_dec(unsigned int a, unsigned int num_symbols = 4)
{  char dd[20];
   if(num_symbols > 19) num_symbols = 19;


   for(int i = num_symbols - 1; i >= 0; --i)
   {  dd[i] = (a % 10) + 0x30; a /= 10;  }

   dd[num_symbols] = 0;

   print_str(dd);
   return; }
//---------------------------------------------------------------------------------//
void hp_int(int a)
{  char dd[4];

   for(int i = 3; i >= 0; --i)
   {  dd[i] = (a % 10); a /= 10;  }

   *HP_CTRL = HP_CE;
   for(int i = 0; i < 4; ++i)
   {  for(int j = 0; j < 5; ++j)
      {  *HP_SREG = digits[8*dd[i]+j];
         while(*HP_SREG) {} } }
   *HP_CTRL = 0;
   
   return; }
//---------------------------------------------------------------------------------//
int main()
{  *LEDS = 0x00;
   *UART_SPD = 54; //921600
   *UART_PAR = 1;
   usleep(50000);

   print_str("Hello.\n");


   print_dec(1234, 8);



   hp_init();
/*  
   for(int i = 0; i < 10000; ++i) 
   {  hp_int(i);
      usleep(50000); }

   usleep(1000000);

   for(int i = 0; i < 10; ++i)
   {  usleep(700000);
      hp_letter(&digits[8*i]); }
*/

   while(1) 
   {  int gx = *GYRO_X;
      int gy = *GYRO_Y;
      int gz = *GYRO_Z;
      print_str("> ");

      if(gx < 0) {print_str("-"); print_dec(-gx, 6); }
      else       {print_str("+"); print_dec( gx, 6); }
      print_str(", ");
      if(gy < 0) {print_str("-"); print_dec(-gy, 6); }
      else       {print_str("+"); print_dec( gy, 6); }
      print_str(", ");
      if(gz < 0) {print_str("-"); print_dec(-gz, 6); }
      else       {print_str("+"); print_dec( gz, 6); }
      print_str("\n");
      usleep(100000);  };

   return 0; }
