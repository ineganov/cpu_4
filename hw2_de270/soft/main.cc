#include "ioaddr.h"
#include "std_io.h"
#include "dm9k.h"

extern "C" int main();
extern "C" void delay( int );

inline void _break() { asm( "break" ); }

//---------------------------------------------------------------------------------//
void silence_test()
{ int fill;
  while(1)
  { fill = *AUD_L;
      if(fill < 100)
        { for(int j = 0; j < 16; ++j)
          { for(int i = 0; i < 32; ++i) { *AUD_L = 0; *AUD_R = 0; }
            for(int i = 0; i < 32; ++i) { *AUD_L = 0; *AUD_R = 0; } } }
      else  
        usleep(1000); }

  return; }
//---------------------------------------------------------------------------------//
void square_wave_test()
{ int fill;
  while(1)
  { fill = *AUD_L;
      if(fill < 100)
        { for(int j = 0; j < 16; ++j)
          { for(int i = 0; i < 32; ++i) { *AUD_L = 0; *AUD_R = 0;               }
            for(int i = 0; i < 32; ++i) { *AUD_L = 0x7FFFFF; *AUD_R = 0x7FFFFF; } } }
      else  
        usleep(1000); }

  return; }
//---------------------------------------------------------------------------------//
void sendRequest()
{ static unsigned short int r[] = 
    { 0x003A, 0x0026, 0x2DF3, 0xD108, 0x1A1B, 0x1C1D, 0x1E1F, 0x0800, 
      0x4500, 0x002C, 0xAAAA, 0x0000, 0x8011, 0x0000, 0x0A64, 0x0002, 
      0x0A64, 0x0001, 0x0600, 0x0600, 0x0018, 0xFFFF, 0x0000, 0x0001, 
      0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0007 };

  static int init = 1;
  if(init)
  { for(int i = 1; i < 30; ++i) r[i] = swab(r[i]);
    init = 0; }

  uploadPacket(r);
  return; }
//---------------------------------------------------------------------------------//
int main()
{  print_str("Hello with a super-ultra-long string, which is larger than thrirty-two bytes!\n");

   dm9k_init();
   int vid = (dm9k_rd_reg(0x29) << 8) | dm9k_rd_reg(0x28);
   int pid = (dm9k_rd_reg(0x2b) << 8) | dm9k_rd_reg(0x2a);
   int rev = dm9k_rd_reg(0x2c);
   *SEGS = (vid << 16) | pid | rev;


 // silence_test();

   int num_packets = 0;
   unsigned short buffer[2048];

   const int ST_OPERATE = 1;
   const int ST_WAIT_FOR_DATA = 2;
   int state = ST_WAIT_FOR_DATA;

   while(1)
      {   if(dm9k_packetReceived())
          {   downloadPacket(buffer);
              num_packets++;
              *SEGS = state; //num_packets;
              if (buffer[7]==swab(0x0800))           //IP PACKET
              { if (((buffer[12] >> 8) == 0x11) &&  //UDP PACKET
                     (buffer[19] == swab(UDP_PORT)))
                     {  state = ST_OPERATE;
                        unsigned short num_samples = buffer[22];
                        unsigned short *dd = &buffer[23];
                        for(int i = 0; i < num_samples; ++i) 
                        { unsigned int al = ((unsigned)dd[i*2]     << 8) & 0x00FFFF00;
                          unsigned int ar = ((unsigned)dd[i*2 + 1] << 8) & 0x00FFFF00;
                          *AUD_L = al;
                          *AUD_R = ar; } }
     
                if (((buffer[12] >> 8) == 0x01         ) &&   //ICMP PACKET
                     (buffer[16] == swab(IP_ADDRESS_HI)) &&   //FOR OUR IP
                     (buffer[17] == swab(IP_ADDRESS_LO)) &&   //FOR OUR IP
                     (buffer[18] == swab(0x0800)       ))     //IS ECHO REQUEST
                     {  state = ST_OPERATE;
                        sendPingReply(buffer); }
                }
              else if (buffer[7] == swab(0x0806))               //ARP PACKET
                { if((buffer[11] == swab(0x0001)) &&            //IT IS A REQUEST
                     (buffer[20] == swab(IP_ADDRESS_HI)) &&     //FOR OUR IP
                     (buffer[21] == swab(IP_ADDRESS_LO)) )      //FOR OUR IP
                      { sendArpReply(buffer);
                        print_str("Our ARP!\n"); }  
                     } }
          if((state == ST_OPERATE) && (*AUD_L < 900))
          { state = ST_WAIT_FOR_DATA;
            sendRequest();  }
      }


   return 0; }


//        print_str("RX: ");
//        for(int i = 1; i <= (buffer[0] >> 1); ++i) print_hex16(swab(buffer[i]));
//        print_str("\n");