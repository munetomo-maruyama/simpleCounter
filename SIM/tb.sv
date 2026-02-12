`timescale 1ns/100ps 

`define TB_CYCLE  20          //ns 
`define TB_FINISH_COUNT 10000 //cyc 

//------------------
// Top of Test Bench 
//------------------ 
module tb();

//----------------------------- 
// Generate Wave File to Check 
//----------------------------- 
initial 
begin    
    $dumpfile("tb.vcd");        
    $dumpvars(0, tb); 
end 

//------------------------------- 
// Generate Clock 
//------------------------------- 
logic clk; 
// 
initial clk = 1'b0; 
always #(`TB_CYCLE / 2) clk = ~clk; 

//-------------------------- 
// Generate Reset 
//-------------------------- 
logic res;
//
initial
begin
    res = 1'b1;
        # (`TB_CYCLE * 10)
    res = 1'b0;	 
end 

//---------------------- 
// Cycle Counter 
//---------------------- 
logic [31:0] tb_cycle_counter; 
// 
always_ff @(posedge clk, posedge res) 
begin    
    if (res)        
        tb_cycle_counter <= 32'h0;    
    else        
        tb_cycle_counter <= tb_cycle_counter + 32'h1; 
end 
//
initial
begin
    forever
    begin
        @(posedge clk);
        if (tb_cycle_counter == `TB_FINISH_COUNT)
        begin
            $display("***** SIMULATION TIMEOUT ***** at %d", tb_cycle_counter);
            $finish;
        end
    end
end

//-----------------------
// Module Under Test
//-----------------------
logic [7:0] din;
logic       load;
logic       up, dn;
logic [7:0] dout;
logic       ovf;
logic       udf;
//
TOP u_TOP
(
    .CLK   (clk),
    .RES   (res),
    //
    .DIN   (din ),   // data input
    .LOAD  (load),   // data load
    .UP    (up  ),   // count up
    .DN    (dn  ),   // count down
    //
    .DOUT  (dout),   // counter output
    .OVF   (ovf ),   // over flow
    .UDF   (udf )    // under flow
);

//-----------------
// Task: Initialize
//-----------------
task TASK_INIT();
begin
    #(`TB_CYCLE *  0);
    din  = 8'hxx;
    load = 1'b0;
    up   = 1'b0;    
    dn   = 1'b0;    
    //
    #(`TB_CYCLE *  12);
end
endtask

//----------------
// Task: Load Data
//----------------
task TASK_LOAD(input logic [7:0] data);
begin
    #(`TB_CYCLE *  0);
    din = data;
    load = 1'b1;
    //
    #(`TB_CYCLE *  1);
    din  = 8'hxx;  
    load = 1'b0;
end
endtask

//----------------
// Task: Up Count
//----------------
task TASK_UP();
begin
    #(`TB_CYCLE *  0);
    up = 1'b1;
    //
    #(`TB_CYCLE *  1);
    up = 1'b0;    
end
endtask

//------------------
// Task: Down Count
//------------------
task TASK_DOWN();
begin
    #(`TB_CYCLE *  0);
    dn = 1'b1;
    //
    #(`TB_CYCLE *  1);
    dn = 1'b0;    
end
endtask

//-----------------------
// Task: Any Combination
//-----------------------
task TASK_ANY
(
    input logic [7:0] i, // data input
    input logic       l, // data load
    input logic       u, // count up
    input logic       d  // count down
);
begin
    #(`TB_CYCLE *  0);
    din  = i;
    load = l;
    up   = u;
    dn   = d;
    //
    #(`TB_CYCLE *  1);
    din  = 8'hxx;
    load = 1'b0;
    up   = 1'b0;
    dn   = 1'b0;
end
endtask

//---------------------
// Test Pattern
//---------------------
initial
begin
    TASK_INIT();
    
    // Test Load Function
    TASK_LOAD(8'h01);
    TASK_LOAD(8'h23);
    TASK_LOAD(8'h45);
    TASK_LOAD(8'h67);
    
    // Test Up/Down
    TASK_LOAD(8'h00);
    TASK_UP  ();
    TASK_UP  ();
    TASK_UP  ();
    TASK_UP  ();
    TASK_DOWN();    
    TASK_DOWN();
    
    // Test Overflow/Underflow
    TASK_LOAD(8'hfe);
    TASK_UP  ();
    TASK_UP  ();
    TASK_UP  ();
    TASK_UP  ();
    TASK_DOWN();    
    TASK_DOWN();
    TASK_DOWN();    
    TASK_DOWN();
    
    // Test Conflict
    TASK_ANY(8'h12, 1'b1, 1'b1, 1'b1); // load
    TASK_ANY(8'h34, 1'b1, 1'b0, 1'b1); // load
    TASK_ANY(8'h56, 1'b1, 1'b1, 1'b0); // load
    TASK_ANY(8'h78, 1'b0, 1'b1, 1'b1); // up
    TASK_ANY(8'h9a, 1'b0, 1'b0, 1'b1); // down

    // End of Simulation
    #(`TB_CYCLE * 20);
    $finish; 
end

endmodule
