module pattern_gen (
    input  wire [9:0] h_count,
    input  wire [9:0] v_count,
    input  wire       video_on,
    input  wire [7:0] offset,     // For scrolling/animation
    output reg  [3:0] red,
    output reg  [3:0] green,
    output reg  [3:0] blue
);

    wire [4:0] local_x = (h_count + offset) & 5'h1F;
    wire [4:0] local_y = v_count & 5'h1F;

    always @(*) begin
        if (!video_on) begin
            {red, green, blue} = 12'h000;
        end else begin
            // LATENCY TEST: A single white pixel that "flickers" on specific counts
            if (h_count == offset && v_count == offset) 
                {red, green, blue} = 12'hFFF;
            
            // QUADRANT 1: Scrolling Stripes (Top-Left)
            else if (h_count < 320 && v_count < 240) begin
                if (((h_count + offset) & 6'h3F) < 21)      {red, green, blue} = 12'hF00; // Red
                else if (((h_count + offset) & 6'h3F) < 42) {red, green, blue} = 12'h0F0; // Green
                else                                   {red, green, blue} = 12'h00F; // Blue
            end
            
            // QUADRANT 2: Miniature Tiled Shapes (Top-Right)
            else if (h_count >= 320 && v_count < 240) begin
                if (((local_x-16)*(local_x-16) + (local_y-16)*(local_y-16)) < 64)
                    {red, green, blue} = 12'hFF0; // Yellow Circles
                else
                    {red, green, blue} = 12'h440; // Background
            end
            
            // QUADRANT 4: Big Bouncing Diamond (Bottom-Right) - Moved up to avoid logic overlap
            else if (h_count >= 320 && v_count >= 240) begin
                if (((h_count > (480 + offset[5:0]) ? h_count-(480+offset[5:0]) : (480+offset[5:0])-h_count) + 
                     (v_count > 360 ? v_count-360 : 360-v_count)) < 40)
                    {red, green, blue} = 12'hF0F; 
                else
                    {red, green, blue} = 12'h222;
            end

            // QUADRANT 3: Grayscale Ramp (Bottom-Left)
            else begin
                red = h_count[7:4]; green = h_count[7:4]; blue = h_count[7:4];
            end
        end
    end
endmodule