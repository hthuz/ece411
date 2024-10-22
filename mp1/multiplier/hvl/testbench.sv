
`ifndef testbench
`define testbench
module testbench(multiplier_itf.testbench itf);
import mult_types::*;

add_shift_multiplier dut (
    .clk_i          ( itf.clk          ),
    .reset_n_i      ( itf.reset_n      ),
    .multiplicand_i ( itf.multiplicand ),
    .multiplier_i   ( itf.multiplier   ),
    .start_i        ( itf.start        ),
    .ready_o        ( itf.rdy          ),
    .product_o      ( itf.product      ),
    .done_o         ( itf.done         )
);

assign itf.mult_op = dut.ms.op;
default clocking tb_clk @(negedge itf.clk); endclocking

initial begin
    $fsdbDumpfile("dump.fsdb");
    $fsdbDumpvars(0, "+all");
end

// DO NOT MODIFY CODE ABOVE THIS LINE

/* Uncomment to "monitor" changes to adder operational state over time */
// initial $monitor("[student_testbench] dut-op: time: %0t op: %s", $time, dut.ms.op.name);


// Resets the multiplier
task reset();
    itf.reset_n <= 1'b0;
    ##5;
    itf.reset_n <= 1'b1;
    ##1;
endtask : reset

// error_e defined in package mult_types in file ../include/types.sv
// Asynchronously reports error in DUT to grading harness
function void report_error(error_e error);
    itf.tb_report_dut_error(error);
endfunction : report_error


initial itf.reset_n = 1'b0;
initial begin
    reset();
    /********************** Your Code Here *****************************/

    assert (itf.rdy == 1'b1)
    else begin
        $error("%0d: %0t: NOT_READY error detected", `__LINE__, $time);
        report_error (NOT_READY);
    end

    // Coverage 1: assert start_i with every multiplier and multiplicant 
    for(int i = 0; i < 256; i++) begin
        for(int j = 0; j < 256; j++) begin
            itf.multiplier <= i;
            itf.multiplicand <= j;
            // Coverage 2: assert start_i in run state
            itf.start <= 1'b1;
            @(tb_clk iff itf.done == 1'b1 );

            assert (itf.rdy == 1'b1)
            else begin
                $error("%0d: %0t: NOT_READY error detected", `__LINE__, $time);
                report_error (NOT_READY);
            end

            assert (itf.product == i * j)
            else begin
                $error("%0d: %0t: BAD_PRODUCT error detected", `__LINE__, $time);
                report_error (BAD_PRODUCT);
            end
        end
    end

    itf.start <= 1'b0;
    @(tb_clk);
    // Coverage 3: assert reset_n_i when in run state
    itf.multiplicand <= 10;
    itf.multiplier <= 10;
    itf.start <= 1'b1;
    ##3; // First run state
    itf.reset_n <= 1'b0;
    ##1;
    assert (itf.rdy == 1'b1)
    else begin
        $error("%0d: %0t: NOT_READY error detected", `__LINE__, $time);
        report_error (NOT_READY);
    end
    ##3;
    itf.reset_n <= 1'b1;

    ##4; // Second run state
    itf.reset_n <= 1'b0;
    ##1;
    assert (itf.rdy == 1'b1)
    else begin
        $error("%0d: %0t: NOT_READY error detected", `__LINE__, $time);
        report_error (NOT_READY);
    end
    ##3;
    itf.reset_n <= 1'b1;



    // @(tb_clk iff itf.done == 1'b1);
    // assert (itf.rdy == 1'b1)
    // else begin
    //     $error("%0d: %0t: NOT_READY error detected", `__LINE__, $time);
    //     report_error (NOT_READY);
    // end

    // assert (itf.product == 10 * 10)
    // else begin
    //     $error("%0d: %0t: BAD_PRODUCT error detected", `__LINE__, $time);
    //     report_error (BAD_PRODUCT);
    // end


    /*******************************************************************/
    itf.finish(); // Use this finish task in order to let grading harness
                  // complete in process and/or scheduled operations
    $error("Improper Simulation Exit");
end


endmodule : testbench
`endif
 