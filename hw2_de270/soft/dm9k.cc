#include "dm9k.h"
#include "ioaddr.h"
#include "std_io.h"

extern "C" void sdma_read(unsigned short * buffer, unsigned int num_words);
extern "C" void sdma_write(unsigned short * buffer, unsigned int num_words);

//--------------------------------------------------------------------//
unsigned short swab(unsigned short a)
{ int t = a >> 8;
  return (a << 8) | t; }
//--------------------------------------------------------------------//
void dm9k_reset()
{ *DM9K = 0x00080000;
  usleep(30000); //reset pulse should be no less than 20ms
  *DM9K = 0x00000000; 
  usleep(1000);
  return; }
//--------------------------------------------------------------------//
void dm9k_wr_reg(int reg, int data)
{ *DM9K = 0x01100000 | (reg  & 0xFF); //write IDX port
  asm("nop; nop; nop;");
  *DM9K = 0x01110000 | (data & 0xFF); //write DATA port
  asm("nop; nop; nop;");
  return; }
//--------------------------------------------------------------------//
unsigned short dm9k_rd_reg(int reg)
{ *DM9K = 0x01100000 | (reg & 0xFF); //write IDX port
  asm("nop; nop; nop;");
  *DM9K = 0x01010000; //read DATA port
  asm("nop; nop; nop;");
  return 0xFFFF & *DM9K; }
//--------------------------------------------------------------------//
unsigned short dm9k_rd_dta()
{ *DM9K = 0x01010000; //read DATA port
  asm("nop; nop; nop;");
  return 0xFFFF & *DM9K; }
//--------------------------------------------------------------------//
void dm9k_wr_dta(unsigned short data)
{ *DM9K = 0x01110000 | data; //write DATA port
  asm("nop; nop; nop;");
  return; }
//--------------------------------------------------------------------//
unsigned short dm9k_rd_idx()
{ *DM9K = 0x01000000; //read INDEX port
  asm("nop; nop; nop;");
  return 0xFFFF & *DM9K; }
//--------------------------------------------------------------------//
void dm9k_wr_idx(unsigned short data)
{ *DM9K = 0x01100000 | data; //write INDEX port
  asm("nop; nop; nop;");
  return; }
//--------------------------------------------------------------------//
void dm9k_init()
{ dm9k_reset();

  dm9k_wr_reg(0x10, MAC_ADDRESS_HI >> 8  ); //MAC ADDRESS
  dm9k_wr_reg(0x11, MAC_ADDRESS_HI & 0xFF); //MAC ADDRESS
  dm9k_wr_reg(0x12, MAC_ADDRESS_MI >> 8  ); //MAC ADDRESS
  dm9k_wr_reg(0x13, MAC_ADDRESS_MI & 0xFF); //MAC ADDRESS
  dm9k_wr_reg(0x14, MAC_ADDRESS_LO >> 8  ); //MAC ADDRESS
  dm9k_wr_reg(0x15, MAC_ADDRESS_LO & 0xFF); //MAC ADDRESS

  dm9k_wr_reg(0xFF, 0x83); //Enable pointer auto-return 
                           //Enable packet tx&rx interrupts

  dm9k_wr_reg(0x31, 0x05); //Enable UDP and IP checksum

  dm9k_wr_reg(0x05, 0x3B); //Enable receiver
                           //discard long or broken packets
                           //but receive all valid packet (promiscous)

  dm9k_wr_reg(0xFE, 0xFF); //Clear interrupts

  dm9k_wr_reg(0x1F, 0x00); //power up phy
  return; }
//--------------------------------------------------------------------//
int dm9k_packetReceived()
  { int int_status = dm9k_rd_reg(0xFE);
    if(int_status & 0x01) //rx interrupt
    { dm9k_wr_reg(0xFE, (int_status | 0x01)); //ack interrupt
      dm9k_rd_reg(0xF0);            //this construct
      int rx_ready = dm9k_rd_dta(); //reads 0xF0 twice. Whatever. 
      return rx_ready & 1; }
    return 0; }
