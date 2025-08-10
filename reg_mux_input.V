module reg_mux_input(in,clk,rst,ce,out);
parameter SELECTOR=1;
parameter INPUT_WIDTH=18;
parameter RSTTYPE="SYNC";
    input  clk, rst, ce;
    input  [INPUT_WIDTH-1:0] in;
    output [INPUT_WIDTH-1:0] out;

    reg [INPUT_WIDTH-1:0] q;
generate
    if(RSTTYPE == "SYNC") begin
        always @(posedge clk) begin
            if (rst) begin
                q <= 0;
            end else if (ce) begin
                q <= in;
            end
        end
    end else if (RSTTYPE == "ASYNC") begin
        always @(posedge clk or posedge rst) begin
            if (rst) begin
                q <= 0;
            end else if (ce) begin
                q <= in;
            end
        end
    end else begin
        always @(posedge clk) begin
            if (rst) begin
                q <= 0;
            end else if (ce) begin
                q <= in;
            end
        end
    end
endgenerate
assign out = (SELECTOR == 1) ? q : in;

endmodule
