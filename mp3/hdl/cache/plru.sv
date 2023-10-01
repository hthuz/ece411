
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
    output logic we [4]
);
    localparam num_sets = 2**s_index;
    logic [width - 1: 0] plru_array [num_sets];

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
        if(need_replace) begin
            if(plru_array[addr][0] & plru_array[addr][1]) begin
                plru_array[addr][0] <= 1'b0;
                plru_array[addr][1] <= 1'b0;
            end
            else if(plru_array[addr][0] & ~plru_array[addr][1]) begin
                plru_array[addr][0] <= 1'b0;
                plru_array[addr][1] <= 1'b1;
            end
            else if(~plru_array[addr][0] & plru_array[addr][2]) begin
                plru_array[addr][0] <= 1'b1;
                plru_array[addr][2] <= 1'b0;
            end
            else  begin
                plru_array[addr][0] <= 1'b1;
                plru_array[addr][2] <= 1'b1;
            end
        end

    endfunction

    // When all sets are full
    function void do_replace_decision();
        if(plru_array[addr][0] & plru_array[addr][1])
            we[0] = 1'b1;
        else if(plru_array[addr][0] & ~plru_array[addr][1])
            we[1] = 1'b1;
        else if(~plru_array[addr][0] & plru_array[addr][2])
            we[2] = 1'b1;
        else 
            we[3] = 1'b1;
    endfunction

    // When some sets are empty
    function void do_find_empty();
        if(~valid_o[0])
            we[0] = 1'b1;
        else if(~valid_o[1])
            we[1] = 1'b1;
        else if(~valid_o[2])
            we[2] = 1'b1;
        else
            we[3] = 1'b1;
    endfunction

    always_ff @(posedge clk) begin
        if (rst) begin
            for(int i = 0; i < num_sets; i++) begin
                plru_array[i] <= '0;
            end 
        end else begin
            if(hit | need_replace)
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
        end
    end




endmodule : plru
