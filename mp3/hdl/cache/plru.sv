
module plru (

    input logic load_cache,
    output logic we [4]
);

    always_comb begin
        we[0] = 1'b0;
        we[1] = 1'b0;
        we[2] = 1'b0;
        we[3] = 1'b0;
        if(load_cache)
            we[0] = 1'b1;
    end



endmodule : plru
