module led_pattern #(
    parameter integer CLK_HZ = 100_000_000
)(
    input  wire clk,
    input  wire rst,
    input  wire running,
    input  wire done,
    input  wire mode,
    output reg  [7:0] led
);
    reg [31:0] cnt;
    always @(posedge clk) begin
        if (rst) cnt <= 32'd0;
        else     cnt <= cnt + 32'd1;
    end

    wire slow = cnt[26];
    wire mid  = cnt[22];

    reg mid_d;
    always @(posedge clk) begin
        if (rst) begin
            mid_d  <= 1'b0;
        end else begin
            mid_d  <= mid;
        end
    end

    wire mid_pulse  = mid  & ~mid_d;

    reg [2:0] pos;
    always @(posedge clk) begin
        if (rst) begin
            pos <= 3'd0;
        end else if (running && !done && mid_pulse) begin
            pos <= pos + 3'd1;
        end
    end

    reg [3:0] step;
    reg [7:0] stop_pat;
    always @(posedge clk) begin
        if (rst) begin
            step     <= 4'd0;
            stop_pat <= 8'h00;
        end else if (!running && !done && mode && mid_pulse) begin
            if (step < 4'd8) begin
                stop_pat <= (8'h01 << step) | stop_pat;
            end else begin
                stop_pat <= stop_pat & ~(8'h01 << (step - 4'd8));
            end
            step <= step + 4'd1;
        end else if (running || done || !mode) begin
            step     <= 4'd0;
            stop_pat <= 8'h00;
        end
    end

    always @(*) begin
        if (done) begin
            led = slow ? 8'hFF : 8'h00;  // DONE£ºÈ«ÉÁ
        end else if (running) begin
            led = (8'b0000_0001 << pos); // RUN£ºÁ÷Ë®
        end else if (!mode) begin
            led = slow ? 8'hAA : 8'h55;  // STOP + mode=0£º½»ÌæÂıÉÁ
        end else begin
            led = stop_pat;    // STOP + mode=1£ºË³ĞòÁÁÃğ
        end
    end

endmodule
