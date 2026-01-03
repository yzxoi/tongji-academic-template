module tick_gen #(
    parameter integer CLK_HZ  = 100_000_000,
    parameter integer TICK_HZ = 100
)(
    input  wire clk,
    input  wire rst,
    output reg  tick
);
    localparam integer DIV = CLK_HZ / TICK_HZ;
    reg [$clog2(DIV)-1:0] cnt;

    always @(posedge clk) begin
        if (rst) begin
            cnt  <= 0;
            tick <= 1'b0;
        end else begin
            if (cnt == DIV-1) begin
                cnt  <= 0;
                tick <= 1'b1;
            end else begin
                cnt  <= cnt + 1'b1;
                tick <= 1'b0;
            end
        end
    end
endmodule
