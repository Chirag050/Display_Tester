`timescale 1ns / 1ps

module tb_hdmi_system();
    reg clk_100MHz = 0;
    reg reset;
    
    // Differential signals are wires
    wire hdmi_tx_clk_p, hdmi_tx_clk_n;
    wire [2:0] hdmi_tx_p, hdmi_tx_n;

    // Instantiate Top Module
    hdmi_top uut (
        .clk_100MHz(clk_100MHz),
        .reset(reset),
        .hdmi_tx_clk_p(hdmi_tx_clk_p),
        .hdmi_tx_clk_n(hdmi_tx_clk_n),
        .hdmi_tx_p(hdmi_tx_p),
        .hdmi_tx_n(hdmi_tx_n)
    );

    // 100MHz Clock Generation
    always #5 clk_100MHz = ~clk_100MHz;

    initial begin
        // Initialize
        reset = 1;
        #100;
        reset = 0;
        
        $display("HDMI System Simulation Started...");
        
        // Run long enough to see the first few lines of video
        // Since we have a clock divider/wizard, we need extra time
        #500000; 
        $display("Simulation Finished");
        $finish;
    end
endmodule