module hdmi_top (
    input  wire        clk_100MHz,    // Pin H16
    input  wire        reset,         // Pin D19
    output wire        hdmi_tx_clk_p, // HDMI Clock +
    output wire        hdmi_tx_clk_n, // HDMI Clock -
    output wire [2:0]  hdmi_tx_p,     // HDMI Data +
    output wire [2:0]  hdmi_tx_n      // HDMI Data -
);

    // Internal Signals
    wire [9:0] h_c, v_c;
    wire v_on, h_s, v_s;
    wire [3:0] r, g, b;
    wire pix_clk, ser_clk, locked;
    reg [7:0] off_reg = 0;

    // 1. Clocking Wizard IP 
    // You must generate this IP in Vivado with 25.2MHz and 126MHz outputs
    clk_wiz_0 clk_gen (
        .clk_in1(clk_100MHz),
        .clk_out1(pix_clk),   // 25.2 MHz
        .clk_out2(ser_clk),   // 126.0 MHz
        .reset(reset),
        .locked(locked)
    );

    // 2. Motion Offset Logic
    always @(posedge pix_clk) begin
        if (reset || !locked) 
            off_reg <= 0;
        else if (h_c == 799 && v_c == 524) 
            off_reg <= off_reg + 1;
    end

    // 3. Timing Generator (The Conductor)
    vga_sync sync_i (
        .clk(pix_clk), .rst(reset), 
        .h_count(h_c), .v_count(v_c), 
        .h_sync(h_s), .v_sync(v_s), .video_on(v_on)
    );

    // 4. Pattern Generator (The Artist)
    pattern_gen art_i (
        .h_count(h_c), .v_count(v_c), .video_on(v_on), 
        .offset(off_reg), .red(r), .green(g), .blue(b)
    );

    // 5. HDMI/DVI Encoder (The Downloaded GitHub Module)
    rgb2dvi #(
        .kGenerateSerialClk(1'b0), 
        .kClkPrimitive("MMCM")
    ) encoder (
        .TMDS_Clk_p(hdmi_tx_clk_p), .TMDS_Clk_n(hdmi_tx_clk_n),
        .TMDS_Data_p(hdmi_tx_p),    .TMDS_Data_n(hdmi_tx_n),
        .aRst(reset),
        .vid_pData({r, 4'b0, g, 4'b0, b, 4'b0}), // 4-bit to 8-bit padding
        .vid_pVDE(v_on),
        .vid_pHSync(h_s),
        .vid_pVSync(v_s),
        .PixelClk(pix_clk),
        .SerialClk(ser_clk)
    );

endmodule