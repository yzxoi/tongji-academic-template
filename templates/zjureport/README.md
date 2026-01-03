题目1. 利用FPGA 实现一个秒表功能。根据个人能力，实现如下功能：
1) 通过按键S2 启动秒表计时，S0 停止秒表计时，通过数码管显示计时时间，计时范围：00.00.00-
59.59.99，秒表分辨率为10ms，可以通过RESET 按键复位计时器；（1 分）
2) 通过LED0-LED7 不同的花样灯显示计时、停止状态；（1 分）
3) 秒表可以实现定时功能，从预定时间倒计时到0，并通过LED0-LED7 进行状态指示；（1 分）
4) 能够实现秒表跑圈功能，每按一次S4 按键，记录下当前秒表时间,但是不停止计数；计时结束
后（S0 按钮）可以查阅每圈秒表读数，需要至少保存四组数据；（1 分）；

Source Code:

Look at src folder.


下面是一份可直接用于提交/汇报的《FPGA 秒表/定时器系统设计报告》（Verilog 实现），内容按“任务需求 → 总体方案 → 模块设计 → 关键细节与创新 → 约束与上板 → 测试与结果 → 总结”组织，请你根据 src 目录下实际的代码进行修改。

FPGA 秒表/定时器系统设计报告（Verilog）

1. 项目概述

本项目基于 FPGA 使用 Verilog HDL 实现一套秒表 + 定时倒计时 + 跑圈（Lap）记录的计时系统。系统支持：
	•	秒表正计时：00.00.00 ～ 59.59.99（分.秒.百分秒），分辨率 10ms；
	•	定时倒计时：从预设时间倒计时到 0，完成后给出 LED 状态指示；
	•	跑圈功能：计时过程中按键记录时间点，停止后可浏览，至少保存 4 组；
	•	数码管显示：8 位显示（实际使用 6 位显示时间 + 2 位可空白），带小数点；
	•	LED 花样灯：以不同灯效区分 running / stop / done 等状态。

系统采用模块化设计，保证可读性、可维护性与可扩展性。

⸻

2. 需求分析与功能分解

2.1 功能需求（对应题目）

功能点	需求描述	设计实现方式
1	S2 启动，S0 停止，RESET 复位；显示范围 00.00.00～59.59.99，10ms 分辨率	10ms tick + BCD 计数链（正计时进位/倒计时借位）
2	LED0-LED7 花样灯区分计时/停止状态	LED 状态机 + running/done 驱动不同灯效
3	定时功能：从预设时间倒计时到 0，LED 指示	SW 预置（BCD MMSS）+ timer mode 倒计时 + done 标志
4	跑圈：S4 记录但不停表，停止后可查看；至少保存 4 组	Lap 存储 RAM（寄存器数组）+ 写指针/浏览指针

2.2 硬件特性带来的关键约束

本实验板数码管不是“单 8 位共用段线”结构，而是：
	•	两组段选信号：seg[7:0] 与 seg_data_1_pin[7:0]
	•	位选分成两组 4 位：通常 an[3:0] 对应第一组 4 位、an[7:4] 对应第二组 4 位

因此显示驱动必须采用“双 4 位扫描器并行”的方式，而不是传统的单 8 位 multiplex 扫描。这一点是上板调试中最关键的结构性问题，也是本设计的重要亮点之一。

⸻

3. 总体设计方案

3.1 系统结构框图（模块划分）

            ┌───────────────┐
clk/reset → │ Reset Sync     │ → rst(同步复位)
            └───────┬───────┘
                    │
keys → key_pulse →  │ p_start/p_stop/p_load/p_mode/p_lap
                    ▼
            ┌───────────────────────────┐
            │ Core Control + Time Engine │
            │ mode/running/done          │
            │ BCD Up/Down counter(10ms)  │
            │ Lap RAM(4 entries)         │
            └───────┬───────────────────┘
                    │  dm/ds/dc (显示用BCD)
                    ▼
            ┌───────────────────────────┐
            │ Display Driver (Dual 4-digit)│
            │ seg1/sel1 + seg2/sel2      │
            │ dp_mask + digit mapping     │
            └───────┬───────────────────┘
                    ▼
               8位数码管显示

running/done → led_pattern → LED[7:0]

3.2 核心数据表示：采用 BCD 计数

为简化数码管译码，计时器内部采用 BCD 字段保存：
	•	m_tens, m_ones（分钟 00～59）
	•	s_tens, s_ones（秒 00～59）
	•	c_tens, c_ones（百分秒 00～99）

这样显示时无需二进制转十进制，逻辑清晰且资源开销小。

⸻

4. 关键模块设计与实现

