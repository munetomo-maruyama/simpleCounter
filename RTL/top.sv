//----------------
// Top Module
//----------------
module TOP
(
    input  logic CLK,
    input  logic RES,
    //
    input  logic [7:0] DIN,  // data input
    input  logic       LOAD, // data load
    input  logic       UP,   // count up
    input  logic       DN,   // count down
    //
    output logic [7:0] DOUT, // counter out
    output logic       OVF,  // over flow
    output logic       UDF   // under flow
);

//-----------------
// Internal Signals
//-----------------
logic [7:0] counter;
logic       counter_min;
logic       counter_max;

//--------------
// Data Output
//--------------
assign DOUT = counter; // 8bit data

//-----------------
// Main Counter
//-----------------
always_ff @(posedge CLK, posedge RES)
begin
    if (RES)
        counter <= 8'h00;
    else if (LOAD)
        counter <= DIN;
    else if (UP)
        counter <= counter + 8'h01;
    else if (DN)
        counter <= counter - 8'h01;
end

//----------------
// Overflow Pulse
//----------------
assign counter_max = (counter == 8'hff); 
//
always_ff @(posedge CLK, posedge RES)
begin
    if (RES)
        OVF <= 1'b0;
    else if (counter_max & UP)
        OVF <= 1'b1;
    else if (OVF)
        OVF <= 1'b0;
end    

//----------------
// Underflow Pulse
//----------------
assign counter_min = (counter == 8'h00); 
//
always_ff @(posedge CLK, posedge RES)
begin
    if (RES)
        UDF <= 1'b0;
    else if (counter_min & DN)
        UDF <= 1'b1;
    else if (UDF)
        UDF <= 1'b0;
end    

endmodule
