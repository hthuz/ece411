module cache_datapath #(
            parameter       s_offset = 5,
            parameter       s_index  = 4,
            parameter       s_tag    = 32 - s_offset - s_index,
            parameter       s_mask   = 2**s_offset,
            parameter       s_line   = 8*s_mask,
            parameter       num_sets = 2**s_index
)(
    input clk,
    input rst,
    input logic [31:0] mem_address

);

            logic   [255:0] data_d      [4];

    genvar i;
    generate for (i = 0; i < 4; i++) begin : arrays
        mp3_data_array data_array (
            .clk0       (clk),
            .csb0       (1'b0), // Chip select, active low
            .web0       (),     // Write enable, active low
            .wmask0     (),     // Write mask
            .addr0      (),
            .din0       (data_d[i]), // Write data
            .dout0      ()      // Read data
        ); 
    end endgenerate

endmodule : cache_datapath
