module mp3
import rv32i_types::*;
(
    input   logic           clk,
    input   logic           rst,
    output  logic   [31:0]  bmem_address,
    output  logic           bmem_read,
    output  logic           bmem_write,
    input   logic   [63:0]  bmem_rdata,
    output  logic   [63:0]  bmem_wdata,
    input   logic           bmem_resp
);


// Signal interface of CPU
logic [31:0] mem_address;
logic mem_read;
logic mem_write;
logic [3:0] mem_byte_enable;
logic [31:0] mem_rdata;
logic [31:0] mem_wdata;
logic  mem_resp;

// Bus adapter
logic [255:0] mem_wdata256;
logic [255:0] mem_rdata256;
logic [31:0] mem_byte_enable256;


// Signals between cache and cacheline_adaptor(memory)
logic [31:0] pmem_address;
logic [255:0] pmem_rdata;
logic [255:0] pmem_wdata;
logic pmem_read;
logic pmem_write;
logic pmem_resp;

    // Signal names are the same
    cpu cpu(.*);

    bus_adapter bus_adapter(
        .address(mem_address),
        .mem_wdata256(mem_wdata256),
        .mem_rdata256(mem_rdata256),
        .mem_wdata(mem_wdata),              // 32 bits
        .mem_rdata(mem_rdata),
        .mem_byte_enable(mem_byte_enable),
        .mem_byte_enable256(mem_byte_enable256)
    );

    cache cache(
        .clk(clk),
        .rst(rst),
        // CPU side signals
        .mem_address(mem_address),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_byte_enable(mem_byte_enable256),
        .mem_rdata(mem_rdata256),
        .mem_wdata(mem_wdata256),
        .mem_resp(mem_resp),
        // Memory side signals
        .pmem_address(pmem_address),
        .pmem_read(pmem_read),
        .pmem_write(pmem_write), 
        .pmem_rdata(pmem_rdata),            // 256 bits
        .pmem_wdata(pmem_wdata),
        .pmme_resp(pmem_resp)
    );

    // Anything else?
    cacheline_adaptor cacheline_adaptor(
        .clk(clk),
        .reset_n(~rst),
        // Port to cache
        .line_i(pmem_wdata), // cacheline to be written to memory by cache
        .line_o(pmem_rdata), // cacheline to be written to cache
        .address_i(pmem_address),
        .read_i(pmem_read),
        .write_i(pmem_write),
        .resp_o(pmem_resp),
        // Port to memory
        .burst_i(bmem_rdata),
        .burst_o(bmem_wdata), // 64bits
        .address_o(bmem_address),
        .read_o(bmem_read),
        .write_o(bmem_write),
        .resp_i(bmem_resp)
    );

endmodule : mp3
