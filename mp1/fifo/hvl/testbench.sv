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

function void assert_after_reset();
    assert(itf.rdy == 1'b1)
        else begin
            error_e err = RESET_DOES_NOT_CAUSE_READY_O;
            $error ("%0d: %0t: %s error detected", `__LINE__, $time, err.name);
            report_error (err);
        end
endfunction : assert_after_reset

initial begin
    reset();
    /************************ Your Code Here ***********************/
    // Feel free to make helper tasks / functions, initial / always blocks, etc.
    @(tb_clk);
    assert_after_reset();

    // Enque coverage
    itf.valid_i <= 1'b1;
    for (int i = 0; i < CAP_P; i++) begin
        itf.data_i <= i;
        @(tb_clk);
        // assert (itf.rdy == 1'b1);
    end
    itf.valid_i <= 1'b0;

    // Deque converage
    itf.yumi <= 1'b1;
    for (int i = 0; i < CAP_P; i++) begin
        assert(itf.valid_o == 1'b1);
        // $display("i is %0d, data_o is %0d", i, itf.data_o);
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
    for(int i = 1; i < CAP_P; i++) begin
        reset();
        @(tb_clk);
        assert_after_reset();
        // Load i elements
        itf.valid_i <= 1'b1;
        for(int j = 0; j < i; j++) begin
            itf.data_i <= j;
            @(tb_clk);
            assert (itf.rdy == 1'b1);
        end

        // Enque and deque simultaneously for one time
        itf.yumi <= 1'b1;
        assert(itf.rdy == 1'b1);
        assert(itf.valid_o == 1'b1);
        assert(itf.data_o == 0)
            else begin
                error_e err = INCORRECT_DATA_O_ON_YUMI_I;
                $error ("%0d: %0t: %s error detected", `__LINE__, $time, err.name);
                report_error (err);
            end
        @(tb_clk);
        itf.valid_i <= 1'b0;
        itf.yumi <= 1'b0;
    end


    /***************************************************************/
    // Make sure your test bench exits by calling itf.finish();
    itf.finish();
    $error("TB: Illegal Exit ocurred");
end

endmodule : testbench
`endif

