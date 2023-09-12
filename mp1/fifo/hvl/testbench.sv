`ifndef testbench
`define testbench


module testbench(fifo_itf itf);
import fifo_types::*;

fifo_synch_1r1w dut (
    .clk_i     ( itf.clk     ),
    .reset_n_i ( itf.reset_n ),

    // valid-ready enqueue protocol
    .data_i    ( itf.data_i  ),
    .valid_i   ( itf.valid_i ),
    .ready_o   ( itf.rdy     ),

    // valid-yumi deqeueue protocol
    .valid_o   ( itf.valid_o ),
    .data_o    ( itf.data_o  ),
    .yumi_i    ( itf.yumi    )
);

initial begin
    $fsdbDumpfile("dump.fsdb");
    $fsdbDumpvars(0, "+all");
end

// Clock Synchronizer for Student Use
default clocking tb_clk @(negedge itf.clk); endclocking

task reset();
    itf.reset_n <= 1'b0;
    ##(10);
    itf.reset_n <= 1'b1;
    ##(1);
endtask : reset

function automatic void report_error(error_e err); 
    itf.tb_report_dut_error(err);
endfunction : report_error

// DO NOT MODIFY CODE ABOVE THIS LINE

initial begin
    reset();
    /************************ Your Code Here ***********************/
    // Feel free to make helper tasks / functions, initial / always blocks, etc.

    // Assert ready after reset
    @(tb_clk);
    assert(itf.rdy == 1'b1)
        else begin
            error_e err = RESET_DOES_NOT_CAUSE_READY_O;
            $error ("%0d: %0t: %s error detected", `__LINE__, $time, err.name);
            report_error (err);
        end

    // Enque coverage
    itf.valid_i <= 1'b1;
    for (int i = 0; i < 10; i++) begin
        itf.data_i <= i;
        @(tb_clk);
        assert (itf.rdy == 1'b1);
    end
    itf.valid_i <= 1'b0;

    // Deque converage
    itf.yumi <= 1'b1;
    for (int i = 0; i < 10; i++) begin
        assert(itf.valid_o == 1'b1);
        assert(itf.data_o == i)
            else begin
                error_e err = INCORRECT_DATA_O_ON_YUMI_I;
                $error ("%0d: %0t: %s error detected", `__LINE__, $time, err.name);
                report_error (err);
            end
        @(tb_clk);
    end
    itf.yumi <= 1'b0;

    // Both coverage
    reset();
    @(tb_clk);
    assert(itf.rdy == 1'b1)
        else begin
            error_e err = RESET_DOES_NOT_CAUSE_READY_O;
            $error ("%0d: %0t: %s error detected", `__LINE__, $time, err.name);
            report_error (err);
        end

    for (int i = 1; i < 10; i++) begin
        itf.valid_i <= 1'b1;
        itf.data_i <= i;
        itf.yumi <= 1'b1;
        @(tb_clk);
        // assert(itf.rdy == 1'b1);
        // assert(itf.valid_o == 1'b1);
        assert(itf.data_o == i)
            else begin
                error_e err = INCORRECT_DATA_O_ON_YUMI_I;
                $error ("%0d: %0t: %s error detected", `__LINE__, $time, err.name);
                report_error (err);
            end
    end
    itf.valid_i <= 1'b0;
    itf.yumi <= 1'b0;






    /***************************************************************/
    // Make sure your test bench exits by calling itf.finish();
    itf.finish();
    $error("TB: Illegal Exit ocurred");
end

endmodule : testbench
`endif

