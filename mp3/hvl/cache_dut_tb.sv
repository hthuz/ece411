module cache_dut_tb;

    timeunit 1ns;
    timeprecision 1ns;


    // Index is 0
    parameter mem_addr0 = 32'h40008000;
    // The following address all have index 2
    parameter mem_addr1 = 32'h40008042;
    parameter mem_addr2 = 32'h40018042;
    parameter mem_addr3 = 32'h40028042;
    parameter mem_addr4 = 32'h40038042;
    parameter mem_addr5 = 32'h40048042;

    // Continous memory
    parameter cmem_addr1 = 32'h40000800;
    parameter cmem_addr2 = 32'h40000804;
    parameter cmem_addr3 = 32'h40000808;

    parameter cmem_data1 = 256'h1234;

    parameter mem_nodata = 256'hffff;

    parameter mem_data0 = 256'h0000;
    parameter mem_data1 = 256'h1111;
    parameter mem_data2 = 256'h2222;
    parameter mem_data3 = 256'h3333;
    parameter mem_data4 = 256'h4444;
    parameter mem_data5 = 256'h5555;

    parameter mem_wdata0 = 256'hf000;
    parameter mem_wdata1 = 256'hf111;
    parameter mem_wdata2 = 256'hf222;
    parameter mem_wdata3 = 256'hf333;
    parameter mem_wdata4 = 256'hf444;
    parameter mem_wdata5 = 256'hf555; 

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

        // repeat(1) @(posedge clk);
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
        itf.addr <= mem_addr1;
        @(posedge clk iff itf.resp == 1'b1);
        // itf.addr <= mem_addr1;
        @(posedge clk iff itf.resp == 1'b1);
        assert(itf.rdata == mem_data1)
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

    task do_reads_on_same_index();
        itf.read <= 1'b1;
        itf.addr <= mem_addr1;
        @(posedge clk iff itf.resp == 1'b1);
        assert(itf.rdata == mem_data1)
        else begin
            $error("%0d: %0t: Read #1 mismatch!", `__LINE__, $time);
        end

        itf.addr <= mem_addr2;
        @(posedge clk iff itf.resp == 1'b1);
        assert(itf.rdata == mem_data2)
        else begin
            $error("%0d: %0t: Read #2 mismatch!", `__LINE__, $time);
        end

        itf.addr <= mem_addr3;
        @(posedge clk iff itf.resp == 1'b1);
        assert(itf.rdata == mem_data3)
        else begin
            $error("%0d: %0t: Read #3 mismatch!", `__LINE__, $time);
        end

        itf.addr <= mem_addr4;
        @(posedge clk iff itf.resp == 1'b1);
        assert(itf.rdata == mem_data4)
        else begin
            $error("%0d: %0t: Read #4 mismatch!", `__LINE__, $time);
        end

        itf.addr <= mem_addr1;
        @(posedge clk iff itf.resp == 1'b1);
        assert(itf.rdata == mem_data1)
        else begin
            $error("%0d: %0t: Read #1 mismatch!", `__LINE__, $time);
        end

        // Replacement
        itf.addr <= mem_addr5;
        @(posedge clk iff itf.resp == 1'b1);
        assert(itf.rdata == mem_data5)
        else begin
            $error("%0d: %0t: Read #5 mismatch!", `__LINE__, $time);
        end

        itf.addr <= mem_addr3;
        @(posedge clk iff itf.resp == 1'b1);
        assert(itf.rdata == mem_data3)
        else begin
            $error("%0d: %0t: Read #3 mismatch!", `__LINE__, $time);
        end

        itf.read <= 1'b0;
        repeat(8) @(posedge clk);
    endtask : do_reads_on_same_index

    task do_read_hit_with_diff_offset();
        itf.read <= 1'b1;
        itf.addr <= cmem_addr1;
        @(posedge clk iff itf.resp == 1'b1);
        assert(itf.rdata == cmem_data1)
        else begin
            $error("%0d: %0t: Read #1 mismatch!", `__LINE__, $time);
        end

        itf.addr <= cmem_addr2;
        @(posedge clk iff itf.resp == 1'b1);
        assert(itf.rdata == cmem_data1)
        else begin
            $error("%0d: %0t: Read #2 mismatch!", `__LINE__, $time);
        end
        itf.read <= 1'b0;
        repeat(5) @(posedge clk);
    endtask : do_read_hit_with_diff_offset

    task do_one_write();
        // Address is no given until read/write starts
        // Before address is given, cache output is invalid
        itf.write <= 1'b1;
        itf.addr <= mem_addr1;
        itf.wdata <= mem_data2;
        // repeat(15) @(posedge clk);
        // itf.write <= 1'b0;
        @(posedge clk iff itf.resp == 1'b1);
        itf.write <= 1'b0;
        itf.read <= 1'b1;
        @(posedge clk iff itf.resp == 1'b1);
        assert(itf.rdata == mem_data2)
        else begin
            $error("%0d: %0t: Write Wrong!", `__LINE__, $time);
        end
        itf.read <= 1'b0;
    endtask : do_one_write

    task do_two_write_on_same_addr();
        itf.write <= 1'b1;
        itf.addr <= mem_addr1;
        itf.wdata <= mem_data2;
        @(posedge clk iff itf.resp == 1'b1);
        // Second write
        itf.wdata <= mem_data3;
        @(posedge clk iff itf.resp == 1'b1);
        // Read
        itf.write <= 1'b0;
        itf.read <= 1'b1;
        @(posedge clk iff itf.resp == 1'b1);
        assert(itf.rdata == mem_data3)
        else begin
            $error("%0d: %0t: Write Wrong!", `__LINE__, $time);
        end
        itf.read <= 1'b0;
        repeat(15) @(posedge clk);
    endtask : do_two_write_on_same_addr

    task do_write_on_same_index();
        itf.write <= 1'b1;

        itf.wdata <= mem_wdata1;
        itf.addr <= mem_addr1;
        @(posedge clk iff itf.resp == 1'b1);
        itf.wdata <= mem_wdata2;
        itf.addr <= mem_addr2;
        @(posedge clk iff itf.resp == 1'b1);
        itf.wdata <= mem_wdata3;
        itf.addr <= mem_addr3;
        @(posedge clk iff itf.resp == 1'b1);
        itf.wdata <= mem_wdata4;
        itf.addr <= mem_addr4;
        @(posedge clk iff itf.resp == 1'b1);
        // Write back should happen
        itf.addr <= mem_addr5;
        itf.wdata <= mem_wdata5;
        @(posedge clk iff itf.resp == 1'b1);

        itf.write <= 1'b0;
        itf.read <= 1'b1;
        // Read miss
        itf.addr <= mem_addr1;
        @(posedge clk iff itf.resp == 1'b1);
        itf.read <= 1'b0;
        assert(itf.rdata == mem_wdata1)
        else begin
            $error("%0d: %0t: Read mismatch!", `__LINE__, $time);
        end
        repeat(10) @(posedge clk);
    endtask : do_write_on_same_index

    task do_read_until_full_then_write();
        itf.read <= 1'b1;
        itf.addr <= mem_addr1;
        @(posedge clk iff itf.resp == 1'b1);
        itf.addr <= mem_addr2;
        @(posedge clk iff itf.resp == 1'b1);
        itf.addr <= mem_addr3;
        @(posedge clk iff itf.resp == 1'b1);
        itf.addr <= mem_addr4;
        @(posedge clk iff itf.resp == 1'b1);

        // Do write, there should be no write back
        itf.read <= 1'b0;
        itf.write <= 1'b1;
        itf.wdata <= mem_wdata1;
        itf.addr <= mem_addr5;
        @(posedge clk iff itf.resp == 1'b1);
        itf.write <= 1'b0;
        repeat(15) @(posedge clk);



    endtask : do_read_until_full_then_write
    initial begin
        $display("Hello from mp3_cache_dut!");
        do_reset();
        // do_read_hit_with_diff_offset();
        // do_two_reads_on_same_addr();
        $finish;
    end



    //----------------------------------------------------------------------
    // You likely want a process for pmem responses, like this:
    //----------------------------------------------------------------------
    logic [255:0] mem_arr [7];
    always @(posedge clk) begin

        // Set pmem signals here to behaviorally model physical memory.
        pmem_resp <= 1'b0;
        pmem_rdata <= mem_nodata;
        if(rst) begin
            mem_arr[0] <= mem_data0;
            mem_arr[1] <= mem_data1;
            mem_arr[2] <= mem_data2;
            mem_arr[3] <= mem_data3;
            mem_arr[4] <= mem_data4;
            mem_arr[5] <= mem_data5;
            mem_arr[6] <= cmem_data1;
        end
        else if(pmem_read | pmem_write) begin
            pmem_counter <= pmem_counter + 1;
        end

        if(pmem_counter == pmem_access_time && pmem_read) begin
            pmem_counter <= 0;
            pmem_resp <= 1'b1;
            case(pmem_address) 
                mem_addr0: pmem_rdata <= mem_arr[0];
                mem_addr1: pmem_rdata <= mem_arr[1];
                mem_addr2: pmem_rdata <= mem_arr[2];
                mem_addr3: pmem_rdata <= mem_arr[3];
                mem_addr4: pmem_rdata <= mem_arr[4];
                mem_addr5: pmem_rdata <= mem_arr[5];
                cmem_addr1: pmem_rdata <= mem_arr[6];
            endcase
        end

        if(pmem_counter == pmem_access_time && pmem_write) begin
            pmem_counter <= 0;
            pmem_resp <= 1'b1;
            case (pmem_address)
                mem_addr0: mem_arr[0] <= pmem_wdata;
                mem_addr1: mem_arr[1] <= pmem_wdata;
                mem_addr2: mem_arr[2] <= pmem_wdata;
                mem_addr3: mem_arr[3] <= pmem_wdata;
                mem_addr4: mem_arr[4] <= pmem_wdata;
                mem_addr5: mem_arr[5] <= pmem_wdata;
            endcase
        end
    end


endmodule