//--------------------------------------------------------------------//
void downloadPacket(unsigned short * buffer)
{ unsigned short rx_status = dm9k_rd_reg(0xF2);
  unsigned short rx_length = dm9k_rd_dta();

  buffer[0] = rx_length;
  if(rx_length > 1500) rx_length = 1500;
  rx_length = (rx_length + 1) >> 1;

  sdma_read(&buffer[1], rx_length);
//  for(int i = 1; i <= rx_length; i++)
//      buffer[i] = dm9k_rd_dta();

  return; }
//--------------------------------------------------------------------//
void uploadPacket(unsigned short * buffer)
{ unsigned short tx_length = buffer[0];

  if (tx_length > 1500) tx_length = 1500;
  int tx_length_h = (tx_length + 1) >> 1;

  dm9k_wr_idx(0xF8);

  sdma_write(&buffer[1], tx_length_h);
//  for(int i = 1; i <= tx_length_h; i++)
//     dm9k_wr_dta(buffer[i]);

  dm9k_wr_reg(0xFD, (tx_length >> 8));     //Packet length HI byte
  dm9k_wr_reg(0xFC, (tx_length & 0x00FF)); //Packet length LO byte
  dm9k_wr_reg(0x02, 1);                    //go!

  return; }
//--------------------------------------------------------------------//
void sendArpReply(unsigned short* buffer)
{   buffer[0] -= 4;
    buffer[1] = buffer[4];   //sender MAC
    buffer[2] = buffer[5];   //sender MAC
    buffer[3] = buffer[6];   //sender MAC

    buffer[4] = swab(MAC_ADDRESS_HI);
    buffer[5] = swab(MAC_ADDRESS_MI);
    buffer[6] = swab(MAC_ADDRESS_LO);

    buffer[17] = buffer[1];   //target MAC
    buffer[18] = buffer[2];   //target MAC
    buffer[19] = buffer[3];   //target MAC

    buffer[20] = buffer[15];  //target ip = sender ip
    buffer[21] = buffer[16];  //target ip = sender ip

    buffer[15] = swab(IP_ADDRESS_HI);  //sender ip = our ip
    buffer[16] = swab(IP_ADDRESS_LO);  //sender ip = our ip

    buffer[12] = swab(MAC_ADDRESS_HI); //our MAC
    buffer[13] = swab(MAC_ADDRESS_MI); //our MAC
    buffer[14] = swab(MAC_ADDRESS_LO); //our MAC

    buffer[11] = swab(0x0002);

    uploadPacket(buffer);

    return; }
//--------------------------------------------------------------------//
void sendPingReply(unsigned short* buffer)
{   buffer[0] -= 4;
    buffer[1] = buffer[4];   //sender MAC
    buffer[2] = buffer[5];   //sender MAC
    buffer[3] = buffer[6];   //sender MAC

    buffer[4] = swab(MAC_ADDRESS_HI);
    buffer[5] = swab(MAC_ADDRESS_MI);
    buffer[6] = swab(MAC_ADDRESS_LO);

    buffer[16] = buffer[14];  //target ip = sender ip
    buffer[17] = buffer[15];  //target ip = sender ip

    buffer[14] = swab(IP_ADDRESS_HI);  //sender ip = our ip
    buffer[15] = swab(IP_ADDRESS_LO);  //sender ip = our ip

    buffer[18] = 0;
    buffer[19] = 0; //icmp checksum

    int i;
    unsigned int sum = 0;

   //ip-icmp checksum calculation
    for (i = 18; i <= buffer[0]/2; i++)
            sum += (unsigned int)swab(buffer[i]);

    while (sum>>16)  sum = (sum & 0xFFFF)+(sum >> 16);
    sum = (~sum) & 0xFFFF;

    buffer[19] = swab((unsigned short) sum); //calculated icmp checksum

    uploadPacket(buffer);

    return; }
//--------------------------------------------------------------------//