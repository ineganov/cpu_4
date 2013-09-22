module i2c_top( input         CLK,
                input         RESET,
                input   [3:0] A,
                output [31:0] RD,
                inout         SDA,
                inout         SCL );

logic [15:0] gyro_x_q, gyro_y_q, gyro_z_q;
logic  [7:0] i2c_data, gyro_z_hi_q, gyro_z_lo_q, gyro_y_hi_q, 
             gyro_y_lo_q, gyro_x_hi_q, gyro_x_lo_q;
logic        i2c_en, i2c_st;

ffd #(8) gyro_zl_fd(CLK, i2c_st, i2c_en, i2c_data,    gyro_z_lo_q );
ffd #(8) gyro_zh_fd(CLK, i2c_st, i2c_en, gyro_z_lo_q, gyro_z_hi_q );
ffd #(8) gyro_yl_fd(CLK, i2c_st, i2c_en, gyro_z_hi_q, gyro_y_lo_q );
ffd #(8) gyro_yh_fd(CLK, i2c_st, i2c_en, gyro_y_lo_q, gyro_y_hi_q );
ffd #(8) gyro_xl_fd(CLK, i2c_st, i2c_en, gyro_y_hi_q, gyro_x_lo_q );
ffd #(8) gyro_xh_fd(CLK, i2c_st, i2c_en, gyro_x_lo_q, gyro_x_hi_q );

ffd #(16) gyro_x_fd(CLK, RESET, i2c_st, {gyro_x_hi_q, gyro_x_lo_q}, gyro_x_q );
ffd #(16) gyro_y_fd(CLK, RESET, i2c_st, {gyro_y_hi_q, gyro_y_lo_q}, gyro_y_q );
ffd #(16) gyro_z_fd(CLK, RESET, i2c_st, {gyro_z_hi_q, gyro_z_lo_q}, gyro_z_q );

i2c_master  i2c_master ( .CLK      ( CLK      ),
                         .RESET    ( RESET    ),
                         .DATA_OUT ( i2c_data ),
                         .DATA_EN  ( i2c_en   ),
                         .DATA_ST  ( i2c_st   ),
                         .SDA      ( SDA      ),
                         .SCL      ( SCL      ) );

mux4 #(32) out_mux( A[1:0],
                    { {16{gyro_x_q[15]}}, gyro_x_q},
                    { {16{gyro_y_q[15]}}, gyro_y_q},
                    { {16{gyro_z_q[15]}}, gyro_z_q},
                    32'd0,
                    RD );

endmodule
