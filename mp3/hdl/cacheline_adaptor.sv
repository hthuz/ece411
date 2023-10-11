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

assign address_o = address_i;
// assign write_o = write_i;

// logic [1:0] burst_num;
logic [2:0] read_burst_num;

int write_burst_num;
logic [63:0] buffered_read[4];
logic [63:0] buffered_write[4];
logic [63:0] buffered_read_in[4];
logic [63:0] buffered_write_in[4];

enum logic [2:0] {
    s_wait,
    s_read,      // Read from memory
    s_read_send, // Send to LLC
    s_write,     // Write from LLC to cacheline 
    s_write_send // Send to memory
} state, next_state;

always_ff @(posedge clk) begin
    for(int i = 0; i < 4; i++) begin
        buffered_write[i] <= buffered_write_in[i];
        buffered_read[i] <= buffered_read_in[i];
    end
end

always_ff @(posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        state <= s_wait;
        read_burst_num <= 0;
        write_burst_num <= 0;
    end
    else begin
        state <= next_state;
        if(resp_i && state == s_read)
            read_burst_num <= read_burst_num + 1;
        if(state == s_read_send) begin
            read_burst_num <= 0;
        end
        if(resp_i && state == s_write_send)
            write_burst_num <= write_burst_num + 1;
        if(state == s_write)
            write_burst_num <= 0;
    end
end


always_comb begin

    read_o = 1'b0;
    write_o = 1'b0;
    resp_o = 1'b0;

    line_o = '0;
    burst_o = '0;

    for(int i = 0; i < 4; i++) begin
        buffered_read_in[i] = buffered_read[i];
        buffered_write_in[i] = buffered_write[i];
    end

    next_state = state;
    unique case(state)
        s_wait:
            if (read_i)
                next_state = s_read;
            else if (write_i)
                next_state = s_write;
            else
                next_state = s_wait;
        s_read:
            if (read_burst_num == 3)
                next_state = s_read_send;
            else
                next_state = s_read;
        s_read_send:
            next_state = s_wait;
        s_write:
            next_state = s_write_send;
        s_write_send:
            if (write_burst_num == 4)
                next_state = s_wait;
            else
                next_state = s_write_send;
        default: ;
    endcase

    case(state)
        s_wait: begin
        end
        s_read: begin
            read_o = 1'b1;
            if(resp_i) begin
                buffered_read_in[read_burst_num] = burst_i;
            end
        end
        s_read_send: begin
            resp_o = 1'b1;
            line_o = {buffered_read[3],buffered_read[2],buffered_read[1],buffered_read[0]};
        end
        s_write: begin
            buffered_write_in[0] = line_i[63:0];
            buffered_write_in[1] = line_i[127:64];
            buffered_write_in[2] = line_i[191:128];
            buffered_write_in[3] = line_i[255:192];
        end
        s_write_send: begin
            write_o = 1'b1;
            burst_o = buffered_write[write_burst_num];
            if(write_burst_num == 4)
                resp_o = 1'b1;
        end
    endcase

end

// always_ff @(posedge clk, negedge reset_n) begin

//     if (~reset_n) begin
//         read_o <= 1'b0;
//         write_o <= 1'b0;
//         read_burst_num <= 0;
//         write_burst_num <= 0;
//     end
//     else begin

//         // Receive read signal from LLC
//         if(read_i) begin
//             read_o <= 1'b1;
//         end

//         // Reading from DRAM
//         if(read_o) begin
//             if(resp_i) begin
//                 buffered_read[read_burst_num] <= burst_i;
//                 read_burst_num <= read_burst_num + 1;
//             end
//         end

//         resp_o <= 1'b0;
//         // Returning data to LLC
//         if(read_burst_num == 3) begin
//             read_o <= 1'b0;
//             resp_o <= 1'b1;
//             line_o <= {buffered_read[3],buffered_read[2],buffered_read[1],buffered_read[0]};
//             read_burst_num <= 0;
//         end

//         // // Receive write request from LLC
//         // if (write_i) begin
//         //     buffered_write[0] <= line_i[63:0];
//         //     buffered_write[1] <= line_i[127:64];
//         //     buffered_write[2] <= line_i[191:128];
//         //     buffered_write[3] <= line_i[255:192];
//         //     write_o <= 1'b1;
//         //     // $display("buffered %x%x%x%x", buffered_write[3], buffered_write[2], buffered_write[1], buffered_write[0]);
//         // end

//         // // Writing to DRAM
//         // if(write_o) begin
//         //     burst_o <= buffered_write[write_burst_num];
//         //     if(resp_i) begin
//         //         write_burst_num <= write_burst_num + 1;
//         //         $display("burst_o %x", burst_o);
//         //     end
//         // end

//         // // Writing completed
//         // if(write_burst_num == 4) begin
//         //     write_o <= 1'b0;
//         //     write_burst_num <= 0;
//         //     resp_o <= 1'b1;
//         // end


//     end


// end



endmodule : cacheline_adaptor
