module cache_control (
    input   clk,
    input   rst,
    input logic mem_read,
    input logic mem_write,
    input logic pmem_resp,
    input logic pmem_read,
    input logic pmem_write,

    input logic hit,

    output logic load_mem_rdata
);


enum int unsigned {
    s_idle,
    s_check,
    s_read_mem,
    s_write_mem
} state, next_state;

always_comb 
begin : state_actions

    load_mem_rdata = 1'b0;

    case(state)
        s_idle: begin
        end
        s_check: begin
            load_mem_rdata = hit;
        end

        s_read_mem: begin
            pmem_read = 1'b1;
            if(pmem_resp)
                load_mem_rdata = 1'b1;
        end

        s_write_mem: begin

        end
    endcase
end


always_comb
begin: next_state_logic

    next_state = state;
    case(state)
        s_idle: 
            if(mem_read | mem_write)
                next_state = s_check;
            else
                next_state = s_idle;
        s_check: 
            if(hit)
                next_state = s_idle;
            else begin
                if(mem_read)
                    next_state = s_read_mem;
                else if (mem_write)
                    next_state = s_write_mem;
            end
        s_read_mem: 
            if(pmem_resp)
                next_state = s_idle;
            else
                next_state = s_read_mem;
        s_write_mem: ;

    endcase

end


always_ff @(posedge clk)
begin: next_state_assignment
    if (rst) 
        state <= s_idle;
    else
        state <= next_state;
end

endmodule : cache_control



