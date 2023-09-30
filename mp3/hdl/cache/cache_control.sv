module cache_control (
    input   clk,
    input   rst,
    input logic mem_read,
    input logic mem_write,
    input logic pmem_resp
);


enum int unsigned {
    s_idle,
    s_check,
    s_read_mem,
    s_write_mem
} state, next_state;

always_comb 
begin : state_actions

    case(state)
        s_idle: begin

        end
        s_check: begin

        end

        s_read_mem: begin

        end

        s_write_mem: begin

        end
    endcase
end


always_comb
begin: next_state_logic

    case(state)
        s_idle: 
            next_state = s_idle;
        s_check: ;

        s_read_mem: ;

        s_write_mem: ;

    endcase

end


always_ff @(posedge clk)
begin: next_state_assignment
    if (rst) 
        state <= s_fetch1;
    else
        state <= next_state;
end

endmodule : cache_control



