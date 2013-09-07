//====================================================================//
// Warning: this function is not exactly a logarithm, as it computes
// the number of bit needed. E.g. log2(256) = 9, log2(255) = 8
// (c) Altera Synthesis Cookbook
function integer log2;
  input integer val;
  begin
   log2 = 0;
   while (val > 0) begin
      val = val >> 1;
    log2 = log2 + 1;
   end
  end
endfunction
//====================================================================//