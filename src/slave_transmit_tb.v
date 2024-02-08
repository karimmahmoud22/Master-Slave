`timescale 1ns / 1ps

module tb_SPI_Transmitter22();

reg clk;
reg rst;
wire sendComplete;
wire MOSI;
wire SCLK; 
wire CS;
wire MISO;
reg [7:0] sendData;
wire [7:0] recvData;

SPI_Transmitter22 transmitter1(
    .clk(clk),
    .rst(rst),
    .sendComplete(sendComplete),
    .MISO(MISO),
    .SCLK(SCLK),
    .CS(CS),
    .MOSI(MOSI),
    .sendData(sendData),
    .recvData(recvData)
);

reg [7:0] slaveData;
reg [7:0] MISOReg;
assign MOSI = slaveData[7];
// pseud slave device
always @ (posedge SCLK or negedge rst)begin
    if(rst == 1'b0)begin
        slaveData <= 8'b1000_0011;
        MISOReg <= 8'b0000_0000;
    end else begin
        slaveData <= {slaveData[6:0],1'b0};
	  MISOReg <= {MISOReg[6:0],MISO};
    end
end

always #10
    if(rst == 1'b0)
        clk <= 1'b0;
    else
        clk <= ~clk;

initial begin
    #0
    rst <= 1'b1;
    sendData <= 8'b10100010;
    MISOReg <= 8'b00000000;
    #30
    rst <= 1'b0;
	$display("Start Transmitting --> Data to send : %b, MISO_Reg : %b", sendData , MISOReg);
    #50
    rst <= 1'b1;
    #2500
	$display("End Transmitting --> Data to send : %b, MISO_Reg : %b", slaveData , MISOReg);
    $finish;
end

endmodule