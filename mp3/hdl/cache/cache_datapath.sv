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
    input load_mem_rdata, // from control
    input load_mem_wdata,
    input load_cache,
    input load_plru,
    input logic dirty_value,
    output logic [255:0] mem_rdata,
    input logic [31:0] mem_address,
    input logic [255:0] mem_wdata,
    input logic [31:0] mem_byte_enable,
    input logic [255:0] pmem_rdata,
    input logic pmem_write,
    output logic [31:0] pmem_address,
    output logic [255:0] pmem_wdata,
    output logic hit,
    output logic dirty,
    // Way determined by plru to do choose and replace
    output logic [1:0] plru_way
);

    logic [4:0] offset;
    logic [3:0] index;
    logic [22:0] tag;


    logic   [255:0] data_d [4];
    logic   [255:0] data_o [4];
    logic   valid_d [4];
    logic   valid_o [4];
    logic   dirty_o [4];
    logic   hit_o [4];
    logic   [22:0] tag_o [4];
    logic   load_data[4];

    logic   tag_match [4];
    
    logic   [31:0] data_mask;

    assign offset = mem_address[4:0];
    assign index = mem_address[8:5];
    assign tag = mem_address[31:9];

    always_comb begin
        if(pmem_write) begin
            pmem_address = {tag_o[plru_way],index, 5'b00000};
            // pmem_address = {tag_o[plru_way], index, offset};
        end else begin
            // Bit 4:0 are offset. It should read one block at a time
            // This will make test with cache_dut_tb incompatible
            pmem_address = {mem_address[31:5], 5'b00000};
            // pmem_address = mem_address;
        end
    end

    assign dirty = dirty_o[plru_way];

    // When to load cache
    always_comb begin
        load_data[0] = 1'b0;
        load_data[1] = 1'b0;
        load_data[2] = 1'b0;
        load_data[3] = 1'b0;
        if(load_cache) begin
            load_data[plru_way] = 1'b1;
        end
    end

    always_comb begin
        data_mask = 32'hffffffff;
        if(load_mem_wdata)
            data_mask = mem_byte_enable;
    end

    genvar i;
    generate for (i = 0; i < 4; i++) begin : arrays
        mp3_data_array data_array (
            .clk0       (clk),
            .csb0       (1'b0), // Chip select, active low
            .web0       (~load_data[i]),     // Write enable, active low
            .wmask0     (data_mask),     // Write mask ,32 bits
            .addr0      (index), 
            .din0       (data_d[i]), // Write data
            .dout0      (data_o[i])      // Read data
        ); 

        mp3_tag_array tag_array (
            .clk0       (clk),
            .csb0       (1'b0), // Chip select, active low
            .web0       (~load_data[i]),     // Write enable, active low
            .addr0      (index),
            .din0       (tag), // Write data
            .dout0      (tag_o[i])      // Read data
        ); 

        ff_array valid_array (
            .clk0       (clk),
            .rst0       (rst),
            .csb0       (1'b0), // Chip select, active low
            .web0       (~load_data[i]),     // Write enable, active low
            .addr0      (index),
            .din0       (1'b1), // Write data
            .dout0      (valid_o[i])      // Read data
        ); 

        ff_array dirty_array (
            .clk0       (clk),
            .rst0       (rst),
            .csb0       (1'b0), // Chip select, active low
            .web0       (~load_data[i]),     // Write enable, active low
            .addr0      (index),
            .din0       (dirty_value), // Write data
            .dout0      (dirty_o[i])      // Read data
        ); 


        always_comb begin
            if(load_mem_wdata) begin
                data_d[i] = mem_wdata;
            end else begin
                data_d[i] = pmem_rdata;
            end
        end

        // assign tag_match[i] = (tag == tag_o[i]);
        always_comb begin
            if(tag == tag_o[i])
                tag_match[i] = 1'b1;
            else
                tag_match[i] = 1'b0;
        end
        assign hit_o[i] = tag_match[i] & valid_o[i];

    end endgenerate

    plru plru (
        .clk(clk),
        .rst(rst),
        .addr(index),
        .hit_o(hit_o),
        .valid_o(valid_o),
        .hit(hit),
        .load_plru(load_plru),
        .plru_way(plru_way)
    );

    assign hit = hit_o[0] | hit_o[1] | hit_o[2] | hit_o[3];
    // Select valid data to mem_rdata
    always_comb begin
        mem_rdata = '0;
        if(load_mem_rdata) begin
            if(hit_o[0])
                mem_rdata = data_o[0];
            else if(hit_o[1])
                mem_rdata = data_o[1];
            else if(hit_o[2])
                mem_rdata = data_o[2];
            else if(hit_o[3])
                mem_rdata = data_o[3];
            else begin
                // TODO if not in cache
                mem_rdata = pmem_rdata;
            end
        end
    end

    always_comb begin
        pmem_wdata = '0;
        if(pmem_write) begin
            pmem_wdata = data_o[plru_way];
        end
    end



endmodule : cache_datapath












