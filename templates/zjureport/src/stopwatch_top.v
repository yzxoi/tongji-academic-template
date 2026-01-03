`timescale 1ns/1ps

module stopwatch_top #(
    parameter integer CLK_HZ = 100_000_000
)(
    input  wire        clk,
    input  wire        reset_n,
    input  wire        S0_stop,
    input  wire        S1_load,
    input  wire        S2_start,
    input  wire        S3_mode, // 0 正计时，1 倒计时
    input  wire        S4_lap,
    input  wire [15:0] SW,  // 预置时间输入（BCD：MM,SS）
    output wire [7:0]  led,
    output wire [7:0]  seg1,  // 段选 a b c d e f g dp
    output wire [7:0]  seg2,
    output wire [7:0]  an  // 位选
);

    reg [1:0] rst_sync;
    always @(posedge clk) rst_sync <= {rst_sync[0], ~reset_n};
    wire rst = rst_sync[1]; // rst=1 同步复位

    wire p_stop, p_start, p_load, p_mode, p_lap;
    key_pulse #(.CLK_HZ(CLK_HZ)) u_k0 (.clk(clk), .rst(rst), .key_in(S0_stop),  .pulse(p_stop));
    key_pulse #(.CLK_HZ(CLK_HZ)) u_k1 (.clk(clk), .rst(rst), .key_in(S1_load),  .pulse(p_load));
    key_pulse #(.CLK_HZ(CLK_HZ)) u_k2 (.clk(clk), .rst(rst), .key_in(S2_start), .pulse(p_start));
    key_pulse #(.CLK_HZ(CLK_HZ)) u_k3 (.clk(clk), .rst(rst), .key_in(S3_mode),  .pulse(p_mode));
    key_pulse #(.CLK_HZ(CLK_HZ)) u_k4 (.clk(clk), .rst(rst), .key_in(S4_lap),   .pulse(p_lap));

    wire tick_10ms;
    tick_gen #(.CLK_HZ(CLK_HZ), .TICK_HZ(100)) u_tick (
        .clk(clk), .rst(rst), .tick(tick_10ms)
    );

    reg mode_timer;  // 0=stopwatch up, 1=timer down
    reg running;
    reg done;   // timer 到0标志

    // 当前计时值（BCD）
    reg [3:0] m_tens, m_ones, s_tens, s_ones, c_tens, c_ones;

    // lap 存储（4组循环）
    reg [3:0] lap_m_tens [0:3];
    reg [3:0] lap_m_ones [0:3];
    reg [3:0] lap_s_tens [0:3];
    reg [3:0] lap_s_ones [0:3];
    reg [3:0] lap_c_tens [0:3];
    reg [3:0] lap_c_ones [0:3];

    reg [1:0] lap_wr_idx;   // 写入lap索引 0..3
    reg [2:0] lap_count;
    reg [1:0] lap_view_idx;
    reg       viewing_lap;   // 0显示当前计时；1显示lap

    // 预置时间合法性裁剪（分钟十位/秒十位<=5）
    wire [3:0] sw_mt = (SW[15:12] > 4'd5) ? 4'd5 : SW[15:12];
    wire [3:0] sw_mo = (SW[11:8]  > 4'd9) ? 4'd9 : SW[11:8];
    wire [3:0] sw_st = (SW[7:4]   > 4'd5) ? 4'd5 : SW[7:4];
    wire [3:0] sw_so = (SW[3:0]   > 4'd9) ? 4'd9 : SW[3:0];

    integer i;
    always @(posedge clk) begin
        if (rst) begin
            mode_timer  <= 1'b0;
            running     <= 1'b0;
            done        <= 1'b0;

            m_tens <= 0; m_ones <= 0; s_tens <= 0; s_ones <= 0; c_tens <= 0; c_ones <= 0;

            lap_wr_idx <= 0; lap_count <= 0; lap_view_idx <= 0;
            viewing_lap <= 1'b0;

            for (i=0; i<4; i=i+1) begin
                lap_m_tens[i] <= 0; lap_m_ones[i] <= 0; lap_s_tens[i] <= 0; lap_s_ones[i] <= 0; lap_c_tens[i] <= 0; lap_c_ones[i] <= 0;
            end
        end else begin
            // 仅在停止时模式切换
            if (p_mode && !running) begin
                mode_timer <= ~mode_timer;
                done <= 1'b0;
            end

            if (p_start) begin
                if (!done) begin
                    running    <= 1'b1;
                    viewing_lap<= 1'b0;
                end
            end
            if (p_stop) begin
                running     <= 1'b0;
                viewing_lap <= 1'b0;
            end

            if (p_load && mode_timer && !running) begin
                m_tens <= sw_mt; m_ones <= sw_mo;  s_tens <= sw_st; s_ones <= sw_so; c_tens <= 0; c_ones <= 0;
                done <= 1'b0;
            end

            // Lap：运行中记录；停止后查阅
            if (p_lap) begin
                if (running) begin
                    lap_m_tens[lap_wr_idx] <= m_tens;
                    lap_m_ones[lap_wr_idx] <= m_ones;
                    lap_s_tens[lap_wr_idx] <= s_tens;
                    lap_s_ones[lap_wr_idx] <= s_ones;
                    lap_c_tens[lap_wr_idx] <= c_tens;
                    lap_c_ones[lap_wr_idx] <= c_ones;

                    lap_wr_idx <= lap_wr_idx + 1'b1;
                    if (lap_count < 3'd4) lap_count <= lap_count + 3'd1;
                end else begin
                    if (lap_count != 0) begin
                        if (!viewing_lap) begin
                            viewing_lap  <= 1'b1;
                            lap_view_idx <= 2'd0;
                        end else begin
                            if (lap_view_idx == (lap_count - 1)) lap_view_idx <= 2'd0;
                            else lap_view_idx <= lap_view_idx + 2'd1;
                        end
                    end
                end
            end

            if (tick_10ms && running) begin
                if (!mode_timer) begin
                    if (c_ones != 9) c_ones <= c_ones + 1;
                    else begin
                        c_ones <= 0;
                        if (c_tens != 9) c_tens <= c_tens + 1;
                        else begin
                            c_tens <= 0;
                            if (s_ones != 9) s_ones <= s_ones + 1;
                            else begin
                                s_ones <= 0;
                                if (s_tens != 5) s_tens <= s_tens + 1;
                                else begin
                                    s_tens <= 0;
                                    if (m_ones != 9) m_ones <= m_ones + 1;
                                    else begin
                                        m_ones <= 0;
                                        if (m_tens != 5) m_tens <= m_tens + 1;
                                        else begin
                                            m_tens <= 0;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end else begin
                    if ({m_tens,m_ones,s_tens,s_ones,c_tens,c_ones} == 24'h000000) begin
                        running <= 1'b0;
                        done    <= 1'b1;
                    end else begin
                        if (c_ones != 0) c_ones <= c_ones - 1;
                        else begin
                            c_ones <= 9;
                            if (c_tens != 0) c_tens <= c_tens - 1;
                            else begin
                                c_tens <= 9;
                                if (s_ones != 0) s_ones <= s_ones - 1;
                                else begin
                                    s_ones <= 9;
                                    if (s_tens != 0) s_tens <= s_tens - 1;
                                    else begin
                                        s_tens <= 5;
                                        if (m_ones != 0) m_ones <= m_ones - 1;
                                        else begin
                                            m_ones <= 9;
                                            if (m_tens != 0) m_tens <= m_tens - 1;
                                            else m_tens <= 0;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if (mode_timer && ({m_tens,m_ones,s_tens,s_ones,c_tens,c_ones} == 24'h000000)) begin
                if (running) begin
                    running <= 1'b0;
                    done    <= 1'b1;
                end
            end
        end
    end

    wire [1:0] lap_rd_idx = lap_wr_idx - 2'd1 - lap_view_idx;
    reg [3:0] dm_tens, dm_ones, ds_tens, ds_ones, dc_tens, dc_ones;
    always @(*) begin
        if (viewing_lap) begin
            dm_tens = lap_m_tens[lap_rd_idx];
            dm_ones = lap_m_ones[lap_rd_idx];
            ds_tens = lap_s_tens[lap_rd_idx];
            ds_ones = lap_s_ones[lap_rd_idx];
            dc_tens = lap_c_tens[lap_rd_idx];
            dc_ones = lap_c_ones[lap_rd_idx];
        end else begin
            dm_tens = m_tens; dm_ones = m_ones;
            ds_tens = s_tens; ds_ones = s_ones;
            dc_tens = c_tens; dc_ones = c_ones;
        end
    end


    wire [7:0] dp_mask = 8'b0010_1000; // 第2位、第4位显示小数（倒置）
    wire [3:0] dig7 = dc_ones;
    wire [3:0] dig6 = dc_tens;
    wire [3:0] dig5 = ds_ones;
    wire [3:0] dig4 = ds_tens;
    wire [3:0] dig3 = dm_ones;
    wire [3:0] dig2 = dm_tens;
    wire [3:0] dig1 = 4'hF;
    wire [3:0] dig0 = 4'hF;
    
    disp8_dual4 #(
        .CLK_HZ(CLK_HZ),
        .SCAN_DIV(250000)
    ) u_seg (
        .clk(clk),
        .rst_n(reset_n),
        .d0(dig0), .d1(dig1), .d2(dig2), .d3(dig3),
        .d4(dig4), .d5(dig5), .d6(dig6), .d7(dig7),
        .dp_mask(dp_mask),
        .seg1(seg1),
        .seg2(seg2),
        .an(an)
    );

    led_pattern #(.CLK_HZ(CLK_HZ)) u_led (
        .clk(clk), .rst(rst),
        .running(running),
        .done(done),
        .mode(mode_timer),
        .led(led)
    );

endmodule
