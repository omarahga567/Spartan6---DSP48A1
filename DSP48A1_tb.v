module DSP48A1_tb ();
// parameters added if needed to change them
parameter A0REG=0;parameter A1REG=1;parameter B0REG=0;parameter B1REG=1;
parameter CREG=1;parameter DREG=1;parameter PREG=1;parameter MREG=1;
parameter CARRYINREG=1;parameter OPMODEREG=1;parameter CARRYOUTREG=1;
parameter CARRYINSEL="OPMODE5";parameter B_INPUT="DIRECT";parameter RSTTYPE="SYNC";
//input signals
reg [17:0] A, B, D;
reg [47:0] C;
reg CLK, CARRYIN, RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE;
reg CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE;
reg [7:0] OPMODE;
reg [17:0] BCIN;
reg [47:0] PCIN;
//output signals   
wire [17:0] BCOUT;
wire [47:0] PCOUT;
wire [47:0] P;
wire [35:0] M;
wire CARRYOUT, CARRYOUTF;

reg [47:0] past_p_out;
reg past_carryout_out;
// Instantiate the DSP48A1_TOP module
DSP48A1 #(
    .A0REG(A0REG), .A1REG(A1REG), .B0REG(B0REG), .B1REG(B1REG),
    .CREG(CREG), .DREG(DREG), .PREG(PREG), .MREG(MREG),
    .CARRYINREG(CARRYINREG), .OPMODEREG(OPMODEREG), .CARRYOUTREG(CARRYOUTREG),
    .CARRYINSEL(CARRYINSEL), .B_INPUT(B_INPUT), .RSTTYPE(RSTTYPE)
) DUT (
    .A(A), .B(B), .C(C), .D(D),
    .CLK(CLK), .CARRYIN(CARRYIN),
    .OPMODE(OPMODE), .BCIN(BCIN), 
    .RSTA(RSTA), .RSTB(RSTB), .RSTM(RSTM), 
    .RSTP(RSTP), .RSTC(RSTC), .RSTD(RSTD),
    .RSTCARRYIN(RSTCARRYIN), .RSTOPMODE(RSTOPMODE),
    .CEA(CEA), .CEB(CEB), .CEM(CEM), 
    .CEP(CEP), .CEC(CEC), .CED(CED),
    .CECARRYIN(CECARRYIN), .CEOPMODE(CEOPMODE),
    .PCIN(PCIN),
    .BCOUT(BCOUT), 
    .PCOUT(PCOUT),
    .P(P),
    .M(M),
    .CARRYOUT(CARRYOUT),
    .CARRYOUTF(CARRYOUTF)
);
// clock generation
initial begin
    CLK = 0;
    forever #1 CLK = ~CLK; 
