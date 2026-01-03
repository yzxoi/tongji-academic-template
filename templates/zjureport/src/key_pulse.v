module key_pulse #(
    parameter integer CLK_HZ = 100_000_000,
    parameter integer DEBOUNCE_MS = 20
)(
    input  wire clk,
    input  wire rst,
    input  wire key_in,
    output wire pulse
);
    localparam integer CNT_MAX = (CLK_HZ/1000)*DEBOUNCE_MS;

    reg key_sync1, key_sync2;
    always @(posedge clk) begin
        key_sync1 <= key_in;
        key_sync2 <= key_sync1;
    end

    reg stable;
    reg [$clog2(CNT_MAX+1)-1:0] cnt;
    reg debounced;

    always @(posedge clk) begin
        if (rst) begin
            stable    <= 0;
            cnt       <= 0;
            debounced <= 0;
        end else begin
            if (key_sync2 == stable) begin
                cnt <= 0;
            end else begin
                if (cnt == CNT_MAX-1) begin
                    stable <= key_sync2;
                    cnt    <= 0;
                end else begin
                    cnt <= cnt + 1;
                end
            end
            debounced <= stable;
        end
    end

    reg debounced_d;
    always @(posedge clk) begin
        if (rst) debounced_d <= 0;
        else     debounced_d <= debounced;
    end

    assign pulse = debounced & ~debounced_d;

endmodule
