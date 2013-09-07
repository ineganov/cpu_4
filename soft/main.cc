#include "ioaddr.h"
#include "std_io.h"

extern "C" int main();
extern "C" void delay( int );
extern "C" void interrupt(int, int, int *);

inline void _break() { asm( "break" ); }

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
void sdcard_reset() // Sets clock, resets controller status, sends CMD0 and waits 1ms
{  *SD_CLOCK  = 1; //Set 12.5MHz Clock
   *SD_STATUS = 0; //Reset status bits and clear fifo
   *SD_ARG = 0;
   *SD_CMD = 0; // CRC check disabled, wait-response disabled
   usleep(1000);
   return;  }
//---------------------------------------------------------------------------------//
int sdcard_cmd(int cmd, int arg, int en_crc = 1, int long_resp = 0, int en_resp = 1) 
{  *SD_ARG = arg;
   *SD_CMD = ( en_crc    << 10 ) |
             ( long_resp << 9  ) |
             ( en_resp   << 8  ) |
             ( cmd & 0x3F      ) ;
   while(*SD_STATUS & 1) {} //Wait for the answer. Timeout is handled in HW
   return *SD_RESP_S;   }   //Return short response
//---------------------------------------------------------------------------------//
void sdcard_read(int block, int rca)
{  sdcard_cmd(18, block);
   *SD_DAT_CONF = 1; //DAT_WREN = 0; //DAT_ACT = 1;

   unsigned int buf[256];

   for(int i = 0; i < 256; ++i)
   {  while(1 & (*SD_STATUS >> 2)) {} //wait while fifo is empty
      buf[i] = *SD_FIFO;  }           //Read word

   *SD_DAT_CONF = 0;  // DAT_ACT = 0; Disables the receiver.
   sdcard_cmd(12, 0); // Send "stop transmission" command

   for(int i = 0; i < 256; ++i)
   {  print_str(">> "); 
      print_hex32(buf[i]);
      print_str("\n"); } 

   return; }
//---------------------------------------------------------------------------------//
void sdcard_write(int block, int rca)
{  sdcard_cmd(25, block);
   *SD_DAT_CONF = 3; //DAT_WREN = 1; //DAT_ACT = 1;

   for(int i = 0; i < 128*16; ++i)
   {  while(1 & (*SD_STATUS >> 3)) {} //Wait while fifo is full
      *SD_FIFO = 0xAA550000 | i;  }   //Write word

   while(1 & (*SD_STATUS >> 1)) {} //Wait while the last word is transmitted

   *SD_DAT_CONF = 0;  // DAT_ACT = 0; Disables the transmitter
   sdcard_cmd(12, 0); // Send "stop transmission" command

   return; }
//---------------------------------------------------------------------------------//
int main()
{  print_str("\nHello.\n");

   sdcard_reset();

   int r;
   print_str("CMD8 Response: ");
   r = sdcard_cmd(8, 0x000001AA);
   print_hex32(r); print_str("\n");

   print_str("Checking voltage: ");
   sdcard_cmd(55, 0);
   r = sdcard_cmd(41, 0x40FF8000, 0); //no CRC for acmd41
   print_hex32(r); print_str("\n");

   print_str("Controller status: ");
   print_hex32(*SD_STATUS); print_str("\n");

   int s = 0;
   print_str("Entering init...");
   for(int i = 0; i < 100; ++i)
   {  sdcard_cmd(55, 0);
      r = sdcard_cmd(41, 0x40FF8000, 0);
      if(r & 0x80000000) {s = 1; break;}      
      usleep(10000); }

   if(s) print_str("OK.\n");
   else  print_str("FAIL.\n");

   sdcard_cmd(2, 0, 0, 1, 1); //no CRC, Long response
   unsigned int r0 = *SD_RESP_1;
   unsigned int r1 = *SD_RESP_2;
   unsigned int r2 = *SD_RESP_3;
   unsigned int r3 = *SD_RESP_4;

   print_str("CID R0: "); print_hex32(r0); print_str("\n");
   print_str("CID R1: "); print_hex32(r1); print_str("\n");
   print_str("CID R2: "); print_hex32(r2); print_str("\n");
   print_str("CID R3: "); print_hex32(r3); print_str("\n");

   int rca = sdcard_cmd(3, 0) & 0xFFFF0000;
   print_str("RCA: ");
   print_hex32(rca); print_str("\n");

   sdcard_cmd( 7, rca); // Go to transfer mode
   sdcard_cmd(16, 512); // Set block size
   sdcard_cmd(55, rca);
   sdcard_cmd( 6, 2);   //set 4-bit bus

   sdcard_write(0, rca);
//   sdcard_read(0, rca);


   *SEGS = *SD_STATUS;


   int l = 0x8000;
   while(1) 
   { *LEDS = l;
     l ^= 0x8000;
     usleep(1000000); }


   return 0; }
