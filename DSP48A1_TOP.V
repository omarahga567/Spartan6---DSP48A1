module DSP48A1(A,B,C,D,CLK,CARRYIN,OPMODE,BCIN,RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE,
PCIN,BCOUT,PCOUT,P,M,CARRYOUT,CARRYOUTF);
parameter A0REG=0;
parameter A1REG=1;
parameter B0REG=0;
parameter B1REG=1;
parameter CREG=1;
parameter DREG=1;
parameter PREG=1;
parameter MREG=1;
parameter CARRYINREG=1;
parameter OPMODEREG=1;
parameter CARRYOUTREG=1;
parameter CARRYINSEL="OPMODE5";
parameter B_INPUT="DIRECT";
parameter RSTTYPE="SYNC";
input [17:0] A, B, D;
input [47:0] C;
input CLK, CARRYIN, RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE, CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE;
input [7:0] OPMODE;
input [17:0]  BCIN;
input [47:0] PCIN;
output [47:0]  PCOUT;
output [17:0]  BCOUT;
output [47:0] P;
output [35:0] M;
output CARRYOUT, CARRYOUTF;
wire [17:0] a0reg_out, a1reg_out;
wire [17:0] b0reg_out, b1reg_out,mux_bcascade_out;
wire [47:0] creg_out;
wire [17:0] dreg_out;
wire [7:0] opmodereg_out;
wire [35:0] mreg_out;
wire [47:0] DAB_concatenated;
wire carrycascade_out;
wire carryinreg_out;
wire carryoutreg_out;
wire [47:0] preg_out;
wire [47:0] mreg_extended_out;
reg [17:0] preaddsub_out;
reg [17:0] mux_preaddsub_out;
reg [35:0] mul_out;
reg [47:0] mux_x_out;
reg [47:0] mux_z_out;
reg [47:0] postaddsub_out;
reg carryout_postaddsub;
assign mux_bcascade_out = (B_INPUT == "DIRECT") ? B : (B_INPUT == "CASCADE") ? BCIN : 18'b0; // MUX THAT INDICATES THE INPUT FOR B0REG
assign carrycascade_out = (CARRYINSEL == "OPMODE5") ? opmodereg_out[5] : (CARRYINSEL == "CARRYIN") ? CARRYIN : 1'b0;//MUX THAT INDICATES THE INPUT FOR CARRYINREG
assign M=mreg_out;
assign P=preg_out;
assign PCOUT = preg_out;
assign mreg_extended_out = {12'b0,mreg_out}; // Extend MREG to 48 bits to enter the x mux with 48bit output
assign BCOUT = b1reg_out;
assign CARRYOUT = carryoutreg_out;
assign CARRYOUTF = CARRYOUT; // CARRYOUTF is the same as CARRYOUT in DSP48A1
assign DAB_concatenated={dreg_out[11:0],a1reg_out[17:0],b1reg_out[17:0]}; // Concatenate 48 bits


// Instantiate the input registers based on the parameters
//A0REG
reg_mux_input #(.SELECTOR(A0REG), .INPUT_WIDTH(18), .RSTTYPE(RSTTYPE)) a0reg (
    .in(A),
    .clk(CLK),
    .rst(RSTA),
    .ce(CEA),
    .out(a0reg_out)
);
//A1REG
reg_mux_input #(.SELECTOR(A1REG), .INPUT_WIDTH(18), .RSTTYPE(RSTTYPE)) a1reg (
    .in(a0reg_out),
    .clk(CLK),
    .rst(RSTA),
    .ce(CEA),
    .out(a1reg_out)
);
//B0REG 
reg_mux_input #(.SELECTOR(B0REG), .INPUT_WIDTH(18), .RSTTYPE(RSTTYPE)) b0reg (
    .in(mux_bcascade_out),
    .clk(CLK),
    .rst(RSTB),
    .ce(CEB),
    .out(b0reg_out)
);
//B1REG
reg_mux_input #(.SELECTOR(B1REG), .INPUT_WIDTH(18), .RSTTYPE(RSTTYPE)) b1reg (
    .in(mux_preaddsub_out),
    .clk(CLK),
    .rst(RSTB),
    .ce(CEB),
    .out(b1reg_out)
);
//CREG
reg_mux_input #(.SELECTOR(CREG), .INPUT_WIDTH(48), .RSTTYPE(RSTTYPE)) creg (
    .in(C),
    .clk(CLK),
    .rst(RSTC),
    .ce(CEC),
    .out(creg_out)
);
//DREG
reg_mux_input #(.SELECTOR(DREG), .INPUT_WIDTH(18), .RSTTYPE(RSTTYPE)) dreg (
    .in(D),
    .clk(CLK),
    .rst(RSTD),
    .ce(CED),
    .out(dreg_out)
);
//OPMODEREG
reg_mux_input #(.SELECTOR(OPMODEREG), .INPUT_WIDTH(8), .RSTTYPE(RSTTYPE)) opmodereg (
    .in(OPMODE),
    .clk(CLK),
    .rst(RSTOPMODE),
    .ce(CEOPMODE),
    .out(opmodereg_out)
);
//MREG
reg_mux_input #(.SELECTOR(MREG), .INPUT_WIDTH(36), .RSTTYPE(RSTTYPE)) mreg (
    .in(mul_out),
    .clk(CLK),
    .rst(RSTM),
    .ce(CEM),
    .out(mreg_out)
);
//CARRYINREG
reg_mux_input #(.SELECTOR(CARRYINREG), .INPUT_WIDTH(1), .RSTTYPE(RSTTYPE)) carryinreg (
    .in(carrycascade_out),
    .clk(CLK),
    .rst(RSTCARRYIN),
    .ce(CECARRYIN),
    .out(carryinreg_out)
);
//CARRYOUTREG
reg_mux_input #(.SELECTOR(CARRYOUTREG), .INPUT_WIDTH(1), .RSTTYPE(RSTTYPE)) carryoutreg (
    .in(carryout_postaddsub),
    .clk(CLK),
    .rst(RSTCARRYIN),
    .ce(CECARRYIN),
    .out(carryoutreg_out)
);
//PREG
reg_mux_input #(.SELECTOR(PREG), .INPUT_WIDTH(48), .RSTTYPE(RSTTYPE)) preg (
    .in(postaddsub_out),
    .clk(CLK),
    .rst(RSTP),
    .ce(CEP),
    .out(preg_out)
);
always @(dreg_out or b0reg_out or opmodereg_out[6] or opmodereg_out[4] or b1reg_out or a1reg_out) begin
   case (opmodereg_out[6])
         1'b0: preaddsub_out = dreg_out + b0reg_out; // ADD
         1'b1: preaddsub_out = dreg_out - b0reg_out; // SUB
   endcase
    if (opmodereg_out[4]) begin
         mux_preaddsub_out = preaddsub_out; // If OPMODE[4]=1, use the preaddsub_out
    end else begin
         mux_preaddsub_out = b0reg_out; // Otherwise, use b0reg_out
    end
    mul_out = a1reg_out * b1reg_out; // Perform multiplication
end
always @(preg_out or DAB_concatenated or mreg_extended_out or creg_out or PCIN or opmodereg_out [3:0] or carryinreg_out) begin
    //multiplexior X
    case (opmodereg_out[1:0])
        2'b00: mux_x_out = 48'h0; // 0
        2'b01: mux_x_out = mreg_extended_out; // multiplier output
        2'b10: mux_x_out = preg_out; // PREG output
        2'b11: mux_x_out = DAB_concatenated; // Concatenated DAB
    endcase
    //multiplexior Z
    case (opmodereg_out[3:2])
        2'b00: mux_z_out = 48'h0; // 0
        2'b01: mux_z_out = PCIN; // PCIN input
        2'b10: mux_z_out = preg_out; // PREG output
        2'b11: mux_z_out = creg_out; // CREG output
    endcase
    //postaddsub_out
    if (!opmodereg_out[7]) begin
       {carryout_postaddsub, postaddsub_out} = mux_x_out + mux_z_out + carryinreg_out; // If OPMODE[7]=0, perform addition
    end else begin
        {carryout_postaddsub, postaddsub_out} = mux_z_out - (mux_x_out + carryinreg_out); // Otherwise, perform subtraction
        
    end
end


endmodule