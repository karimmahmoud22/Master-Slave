`timescale 1ns / 1ps

module tb_SPI_Transmitter();

reg clk;
reg rst;
wire sendComplete;
wire MOSI;
wire SCLK;
wire CS;
wire MISO;
reg [7:0] sendData;
wire [7:0] recvData;

SPI_Transmitter transmitter(
    .clk(clk),
    .rst(rst),
    .sendComplete(sendComplete),
    .MOSI(MOSI),
    .SCLK(SCLK),
    .CS(CS),
    .MISO(MISO),
    .sendData(sendData),
    .recvData(recvData)
);

reg [7:0] slaveData;
reg [7:0] MOSIReg;
assign MISO = slaveData[7];
// pseud slave device
always @ (posedge SCLK or negedge rst)begin
    if(rst == 1'b0)begin
        slaveData <= 8'b1000_0011;
        MOSIReg <= 8'b0000_0000;
    end else begin
        slaveData <= {slaveData[7:0],1'b0};
        MOSIReg <= {MOSIReg[7:0],MOSI};
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
    sendData <= 8'b11100010;
    MOSIReg <= 8'b00000000;
    #30
    rst <= 1'b0;
	$display("Before Transmitting --> Data to send : %b, MOSI_REG : %b", sendData , MOSIReg);
    #50
    rst <= 1'b1;
    #2500
	$display("After Transmitting --> Data to send : %b, MOSI_REG : %b", slaveData , MOSIReg);
    $finish;
end

endmodule