4.1 复位同步（Reset Sync）

按键 reset_n 为异步输入，直接使用可能引发亚稳态；因此先用两级寄存器同步到系统时钟域：

reg [1:0] rst_sync;
always @(posedge clk) rst_sync <= {rst_sync[0], ~reset_n};
wire rst = rst_sync[1]; // 同步复位，高有效

意义：提高系统可靠性，避免上板随机异常。

⸻

4.2 按键消抖 + 单脉冲（key_pulse）

计时控制使用边沿触发（按一次只触发一次）。模块输出 pulse，保证一个按下动作只产生一个时钟周期的高脉冲。
（此处可在报告里附上 key_pulse 的去抖计数器原理，篇幅原因略。）

工程实践要点：
板子按键常见为低有效或带反相，本设计通过上板现象定位极性问题，并最终保证 p_start/p_stop/... 能稳定产生脉冲（这一点是调试成功的关键）。

⸻

4.3 10ms 时基生成（tick_gen）

要求分辨率 10ms，即 100Hz tick。设计为可参数化 tick 生成器：

tick_gen #(.CLK_HZ(CLK_HZ), .TICK_HZ(100)) u_tick (
    .clk(clk), .rst(rst), .tick(tick_10ms)
);

优势：若板载时钟非 100MHz，只需改 CLK_HZ 参数即可全局适配。

⸻

4.4 主控制与计时引擎（Core）

4.4.1 状态变量
	•	mode_timer：0=秒表正计时，1=定时倒计时
	•	running：运行标志
	•	done：倒计时到 0 完成标志

4.4.2 模式切换策略（防止运行中跳变）

仅在停止状态允许切换模式，避免运行中数值突变导致逻辑混乱：

if (p_mode && !running) begin
    mode_timer <= ~mode_timer;
    done       <= 1'b0;
end

4.4.3 正计时 BCD 进位链（10ms +1）

核心思路：从最低位 c_ones 开始加 1，满 9 进位；s_tens 满 5 进位；分钟十位满 5 回到 0。

代码片段（核心逻辑示意）：

if (tick_10ms && running && !mode_timer) begin
    if (c_ones != 9) c_ones <= c_ones + 1;
    else begin
        c_ones <= 0;
        if (c_tens != 9) c_tens <= c_tens + 1;
        else begin
            c_tens <= 0;
            ...
            if (m_tens == 5 && m_ones == 9 && s_tens == 5 && s_ones == 9 && c_tens == 9 && c_ones == 9)
                {m_tens,m_ones,s_tens,s_ones,c_tens,c_ones} <= 24'h000000;
        end
    end
end

4.4.4 倒计时 BCD 借位链（10ms -1）+ done 检测

倒计时从最低位减 1；若某位为 0，则借位（例如 c_ones=0 借到 9，同时 c_tens -1）。

done 判定：若当前已经为 0，则停止并置 done=1：

if (tick_10ms && running && mode_timer) begin
    if (time_all_zero) begin
        running <= 1'b0;
        done    <= 1'b1;
    end else begin
        // 借位减1（10ms）
        ...
    end
end


⸻

4.5 预置时间输入与合法性裁剪（SW BCD）

预置时间用 SW 提供 BCD：MMSS。为了防止输入非法（如秒十位>5），对输入进行裁剪：

