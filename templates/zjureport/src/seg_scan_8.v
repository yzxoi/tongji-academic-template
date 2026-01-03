module disp8_dual4 #(
    parameter integer CLK_HZ = 100_000_000,
    parameter integer SCAN_DIV = 250000
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [3:0]  d0,d1,d2,d3,d4,d5,d6,d7,
    input  wire [7:0]  dp_mask, // dp_mask[i]=1 点亮第i位小数点

    output wire [7:0]  seg1,
    output wire [7:0]  seg2,
    output wire [7:0]  an
);

    reg [19:0] CNT;
    reg scan_clk;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            CNT      <= 0;
            scan_clk <= 0;
        end else if(CNT == SCAN_DIV) begin
            CNT      <= 0;
            scan_clk <= ~scan_clk;
        end else begin
            CNT <= CNT + 1'b1;
        end
    end

    // 低4位（d0~d3）-> seg + an[3:0]
    wire [7:0] seg_lo;
    wire [3:0] sel1;
    seg_decoder_dp u_lo (
        .rst_n(rst_n),
        .clk(scan_clk),
        .dat({d3,d2,d1,d0}),
        .dp_mask(dp_mask[3:0]),
        .seg(seg_lo),
        .sel(sel1)
    );

    // 高4位（d4~d7）-> seg_data_1_pin + an[7:4]
    wire [7:0] seg_hi;
    wire [3:0] sel2;
    seg_decoder_dp u_hi (
        .rst_n(rst_n),
        .clk(scan_clk),
        .dat({d7,d6,d5,d4}),
        .dp_mask(dp_mask[7:4]),
        .seg(seg_hi),
        .sel(sel2)
    );

    assign seg1 = seg_lo;
    assign seg2 = seg_hi;
    assign an[3:0] = sel1;
    assign an[7:4] = sel2;

endmodule


module seg_decoder_dp (
    input  wire        rst_n,
    input  wire        clk,
    input  wire [15:0] dat, // 4 BCD：{d3,d2,d1,d0}
    input  wire [3:0]  dp_mask,
    output reg  [7:0]  seg,  // [6:0]=a~g, [7]=dp
    output reg  [3:0]  sel
);

    reg [3:0] display_dat;
    reg dp_on;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sel <= 4'b0001;
        end else begin
            case(sel)
                4'b0001: sel <= 4'b0010;
                4'b0010: sel <= 4'b0100;
                4'b0100: sel <= 4'b1000;
                4'b1000: sel <= 4'b0001;
                default: sel <= 4'b0001;
            endcase
        end
    end

    always @(*) begin
        case(sel)
            4'b0001: begin display_dat = dat[3:0];   dp_on = dp_mask[0]; end
            4'b0010: begin display_dat = dat[7:4];   dp_on = dp_mask[1]; end
            4'b0100: begin display_dat = dat[11:8];  dp_on = dp_mask[2]; end
            4'b1000: begin display_dat = dat[15:12]; dp_on = dp_mask[3]; end
            default: begin display_dat = dat[3:0];   dp_on = 1'b0;       end
        endcase
    end

    always @(*) begin
        case (display_dat)
            4'h0: seg[6:0] = 7'b0111111;
            4'h1: seg[6:0] = 7'b0000110;
            4'h2: seg[6:0] = 7'b1011011;
            4'h3: seg[6:0] = 7'b1001111;
            4'h4: seg[6:0] = 7'b1100110;
            4'h5: seg[6:0] = 7'b1101101;
            4'h6: seg[6:0] = 7'b1111101;
            4'h7: seg[6:0] = 7'b0000111;
            4'h8: seg[6:0] = 7'b1111111;
            4'h9: seg[6:0] = 7'b1101111;
            4'hA: seg[6:0] = 7'b1110111;
            4'hB: seg[6:0] = 7'b1111100;
            4'hC: seg[6:0] = 7'b0111001;
            4'hD: seg[6:0] = 7'b1011110;
            4'hE: seg[6:0] = 7'b1111001;
            4'hF: seg[6:0] = 7'b0000000;
            default: seg[6:0] = 7'b0000000;
        endcase
        seg[7] = dp_on;
    end

endmodule
