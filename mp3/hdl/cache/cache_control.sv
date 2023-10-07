module cache_control (
    input   clk,
    input   rst,
    input logic mem_read,
    input logic mem_write,
    output logic mem_resp,
    input logic pmem_resp,
    output logic pmem_read,
    output logic pmem_write,

    input logic hit,
    input logic dirty,
    input logic [1:0] plru_way,

    output logic load_mem_rdata,
    output logic load_cache, // On a miss load data from memory to cache
    output logic load_plru,
    output logic load_dirty[4],
    output logic dirty_value
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
    load_cache = 1'b0;
    load_plru = 1'b0;
    pmem_read = 1'b0;
    mem_resp = 1'b0;

    load_dirty[0] = 1'b0;
    load_dirty[1] = 1'b0;
    load_dirty[2] = 1'b0;
    load_dirty[3] = 1'b0;

    dirty_value = 1'b1;
    case(state)
        s_idle: begin
        end
        s_check: begin
            load_mem_rdata = hit;
            mem_resp = hit;
            load_plru = hit;
        end

        s_read_mem: begin
            pmem_read = 1'b1;
            if(pmem_resp) begin
                load_cache = 1'b1;
                load_mem_rdata = 1'b1;
                mem_resp = 1'b1;
                load_plru = 1'b1;
                load_dirty[plru_way] = 1'b1;
            end
        end

        s_write_mem: begin
            pmem_write = 1'b1;
            if(pmem_resp) begin
                load_cache = 1'b1;
                mem_resp = 1'b1;
                load_plru = 1'b1;
                load_dirty[plru_way] = 1'b1;
            end
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
                if(mem_read | (mem_write & ~dirty))
                    next_state = s_read_mem;
                else if (mem_write & dirty)
                    next_state = s_write_mem;
            end
        s_read_mem: 
            if(pmem_resp)
                next_state = s_idle;
            else
                next_state = s_read_mem;
        s_write_mem: 
            if(pmem_resp)
                next_state = s_idle;
            else 
                next_state = s_write_mem;
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



