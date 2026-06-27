module vga_sync (
    input  wire        clk,        // 25.175 MHz Pixel Clock
    input  wire        rst,        // Reset
    output reg  [9:0]  h_count,    // Horizontal position (0-799)
    output reg  [9:0]  v_count,    // Vertical position (0-524)
    output wire        h_sync,     // Horizontal Sync Pulse
    output wire        v_sync,     // Vertical Sync Pulse
    output wire        video_on    // High when pixels are in the 640x480 area
);

    // VESA Standard 640x480 @ 60Hz Constants
    // Horizontal
    localparam H_ACTIVE = 640;
    localparam H_FRONT  = 16;
    localparam H_SYNC   = 96;
    localparam H_BACK   = 48;
    localparam H_TOTAL  = 800;

    // Vertical
    localparam V_ACTIVE = 480;
    localparam V_FRONT  = 10;
    localparam V_SYNC   = 2;
    localparam V_BACK   = 33;
    localparam V_TOTAL  = 525;

    // 1. Horizontal Counter
    always @(posedge clk or posedge rst) begin
        if (rst)
            h_count <= 0;
        else if (h_count == H_TOTAL - 1)
            h_count <= 0;
        else
            h_count <= h_count + 1;
    end

    // 2. Vertical Counter (Increments only when H_COUNT hits the end of a line)
    always @(posedge clk or posedge rst) begin
        if (rst)
            v_count <= 0;
        else if (h_count == H_TOTAL - 1) begin
            if (v_count == V_TOTAL - 1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end
    end

    // 3. Generate Sync Pulses (Active-Low)
    assign h_sync = (h_count >= (H_ACTIVE + H_FRONT) && h_count < (H_ACTIVE + H_FRONT + H_SYNC)) ? 1'b0 : 1'b1;
    assign v_sync = (v_count >= (V_ACTIVE + V_FRONT) && v_count < (V_ACTIVE + V_FRONT + V_SYNC)) ? 1'b0 : 1'b1;

    // 4. Video On Logic (High only in the active 640x480 window)
    assign video_on = (h_count < H_ACTIVE) && (v_count < V_ACTIVE);

endmodule