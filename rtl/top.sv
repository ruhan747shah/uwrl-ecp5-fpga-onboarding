module top #(
    parameter integer HALF_PERIOD_CYCLES = 12_500_000
) (
    input  logic clk_25mhz,
    output logic led = 1'b0
);

    localparam integer COUNTER_WIDTH =
        (HALF_PERIOD_CYCLES > 1) ? $clog2(HALF_PERIOD_CYCLES) : 1;

    logic [COUNTER_WIDTH-1:0] counter = '0;

    always_ff @(posedge clk_25mhz) begin
        if (counter == HALF_PERIOD_CYCLES - 1) begin
            counter <= '0;
            led <= ~led;
        end
        else begin
            counter <= counter + 1'b1;
        end
    end

endmodule