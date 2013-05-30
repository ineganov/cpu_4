module store_reorder( input  [ 1:0] LO_ADDR,
                      input  [31:0] DATA_IN,
                      input         PARTIAL,
                      input  [ 1:0] OP_TYPE,
                      
                      output [ 3:0] BYTE_EN,
                      output [31:0] DATA_OUT );

logic [35:0] out;

//Architeture endianness is defined here.
//Ours is big-endian, ie it stores msb at lower mem addresses (which is considered first)

always_comb
  if(PARTIAL)
    begin
    if(OP_TYPE[0]) //if half-word
      begin
      if(LO_ADDR[1])  out = {4'b0011, 16'd0, DATA_IN[15:0]};  
      else            out = {4'b1100, DATA_IN[15:0], 16'd0};
      end
    else           //if byte
      begin
      case(LO_ADDR)
        2'd0:  out = {4'b1000, DATA_IN[7:0], 24'd0};
        2'd1:  out = {4'b0100, 8'd0,  DATA_IN[7:0], 16'd0};
        2'd2:  out = {4'b0010, 16'd0, DATA_IN[7:0], 8'd0};
      default: out = {4'b0001, 24'd0, DATA_IN[7:0]};
      endcase
      end
    end
  else out = {4'b1111, DATA_IN};

assign BYTE_EN  = out[35:32];
assign DATA_OUT = out[31:0];
     
endmodule




module load_reorder(  input  [ 1:0] LO_ADDR,
                      input  [31:0] DATA_IN,
                      input         PARTIAL,
                      input  [ 1:0] OP_TYPE,
                      output [31:0] DATA_OUT );

logic [31:0] out;

always_comb
  if(PARTIAL)
    case(OP_TYPE)
    2'b01:    begin //if half-word unsigned
                if(LO_ADDR[1])  out = {16'd0, DATA_IN[15:00]};  
                else            out = {16'd0, DATA_IN[31:16]};
              end
    2'b00:    begin //byte unsigned
                case(LO_ADDR)
                2'd0:           out = {24'd0, DATA_IN[31:24]};
                2'd1:           out = {24'd0, DATA_IN[23:16]};
                2'd2:           out = {24'd0, DATA_IN[15:08]};
                default:        out = {24'd0, DATA_IN[07:00]};
                endcase
              end
    2'b11:    begin //if half-word signed
                if(LO_ADDR[1])  out = {{16{DATA_IN[15]}}, DATA_IN[15:00]};  
                else            out = {{16{DATA_IN[31]}}, DATA_IN[31:16]};
              end
    default:  begin //byte signed
                case(LO_ADDR)
                2'd0:           out = {{24{DATA_IN[31]}}, DATA_IN[31:24]};
                2'd1:           out = {{24{DATA_IN[23]}}, DATA_IN[23:16]};
                2'd2:           out = {{24{DATA_IN[15]}}, DATA_IN[15:08]};
                default:        out = {{24{DATA_IN[07]}}, DATA_IN[07:00]};
                endcase
              end
    endcase
  else out = DATA_IN;

assign DATA_OUT = out;

endmodule
