
module testbench(cam_itf itf);
import cam_types::*;

cam dut (
    .clk_i     ( itf.clk     ),
    .reset_n_i ( itf.reset_n ),
    .rw_n_i    ( itf.rw_n    ),
    .valid_i   ( itf.valid_i ),
    .key_i     ( itf.key     ),
    .val_i     ( itf.val_i   ),
    .val_o     ( itf.val_o   ),
    .valid_o   ( itf.valid_o )
);

default clocking tb_clk @(negedge itf.clk); endclocking

initial begin
    $fsdbDumpfile("dump.fsdb");
    $fsdbDumpvars(0, "+all");
end

task reset();
    itf.reset_n <= 1'b0;
    repeat (5) @(tb_clk);
    itf.reset_n <= 1'b1;
    repeat (5) @(tb_clk);
endtask

// DO NOT MODIFY CODE ABOVE THIS LINE

task write(input key_t key, input val_t val);
    itf.rw_n <= 1'b0;
    itf.valid_i <= 1'b1;
    itf.key <= key;
    itf.val_i <= val;
    @(tb_clk);
    itf.valid_i <= 1'b0;
endtask

task read(input key_t key, output val_t val);
    itf.rw_n <= 1'b1;
    itf.valid_i <= 1'b1;
    itf.key <= key;
    val <= itf.val_o;
    @(tb_clk);
    itf.valid_i <= 1'b0;
endtask

function assert_read_error(input val_t val_o, input val_t expected_val);
    assert (val_o == expected_val) else  begin
        itf.tb_report_dut_error(READ_ERROR);
        $error("%0t TB: Read %0d, expected %0d", $time, val_o, expected_val);
    end
endfunction


initial begin
    $display("Starting CAM Tests");

    reset();
    /************************** Your Code Here ****************************/
    // Feel free to make helper tasks / functions, initial / always blocks, etc.
    // Consider using the task skeltons above
    // To report errors, call itf.tb_report_dut_error in cam/include/cam_itf.sv
    

    // Coverage 3: Write of different values on the same key on consecutive clock cycles
    for(int i = 0; i < 4; i++) begin
        key_t key = 0;
        write(key,i);
    end
    
    // Coverage 4: write then read;
    reset();
    for(int i = 0; i < 4; i++) begin
        key_t key = 0;
        val_t val;
        write(key, i);
        read(key, val);
        assert_read_error(val, i);
    end



    /**********************************************************************/

    itf.finish();
end

endmodule : testbench
