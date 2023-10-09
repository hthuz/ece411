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
    output logic load_mem_wdata,
    output logic load_cache, // On a miss load data from memory to cache
    output logic load_plru,
    output logic dirty_value
);


enum int unsigned {
    s_idle,
    s_check,
    s_allocate,
    s_write_back
} state, next_state;

always_comb 
begin : state_actions

    load_mem_rdata = 1'b0;
    load_mem_wdata = 1'b0;
    load_cache = 1'b0;
    load_plru = 1'b0;
    pmem_read = 1'b0;
    pmem_write = 1'b0;
    mem_resp = 1'b0;
    dirty_value = 1'b0;

    case(state)
        s_idle: begin
        end
        s_check: begin
            if(mem_read)
                load_mem_rdata = hit;
            if(mem_write) begin
                load_mem_wdata = hit;
                load_cache = hit;
                dirty_value = hit;
            end
            mem_resp = hit;
            load_plru = hit;
        end

        s_allocate: begin
            pmem_read = 1'b1;
            if(pmem_resp) begin
                load_cache = 1'b1;
                // load_mem_rdata = mem_read;
                // load_mem_wdata = mem_write;
                // dirty_value = mem_write;
                // mem_resp = 1'b1;
                // load_plru = 1'b1;
            end
        end

        s_write_back: begin
            pmem_write = 1'b1;
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
                if(dirty)
                    next_state = s_write_back;
                else 
                    next_state = s_allocate;
            end
        s_allocate: 
            if(pmem_resp)
                next_state = s_check;
            else
                next_state = s_allocate;
        s_write_back: 
            if(pmem_resp)
                next_state = s_allocate;
            else 
                next_state = s_write_back;
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



