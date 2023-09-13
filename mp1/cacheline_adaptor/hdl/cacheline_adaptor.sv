module cacheline_adaptor
(
    input                clk,
    input                reset_n,

    // All _i and _o here are from the perspective of your cacheline adaptor

    // Port to LLC (Lowest Level Cache)
    input logic [255:0]  line_i,    // cacheline to be written to memory by LLC
    output logic [255:0] line_o,    // cacheline to be written to LLC
    input logic [31:0]   address_i, // address of cacheline to be read / written
    input                read_i,    // signifies a read from LLC
    input                write_i,   // signifies a write from LLC
    output logic         resp_o,    // on reads, signifies that line_o is valid and the read is complete \
                                    // on writes, signifies that the write is complete

    // Port to memory
    input logic [63:0]   burst_i,   // burst of data read from memory
    output logic [63:0]  burst_o,   // burst of data to be written to memory
    output logic [31:0]  address_o, // address of data to be read / written
    output logic         read_o,    // signifies a read to memory
    output logic         write_o,   // signifies a write to memory
    input                resp_i     // on reads, signifies that burst_i is valid and the read is complete \
                                    // on writes, signifies that the write is complete
);

assign read_o = read_i;
assign write_o = write_i;

logic [1:0] burst_num;
logic [63:0] buffered_read[4];
logic resp_i_flag;

always_ff @(posedge clk_i, negedge reset_n) begin

    // Reading from DRAM
    if(read_o) begin
        if(resp_i) begin
            buffered_read[burst_num] <= burst_i;
            burst_num <= burst_num + 1;
            resp_i_flag <= 1'b1;
        end
    end

    // Returning data to LLC
    if(resp_i_flag && (burst_num == 0)) begin
        resp_o <= 1'b1;
        line_o <= {burst_num[3],burst_num[2],burst_num[1],burst_num[0]};
        resp_i_flag <= 1'b0;
    end




end



endmodule : cacheline_adaptor