end
//test module
initial begin
  //test 1: Verify Reset Operation
  RSTA = 1; RSTB = 1; RSTM = 1; RSTP = 1; RSTC = 1; RSTD = 1; RSTCARRYIN = 1; RSTOPMODE = 1; // Assert all resets by setting them 1
  A=$random; B=$random; C=$random; D=$random; OPMODE=$random; BCIN=$random; PCIN=$random;CARRYIN=$random;
  CEA=$random; CEB=$random; CEM=$random; CEP=$random; CEC=$random; CED=$random; CECARRYIN=$random; CEOPMODE=$random;//Drive remaining inputs with (random) values.
  @(negedge CLK);
  if (BCOUT!=0||PCOUT!=0||P!=0||M!=0||CARRYOUT!=0||CARRYOUTF!=0) begin
    $display("ERROR - (Verify Reset Operation test) Failed - Outputs not zero after reset");
    $stop;
  end else begin
    $display("Correct outputs - (Verify Reset Operation test) Passed - Outputs are zero after reset");
  end
  RSTA = 0; RSTB = 0; RSTM = 0; RSTP = 0; RSTC = 0; RSTD = 0; RSTCARRYIN = 0; RSTOPMODE = 0; // Deassert resets 
  CEA=1; CEB=1; CEM=1; CEP=1; CEC=1; CED=1; CECARRYIN=1; CEOPMODE=1; //assert all clock enable signals


  //test 2: Verify DSP Path 1
  OPMODE = 8'b11011101;
    A=18'd20; B=18'd10; C=48'd350; D=18'd25;
    BCIN=$random; PCIN=$random; CARRYIN=$random;
    repeat(4) @(negedge CLK); // Wait for 4 clock cycles
    if (BCOUT!=18'hf) begin
        $display("ERROR - (verify DSP path 1 test) Failed - BCOUT output is wrong value BCOUT=%h  expected= 18'hf", BCOUT);
        $stop;
    end else begin
        $display("Correct BCOUT output  BCOUT=%h  expected= 18'hf", BCOUT);
    end
     if (M!=36'h12c) begin
        $display("ERROR - (verify DSP path 1 test) Failed - M output is wrong value M=%h  expected= 36'h12c", M);
        $stop;
    end else begin
        $display("Correct M output  M=%h  expected= 36'h12c", M);
    end
     if (P!=48'h32) begin
        $display("ERROR - (verify DSP path 1 test) Failed - P output is wrong value P=%h  expected= 48'h32", P);
        $stop;
     end else if (PCOUT!=P) begin
        $display("ERROR - (verify DSP path 1 test) Failed - PCOUT output is NOT equal P output value    PCOUT=%h  expected=%h", PCOUT, P);
        $stop;
    end else begin
        $display("Correct P and PCOUT output values  P=%h   PCOUT=%h  expected= 48'h32", P, PCOUT);
    end
    if (CARRYOUT!=1'b0) begin
            $display("ERROR - (verify DSP path 1 test) Failed - CARRYOUT output is wrong value CARRYOUT=%b  expected= 1'b0", CARRYOUT);
            $stop;
    end else if (CARRYOUTF!=CARRYOUT) begin
            $display("ERROR - (verify DSP path 1 test) Failed - CARRYOUTF output is NOT equal CARRYOUT output value    CARRYOUTF=%b  expected= %b", CARRYOUTF, CARRYOUT);
    end else begin
            $display("Correct CARRYOUT and CARRYOUTF output values  CARRYOUT=%b  CARRYOUTF=%b  expected= 1'b0", CARRYOUT, CARRYOUTF);
    end
          $display("Correct outputs - (Verify DSP Path 1 test) Passed - Outputs are correct after DSP path 1 operation");     


//test 3: Verify DSP Path 2
   OPMODE=8'b00010000;
    A=18'd20; B=18'd10; C=48'd350; D=18'd25;
    BCIN=$random; PCIN=$random; CARRYIN=$random;
    repeat(3) @(negedge CLK); // Wait for 3 clock cycles
    if (BCOUT!=18'h23) begin
        $display("ERROR - (verify DSP path 2 test) Failed - BCOUT output is wrong value BCOUT=%h  expected= 18'h23", BCOUT);
        $stop;
    end else begin
        $display("Correct BCOUT output  BCOUT=%h  expected= 18'h23", BCOUT);
    end
     if (M!=36'h2bc) begin
        $display("ERROR - (verify DSP path 2 test) Failed - M output is wrong value M=%h  expected= 36'h2bc", M);
        $stop;
    end else begin
        $display("Correct M output  M=%h  expected= 36'h2bc", M);
    end
     if (P!=48'h0) begin
        $display("ERROR - (verify DSP path 2 test) Failed - P output is wrong value P=%h  expected= 48'h0", P);
        $stop;
     end else if (PCOUT!=P) begin
        $display("ERROR - (verify DSP path 2 test) Failed - PCOUT output is NOT equal P output value    PCOUT=%h  expected=%h", PCOUT, P);
        $stop;
    end else begin
        $display("Correct P and PCOUT output values  P=%h   PCOUT=%h  expected= 48'h0", P, PCOUT);
    end
    if (CARRYOUT!=1'b0) begin
            $display("ERROR - (verify DSP path 2 test) Failed - CARRYOUT output is wrong value CARRYOUT=%b  expected= 1'b0", CARRYOUT);
            $stop;
    end else if (CARRYOUTF!=CARRYOUT) begin
            $display("ERROR - (verify DSP path 2 test) Failed - CARRYOUTF output is NOT equal CARRYOUT output value    CARRYOUTF=%b  expected= %b", CARRYOUTF, CARRYOUT);
    end else begin
            $display("Correct CARRYOUT and CARRYOUTF output values  CARRYOUT=%b  CARRYOUTF=%b  expected= 1'b0", CARRYOUT, CARRYOUTF);
    end
            $display("Correct outputs - (Verify DSP Path 2 test) Passed - Outputs are correct after DSP path 2 operation");


//test 4: Verify DSP Path 3
   OPMODE=8'b00001010;
    A=18'd20; B=18'd10; C=48'd350; D=18'd25;
    BCIN=$random; PCIN=$random; CARRYIN=$random;
   past_p_out = P; // Store the previous P output value
   past_carryout_out = CARRYOUT; // Store the previous CARRYOUT output value
   repeat(3) @(negedge CLK); // Wait for 3 clock cycles
    if (BCOUT!=18'ha) begin
        $display("ERROR - (verify DSP path 3 test) Failed - BCOUT output is wrong value BCOUT=%h  expected= 18'ha", BCOUT);
        $stop;
    end else begin
        $display("Correct BCOUT output  BCOUT=%h  expected= 18'ha", BCOUT);
    end
     if (M!=36'hc8) begin
        $display("ERROR - (verify DSP path 3 test) Failed - M output is wrong value M=%h  expected= 36'hc8", M);
        $stop;
    end else begin
        $display("Correct M output  M=%h  expected= 36'hc8", M);
    end
     if (P!=past_p_out) begin
        $display("ERROR - (verify DSP path 3 test) Failed - P output is wrong value P=%h  expected= %h", P, past_p_out);
        $stop;
     end else if (PCOUT!=P) begin
        $display("ERROR - (verify DSP path 3 test) Failed - PCOUT output is NOT equal P output value    PCOUT=%h  expected=%h", PCOUT, P);
        $stop;
    end else begin
        $display("Correct P and PCOUT output values  P=%h   PCOUT=%h  expected=%h", P, PCOUT, past_p_out);
    end
    if (CARRYOUT!=past_carryout_out) begin
            $display("ERROR - (verify DSP path 3 test) Failed - CARRYOUT output is wrong value CARRYOUT=%b  expected= %b", CARRYOUT, past_carryout_out);
            $stop;
    end else if (CARRYOUTF!=CARRYOUT) begin
            $display("ERROR - (verify DSP path 3 test) Failed - CARRYOUTF output is NOT equal CARRYOUT output value    CARRYOUTF=%b  expected= %b", CARRYOUTF, CARRYOUT);
    end else begin
            $display("Correct CARRYOUT and CARRYOUTF output values  CARRYOUT=%b  CARRYOUTF=%b  expected= %b", CARRYOUT, CARRYOUTF, past_carryout_out);
    end
            $display("Correct outputs - (Verify DSP Path 3 test) Passed - Outputs are correct after DSP path 3 operation");



//test 5: Verify DSP Path 4
   OPMODE=8'b10100111;
    A=18'd5; B=18'd6; C=48'd350; D=18'd25;
    BCIN=$random; PCIN=48'd3000; CARRYIN=$random;
    repeat(3) @(negedge CLK); // Wait for 3 clock cycles
    if (BCOUT!=18'h6) begin
        $display("ERROR - (verify DSP path 4 test) Failed - BCOUT output is wrong value BCOUT=%h  expected= 18'h6", BCOUT);
        $stop;
    end else begin
        $display("Correct BCOUT output  BCOUT=%h  expected= 18'h6", BCOUT);
    end
     if (M!=36'h1e) begin
        $display("ERROR - (verify DSP path 4 test) Failed - M output is wrong value M=%h  expected= 36'h1e", M);
        $stop;
    end else begin
        $display("Correct M output  M=%h  expected= 36'h1e", M);
    end
     if (P!=48'hfe6fffec0bb1) begin
        $display("ERROR - (verify DSP path 4 test) Failed - P output is wrong value P=%h  expected= %h", P, 48'hfe6fffec0bb1);
        $stop;
     end else if (PCOUT!=P) begin
        $display("ERROR - (verify DSP path 4 test) Failed - PCOUT output is NOT equal P output value    PCOUT=%h  expected=%h", PCOUT, P);
        $stop;
    end else begin
        $display("Correct P and PCOUT output values  P=%h   PCOUT=%h  expected=%h", P, PCOUT, 48'hfe6fffec0bb1);
    end
    if (CARRYOUT!=1'b1) begin
            $display("ERROR - (verify DSP path 4 test) Failed - CARRYOUT output is wrong value CARRYOUT=%b  expected= %b", CARRYOUT, 1'b1);
            $stop;
    end else if (CARRYOUTF!=CARRYOUT) begin
            $display("ERROR - (verify DSP path 4 test) Failed - CARRYOUTF output is NOT equal CARRYOUT output value    CARRYOUTF=%b  expected= %b", CARRYOUTF, CARRYOUT);
    end else begin
            $display("Correct CARRYOUT and CARRYOUTF output values  CARRYOUT=%b  CARRYOUTF=%b  expected= %b", CARRYOUT, CARRYOUTF, 1'b1);
    end
            $display("Correct outputs - (Verify DSP Path 4 test) Passed - Outputs are correct after DSP path 4 operation");
            $display("ALL tests are passed");
            $stop;
end

endmodule