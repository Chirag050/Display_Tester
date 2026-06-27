`timescale 1ns / 1ps

module tb_vga_sync();
    // Inputs
    reg clk;
    reg rst;

    // Outputs
    wire [9:0] h_count;
    wire [9:0] v_count;
    wire h_sync;
    wire v_sync;
    wire video_on;

    // Instantiate the Unit Under Test (UUT)
    vga_sync uut (
        .clk(clk),
        .rst(rst),
        .h_count(h_count),
        .v_count(v_count),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .video_on(video_on)
    );

    // Generate 25.175 MHz Clock (approx 39.72ns period)
    initial clk = 0;
    always #19.86 clk = ~clk;

    initial begin
        // Initialize Inputs
        rst = 1;
        #100;
        rst = 0; // Release reset

        // Run for enough time to see at least one full Vertical frame
        // 1 frame at 60Hz = 16.67ms. We run for 20ms to be safe.
        #200000000; 
        
        $display("Simulation Finished");
        $finish;
    end
endmodule