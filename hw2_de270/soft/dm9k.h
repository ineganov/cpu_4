#ifndef __DM9K_H__
#define __DM9K_H__

void dm9k_reset();
void dm9k_wr_reg(int reg, int data);
unsigned short dm9k_rd_reg(int reg);

unsigned short dm9k_rd_dta();
void dm9k_wr_dta(unsigned short data);
unsigned short dm9k_rd_idx();
void dm9k_wr_idx(unsigned short data);

void dm9k_init();
int dm9k_packetReceived();
void downloadPacket(unsigned short * buffer);
void uploadPacket(unsigned short * buffer);

void sendArpReply(unsigned short* buffer);
void sendPingReply(unsigned short* buffer);

unsigned short swab(unsigned short);

const unsigned short MAC_ADDRESS_HI = 0x1A1B;
const unsigned short MAC_ADDRESS_MI = 0x1C1D;
const unsigned short MAC_ADDRESS_LO = 0x1E1F;
const unsigned short UDP_PORT = 1536;
const unsigned short IP_ADDRESS_HI = 0x0A64; //10.100.
const unsigned short IP_ADDRESS_LO = 0x0002; //0.2

#endif
