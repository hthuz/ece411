module cache_dut_tb;

    timeunit 1ns;
    timeprecision 1ns;


    parameter mem_addr0 = 32'h40008000;
    parameter mem_addr1 = 32'h40008042;
    parameter mem_nodata = 256'hffff;
    parameter mem_data0 = 256'h1234;
    parameter mem_data1 = 256'h5678;
    parameter pmem_access_time = 10;
    int pmem_counter;
    //----------------------------------------------------------------------
    // Waveforms.
    //----------------------------------------------------------------------
    initial begin
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, "+all");
    end

    //----------------------------------------------------------------------
    // Generate the clock.
    //----------------------------------------------------------------------
    bit clk;
    initial clk = 1'b1;
    always #1 clk = ~clk;

    //----------------------------------------------------------------------
    // Generate the reset.
    //----------------------------------------------------------------------
    bit rst;
    cache_itf itf(.*);

    logic   [31:0]  pmem_address;
    logic           pmem_read;
    logic           pmem_write;
    logic   [255:0] pmem_rdata;
    logic   [255:0] pmem_wdata;
    logic           pmem_resp;

    task do_reset();
        pmem_counter <= 0;
        itf.read <= 1'b0;
        itf.write <= 1'b0;

        rst <= 1'b1;
        repeat(1) @(posedge clk);
        rst <= 1'b0;
        repeat(3) @(posedge clk);
        // Fill this out!
    endtask : do_reset

    //----------------------------------------------------------------------
    // Collect coverage here:
    //----------------------------------------------------------------------
    // covergroup cache_cg with function sample(...)
    //     // Fill this out!
    // endgroup
    // Note that you will need the covergroup to get `make covrep_dut` working.

    //----------------------------------------------------------------------
    // Want constrained random classes? Do that here:
    //----------------------------------------------------------------------
    // class RandAddr;
    //     rand bit [31:0] addr;
    //     // Fill this out!
    // endclass : RandAddr

    //----------------------------------------------------------------------
    // Instantiate your DUT here.
    //----------------------------------------------------------------------
    cache dut (
        .clk(clk),
        .rst(rst),
        .mem_address(itf.addr),
        .mem_read(itf.read),
        .mem_write(itf.write),
        .mem_byte_enable(itf.wmask),
        .mem_rdata(itf.rdata),
        .mem_wdata(itf.wdata),
        .mem_resp(itf.resp),
        
        .pmem_address(pmem_address),
        .pmem_read(pmem_read),
        .pmem_write(pmem_write),
        .pmem_rdata(pmem_rdata),
        .pmem_wdata(pmem_wdata),
        .pmem_resp(pmem_resp)
    );

    //----------------------------------------------------------------------
    // Write your tests and run them here!
    //----------------------------------------------------------------------
    // Recommended: package your tests into tasks.

    task do_one_read();
        itf.read <= 1'b1;
        itf.addr <= mem_addr0;
        repeat (15) @(posedge clk);
        assert(itf.rdata == mem_data0)
        else begin
            $error("%0d: %0t: Read mismatch!", `__LINE__, $time);
        end

        itf.read <= 1'b0;
    endtask : do_one_read

    task do_two_reads_on_same_addr();
        itf.read <= 1'b1;
        itf.addr <= mem_addr0;
        repeat (15) @(posedge clk);
        itf.read <= 1'b0;
        repeat (3) @(posedge clk);
        itf.read <= 1'b1;
        itf.addr <= mem_addr0;
        assert(itf.rdata == mem_data0)
        else begin
            $error("%0d: %0t: Read mismatch!", `__LINE__, $time);
        end
    endtask: do_two_reads_on_same_addr

    task do_four_reads_on_diff_index();
        itf.read <= 1'b1;
        itf.addr <= mem_addr0;
        @(posedge clk iff itf.resp == 1'b1);
        itf.read <= 1'b0;
        assert(itf.rdata == mem_data0)
        else begin
            $error("%0d: %0t: Read #1 mismatch!", `__LINE__, $time);
        end
        repeat (3) @(posedge clk);

        // Do the second read on different address
        itf.read <= 1'b1;
        itf.addr <= mem_addr1;
        @(posedge clk iff itf.resp == 1'b1);
        itf.read <= 1'b0;
        assert(itf.rdata == mem_data1)
        else begin
            $error("%0d: %0t: Read #2 mismatch!", `__LINE__, $time);
        end
        repeat (3) @(posedge clk);

        // Do the third read on address 0
        itf.read <= 1'b1;
        itf.addr <= mem_addr0;
        @(posedge clk iff itf.resp == 1'b1);
        itf.read <= 1'b0;
        assert(itf.rdata == mem_data0)
        else begin
            $error("%0d: %0t: Read #3 mismatch!", `__LINE__, $time);
        end
        repeat (3) @(posedge clk);

        // Do the fourth red on address 1
        itf.read <= 1'b1;
        itf.addr <= mem_addr1;
        @(posedge clk iff itf.resp == 1'b1);
        itf.read <= 1'b0;
        assert(itf.rdata == mem_data1)
        else begin
            $error("%0d: %0t: Read #4 mismatch!", `__LINE__, $time);
        end

    endtask: do_four_reads_on_diff_index

    initial begin
        $display("Hello from mp3_cache_dut!");
        do_reset();
        do_four_reads_on_diff_index();
        $finish;
    end



    //----------------------------------------------------------------------
    // You likely want a process for pmem responses, like this:
    //----------------------------------------------------------------------
    always @(posedge clk) begin
    //     // Set pmem signals here to behaviorally model physical memory.
        pmem_resp <= 1'b0;
        pmem_rdata <= mem_nodata;
        if(pmem_read) begin
            pmem_counter <= pmem_counter + 1;
        end
        if(pmem_counter == pmem_access_time && pmem_read) begin
            pmem_counter <= 0;
            pmem_resp <= 1'b1;
            case(pmem_address) 
                mem_addr0: pmem_rdata <= mem_data0;
                mem_addr1: pmem_rdata <= mem_data1;
            endcase
        end
    end


endmodule
