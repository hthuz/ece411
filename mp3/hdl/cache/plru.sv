
module plru # (
    parameter s_index = 4,
    parameter width = 3
)(
    input logic clk,
    input logic rst,
    input [3:0] addr,
    input logic hit_o [4],
    input logic valid_o [4],
    input logic hit,
    input logic load_plru,
    output logic [1:0] plru_way
);
    localparam num_sets = 2**s_index;
    logic [width - 1: 0] plru_array [num_sets];

    // For debugging purpose
    logic [2:0] test_plru_entry;
    assign test_plru_entry = plru_array[2];


    assign need_replace = valid_o[0] & valid_o[1] & valid_o[2] & valid_o[3];

    function void update_lru();
        if(hit) begin
        if(hit_o[0]) begin
            plru_array[addr][0] <= 1'b0;
            plru_array[addr][1] <= 1'b0;
        end
        else if (hit_o[1]) begin
            plru_array[addr][0] <= 1'b0;
            plru_array[addr][1] <= 1'b1;
        end
        else if (hit_o[2]) begin
            plru_array[addr][0] <= 1'b1;
            plru_array[addr][2] <= 1'b0;
        end
        else if (hit_o[3]) begin
            plru_array[addr][0] <= 1'b1;
            plru_array[addr][2] <= 1'b1;
        end
        end
        else begin
            if(plru_way == 2'b00) begin
                plru_array[addr][0] <= 1'b0;
                plru_array[addr][1] <= 1'b0;
            end 
            else if(plru_way == 2'b01) begin
                plru_array[addr][0] <= 1'b0;
                plru_array[addr][1] <= 1'b1;
            end
            else if(plru_way == 2'b10) begin
                plru_array[addr][0] <= 1'b1;
                plru_array[addr][2] <= 1'b0;
            end
            else if(plru_way == 2'b11) begin
                plru_array[addr][0] <= 1'b1;
                plru_array[addr][2] <= 1'b1;
            end
        end

    endfunction

    // When all sets are full
    always_ff @(posedge clk) begin
        if (rst) begin
            for(int i = 0; i < num_sets; i++) begin
                plru_array[i] <= '0;
            end 
        end else begin
            if(load_plru)
                update_lru();
        end
    end

    // Evaluate if cache is dirty
    always_comb begin
        if(need_replace) begin
            if(plru_array[addr][0] & plru_array[addr][1]) begin
                plru_way = 2'b00;
            end
            else if(plru_array[addr][0] & ~plru_array[addr][1]) begin
                plru_way = 2'b01;
            end
            else if(~plru_array[addr][0] & plru_array[addr][2]) begin
                plru_way = 2'b10;
            end
            else begin
                plru_way = 2'b11;
            end
        end
        else begin
            if(~valid_o[0]) begin
                plru_way = 2'b00;
            end
            else if(~valid_o[1]) begin
                plru_way = 2'b01;
            end
            else if(~valid_o[2]) begin
                plru_way = 2'b10;
            end
            else begin
                plru_way = 2'b11;
            end
        end
    end




endmodule : plru
