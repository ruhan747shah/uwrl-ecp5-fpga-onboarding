module tb_top #(
    parameter integer HALF_PERIOD_CYCLES = 7
);

    timeunit 1ns;
    timeprecision 1ps;

    logic clk_25mhz = 1'b0;
    logic led;

    logic expected_led = 1'b0;
    integer cycle_count = 0;
    integer toggle_count = 0;

    time last_rising_edge = 0;

    top #(
        .HALF_PERIOD_CYCLES(HALF_PERIOD_CYCLES)
    ) dut (
        .clk_25mhz(clk_25mhz),
        .led(led)
    );

    // 25 MHz clock = 40 ns period
    always #20ns clk_25mhz = ~clk_25mhz;

    // Save waveform
    initial begin
        $dumpfile("build/blink.vcd");
        $dumpvars(0, tb_top);
    end

    // Record each rising edge
    always @(posedge clk_25mhz) begin
        last_rising_edge = $time;
    end

    // LED should only change at a rising clock edge
    always @(led) begin
        if (($time > 0) && ($time != last_rising_edge))
            $fatal(1, "LED changed between rising clock edges");
    end

    // Main test
    initial begin
        #1ns;

        if (led !== 1'b0)
            $fatal(1, "LED did not start low");

        while (toggle_count < 4) begin

            @(posedge clk_25mhz);
            cycle_count = cycle_count + 1;

            if (cycle_count == HALF_PERIOD_CYCLES) begin
                expected_led = ~expected_led;
                cycle_count = 0;
                toggle_count = toggle_count + 1;
            end

            #1ps;

            if ((led !== 1'b0) && (led !== 1'b1))
                $fatal(1, "LED contains X or Z");

            if (led !== expected_led)
                $fatal(1, "LED toggled at the wrong time");
        end

        $display("PASS: HALF_PERIOD_CYCLES = %0d",
                 HALF_PERIOD_CYCLES);

        $finish;
    end

    // Timeout in case design gets stuck
    initial begin
        #(40ns * HALF_PERIOD_CYCLES * 10);
        $fatal(1, "TIMEOUT");
    end

endmodule