wire [3:0] sw_mt = (SW[15:12] > 4'd5) ? 4'd5 : SW[15:12];
wire [3:0] sw_mo = (SW[11:8]  > 4'd9) ? 4'd9 : SW[11:8];
wire [3:0] sw_st = (SW[7:4]   > 4'd5) ? 4'd5 : SW[7:4];
wire [3:0] sw_so = (SW[3:0]   > 4'd9) ? 4'd9 : SW[3:0];

并要求仅在 timer 模式、停止状态时装载：

if (p_load && mode_timer && !running) begin
    m_tens <= sw_mt; m_ones <= sw_mo;
    s_tens <= sw_st; s_ones <= sw_so;
    c_tens <= 0;     c_ones <= 0;
    done   <= 1'b0;
end


⸻

4.6 跑圈功能（Lap）设计

4.6.1 数据结构

至少保存 4 组，每组保存 6 个 BCD 字段（MM SS CC）：

reg [3:0] lap_m_tens [0:3];
reg [3:0] lap_m_ones [0:3];
...
reg [1:0] lap_wr_idx;   // 写指针
reg [2:0] lap_count;    // 已存条数
reg [1:0] lap_view_idx; // 浏览指针
reg viewing_lap;        // 浏览模式

4.6.2 写入策略（运行中按 S4 记录，不停表）

if (p_lap && running) begin
    if (lap_count < 4) begin
        lap_m_tens[lap_wr_idx] <= m_tens;
        ...
        lap_wr_idx <= lap_wr_idx + 1'b1;
        lap_count  <= lap_count + 1'b1;
    end
end

4.6.3 停止后浏览策略（循环查看）

if (p_lap && !running && lap_count != 0) begin
    viewing_lap  <= 1'b1;
    lap_view_idx <= (lap_view_idx + 1'b1 >= lap_count[1:0]) ? 0 : (lap_view_idx + 1'b1);
end

4.6.4 显示选择（实时 vs lap）

always @(*) begin
    if (viewing_lap) begin
        dm_tens = lap_m_tens[lap_view_idx];
        ...
    end else begin
        dm_tens = m_tens;
        ...
    end
end


⸻

4.7 显示驱动（核心难点）：双 4 位数码管并行扫描

4.7.1 为什么不能用传统 8 位扫描？

上板调试发现：
	•	仅驱动一组段线时只能亮一半数码管；
	•	说明硬件结构为 两块 4 位数码管 + 两组段线；
	•	必须采用“两路 4 位扫描器”并行输出，分别驱动 seg1/sel1 和 seg2/sel2。

4.7.2 顶层数字映射（并处理高低位反向）

最终确定实际板上“左/右位序”与 d0~d7 定义相反，因此通过映射调整保证显示正常。示例（根据你们最终校准结果选择顺序）：

// 例：把 CC 放最右，MM 放更左；空白补位
wire [3:0] dig0 = dc_ones;
wire [3:0] dig1 = dc_tens;
wire [3:0] dig2 = ds_ones;
wire [3:0] dig3 = ds_tens;
wire [3:0] dig4 = dm_ones;
wire [3:0] dig5 = dm_tens;
wire [3:0] dig6 = 4'hF; // blank
wire [3:0] dig7 = 4'hF; // blank

4.7.3 小数点控制（dp_mask）

显示格式 MM.SS.CC，常见做法是点亮“分钟个位后”和“秒个位后”的小数点。
注意 dp 与段选同属 8 位输出的一部分。

wire [7:0] dp_mask = 8'b0001_0100; // dp_mask[4]=1, dp_mask[2]=1

4.7.4 双 4 位扫描模块 disp8_dual4
	•	内部生成一个较慢 scan_clk（类似示例工程）；
	•	实例化两份 seg_decoder_dp，分别扫描 4 位；
	•	将 sel1 填入 an[3:0]，sel2 填入 an[7:4]。

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

4.7.5 段码译码与空白处理

为了让 dig6/dig7 空白，译码中将 4'hF 映射为全灭：

4'hF: seg[6:0] = 7'b0000000; // blank

工程效果：显示稳定、无闪烁、能同时驱动两半数码管，满足格式与 dp 显示要求。

⸻

4.8 LED 花样灯（状态可视化）

LED 用于直观区分系统状态：

【待补充】

代码结构采用 led_pattern 模块，输入 running, done，内部用分频计数器生成不同节拍与灯型。

⸻

7. 创新点与工程亮点（重点强调）
	1.	硬件结构自适应的显示方案：
通过对 .xdc 与上板现象分析，识别“两组段线 + 两组位选”结构，采用“双 4 位并行扫描”替代传统 8 位扫描，解决半屏显示与闪烁问题。这是本项目最关键的工程适配点。
	2.	全 BCD 计时链：
直接以 BCD 保存并完成进位/借位，无需 binary-to-BCD 转换，逻辑更直观、资源开销更低，并天然适配数码管显示。
	3.	Lap 记录与浏览一体化：
运行中写入、停止后浏览共享一套数据结构，通过指针与状态位切换实现“记录不停表、停止可回看”的完整跑圈流程，满足任务要求且扩展方便（可扩展更多圈数）。
	4.	健壮性细节：
	•	复位同步降低亚稳态风险；
	•	模式切换限制在停止态，避免运行中跳变；
	•	SW 预置裁剪确保合法时间范围；
	•	done 状态锁存与 LED 提示增强可用性。

⸻

8. 总结与可扩展方向

本设计在满足题目功能点的基础上，实现了稳定可靠的秒表/定时器系统，并针对实验板数码管特殊硬件结构给出了工程级解决方案。
后续可扩展方向包括：
	•	Lap 存储从 4 组扩展到更多（用 BRAM 或更大寄存器阵列）；
	•	增加“清零/暂停继续”等附加控制；
	•	倒计时完成增加蜂鸣器/PWM 输出；
	•	添加串口输出（记录 lap 数据到 PC）。
