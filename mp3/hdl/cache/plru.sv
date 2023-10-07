
module plru # (
    parameter s_index = 4,
    parameter width = 3
)(
    input logic clk,
    input logic rst,
    input [3:0] addr,
    input logic hit_o [4],
    input logic valid_o [4],
    input logic load_cache,
    input logic hit,
    input logic load_plru,
    input logic mem_write,
    output logic [1:0] plru_way,
    output logic we [4]
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
            if(we[0]) begin
                plru_array[addr][0] <= 1'b0;
                plru_array[addr][1] <= 1'b0;
            end 
            else if(we[1]) begin
                plru_array[addr][0] <= 1'b0;
                plru_array[addr][1] <= 1'b1;
            end
            else if(we[2]) begin
                plru_array[addr][0] <= 1'b1;
                plru_array[addr][2] <= 1'b0;
            end
            else if(we[3]) begin
                plru_array[addr][0] <= 1'b1;
                plru_array[addr][2] <= 1'b1;
            end
        end

    endfunction

    // When all sets are full
    function void do_replace_decision();
        if(plru_array[addr][0] & plru_array[addr][1]) begin
            we[0] = 1'b1;
        end
        else if(plru_array[addr][0] & ~plru_array[addr][1]) begin
            we[1] = 1'b1;
        end
        else if(~plru_array[addr][0] & plru_array[addr][2]) begin
            we[2] = 1'b1;
        end
        else begin
            we[3] = 1'b1;
        end
    endfunction

    // When some sets are empty
    function void do_find_empty();
        if(~valid_o[0]) begin
            we[0] = 1'b1;
        end
        else if(~valid_o[1]) begin
            we[1] = 1'b1;
        end
        else if(~valid_o[2]) begin
            we[2] = 1'b1;
        end
        else begin
            we[3] = 1'b1;
        end
    endfunction

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

    always_comb begin 
        we[0] = 1'b0;
        we[1] = 1'b0;
        we[2] = 1'b0;
        we[3] = 1'b0;
        if(load_cache) begin
            if(need_replace)
                do_replace_decision();
            else
                do_find_empty();
        end else if (mem_write & hit) begin
            if(hit_o[0])
                we[0] = 1'b1;
            else if (hit_o[1]) 
                we[1] = 1'b1;
            else if (hit_o[2])
                we[2] = 1'b1;
            else if (hit_o[3])
                we[3] = 1'b1;
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
