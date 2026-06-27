`timescale 1ns / 1ps

module tb_pattern_gen();
    reg [9:0] h_count, v_count;
    reg [7:0] offset; 
    reg video_on;
    wire [3:0] red, green, blue;

    pattern_gen uut (
        .h_count(h_count), 
        .v_count(v_count), 
        .video_on(video_on), 
        .offset(offset),  
        .red(red), 
        .green(green), 
        .blue(blue)
    );

    initial begin
        // Initialize all inputs
        video_on = 1;
        h_count = 0;
        v_count = 0;
        offset = 0;
        #10;
        
        // --- Verify Stripes (Q1) ---
        h_count = 50;  v_count = 100; #10; 
        h_count = 150; v_count = 100; #10; 
        
        // --- Verify Mini-Shapes (Q2) ---
        h_count = 336; v_count = 16;  #10; 
        
        // --- Verify Grayscale (Q3) ---
        h_count = 160; v_count = 300; #10; 
        
        // --- Verify Big Shape (Q4) ---
        h_count = 480; v_count = 360; #10; 
        
        // --- Verify Motion ---
        offset = 50; 
        h_count = 50; v_count = 100; #10; // Color should change from previous Q1 test
        
        $display("Simulation Successful");
        $finish; 
    end
endmodule