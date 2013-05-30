#include "ioaddr.h"
#include "std_io.h"

extern "C" int main();
extern "C" void delay( int );

inline void _break() { asm( "break" ); }

//---------------------------------------------------------------------------------//
int main()
{  print_str("Hello with a super-ultra-long string, which is larger than thrirty-two bytes!\n");

   unsigned int gx, gy, gz;
   while(1)
   {  gx = *GYRO_X;
      gy = *GYRO_Y;
      gz = *GYRO_Z;

      print_str("> ");
      print_hex16(gx); print_str(", ");
      print_hex16(gy); print_str(", ");
      print_hex16(gz); print_str("\n");

      usleep(50000);
    } 

   return 0; }
